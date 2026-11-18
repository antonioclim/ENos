#!/usr/bin/env python3
"""Reproduce the lecture PNG set from the current PlantUML sources.

Author: Revolvix | ASE Bucharest — CSIE. Phase 5 maintenance: ENos v6 candidate.
Generation is staged: a failed compilation never masquerades as an old success.
Only --download permits obtaining the pinned compiler; ordinary runs are offline.
"""
from __future__ import annotations
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import urllib.request

VERSION = '1.2026.10'
JAR_SHA256 = 'e9bc9e6b2eb715e8c0c929f3dcb5fc1923be13f37599b09c293c66d354e88686'
JAR_URL = f'https://github.com/plantuml/plantuml/releases/download/v{VERSION}/plantuml-{VERSION}.jar'
ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def diagram_name(path):
    name = re.sub(r'^\d+_', '', path.stem)
    return {'scheduling_algorithms_gantt_comparison': 'scheduling_gantt_comparison'}.get(name, name)


def compile_one(source, jar, dpi, stage, root):
    dependencies = []
    text = source.read_text(encoding='utf-8')
    if text.count('@startuml') != 1 or text.count('@enduml') != 1:
        raise ValueError(f'{source}: expected exactly one complete diagram')
    for target in re.findall(r'^\s*!include\s+([^\r\n]+)', text, re.M):
        dependency = (source.parent / target.strip()).resolve()
        if not dependency.is_relative_to(root) or not dependency.is_file():
            raise ValueError(f'Missing or non-repository include: {target} in {source}')
        dependencies.append({'path': str(dependency.relative_to(root)), 'sha256': digest(dependency)})
    run = subprocess.run(['java', '-Xmx768m', '-DPLANTUML_LIMIT_SIZE=16384', '-jar', str(jar),
                          '-charset', 'UTF-8', '-tpng', f'-Sdpi={dpi}', '-pipe'],
                         input=text.encode('utf-8'), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         cwd=source.parent, timeout=120)
    if run.returncode or not run.stdout.startswith(b'\x89PNG\r\n\x1a\n') or len(run.stdout) < 24:
        raise RuntimeError(f'{source.relative_to(root)}: compilation failed ({run.returncode}): '
                           + run.stderr.decode('utf-8', 'replace')[-2000:])
    width, height = struct.unpack('>II', run.stdout[16:24])
    if not 0 < width < 16384 or not 0 < height < 16384:
        raise RuntimeError(f'{source}: output has invalid dimensions or reaches the configured rendering limit')
    target = stage / (diagram_name(source) + '.png')
    target.write_bytes(run.stdout)
    return {'source': str(source.relative_to(root)), 'source_sha256': digest(source),
            'dependencies': dependencies, 'output': target.name, 'output_sha256': digest(target),
            'width': width, 'height': height, 'compiler_exit': run.returncode}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--jar', type=Path, default=Path(__file__).parent / f'plantuml-{VERSION}.jar')
    parser.add_argument('--download', action='store_true', help='Explicitly download the pinned compiler if missing')
    parser.add_argument('--source-root', type=Path, default=ROOT)
    parser.add_argument('--output', '-o', type=Path, default=Path(__file__).parent / 'diagrams_png')
    parser.add_argument('--dpi', type=int, default=140)
    parser.add_argument('--workers', '-j', type=int, default=2)
    parser.add_argument('--clean', action='store_true', help='Remove only obsolete PNGs listed in the previous manifest, after successful generation')
    parser.add_argument('--dry-run', action='store_true', help='List canonical source/output mappings without compiler, network or writes')
    args = parser.parse_args()
    if not 72 <= args.dpi <= 300 or not 1 <= args.workers <= 4:
        parser.error('dpi must be 72–300 and workers 1–4')
    root, jar, output = args.source_root.resolve(), args.jar.resolve(), args.output.resolve()
    try:
        sources = sorted((root / '05_LECTURES').glob('**/diagrams/*.puml'))
        if not sources:
            raise ValueError('No lecture diagram sources found')
        names = [diagram_name(p) for p in sources]
        if len(set(names)) != len(names):
            raise ValueError('Duplicate diagram output names')
        if args.dry_run:
            print(json.dumps({'dry_run': True, 'diagram_count': len(sources),
                              'scope': 'Source/output discovery only; compilation and dependency acceptance NOT_RUN.',
                              'diagrams': [{'source': str(p.relative_to(root)), 'source_sha256': digest(p),
                                            'output': str(output / (diagram_name(p)+'.png'))} for p in sources]}, indent=2))
            return 0
        if not jar.is_file() and args.download:
            jar.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.NamedTemporaryFile(dir=jar.parent, delete=False) as handle:
                pending = Path(handle.name)
            try:
                with urllib.request.urlopen(JAR_URL, timeout=60) as response, pending.open('wb') as handle:
                    while chunk := response.read(1024 * 1024):
                        handle.write(chunk)
                if digest(pending) != JAR_SHA256:
                    raise ValueError('Downloaded compiler checksum mismatch')
                os.replace(pending, jar)
            finally:
                pending.unlink(missing_ok=True)
        if not jar.is_file():
            raise ValueError('Compiler missing. Supply --jar or explicitly use --download.')
        if digest(jar) != JAR_SHA256:
            raise ValueError('Compiler checksum does not match the pinned release')
        previous = []
        manifest_path = output / 'manifest.json'
        if args.clean and manifest_path.is_file():
            previous = json.loads(manifest_path.read_text(encoding='utf-8')).get('diagrams', [])
        with tempfile.TemporaryDirectory(prefix='enos-diagrams-') as tmp:
            stage = Path(tmp)
            with ThreadPoolExecutor(max_workers=args.workers) as executor:
                results = list(executor.map(lambda p: compile_one(p, jar, args.dpi, stage, root), sources))
            output.mkdir(parents=True, exist_ok=True)
            for item in results:
                destination = output / item['output']
                with tempfile.NamedTemporaryFile(dir=output, delete=False) as handle:
                    handle.write((stage / item['output']).read_bytes())
                    pending = Path(handle.name)
                os.chmod(pending, 0o644)
                os.replace(pending, destination)
            expected = {item['output'] for item in results}
            for item in previous:
                old = item.get('output', '')
                if old not in expected and re.fullmatch(r'[A-Za-z0-9_-]+\.png', old):
                    (output / old).unlink(missing_ok=True)
            manifest = {'compiler': f'PlantUML {VERSION}', 'compiler_sha256': JAR_SHA256,
                        'dpi': args.dpi, 'render_limit': 16384, 'diagram_count': len(results),
                        'scope': 'Successful native PlantUML compilation; visual review is a separate check.',
                        'diagrams': results}
            manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
        print(f'Generated {len(results)} current diagrams and manifest: {output}')
        return 0
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f'Generation failed: {exc}', file=__import__('sys').stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
