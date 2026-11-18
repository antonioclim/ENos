"""Exact maintained teaching helpers in disposable fixtures; no external services."""
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / 'scripts/examples'

class TeachingExamples(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='enos-examples-')
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name)
    def bash(self, text, *args, env=None):
        return subprocess.run(['bash','-euo','pipefail','-c',text,'_',str(EXAMPLES),str(self.work),*args],
            cwd=self.work,text=True,capture_output=True,timeout=15,env=env)
    def test_factory_observer_and_literal_replay(self):
        result=self.bash(r'''
source "$1/architecture_patterns.sh"
declare -A job_one=() job_two=()
create_backup_job job_one daily 'source one' 'dest one'
create_backup_job job_two weekly 'source two' 'dest two'
[[ ${job_one[name]} == daily && ${job_two[name]} == weekly ]]
record() { printf 'record:%s\n' "$1" >> "$2"; }
record2() { printf 'second:%s\n' "$1" >> "$2"; }
on_event 'backup:complete' record
on_event 'backup:complete' record2
emit_event 'backup:complete' 'space;value' "$2/observed"
execute_command printf '%s\n' 'literal $(touch injected); value'
replay_commands 1
[[ ${#COMMAND_START[@]} == 1 && ! -e injected ]]
LOG_FILE='' log_message INFO 'without a log file'
LOG_LEVEL=INFO log_message DEBUG 'suppressed'
''')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(result.stdout.count('literal $(touch injected); value'),2)
        self.assertEqual((self.work/'observed').read_text().splitlines(),['record:space;value','second:space;value'])
    def test_assertion_failure_survives_later_success_and_file_isolation(self):
        tests=self.work/'tests'; tests.mkdir()
        for name in ('one','two'):
            (tests/f'test_{name}.sh').write_text(f'test_{name}() {{ assert_contains abc z || :; assert_success 7 || :; true; }}\n')
        result=subprocess.run(['bash',str(EXAMPLES/'test_runner.sh'),str(tests)],text=True,capture_output=True,timeout=10)
        self.assertEqual(result.returncode,1,result.stdout+result.stderr)
        self.assertEqual(result.stdout.count('Tests: 1 total, 0 passed, 1 failed'),2)
        empty=self.work/'empty';empty.mkdir()
        result=subprocess.run(['bash',str(EXAMPLES/'test_runner.sh'),str(empty)],capture_output=True,timeout=10)
        self.assertEqual(result.returncode,2)
    def test_decimal_assertions_and_nonfinite_rejected(self):
        result=self.bash(r'''source "$1/test_helpers.sh"
assert_in_range 23.5 0 100
if assert_in_range nan 0 100; then exit 9; fi
if assert_success 4; then exit 8; fi
[[ $ASSERTIONS_PASSED == 1 && $ASSERTIONS_FAILED == 2 ]]
''')
        self.assertEqual(result.returncode,0,result.stderr)
    def test_curl_fixture_body_and_http_transport_status(self):
        env=os.environ.copy();env.update(MOCK_CURL_EXPECTED_ARGV_JSON='["--fail","https://fixture.invalid"]',
            MOCK_CURL_BODY='{"quote":"a\\\"b"}',MOCK_CURL_HTTP_STATUS='503',MOCK_CURL_EXIT='0')
        command=['python3',str(EXAMPLES/'mock_curl.py'),'--fail','https://fixture.invalid']
        result=subprocess.run(command,env=env,capture_output=True)
        self.assertEqual(result.returncode,22)
        env['MOCK_CURL_HTTP_STATUS']='200'
        result=subprocess.run(command,env=env,text=True,capture_output=True)
        self.assertEqual(result.stdout,env['MOCK_CURL_BODY'])
        self.assertEqual(result.returncode,0)
        result=subprocess.run(command+['unexpected'],env=env,capture_output=True)
        self.assertEqual(result.returncode,2)
    def test_retry_external_boundary_success_failure_timeout(self):
        result=self.bash(r'''source "$1/retry.sh"
retry_with_timeout 3 2 0 1 /bin/true
if retry_with_timeout 3 2 0 1 /bin/false; then exit 9; else [[ $? == 1 ]]; fi
if retry_with_timeout 1 2 0 1 sleep 10; then exit 8; else [[ $? == 124 ]]; fi
if retry 0 0 1 true; then exit 7; else [[ $? == 2 ]]; fi
''')
        self.assertEqual(result.returncode,0,result.stderr)
    def test_feature_flag_failure_stops_all_later_stages(self):
        result=self.bash(r'''source "$1/deploy_strategies.sh"
declare -a INSTANCES=(one two)
FEATURE_OBSERVE_SECONDS=0
set_feature_flag() { printf '%s\n' "$2" >> "$work/stages"; }
deploy_rolling() { return 0; }
check_metrics() { return 1; }
rollback_feature_flag() { printf rollback >> "$work/rollback"; }
work=$2
if deploy_with_feature_flag app v1 feature; then exit 9; else [[ $? == 1 ]]; fi
''')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual((self.work/'stages').read_text().splitlines(),['0','5'])
        self.assertEqual((self.work/'rollback').read_text(),'rollback')
    def test_rolling_failure_and_missing_canary_metrics_fail_closed(self):
        result=self.bash(r'''source "$1/deploy_strategies.sh"
work=$2
ROLLING_BATCH_SIZE=0
if deploy_rolling app version one; then exit 9; else [[ $? == 2 ]]; fi
ROLLING_BATCH_SIZE=1
drain_instance() { return 0; }
deploy_to_instance() { printf '%s\n' "$1" >> "$work/instances"; return 7; }
wait_for_health() { return 0; }
enable_instance() { return 0; }
rollback_instance() { return 0; }
if deploy_rolling app version one two; then exit 8; else [[ $? == 1 ]]; fi
for invalid in '' nan inf -1; do
 if canary_values_healthy "$invalid" 20 1 100; then exit 6; fi
done
canary_values_healthy 0 20 1 100
''')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual((self.work/'instances').read_text().splitlines(),['one'])
    def test_checksums_all_algorithms_corruption_and_empty_compression(self):
        result=self.bash(r'''source "$1/backup_examples.sh"
printf 'data with quote\n' > "$2/a b.txt"
for algorithm in md5 sha1 sha256 sha512; do
 generate_checksum "$2/a b.txt" "$algorithm"
 verify_checksum "$2/a b.txt" "$algorithm"
done
printf corrupt >> "$2/a b.txt"
if verify_checksum "$2/a b.txt" sha512; then exit 9; fi
if verify_checksum "$2/a b.txt" unsupported; then exit 8; fi
: > "$2/empty"
compressed=$(compress_file "$2/empty" gzip 6)
[[ -s $compressed ]]
''')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertIn('undefined (empty input)',result.stderr)
    def package(self,name='data',contents=b'new content'):
        package=self.work/'package.tar.gz'
        with tarfile.open(package,'w:gz') as archive:
            entry=tarfile.TarInfo(name);entry.size=len(contents);archive.addfile(entry,io.BytesIO(contents))
        return package,hashlib.sha256(package.read_bytes()).hexdigest()
    def test_release_staging_immutable_version_and_activation(self):
        package,digest=self.package()
        helper=EXAMPLES/'release_reference.py'; root=self.work/'releases'
        def call(*args):return subprocess.run(['python3',str(helper),*map(str,args)],text=True,capture_output=True)
        result=call('create',root,'app','v1',package,digest)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(call('activate',root,'app','v1').returncode,0)
        self.assertEqual(os.readlink(root/'app/current'),'v1')
        self.assertNotEqual(call('create',root,'app','v1',package,digest).returncode,0)
        self.assertNotEqual(call('activate',root,'app','missing').returncode,0)
        self.assertEqual(os.readlink(root/'app/current'),'v1')
        package,digest=self.package('../escape')
        self.assertNotEqual(call('create',root,'app','v2',package,digest).returncode,0)
        self.assertFalse((root/'app/v2').exists())
        self.assertFalse((root/'app/escape').exists())

if __name__=='__main__':unittest.main()
