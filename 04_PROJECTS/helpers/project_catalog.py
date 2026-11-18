#!/usr/bin/env python3
"""Structural catalogue checks, not student grading or functional acceptance."""
import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
GROUPS={'easy':('b)EASY','E',5),'medium':('a)MEDIUM','M',15),'advanced':('c)ADVANCED','A',3)}
def paths(level='all'):
    return sorted(p for name,(folder,prefix,_) in GROUPS.items() if level in ('all',name) for p in (ROOT/folder).glob(prefix+'[0-9][0-9]_*.md'))
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['validate','structure','stats','list','build-docs','test','check']);ap.add_argument('--level',default='all',choices=['all',*GROUPS]);ap.add_argument('--project');args=ap.parse_args()
    files=paths(args.level);failed=0
    if args.action in ('validate','structure'):
        for name,(folder,prefix,count) in GROUPS.items():
            if args.level not in ('all',name):continue
            observed=len(paths(name))
            if not (ROOT/folder).is_dir() or observed!=count: print(f'FAIL {folder}: {observed}/{count} project documents');failed+=1
        if args.action=='structure':return bool(failed)
        for p in files:
            text=p.read_text(); missing=[heading for heading in ['Description','Learning Objectives','Functional Requirements','Project Structure','Specific Evaluation Criteria'] if not re.search(r'^## '+re.escape(heading)+r'\s*$',text,re.M)]
            if missing:failed+=1;print(f'FAIL {p.name}: missing sections {missing}')
            else:print(f'PASS structure: {p.name}')
        print('Scope: document presence/sections only; no functional or grading acceptance.')
        return bool(failed)
    if args.action=='list':
        for p in files:print(p.relative_to(ROOT))
    elif args.action=='stats':
        for name in GROUPS:
            rows=paths(name);lines=sum(len(p.read_text().splitlines()) for p in rows);print(f'{name}: projects={len(rows)} lines={lines} mean_lines={lines/len(rows) if rows else 0:.1f}')
    elif args.action=='check':
        matches=[p for p in files if p.stem==args.project or p.name.startswith((args.project or '')+'_')]
        if len(matches)!=1:print('Expected one exact project ID/stem',file=sys.stderr);return 2
        print(matches[0].relative_to(ROOT));print('\n'.join(x for x in matches[0].read_text().splitlines() if x.startswith('## ')))
    elif args.action=='build-docs':
        if not shutil.which('pandoc'):print('NOT_RUN: pandoc unavailable',file=sys.stderr);return 2
        target=ROOT/'docs/html';target.mkdir(parents=True,exist_ok=True)
        for p in files:
            rc=subprocess.run(['pandoc',str(p),'-o',str(target/(p.stem+'.html')),'--standalone','--metadata','title='+p.stem,'--toc','--highlight-style=tango']).returncode
            if rc: failed+=1
        if not failed:print(f'Generated {len(files)} HTML files in {target}')
    elif args.action=='test':
        reference=list((ROOT/'tests').glob('test_*.py'))
        if not reference:print('NOT_RUN: reference tests missing',file=sys.stderr);return 2
        failed+=subprocess.run([sys.executable,'-m','unittest','discover','-s',str(ROOT/'tests'),'-p','test_*.py'],cwd=ROOT).returncode!=0
        student=[]
        for folder,_,_ in GROUPS.values():student.extend(p.parent for p in (ROOT/folder).glob('*/Makefile') if (p.parent/'tests').is_dir())
        for p in student:failed+=subprocess.run(['make','test'],cwd=p).returncode!=0
        if not student:print('Student implementation suites: NOT_RUN (none present); reference tests are a separate scope.')
    return bool(failed)
if __name__=='__main__':raise SystemExit(main())
