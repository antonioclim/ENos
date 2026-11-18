#!/usr/bin/env python3
"""Build a deterministic, source-identical lecture bundle with local assets.

The source directory layout is preserved so relative resources resolve after
extraction. Package/HTML bytes are not rewritten inside the archive.
"""
from __future__ import annotations
import argparse
import hashlib
import html
import json
from pathlib import Path
import stat
import tempfile
from urllib.parse import quote
import zipfile

ROOT=Path(__file__).resolve().parents[1]
SKIP={'node_modules','__pycache__','.git','.pytest_cache'}


def build(root, output=None):
    lectures=sorted((root/'05_LECTURES').rglob('*.html'))
    if not lectures:
        raise ValueError('No canonical lecture HTML sources found')
    output=output or root/f'05_LECTURES/00-HTML_all_as_ZIP(again)/ALL_{len(lectures)}_INTERACTIVE_PRESENTATIONS.zip'
    assets=sorted(p for p in (root/'assets').rglob('*') if p.is_file() and not SKIP.intersection(p.relative_to(root).parts) and p.suffix not in {'.pyc','.pyo'})
    licence_paths={'LICENSE','LICENCE.md','LICENCE_SCOPE.json'}
    licences=[root/path for path in sorted(licence_paths)]
    if any(not path.is_file() for path in licences):
        raise ValueError('The three component licensing files are required')
    files=lectures+assets+licences
    payloads={p.relative_to(root).as_posix():p.read_bytes() for p in files}
    lecture_paths={p.relative_to(root).as_posix() for p in lectures}
    listing='\n'.join(f'<li><a href="{quote(p.relative_to(root).as_posix(),safe="/")}">{html.escape(p.stem)}</a></li>' for p in lectures)
    payloads['index.html']=('<!DOCTYPE html>\n<html lang="en-GB"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>ENos lecture presentations</title><style>body{font:1rem/1.6 system-ui,sans-serif;max-width:70rem;margin:2rem auto;padding:0 1rem}li{margin:.5rem 0}</style></head><body><h1>ENos — '+str(len(lectures))+' interactive lecture presentations</h1><p>ENos 6.0.0 lecture bundle. Extract the complete archive and retain its directory structure. All selected CSS, JavaScript and fonts are local. Browser, accessibility and print acceptance remain subject to the recorded verification limits.</p><ol>'+listing+'</ol></body></html>\n').encode()
    payloads['README_ARCHIVE.md']=('''# ENos lecture bundle

Extract the complete archive, then open `index.html`. Retain `05_LECTURES/` and `assets/` together; their repository-relative paths preserve the canonical HTML bytes. The bundle includes all canonical lecture HTML and the pinned assets, upstream licences and build metadata. Vendored support HTML is counted separately from lecture documents.

`LICENSE`, `LICENCE.md` and `LICENCE_SCOPE.json` record the adopted component licensing and retained exceptions. Keep upstream notices with their assets. The licence map covers the complete repository; `MANIFEST.json` identifies the members present in this lecture bundle.

`MANIFEST.json` records every member except itself with its SHA-256, size and role. This is the ENos 6.0.0 lecture bundle. Source integrity and packaging checks do not establish browser rendering, screen-reader or print acceptance. Diagram PDFs and other repository materials are delivered separately in the complete release source.

The original archive filename claimed 50 but held 48 of 51 sources. The corrected filename states the actual canonical count; three course-07 sources are included. No historical compression corruption was inferred from that coverage defect.
''').encode()
    members=[]
    for path,data in sorted(payloads.items()):
        members.append({'path':path,'role':'canonical_lecture_html' if path in lecture_paths else 'component_licensing_notice' if path in licence_paths else 'asset' if path.startswith('assets/') else 'bundle_navigation','bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
    manifest={'version':'6.0.0','baseline':'d8fdd0507fe26e6bc1438a692da14afc2112464c','canonical_html_count':len(lectures),'member_count_excluding_manifest':len(members),'method':'Repository-relative canonical bytes, local pinned assets and component licences; deterministic ZIP timestamps and canonical executable modes; no native browser acceptance claim.','files':members}
    payloads['MANIFEST.json']=(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode()
    output.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=output.parent,suffix='.zip',delete=False) as handle:pending=Path(handle.name)
    try:
        with zipfile.ZipFile(pending,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
            for path,data in sorted(payloads.items()):
                source=root/path
                mode=0o755 if source.is_file() and source.stat().st_mode & 0o111 else 0o644
                info=zipfile.ZipInfo(path,(2026,11,18,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.create_system=3;info.external_attr=(stat.S_IFREG|mode)<<16
                archive.writestr(info,data,compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
        with zipfile.ZipFile(pending) as archive:
            if archive.testzip() is not None:raise ValueError('ZIP CRC failed')
            if set(archive.namelist())!=set(payloads):raise ValueError('Archive member set differs')
            for path,data in payloads.items():
                if archive.read(path)!=data:raise ValueError('Archive byte mismatch: '+path)
        pending.chmod(0o644);pending.replace(output)
    finally:pending.unlink(missing_ok=True)
    return {'archive':str(output),'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'bytes':output.stat().st_size,'canonical_html_count':len(lectures),'member_count':len(payloads),'zip_crc':'PASS','all_member_bytes':'PASS','native_browser':'NOT_RUN'}


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,default=ROOT);ap.add_argument('--output',type=Path);args=ap.parse_args()
    print(json.dumps(build(args.root.resolve(),args.output.resolve() if args.output else None),indent=2))

if __name__=='__main__':main()
