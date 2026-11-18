#!/usr/bin/env python3
"""Check parsed Markdown/HTML links; offline by default. Author: Antonio Clim."""
from __future__ import annotations

import argparse
import html
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import sys
import unicodedata
from urllib.error import HTTPError, URLError
from urllib.parse import unquote, urlsplit
from urllib.request import Request, urlopen

try:
    from markdown_it import MarkdownIt
except ImportError:
    print('Missing markdown-it-py. In a Python virtual environment run: '
          'python -m pip install "markdown-it-py>=3,<5"', file=sys.stderr)
    raise SystemExit(2)

SKIP = {'.git', '.venv', 'venv', 'node_modules', '__pycache__', '.pytest_cache'}
PARSER = MarkdownIt('commonmark', {'html': True})
# Three deliberately unfinished citation slots in the project authoring template.
# The same destination in an ordinary document is still a broken local path.
TEMPLATE_PLACEHOLDERS = {'04_PROJECTS/templates/README_template.md': {'url'}}


class HTMLReferences(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []
        self.ids = set()

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if values.get('id'):
            self.ids.add(values['id'])
        if tag == 'a' and values.get('name'):
            self.ids.add(values['name'])
        for key in ('href', 'src'):
            if values.get(key):
                self.links.append(values[key])


def slug(text):
    """GitHub-style heading identifiers, with duplicate suffixes added below."""
    text = html.unescape(re.sub(r'<[^>]+>', '', text)).lower()
    return ''.join(c for c in text if c in '-_ ' or
                   unicodedata.category(c)[0] not in 'PSC').replace(' ', '-')


def parse_document(path):
    source = path.read_text(encoding='utf-8')
    links, anchors = [], set()
    if path.suffix.lower() in ('.html', '.htm', '.svg'):
        document = HTMLReferences()
        document.feed(source)
        return document.links, document.ids
    tokens = PARSER.parse(source)
    seen = {}
    for index, token in enumerate(tokens):
        if token.type == 'heading_open' and index + 1 < len(tokens):
            children = tokens[index + 1].children or []
            label = ''.join(c.content for c in children
                            if c.type in ('text', 'code_inline', 'image'))
            base = slug(label)
            count = seen.get(base, 0)
            identifier = f'{base}-{count}' if count else base
            while identifier in seen:
                count += 1
                identifier = f'{base}-{count}'
            seen[base] = count + 1
            seen[identifier] = seen.get(identifier, 0)
            anchors.add(identifier)
        for child in [token] + (token.children or []):
            if child.type == 'link_open':
                links.append(child.attrGet('href'))
            elif child.type == 'image':
                links.append(child.attrGet('src'))
            elif child.type in ('html_inline', 'html_block'):
                document = HTMLReferences()
                document.feed(child.content)
                links.extend(document.links)
                anchors.update(document.ids)
    return links, anchors


def check(target, repo_root, external=False):
    target, repo_root = Path(target).resolve(), Path(repo_root).resolve()
    if not target.exists():
        raise ValueError(f'Target does not exist: {target}')
    candidates = [target] if target.is_file() else sorted(target.rglob('*'))
    files = [p for p in candidates if p.is_file() and p.suffix.lower() in
             ('.md', '.markdown', '.html', '.htm') and not SKIP.intersection(p.parts)]
    results, cache, external_cache = [], {}, {}
    for source in files:
        try:
            links, anchors = parse_document(source)
            cache[source] = anchors
        except (OSError, UnicodeError, ValueError) as exc:
            results.append({'source': str(source), 'target': '', 'status': 'error', 'detail': str(exc)})
            continue
        for destination in links:
            destination = html.unescape(destination or '')
            if not destination:
                continue
            row = {'source': str(source), 'target': destination}
            source_key = source.relative_to(repo_root).as_posix() if source.is_relative_to(repo_root) else ''
            if destination in TEMPLATE_PLACEHOLDERS.get(source_key, set()):
                row.update(status='not_checked', detail='Declared authoring-template citation placeholder; supply an actual source before publishing a completed project')
                results.append(row)
                continue
            try:
                url = urlsplit(destination)
                if url.scheme or url.netloc:
                    if url.scheme not in ('http', 'https') or not external:
                        row.update(status='not_checked', detail='External/non-file URI; offline check')
                    else:
                        if destination not in external_cache:
                            try:
                                request = Request(destination, headers={'User-Agent': 'ENos-link-check/6'})
                                with urlopen(request, timeout=15) as response:
                                    external_cache[destination] = ('available', f'HTTP {response.status}; availability only')
                            except HTTPError as exc:
                                status = 'broken' if exc.code in (404, 410) else 'unverified'
                                external_cache[destination] = (status, f'HTTP {exc.code}')
                            except (URLError, TimeoutError, OSError) as exc:
                                external_cache[destination] = ('unverified', str(exc))
                        row['status'], row['detail'] = external_cache[destination]
                else:
                    decoded = unquote(url.path)
                    resolved = ((repo_root / decoded.lstrip('/')) if decoded.startswith('/') else
                                (source.parent / decoded)).resolve() if decoded else source
                    if not resolved.exists():
                        row.update(status='broken', detail=f'Missing path: {resolved}')
                    elif url.fragment and resolved.is_file() and resolved.suffix.lower() in (
                            '.md', '.markdown', '.html', '.htm', '.svg'):
                        if resolved not in cache:
                            cache[resolved] = parse_document(resolved)[1]
                        fragment = unquote(url.fragment)
                        row.update(status='valid' if fragment in cache[resolved] else 'broken',
                                   detail='Fragment found' if fragment in cache[resolved] else
                                   f'Missing fragment: {fragment}')
                    else:
                        row.update(status='valid', detail='Local path exists')
            except (OSError, UnicodeError, ValueError) as exc:
                row.update(status='error', detail=str(exc))
            results.append(row)
    counts = {status: sum(r['status'] == status for r in results)
              for status in ('valid', 'available', 'broken', 'unverified', 'not_checked', 'error')}
    return {'files': len(files), 'links': len(results), 'counts': counts,
            'success': not any(counts[s] for s in ('broken', 'unverified', 'error')),
            'scope': 'CommonMark links/references, HTML href/src and static heading/id fragments; '
                     'no JavaScript-generated links or browser rendering. External HTTP proves availability only.',
            'results': results}


def main(argv=None):
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', nargs='?', default=str(root))
    parser.add_argument('--repo-root', default=str(root))
    network = parser.add_mutually_exclusive_group()
    network.add_argument('--external', '-e', action='store_true', help='Check HTTP availability as well as local links')
    network.add_argument('--internal-only', action='store_true', help='Explicit offline mode (the default)')
    output = parser.add_mutually_exclusive_group()
    output.add_argument('--json', action='store_true')
    output.add_argument('--markdown', action='store_true')
    parser.add_argument('--report', type=Path)
    parser.add_argument('--verbose', '-v', action='store_true')
    args = parser.parse_args(argv)
    try:
        report = check(args.target, args.repo_root, args.external)
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    if args.json:
        text = json.dumps(report, ensure_ascii=False, indent=2)
    else:
        text = f"Files: {report['files']}; links: {report['links']}; counts: {report['counts']}\n"
        text += '\n'.join(f"{r['status'].upper()}: {r['source']} -> {r['target']} ({r['detail']})"
                          for r in report['results'] if args.verbose or r['status'] in ('broken', 'unverified', 'error'))
        if args.markdown:
            text = '# Documentation link check\n\n```text\n' + text + '\n```\n'
        text += '\n' + report['scope']
    if args.report:
        args.report.write_text(text + '\n', encoding='utf-8')
    print(text)
    return 0 if report['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
