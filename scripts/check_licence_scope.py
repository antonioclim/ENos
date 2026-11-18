#!/usr/bin/env python3
"""Check or refresh the approved component licence map without network access.

Profiles define boundaries, not ownership. Unknown rights remain excluded.
"""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys
import zipfile

from inventory import selected_files

ROOT = Path(__file__).resolve().parents[1]
TARGET = 'LICENCE_SCOPE.json'
CODE = {'.py', '.sh', '.c', '.h', '.js', '.cjs', '.css', '.toml', '.json',
        '.yaml', '.yml', '.conf', '.cfg', '.ini', '.service', '.timer', '.sql',
        '.ps1', '.s', '.asm', '.bt'}
DOCS = {'.md', '.html', '.txt', '.pdf', '.rst', '.adoc', '.cff'}
FIGURES = {'.svg', '.png', '.puml'}
PROFILES = {
    'original_code': {'terms': ['MIT'], 'boundary': 'Eligible original software, configuration and code examples only.'},
    'original_teaching_mixed': {'terms': ['MIT', 'CC-BY-4.0'], 'boundary': 'CC BY 4.0 original prose/figures; MIT original code examples, scripts and styles. Quoted, institutional and third-party portions remain excluded.'},
    'original_figure': {'terms': ['CC-BY-4.0'], 'boundary': 'Eligible original editable diagram or rendered figure only; third-party portions retain their terms.'},
    'original_question_mixed': {'terms': ['MIT', 'CC-BY-4.0'], 'boundary': 'CC BY 4.0 original question/explanation prose; MIT original code examples and operational schema/configuration code.'},
    'original_example_fixture': {'terms': ['MIT'], 'boundary': 'Eligible original software-example fixtures only; real personal, institutional or third-party data are excluded.'},
    'historical_record': {'terms': ['CC-BY-4.0'], 'boundary': 'Original editorial record only. Retained quotations and historical licence/policy wording preserve their provenance and are not active replacement grants or policies.'},
    'retained_sem02_notice': {'terms': ['CC-BY-SA-4.0'], 'new_D1_grant': False, 'boundary': 'SEM02 package notice and SO ASE-CSIE Team attribution retained. Exact item-level rights boundary is not independently established; no replacement grant is inferred.'},
    'upstream_package_file': {'new_D1_grant': False, 'boundary': 'Exact pinned upstream package bytes. See package licence paths and manifests; no new rights are granted here.'},
    'derived_upstream_asset': {'new_D1_grant': False, 'boundary': 'Font/theme/compiler output retains upstream component terms. Eligible original transformations may be MIT; upstream rights are not replaced.'},
    'provenance_metadata': {'terms': ['CC-BY-4.0'], 'boundary': 'Original explanatory record only; embedded notices and upstream data retain their provenance and terms.'},
    'licence_instrument': {'boundary': 'Licence/policy instrument: read its stated terms and scope rather than inferring a grant from this classification.'},
    'mixed_archive': {'boundary': 'Container only; members follow reviewed source paths and unmatched members remain unresolved.'},
    'unresolved': {'new_D1_grant': False, 'boundary': 'No grant inferred. Establish source and terms before assigning an original-material profile.'},
}


def upstream(root):
    packages, paths, derived, errors = [], {}, {}, []
    for name in ['assets/vendor/MANIFEST.json', 'assets/vendor/FONTS_MANIFEST.json']:
        data = json.loads((root / name).read_text(encoding='utf-8'))
        for item in data['packages']:
            licences = [f['path'] for f in item['files'] if any(
                word in Path(f['path']).name.lower() for word in ('license', 'licence', 'ofl', 'copying'))]
            if not licences:
                errors.append('No retained licence for ' + item['npm_name'])
            packages.append({'package': item['npm_name'], 'version': item['version'],
                             'manifest': name, 'licence_paths': licences,
                             'file_count': len(item['files'])})
            for f in item['files']:
                p = root / f['path']
                if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest() != f['sha256']:
                    errors.append('Changed upstream bytes: ' + f['path'])
                paths[f['path']] = item['npm_name'] + '@' + item['version']
        if data.get('generated_css'):
            derived[data['generated_css']['path']] = {'source_manifests': [name], 'scope': 'Combined Fontsource CSS; component terms remain applicable.'}
    data = json.loads((root / 'assets/tools/THEMES_MANIFEST.json').read_text(encoding='utf-8'))
    for item in data['themes']:
        version = item['source'].split('/')[3]
        derived[item['output']] = {'source_paths': [item['source']], 'licence_paths': ['assets/vendor/reveal.js/' + version + '/LICENSE']}
    derived['assets/css/lecture_utilities.css'] = {'source_manifests': ['assets/tools/TAILWIND_MANIFEST.json'], 'licence_paths': ['assets/vendor/tailwindcss/3.4.17/LICENSE']}
    return packages, paths, derived, errors


def profile(name, root, upstream_paths, derived):
    p = Path(name)
    if name in upstream_paths:
        return 'upstream_package_file'
    if name in derived:
        return 'derived_upstream_asset'
    if name.startswith('SEM02/'):
        return 'retained_sem02_notice'
    if name in {'LICENSE', 'LICENCE.md', TARGET}:
        return 'licence_instrument'
    if name.startswith('assets/vendor/'):
        return 'provenance_metadata' if p.suffix in {'.json', '.md'} else 'unresolved'
    if 'POLICY_HISTORY' in p.name or 'history' in p.parts or name == 'DECISION_PROVENANCE.json':
        return 'historical_record'
    if p.suffix == '.zip':
        return 'mixed_archive'
    if p.suffix in FIGURES:
        return 'original_figure'
    if p.suffix in {'.yaml', '.yml', '.json'} and any(s in name.lower() for s in ('quiz', 'question', 'test_bank', 'formative')):
        return 'original_question_mixed'
    if p.suffix in DOCS:
        return 'original_teaching_mixed'
    if p.suffix in {'.csv', '.tsv', '.log', '.cast'}:
        return 'original_example_fixture'
    if p.suffix in CODE or p.name in {'Makefile', 'Makefile_template', 'Dockerfile', '.gitignore'}:
        return 'original_code'
    if (root / name).read_bytes().startswith(b'#!'):
        return 'original_code'
    return 'unresolved'


def build(root):
    packages, upstream_paths, derived, errors = upstream(root)
    names = {p.relative_to(root).as_posix() for p in selected_files(root)} | {TARGET}
    files = {name: profile(name, root, upstream_paths, derived) for name in sorted(names)}
    notice = (root / 'SEM02/README.md').read_text(encoding='utf-8')
    if 'Licence: CC BY-SA 4.0 - Free use with attribution' not in notice or 'Original materials: SO ASE-CSIE Team' not in notice:
        errors.append('Retained SEM02 licence or attribution changed')
    archives = {}
    for name, kind in files.items():
        if kind != 'mixed_archive':
            continue
        with zipfile.ZipFile(root / name) as archive:
            members = {item.filename: files.get(item.filename, 'unresolved')
                       for item in archive.infolist() if not item.is_dir()}
        archives[name] = {'scope': 'Member profiles follow source paths; this is a licensing boundary record, not source-to-archive byte verification.', 'members': members}
    return {'schema_version': 1, 'decision': 'D1', 'author_approved_on': '2026-11-18',
            'implementation_scope': 'ENos 6.0.0 adopted component scope; publication state is recorded by the GitHub release.',
            'policy': 'LICENCE.md', 'original_grants': {'code': 'MIT', 'teaching_prose_and_figures': 'CC-BY-4.0'},
            'ownership_limit': 'Only original portions the author owns or is entitled to license receive the new grants. Specific third-party attributions, quotations, institutional material and unresolved rights remain excluded, including within mixed files.',
            'sem02_boundary': 'SEM02/** retained package notice; no replacement D1 grant. This does not independently establish item ownership or the exact legal scope of the notice.',
            'profiles': PROFILES, 'upstream_packages': packages, 'derived_assets': derived,
            'counts': dict(sorted(Counter(files.values()).items())), 'files': files,
            'archives': archives}, errors


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root', type=Path, default=ROOT)
    ap.add_argument('--write', action='store_true', help='Refresh after an authorised source change')
    args = ap.parse_args()
    root = args.root.resolve()
    try:
        data, errors = build(root)
        content = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
        target = root / TARGET
        if errors:
            raise ValueError('; '.join(errors))
        if args.write:
            target.write_text(content, encoding='utf-8')
        elif not target.is_file() or target.read_text(encoding='utf-8') != content:
            raise ValueError('Missing or stale LICENCE_SCOPE.json; review changes, then use --write')
        print(json.dumps({'status': 'PASS', 'files': len(data['files']),
                          'upstream_packages': len(data['upstream_packages']),
                          'upstream_files': data['counts'].get('upstream_package_file', 0),
                          'sem02_excluded_files': data['counts'].get('retained_sem02_notice', 0),
                          'unresolved_files': data['counts'].get('unresolved', 0),
                          'scope': 'Map coverage and retained upstream bytes, not ownership or legal adjudication.'}))
        return 0
    except (OSError, ValueError, KeyError, zipfile.BadZipFile) as error:
        print(json.dumps({'status': 'FAIL', 'error': str(error)}))
        return 1


if __name__ == '__main__':
    sys.exit(main())
