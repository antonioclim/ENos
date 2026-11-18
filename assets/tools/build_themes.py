#!/usr/bin/env python3
"""Create local Reveal themes without modifying their upstream source copies."""
import hashlib
import json
from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[2]
manifest=json.loads((ROOT/'assets/vendor/MANIFEST.json').read_text())
records=[]
for version in ['4.5.0','4.6.1']:
    source=ROOT/f'assets/vendor/reveal.js/{version}/theme/night.css'
    entry=next(f for package in manifest['packages'] for f in package['files'] if f['path']==source.relative_to(ROOT).as_posix())
    raw=source.read_bytes()
    if hashlib.sha256(raw).hexdigest()!=entry['sha256']:
        raise ValueError('Upstream theme hash differs from manifest')
    text=raw.decode('utf-8')
    text,count=re.subn(r'@import\s+url\(https://fonts\.googleapis\.com/[^)]+\);', '', text)
    if count!=2:raise ValueError('Expected two upstream Google font imports')
    text='/* ENos derived local-font theme; unmodified upstream CSS and licence retained in assets/vendor. */\n@import url("../vendor/fonts.css");\n'+text
    output=ROOT/f'assets/css/reveal-night-{version}.css';output.write_text(text)
    records.append({'source':entry['path'],'source_sha256':entry['sha256'],'transform':'Replace exactly two Google Fonts imports with local combined font CSS; all other theme bytes retained.','output':output.relative_to(ROOT).as_posix(),'output_sha256':hashlib.sha256(output.read_bytes()).hexdigest()})
(ROOT/'assets/tools/THEMES_MANIFEST.json').write_text(json.dumps({'themes':records},indent=2)+'\n')
print('Built two locally sourced Reveal night themes')
