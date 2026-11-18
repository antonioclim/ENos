#!/usr/bin/env python3
"""Check supplementary source/PNG integrity without executing teaching code.

These checks do not infer authorship from writing style, grade quality out of ten,
or establish browser/VM/kernel acceptance. Author: ing. dr. Antonio Clim.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);args=ap.parse_args();root=args.root.resolve();base=root/'00_SUPPLEMENTARY';errors=[]
    for name in ['README.md','REFERENCES.md','QUICK_REFERENCE_CARD.md','Exam_Exercises_Part1.md','Exam_Exercises_Part2.md','Exam_Exercises_Part3.md','generate_diagrams.py','diagrams_common/skin.puml']:
        if not (base/name).is_file():errors.append('Missing '+name)
    generator=base/'generate_diagrams.py'
    if generator.is_file():
        try:compile(generator.read_text(),str(generator),'exec')
        except (SyntaxError,UnicodeError) as exc:errors.append(str(exc))
    manifest=base/'diagrams_png/manifest.json';count=0
    try:
        report=json.loads(manifest.read_text());count=report['diagram_count'];items=report['diagrams']
        if count!=len(items):errors.append('Manifest diagram count mismatch')
        actual_sources={p.relative_to(root).as_posix() for p in (root/'05_LECTURES').glob('**/diagrams/*.puml')}
        if {x['source'] for x in items}!=actual_sources:errors.append('Manifest does not cover exactly current lecture sources')
        for item in items:
            for name,digest in [(item['source'],item['source_sha256']),('00_SUPPLEMENTARY/diagrams_png/'+item['output'],item['output_sha256'])]+[(d['path'],d['sha256']) for d in item['dependencies']]:
                p=(root/name).resolve()
                if not p.is_relative_to(root):errors.append('Out-of-scope manifest path');continue
                if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=digest:errors.append('Missing or changed: '+name)
            p=base/'diagrams_png'/item['output']
            if p.is_file():
                data=p.read_bytes()
                if not data.startswith(b'\x89PNG\r\n\x1a\n') or len(data)<24:errors.append('Invalid PNG: '+item['output'])
                elif list(struct.unpack('>II',data[16:24]))!=[item['width'],item['height']]:errors.append('PNG size mismatch: '+item['output'])
    except (OSError,ValueError,KeyError,TypeError) as exc:errors.append('Cannot validate diagram manifest: '+str(exc))
    print(json.dumps({'success':not errors,'diagram_count':count,'errors':errors,'scope':'Local presence, Python parse and manifest/source/dependency/PNG hashes; no teaching command, network, renderer or runtime acceptance test.'},indent=2))
    return int(bool(errors))

if __name__=='__main__':sys.exit(main())
