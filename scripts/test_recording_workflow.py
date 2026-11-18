"""Local regressions: no terminal session, SSH service or institutional key."""
import ast
import importlib.util
import json
from pathlib import Path
import subprocess
from typing import Any, Dict

import pytest

ROOT = Path(__file__).resolve().parents[1]


def load_functions(path):
    tree = ast.parse(path.read_text())
    names = {'validate_surname', 'validate_firstname', 'validate_group', 'validate_homework', 'load_config', 'add_recording_metadata'}
    subset = ast.Module(body=[n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names], type_ignores=[])
    scope = {'Dict': Dict, 'Any': Any, 'Path': Path, 'json': json,
             're': __import__('re'), 'os': __import__('os'), 'tempfile': __import__('tempfile'),
             'SPECIALIZATIONS': {'1': ('eninfo', 'English'), '2': ('grupeid', 'ID')}}
    exec(compile(subset, str(path), 'exec'), scope)
    return scope


def shell(script, text, *args):
    return subprocess.run(['bash', '-c', 'source "$1"\n' + text, 'recorder-test', str(script), *map(str, args)],
                          capture_output=True, text=True, timeout=15)


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
def test_validation_config_and_metadata(folder, tmp_path):
    scope = load_functions(ROOT / folder / 'record_homework_tui_EN.py')
    for name, accepted, rejected in [
            ('validate_group', ['1234'], ['١٢٣٤', '1234\n', '123']),
            ('validate_surname', ['Smith-Jones'], ['Smith\n', '-Smith', 'Smith-']),
            ('validate_homework', ['01a', '07C'], ['01a\n', '08a'])]:
        for value in accepted:
            assert scope[name](value)
        for value in rejected:
            assert not scope[name](value)
    config = tmp_path / 'config.json'; scope['CONFIG_FILE'] = str(config)
    for value in [[], 2, None, {'group': 1234, 'surname': 'Smith\n'}]:
        config.write_text(json.dumps(value)); assert scope['load_config']() == {}
    config.write_text('{'); assert scope['load_config']() == {}
    path = tmp_path / 'recording.cast'
    event = '[0.0, "o", "hello\\r\\n"]\n'
    path.write_text('{"version":2,"width":80,"height":24}\n' + event)
    scope['add_recording_metadata'](str(path), {'surname':'SMITH', 'firstname':'John', 'group':'1234', 'homework':'02b'})
    header, body = path.read_text().split('\n', 1)
    assert json.loads(header)['seminar'] == 2
    assert json.loads(header)['student_group'] == '1234'
    assert body == event


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
@pytest.mark.parametrize('succeed_at,expected_calls,expected_status', [(0, 3, 1), (2, 2, 0)])
def test_upload_retry_control_flow(folder, succeed_at, expected_calls, expected_status):
    text = '''
calls=0
sleep() { :; }
timeout() { return 1; }
sshpass() { calls=$((calls+1)); [[ "$calls" == "$2" ]]; }
FILEPATH=/derived-fixture.cast; FILENAME=derived-fixture.cast; SPECIALIZATION=eninfo
# Avoid positional argument capture by the sshpass stub.
target="$2"
sshpass() { calls=$((calls+1)); [[ "$calls" == "$target" ]]; }
if upload_homework; then rc=0; else rc=$?; fi
printf '\\nRESULT:%s:%s\\n' "$calls" "$rc"
'''
    result = shell(ROOT/folder/'record_homework_EN.sh', text, succeed_at)
    assert result.returncode == 0, result.stderr
    assert f'RESULT:{expected_calls}:{expected_status}' in result.stdout


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
def test_offline_does_not_call_network_and_help_is_dependency_free(folder):
    script = ROOT/folder/'record_homework_EN.sh'
    result = shell(script, 'OFFLINE=true\nsshpass() { return 99; }\ntimeout() { return 99; }\nupload_homework')
    assert result.returncode == 0
    for command in [['bash', str(script), '--help'], ['python3', str(ROOT/folder/'record_homework_tui_EN.py'), '--help']]:
        result = subprocess.run(command, capture_output=True, text=True, timeout=10)
        assert result.returncode == 0, result.stderr
        assert '--offline' in result.stdout


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
def test_recording_failure_cleans_temporary_rc(folder, tmp_path):
    result = shell(ROOT/folder/'record_homework_EN.sh', '''
sleep() { :; }
asciinema() { return 7; }
FILEPATH="$2/failure.cast"; SURNAME=SMITH; FIRSTNAME=John; GROUP=1234; SPECIALIZATION=eninfo; HOMEWORK_NUM=01a
if start_recording; then rc=0; else rc=$?; fi
[[ "$rc" == 7 && ! -e "$TEMP_RC" ]]
''', tmp_path)
    assert result.returncode == 0, result.stderr


def checker_module():
    spec = importlib.util.spec_from_file_location('enos_preflight', ROOT/'03_GUIDES/check_my_submission.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module


def test_cast_events_and_limits(tmp_path):
    module = checker_module(); path = tmp_path/'capture.cast'
    header = {'version':2, 'width':80, 'height':24}
    def check(events, h=header, footer=''):
        path.write_text(json.dumps(h)+'\n'+'\n'.join(json.dumps(x) for x in events)+'\n'+footer)
        return module.check(path)
    valid = check([[0,'o','hi'], [1,'i','x'], [1,'m',''], [2,'r','100x50'], [3,'extension','opaque']])
    assert valid['format_status'] == 'VALID_V2_STRUCTURE' and valid['events'] == 5
    assert valid['extensions'] == ['extension'] and valid['authentication_status'] == 'UNVERIFIED'
    for event in [[True,'o','x'],[float('nan'),'o','x'],[-1,'o','x'],[0,'r','0x5'],[0,'o',4]]:
        assert check([event])['errors']
    assert check([[1,'o','x'],[0,'o','y']])['errors']
    assert check([], dict(header,timestamp=True))['errors']
    assert check([[0,'o','x']], footer='\n## this is not base64\n')['errors']
    report = check([[0,'o','x']], footer='\n## ZGVtbw==\n')
    assert not report['errors'] and report['submission_readiness'] == 'UNCONFIRMED'
    path.write_text('text containing "version": 2\nnot json\n## arbitrary\n')
    assert module.check(path)['errors']


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
def test_existing_recording_is_preserved(folder, tmp_path):
    path = tmp_path/'retained.cast'; path.write_bytes(b'original recording bytes')
    result = shell(ROOT/folder/'record_homework_EN.sh', '''
FILEPATH="$2"
asciinema() { printf 'UNEXPECTED_RECORDING'; return 99; }
if start_recording; then rc=0; else rc=$?; fi
[[ "$rc" != 0 ]]
''', path)
    assert result.returncode == 0 and 'UNEXPECTED_RECORDING' not in result.stdout
    assert path.read_bytes() == b'original recording bytes'
    source = ROOT/folder/'record_homework_tui_EN.py'
    tree = ast.parse(source.read_text())
    subset = ast.Module(body=[n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'start_recording'],type_ignores=[])
    scope={'Path':Path,'Dict':Dict}
    exec(compile(subset,str(source),'exec'),scope)
    with pytest.raises(FileExistsError):scope['start_recording'](str(path),{})
    assert path.read_bytes() == b'original recording bytes'


def test_legacy_rsa_long_path_failure_cleans_keys_and_retains_recording(tmp_path):
    import base64
    from datetime import datetime
    import os
    import tempfile
    from types import SimpleNamespace
    private = tmp_path/'disposable-private.pem'; public = tmp_path/'disposable-public.pem'
    subprocess.run(['openssl','genpkey','-algorithm','RSA','-pkeyopt','rsa_keygen_bits:1024','-out',str(private)],check=True,capture_output=True,timeout=15)
    subprocess.run(['openssl','pkey','-in',str(private),'-pubout','-out',str(public)],check=True,capture_output=True,timeout=15)
    private.unlink()  # The test requires only the public half for encryption.
    work=tmp_path/('long_fixture_'+'x'*130);work.mkdir();cast=work/'capture.cast';original=b'{"version":2,"width":80,"height":24}\n[0,"o","fixture"]\n';cast.write_bytes(original)
    keys=tmp_path/'temporary-keys';keys.mkdir()
    import re
    original_script = (ROOT/'03_GUIDES/record_homework_EN.sh').read_text()
    fixture_script = tmp_path/'recorder-with-disposable-public-key.sh'
    fixture_script.write_text(re.sub(r'-----BEGIN PUBLIC KEY-----.*?-----END PUBLIC KEY-----', public.read_text().strip(), original_script, count=1, flags=re.S))
    # DERIVED fixture: the function bytes are unchanged; only the readonly public key differs.
    result=shell(fixture_script,'''
# The source is loaded with the disposable public key already installed.
FILEPATH="$3"; SURNAME=SMITH; FIRSTNAME=John; GROUP=1234
key_dir="$4"
mktemp() { command mktemp "$key_dir/key.XXXXXX"; }
if generate_signature; then rc=0; else rc=$?; fi
[[ "$rc" == 1 ]]
''',public,cast,keys)
    assert result.returncode == 0
    assert 'Recording retained locally' in result.stdout
    assert cast.read_bytes() == original and not list(keys.iterdir())
    source=ROOT/'03_GUIDES/record_homework_tui_EN.py';tree=ast.parse(source.read_text())
    subset=ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='generate_signature'],type_ignores=[])
    scope={'Dict':Dict,'os':os,'datetime':datetime,'subprocess':subprocess,'base64':base64,
           'PUBLIC_KEY':public.read_text(),'tempfile':SimpleNamespace(NamedTemporaryFile=lambda **kw: tempfile.NamedTemporaryFile(dir=keys,**kw)),
           'show_section':lambda *a:None,'show_success':lambda *a:None,'show_info':lambda *a:None,
           'spinner_task':lambda label, fn: fn()}
    exec(compile(subset,str(source),'exec'),scope)
    with pytest.raises(subprocess.CalledProcessError):scope['generate_signature'](str(cast),{'surname':'SMITH','firstname':'John','group':'1234'})
    assert cast.read_bytes()==original and not list(keys.iterdir())


@pytest.mark.parametrize('folder', ['02_INIT_HOMEWORKS', '03_GUIDES'])
@pytest.mark.parametrize('version,accepted', [('asciinema 2.4.0', True), ('asciinema 2.0', True), ('asciinema 3.0.0', False), ('unexpected output', False)])
def test_recorder_format_guard_before_recording(folder, version, accepted):
    """Current guard functions, substituted version process only; no PTY claim."""
    from types import SimpleNamespace
    import re
    import sys
    result = shell(ROOT/folder/'record_homework_EN.sh', '''
fixture_cli_version="$2"
asciinema() { [[ "$1" == --version ]] || return 99; printf '%s\\n' "$fixture_cli_version"; }
require_asciinema_v2
''', version)
    assert (result.returncode == 0) is accepted
    source = ROOT/folder/'record_homework_tui_EN.py'
    tree = ast.parse(source.read_text())
    fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'require_asciinema_v2')
    calls = []
    def run(args, **kwargs):
        calls.append(args)
        return SimpleNamespace(stdout=version+'\n', stderr='')
    scope = {'subprocess': SimpleNamespace(run=run, SubprocessError=subprocess.SubprocessError), 're':re, 'sys':sys}
    exec(compile(ast.Module(body=[fn],type_ignores=[]),str(source),'exec'),scope)
    if accepted:
        scope['require_asciinema_v2']()
    else:
        with pytest.raises(SystemExit) as error: scope['require_asciinema_v2']()
        assert error.value.code == 1
    assert calls == [['asciinema','--version']]
