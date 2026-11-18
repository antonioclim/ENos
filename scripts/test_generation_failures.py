"""Failure-state regressions in owned fixtures; no teaching/service execution."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

import pytest

ROOT = Path(__file__).resolve().parents[1]


def generator():
    path = ROOT / '00_SUPPLEMENTARY/generate_diagrams.py'
    spec = importlib.util.spec_from_file_location('enos_diagrams', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_missing_include_is_rejected_before_compiler(tmp_path, monkeypatch):
    module = generator(); source = tmp_path/'broken.puml'
    source.write_text('@startuml\n!include missing.puml\nAlice -> Bob\n@enduml\n')
    monkeypatch.setattr(module.subprocess, 'run', lambda *a, **k: pytest.fail('Compiler must not run for missing include'))
    with pytest.raises(ValueError, match='Missing or non-repository include'):
        module.compile_one(source, tmp_path/'unused.jar', 140, tmp_path, tmp_path)


def test_failed_batch_preserves_old_png_and_manifest(tmp_path, monkeypatch):
    module = generator(); source_dir = tmp_path/'05_LECTURES/topic/diagrams'; source_dir.mkdir(parents=True)
    (source_dir/'01_example.puml').write_text('@startuml\ninvalid fixture\n@enduml\n')
    jar = tmp_path/'compiler.jar'; jar.write_bytes(b'derived fixture, not a real compiler')
    monkeypatch.setattr(module, 'JAR_SHA256', module.digest(jar))
    def fail(*args):
        raise RuntimeError('DERIVED compiler failure fixture')
    monkeypatch.setattr(module, 'compile_one', fail)
    output = tmp_path/'out'; output.mkdir()
    (output/'example.png').write_bytes(b'original PNG fixture')
    (output/'manifest.json').write_bytes(b'{"diagrams": []}\n')
    before = {p.name:p.read_bytes() for p in output.iterdir()}
    monkeypatch.setattr(sys, 'argv', ['generator', '--jar', str(jar), '--source-root', str(tmp_path), '--output', str(output), '--clean'])
    assert module.main() == 1
    assert {p.name:p.read_bytes() for p in output.iterdir()} == before


@pytest.mark.parametrize('kind', ['missing', 'wrong_hash'])
def test_unavailable_or_wrong_compiler_fails_without_output(tmp_path, kind):
    jar = tmp_path/'compiler.jar'
    if kind == 'wrong_hash': jar.write_bytes(b'not the pinned compiler')
    out = tmp_path/'output'
    result = subprocess.run([sys.executable, str(ROOT/'00_SUPPLEMENTARY/generate_diagrams.py'), '--jar', str(jar), '--output', str(out)], capture_output=True, text=True, timeout=10)
    assert result.returncode == 1
    assert not out.exists()


@pytest.mark.parametrize('stdout,code', [(b'', 0), (b'', 1), (b'\x89PNG\r\n\x1a\n', 0)])
def test_no_fresh_png_never_uses_old_output(tmp_path, monkeypatch, stdout, code):
    module = generator()
    source = tmp_path/'01_example.puml'
    source.write_text('@startuml\nAlice -> Bob\n@enduml\n')
    previous = tmp_path/'example.png'
    previous.write_bytes(b'previous valid output fixture')
    monkeypatch.setattr(module.subprocess, 'run', lambda *a, **k: subprocess.CompletedProcess(a, code, stdout, b'fixture'))
    with pytest.raises(RuntimeError, match='compilation failed'):
        module.compile_one(source, tmp_path/'unused.jar', 140, tmp_path, tmp_path)
    assert previous.read_bytes() == b'previous valid output fixture'


def test_dry_run_discovers_current_sources_without_compiler_or_output(tmp_path):
    output = tmp_path/'not-created'
    result = subprocess.run([sys.executable, str(ROOT/'00_SUPPLEMENTARY/generate_diagrams.py'),
                             '--dry-run', '--jar', str(tmp_path/'absent.jar'), '--output', str(output)],
                            capture_output=True, text=True, timeout=10)
    assert result.returncode == 0, result.stderr
    report = json.loads(result.stdout)
    expected = sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'05_LECTURES').glob('**/diagrams/*.puml'))
    assert sorted(row['source'] for row in report['diagrams']) == expected
    assert report['diagram_count'] == len(expected) == 39
    assert not output.exists()


def test_supplementary_validator_is_repeatable_without_source_writes():
    base = ROOT/'00_SUPPLEMENTARY'
    before = {p.relative_to(base).as_posix(): p.stat().st_mtime_ns for p in base.rglob('*') if p.is_file()}
    command = ['bash', str(ROOT/'00_SUPPLEMENTARY/validate.sh')]
    first = subprocess.run(command, capture_output=True, text=True, timeout=15)
    second = subprocess.run(command, capture_output=True, text=True, timeout=15)
    assert first.returncode == second.returncode == 0
    assert first.stdout == second.stdout
    assert not first.stderr and not second.stderr
    assert json.loads(first.stdout)['diagram_count'] == 39
    after = {p.relative_to(base).as_posix(): p.stat().st_mtime_ns for p in base.rglob('*') if p.is_file()}
    assert after == before


def test_setup_repair_creates_exact_owned_folders_from_another_directory(tmp_path):
    target = tmp_path/'student work'; target.mkdir()
    elsewhere = tmp_path/'other'; elsewhere.mkdir()
    script = ROOT/'01_INIT_SETUP/verify_installation.sh'
    probe = subprocess.run(['bash','-c','source "$1"\ncheck_folders "$2"','folder-test',str(script),str(target)], cwd=elsewhere, capture_output=True,text=True,timeout=10)
    assert probe.returncode == 0
    repair = next(line.strip() for line in probe.stdout.splitlines() if line.strip().startswith('mkdir -p '))
    result = subprocess.run(['bash','-c',repair],cwd=elsewhere,capture_output=True,text=True,timeout=10)
    assert result.returncode == 0
    assert sorted(p.name for p in target.iterdir()) == ['Books','HomeworksOLD','Projects','ScriptsSTUD','TXT','test']
    assert not list(elsewhere.iterdir())
