#!/usr/bin/env python3
"""Synchronise a managed print block in exactly the selected HTML file/tree.

Author: ing. dr. Antonio Clim. Existing content-specific styles are preserved.
Changes are atomic per file, preserve permissions and report failures non-zero.
"""
from __future__ import annotations
import argparse
import os
from pathlib import Path
import re
import stat
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[1]
BLOCK=re.compile(r'\s*<style\b(?=[^>]*\bid=["\']enos-print-styles["\'])[^>]*>.*?</style\s*>',re.I|re.S)

def render(source,css):
    source=BLOCK.sub('',source)
    closing=re.search(r'</head\s*>',source,re.I)
    if not closing:raise ValueError('missing closing </head>; no file was rewritten')
    block='\n<style id="enos-print-styles">\n'+css.rstrip()+'\n</style>\n'
    return source[:closing.start()].rstrip()+block+source[closing.start():]

def replace(path,text):
    mode=stat.S_IMODE(path.stat().st_mode);pending=None
    try:
        with tempfile.NamedTemporaryFile('w',encoding='utf-8',newline='',dir=path.parent,prefix='.enos-print-',delete=False) as f:
            pending=Path(f.name);f.write(text);f.flush();os.fsync(f.fileno());os.fchmod(f.fileno(),mode)
        os.replace(pending,path)
    finally:
        if pending is not None:pending.unlink(missing_ok=True)

def main(argv=None):
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('path',nargs='?',type=Path,default=ROOT,help='one HTML file or directory; default repository root')
    ap.add_argument('--dry-run',action='store_true')
    ap.add_argument('--css',type=Path,default=ROOT/'assets/css/print.css')
    args=ap.parse_args(argv)
    try:
        target=args.path.resolve(strict=True)
        if target.is_file():
            if target.suffix.lower()!='.html':raise ValueError('selected file must have an .html extension')
            if target.is_relative_to(ROOT/'assets/vendor'):raise ValueError('vendored upstream HTML is excluded from print rewriting')
            files=[target]
        elif target.is_dir():files=sorted(p for p in target.rglob('*.html') if p.is_file() and not p.is_symlink() and not p.resolve().is_relative_to(ROOT/'assets/vendor') and not any(x in {'.git','.venv','node_modules','__pycache__'} for x in p.relative_to(target).parts))
        else:raise ValueError('path must be a file or directory')
        if not files:raise ValueError('no HTML files found in the selected scope')
        css=args.css.read_text(encoding='utf-8')
        if '@media print' not in css:raise ValueError('stylesheet contains no @media print block')
        # Validate all source documents before any mutation in this invocation.
        prepared=[]
        for p in files:
            old=p.read_text(encoding='utf-8');new=render(old,css)
            if new!=old:prepared.append((p,new))
        for p,new in prepared:
            if not args.dry_run:replace(p,new)
            print(('WOULD UPDATE ' if args.dry_run else 'UPDATED ')+str(p))
        print(f'Selected {len(files)}; changed {len(prepared)}; unchanged {len(files)-len(prepared)}; dry_run={args.dry_run}')
        return 0
    except (OSError,UnicodeError,ValueError) as exc:
        print(f'Print-style update failed: {exc}',file=sys.stderr);return 1

if __name__=='__main__':raise SystemExit(main())
