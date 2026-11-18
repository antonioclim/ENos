#!/usr/bin/env python3
"""Trace static HTML resource attributes and CSS URLs without network access.

This is a resource-completeness check, not browser or JavaScript execution.
Ordinary outbound hyperlinks and unused upstream source CSS are not requests.
"""
from __future__ import annotations
import argparse
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import re
from urllib.parse import unquote,urlsplit

ROOT=Path(__file__).resolve().parents[1]
SKIP={'.git','.venv','venv','node_modules','__pycache__'}


class Resources(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True);self.references=[];self.styles=[];self.in_style=False
    def handle_starttag(self,tag,attrs):
        values=dict(attrs)
        if tag=='style':self.in_style=True
        if tag in {'script','img','source','audio','video','iframe'} and values.get('src'):self.references.append(values['src'])
        if tag=='link' and set(values.get('rel','').lower().split()) & {'stylesheet','icon','preload','modulepreload'} and values.get('href'):self.references.append(values['href'])
        if values.get('style'):self.styles.append(values['style'])
    def handle_endtag(self,tag):
        if tag=='style':self.in_style=False
    def handle_data(self,data):
        if self.in_style:self.styles.append(data)


def css_urls(source):
    # Comments are not loads; all preserved font/theme URLs are literal.
    source=re.sub(r'/\*.*?\*/','',source,flags=re.S)
    return [next(x for x in groups if x) for groups in re.findall(r'url\(\s*(?:"([^"]+)"|\x27([^\x27]+)\x27|([^\s)]+))\s*\)',source,re.I)] + re.findall(r'@import\s+["\x27]([^"\x27]+)["\x27]',source,re.I)


def check(root):
    pages=sorted(p for p in root.rglob('*.html') if not SKIP.intersection(p.relative_to(root).parts) and not p.is_relative_to(root/'assets/vendor'))
    pending=[];entries=[];visited=set();rows=[]
    for page in pages:
        parsed=Resources();parsed.feed(page.read_text(encoding='utf-8'))
        entries.append({'path':page.relative_to(root).as_posix(),'sha256':hashlib.sha256(page.read_bytes()).hexdigest()})
        pending.extend((page,url) for url in parsed.references)
        for style in parsed.styles:pending.extend((page,url) for url in css_urls(style))
    while pending:
        source,url=pending.pop()
        identity=(source,url)
        if identity in visited:continue
        visited.add(identity);parts=urlsplit(url)
        row={'source':source.relative_to(root).as_posix(),'url':url}
        if parts.scheme=='data' or not parts.path and parts.fragment:row['status']='embedded'
        elif parts.scheme or parts.netloc:row['status']='remote'
        else:
            target=((root/unquote(parts.path).lstrip('/')) if parts.path.startswith('/') else (source.parent/unquote(parts.path))).resolve()
            if not target.is_relative_to(root):row['status']='outside_repository'
            elif not target.is_file():row['status']='missing'
            else:
                row.update(status='local',path=target.relative_to(root).as_posix(),sha256=hashlib.sha256(target.read_bytes()).hexdigest())
                if target.suffix.lower()=='.css':pending.extend((target,ref) for ref in css_urls(target.read_text(encoding='utf-8')))
        rows.append(row)
    counts={status:sum(row['status']==status for row in rows) for status in ['local','embedded','remote','missing','outside_repository']}
    return {'success':not any(counts[k] for k in ['remote','missing','outside_repository']),'html_documents':len(pages),'counts':counts,'entry_sources':entries,'resources':sorted(rows,key=lambda row:(row['source'],row['url'])),'limits':'Static HTML src/selected link attributes, inline styles and recursively referenced CSS URLs only. No JavaScript-generated fetches, browser rendering, source-map retrieval, service availability or native offline browsing acceptance.'}


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,default=ROOT);ap.add_argument('--report',type=Path);args=ap.parse_args()
    report=check(args.root.resolve())
    if args.report:args.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k not in ['entry_sources','resources']},indent=2))
    for row in report['resources']:
        if row['status'] in ['remote','missing','outside_repository']:print(row)
    return 0 if report['success'] else 1

if __name__=='__main__':raise SystemExit(main())
