"""Bounded native fixtures for the supplied M01/M09/M12/M13/M15 references.

Only owned temporary files and child processes are used. Calendar checks invoke
systemd-analyze's parser, never a scheduler or a service. The UID/GID mismatch
fixture edits its own stored baseline; it does not perform privileged chown.
"""
import base64
import datetime as dt
import hashlib
import importlib.util
import io
import json
import os
import re
import select
import shutil
import signal
import sqlite3
import subprocess
import sys
import tarfile
import tempfile
import time
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / 'reference'


class Fixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='enos-reference-')
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name)

    def invoke(self, module, *args, expected=0):
        result = subprocess.run([sys.executable, str(REFERENCE / module), *map(str, args)],
                                capture_output=True, timeout=15)
        self.assertEqual(result.returncode, expected, result.stderr.decode(errors='replace'))
        return result

    def load(self, module):
        spec = importlib.util.spec_from_file_location(module, REFERENCE / (module + '.py'))
        result = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(result)
        return result


@unittest.skipUnless(shutil.which('tar'), 'GNU tar unavailable')
class BackupReference(Fixture):
    def setUp(self):
        super().setUp()
        self.root = self.path / 'backups'
        self.root.mkdir()
        self.source = self.path / 'source.with.dots'
        self.source.mkdir()
        self.snapshot = self.path / 'snapshot'

    def make_point(self, number, parent=None, day=None, compression=''):
        name = f'backup_202601{number:02d}_000000'
        folder = self.root / name
        folder.mkdir()
        archive = folder / ('data.tar' + compression)
        args = ['tar', '--create', '--file=' + str(archive),
                '--listed-incremental=' + str(self.snapshot), '-C', str(self.source), '.']
        if compression:
            args.insert(1, {'.gz': '--gzip', '.bz2': '--bzip2', '.xz': '--xz'}[compression])
        cp = subprocess.run(args, capture_output=True, timeout=15)
        self.assertEqual(cp.returncode, 0, cp.stderr)
        record = {'schema_version': 1, 'parent': parent, 'archive': archive.name,
                  'sha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
                  'source_root': str(self.source),
                  'created': (day or f'2026-01-{number:02d}') + 'T00:00:00Z'}
        (folder / 'manifest.json').write_text(json.dumps(record))
        return name

    def restore(self, name):
        result = self.invoke('backup_manifest.py', 'chain', self.root, name)
        plan = [Path(os.fsdecode(p)) for p in result.stdout.split(b'\0') if p]
        target = self.path / ('restored-' + name)
        target.mkdir()
        for archive in plan:
            cp = subprocess.run(['tar', '--extract', '--listed-incremental=/dev/null',
                                 '--file=' + str(archive), '--directory=' + str(target)],
                                capture_output=True, timeout=15)
            self.assertEqual(cp.returncode, 0, cp.stderr)
        return {str(p.relative_to(target)): p.read_bytes() for p in target.rglob('*') if p.is_file()}

    def test_full_incremental_delete_rename_and_unusual_names(self):
        original = {'A': b'first', 'B': b'delete later', 'space name': b'space',
                    'line\nbreak': b'newline', '-option': b'literal'}
        for name, data in original.items():
            (self.source / name).write_bytes(data)
        one = self.make_point(1)
        (self.source / 'A').write_bytes(b'second and larger')
        (self.source / 'B').unlink()
        (self.source / 'C').write_bytes(b'added')
        two = self.make_point(2, one)
        (self.source / 'C').rename(self.source / 'D')
        three = self.make_point(3, two)
        self.assertEqual(self.restore(one), original)
        middle = {**original, 'A': b'second and larger', 'C': b'added'}
        del middle['B']
        self.assertEqual(self.restore(two), middle)
        final = {**middle, 'D': middle['C']}
        del final['C']
        self.assertEqual(self.restore(three), final)

    def test_retention_protects_all_ancestors_and_active_tip(self):
        (self.source / 'A').write_text('owned')
        one = self.make_point(1)
        two = self.make_point(2, one)
        three = self.make_point(3, two)
        self.snapshot.unlink()
        four = self.make_point(4)
        (self.root / '.active').write_text(three + '\n')
        result = self.invoke('backup_manifest.py', 'retention', self.root, 1, 0, 0)
        self.assertEqual(result.stdout, b'')  # newest point plus active chain
        (self.root / '.active').unlink()
        result = self.invoke('backup_manifest.py', 'retention', self.root, 1, 0, 0)
        self.assertEqual(result.stdout.split(b'\0')[:-1], [n.encode() for n in (one, two, three)])
        self.assertTrue((self.root / four).is_dir())  # planning never deletes

    def test_all_supported_compressions_and_checksum_rejection(self):
        (self.source / 'A').write_text('owned')
        for number, compression in enumerate(('', '.gz', '.bz2', '.xz'), 1):
            if self.snapshot.exists():
                self.snapshot.unlink()
            name = self.make_point(number, compression=compression)
            self.assertEqual(self.restore(name), {'A': b'owned'})
        archive = self.root / name / ('data.tar' + compression)
        archive.write_bytes(archive.read_bytes() + b'corrupt')
        result = self.invoke('backup_manifest.py', 'chain', self.root, name, expected=1)
        self.assertEqual(result.stdout, b'')

    def test_daily_weekly_monthly_tiers_choose_distinct_points(self):
        (self.source / 'A').write_text('owned')
        dates = ['2026-01-01', '2026-01-20', '2026-02-01', '2026-02-15', '2026-02-20', '2026-03-01']
        names = []
        for number, day in enumerate(dates, 1):
            if self.snapshot.exists():
                self.snapshot.unlink()
            names.append(self.make_point(number, day=day))
        result = self.invoke('backup_manifest.py', 'retention', self.root, 1, 2, 3)
        removed = result.stdout.split(b'\0')[:-1]
        self.assertEqual(removed, [names[i].encode() for i in (0, 2, 3)])

    def test_invalid_graph_metadata_and_active_pointer_emit_no_plan(self):
        (self.source / 'A').write_text('owned')
        one = self.make_point(1)
        manifest = self.root / one / 'manifest.json'
        original = manifest.read_text()
        for changed in ({'parent': one}, {'parent': 'backup_19990101_000000'},
                        {'archive': '../data.tar'}, {'created': 42}):
            value = json.loads(original)
            value.update(changed)
            manifest.write_text(json.dumps(value))
            result = self.invoke('backup_manifest.py', 'chain', self.root, one, expected=1)
            self.assertEqual(result.stdout, b'')
            self.assertNotIn(b'Traceback', result.stderr)
        manifest.write_text(original)
        (self.root / '.active').symlink_to(self.path / 'missing')
        result = self.invoke('backup_manifest.py', 'retention', self.root, 0, 0, 0, expected=1)
        self.assertEqual(result.stdout, b'')


class ScheduleReference(Fixture):
    def test_natural_language_and_unsupported_inputs(self):
        module = self.load('schedule_reference')
        for source, expected in [('daily at 3am', '0 3 * * *'), ('daily at 12am', '0 0 * * *'),
                                 ('daily at 12:30pm', '30 12 * * *'),
                                 ('every 6 hours', '0 */6 * * *'),
                                 ('every 15 minutes', '*/15 * * * *')]:
            self.assertEqual(module.parse(source), expected)
        for source in ('every 7 hours', 'daily at 25:00', '0 0 * * MON', '@reboot',
                       '0 0 5L * *', '60 * * * *', '0 0 * * 8', '*/0 * * * *'):
            result = self.invoke('schedule_reference.py', 'parse', source, expected=2)
            self.assertEqual(result.stdout, b'')

    @unittest.skipUnless(shutil.which('systemd-analyze'), 'native calendar parser unavailable')
    def test_native_calendar_next_sets_preserve_all_fields_and_union(self):
        module = self.load('schedule_reference')
        cases = {
            '0 0 * * 0': ['2026-01-04 00:00:00', '2026-01-11 00:00:00', '2026-01-18 00:00:00'],
            '0 8 * * 1-5': ['2026-01-01 08:00:00', '2026-01-02 08:00:00', '2026-01-05 08:00:00'],
            '0 * 1 1 *': ['2026-01-01 01:00:00', '2026-01-01 02:00:00', '2026-01-01 03:00:00'],
            '0 0 1 * *': ['2026-02-01 00:00:00', '2026-03-01 00:00:00', '2026-04-01 00:00:00'],
            '0 0 2 * 1': ['2026-01-02 00:00:00', '2026-01-05 00:00:00', '2026-01-12 00:00:00'],
            '0 0 */2 * 1': ['2026-01-05 00:00:00', '2026-01-19 00:00:00', '2026-02-09 00:00:00'],
            'every 6 hours': ['2026-01-01 06:00:00', '2026-01-01 12:00:00', '2026-01-01 18:00:00'],
        }
        for expression, expected in cases.items():
            occurrences = set()
            for calendar in module.calendars(expression, 'UTC'):
                cp = subprocess.run(['systemd-analyze', 'calendar', '--iterations=3',
                                     '--base-time=2026-01-01 00:00:00 UTC', calendar],
                                    env={**os.environ, 'TZ': 'UTC', 'LC_ALL': 'C'},
                                    capture_output=True, text=True, timeout=10)
                self.assertEqual(cp.returncode, 0, cp.stderr)
                occurrences.update(re.findall(r'(?:Next elapse|Iteration #\d+): \w+ (\d{4}-\d\d-\d\d \d\d:\d\d:\d\d) UTC', cp.stdout))
            self.assertEqual(sorted(occurrences)[:3], expected, expression)


class IntegrityReference(Fixture):
    def setUp(self):
        super().setUp()
        self.first = self.path / 'first'
        self.second = self.path / 'second'
        self.first.mkdir()
        self.second.mkdir()
        self.db = self.path / 'baseline.sqlite'
        self.config = self.path / 'config.json'
        self.write_config([self.first, self.second])

    def write_config(self, roots, algorithm='sha512', exclude=None):
        self.config.write_text(json.dumps({'roots': list(map(str, roots)), 'algorithm': algorithm,
                                          'exclude': exclude or []}))

    def test_create_check_unique_files_metadata_and_literal_names(self):
        names = ["apostrophe's | space", 'line\nname', 'delete-me', 'mode-only', 'owner-oracle']
        for name in names:
            (self.first / name).write_text('original')
        self.invoke('fim_reference.py', 'create', self.db, self.config)
        self.assertEqual(json.loads(self.invoke('fim_reference.py', 'check', self.db).stdout)['files_changed'], 0)
        with sqlite3.connect(self.db) as database:
            stored = database.execute('SELECT hash FROM files LIMIT 1').fetchone()[0]
            self.assertEqual(stored, hashlib.sha512(b'original').hexdigest())
            # A synthetic prior owner record exercises comparison without chown.
            database.execute('UPDATE files SET uid=uid+1,gid=gid+1 WHERE path=?',
                             (str(self.first / 'owner-oracle'),))
        (self.first / names[0]).write_text('changed')
        (self.first / 'delete-me').unlink()
        (self.first / 'added').write_text('new')
        (self.first / 'mode-only').chmod(0o700)
        result = json.loads(self.invoke('fim_reference.py', 'check', self.db, expected=1).stdout)
        self.assertEqual(result['files_changed'], 5)
        changes = {Path(row['path']).name: row['changes'] for row in result['changes']}
        self.assertIn('hash', changes[names[0]])
        self.assertEqual(changes['delete-me'], ['deleted'])
        self.assertEqual(changes['added'], ['added'])
        self.assertIn('permissions', changes['mode-only'])
        self.assertEqual(changes['owner-oracle'], ['uid', 'gid'])

    def test_selective_update_retains_unselected_root_and_rejects_config_change(self):
        (self.first / 'A').write_text('a')
        (self.second / 'B').write_text('b')
        self.invoke('fim_reference.py', 'create', self.db, self.config)
        initial = self.db.read_bytes()
        self.invoke('fim_reference.py', 'create', self.db, self.config, expected=2)
        self.assertEqual(self.db.read_bytes(), initial)
        (self.first / 'A').write_text('new a')
        (self.second / 'B').write_text('new b')
        self.write_config([self.first])
        self.invoke('fim_reference.py', 'update', self.db, self.config)
        result = json.loads(self.invoke('fim_reference.py', 'check', self.db, expected=1).stdout)
        self.assertEqual([r['path'] for r in result['changes']], [str(self.second / 'B')])
        saved = self.db.read_bytes()
        for algorithm, exclusion in [('sha256', []), ('sha512', ['*/ignore'])]:
            self.write_config([self.first], algorithm, exclusion)
            self.invoke('fim_reference.py', 'update', self.db, self.config, expected=2)
            self.assertEqual(self.db.read_bytes(), saved)

    def test_unavailable_root_and_unsupported_cli_cannot_look_clean(self):
        self.write_config([self.path / 'missing'])
        self.invoke('fim_reference.py', 'create', self.db, self.config, expected=2)
        self.assertFalse(self.db.exists())
        self.write_config([self.first])
        self.invoke('fim_reference.py', 'create', self.db, self.config)
        self.invoke('fim_reference.py', 'check', self.db, self.config, expected=2)
        self.first.rmdir()
        self.invoke('fim_reference.py', 'check', self.db, expected=2)


@unittest.skipUnless(shutil.which('tail'), 'GNU tail unavailable')
class TailReference(Fixture):
    def start(self, count):
        files = [self.path / f'log {i}' for i in range(count)]
        for path in files:
            path.write_bytes(b'old backlog\n')
        # Record the actual Popen/wait boundary instead of relying on this test
        # runner's /proc namespace. Child argv and collector logic are unchanged.
        self.trace = self.path / 'owned-children.jsonl'
        launcher = self.path / 'trace_collector.py'
        launcher.write_text('''import importlib.util,json,subprocess,sys
from pathlib import Path
reference,trace,*paths=sys.argv[1:]
def record(event,pid,code=None):
 with open(trace,'a') as stream: stream.write(json.dumps({'event':event,'pid':pid,'code':code})+'\\n')
original=subprocess.Popen
class TracedChild(original):
 def __init__(self,*args,**kwargs):
  super().__init__(*args,**kwargs);record('spawn',self.pid)
 def wait(self,*args,**kwargs):
  code=super().wait(*args,**kwargs);record('reaped',self.pid,code);return code
subprocess.Popen=TracedChild
spec=importlib.util.spec_from_file_location('owned_collector',reference)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
try: raise SystemExit(module.main(paths))
except (ValueError,OSError,RuntimeError) as error:
 print(error,file=sys.stderr);raise SystemExit(2)
''')
        collector = subprocess.Popen([sys.executable, str(launcher), str(REFERENCE / 'tail_reference.py'),
                                      str(self.trace), *map(str, files)],
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=0)
        self.addCleanup(self.stop, collector)
        deadline = time.monotonic() + 8
        self.stream_buffer = b''
        observed = set()
        while time.monotonic() < deadline:
            if collector.poll() is not None:
                self.fail(collector.stderr.read().decode())
            for path in files:
                with path.open('ab') as stream:
                    stream.write(b'__READY__\n')
            for row in self.read_available(collector, 0.1):
                if row['message'] == '__READY__':
                    observed.add(row['source'])
            events = [json.loads(line) for line in self.trace.read_text().splitlines()] if self.trace.exists() else []
            children = [r['pid'] for r in events if r['event'] == 'spawn']
            if len(children) == count and observed == set(map(str, files)):
                return collector, children, files
        self.fail('owned tail children did not observe the readiness records')

    def read_available(self, process, timeout):
        readable, _, _ = select.select([process.stdout], [], [], timeout)
        if not readable:
            return []
        data = os.read(process.stdout.fileno(), 65536)
        if not data:
            self.fail('collector exited before expected records')
        self.stream_buffer += data
        records = []
        while b'\n' in self.stream_buffer:
            line, self.stream_buffer = self.stream_buffer.split(b'\n', 1)
            records.append(json.loads(line))
        return records

    @staticmethod
    def stop(process):
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)
        for stream in (process.stdout, process.stderr):
            if stream:
                stream.close()

    def records(self, process, count):
        records = []
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline and len(records) < count:
            records.extend(r for r in self.read_available(process, 0.2) if r['message'] != '__READY__')
        self.assertEqual(len(records), count)
        return records

    def assert_reaped(self, process, children, expected):
        self.assertEqual(process.wait(timeout=8), expected)
        events = [json.loads(line) for line in self.trace.read_text().splitlines()]
        reaped = {row['pid'] for row in events if row['event'] == 'reaped' and row['code'] is not None}
        self.assertEqual(reaped, set(children))

    def test_single_source_whitespace_header_binary_and_clean_shutdown(self):
        process, children, files = self.start(1)
        lines = [b'  preserve whitespace\t ', b'==> fake-file <==', b'\xff\x80binary']
        with files[0].open('ab') as stream:
            stream.write(b'\n'.join(lines) + b'\n')
        records = self.records(process, 3)
        self.assertEqual([r['source'] for r in records], [str(files[0])] * 3)
        self.assertEqual(records[0]['message'], lines[0].decode())
        self.assertEqual(records[1]['message'], lines[1].decode())
        self.assertEqual(records[2]['encoding'], 'base64')
        self.assertEqual(base64.b64decode(records[2]['message']), lines[2])
        process.terminate()
        self.assert_reaped(process, children, 143)

    def test_two_source_framing_and_child_failure_reaps_the_other_child(self):
        process, children, files = self.start(2)
        for number, path in enumerate(files):
            with path.open('ab') as stream:
                stream.write(f'source {number}\n'.encode())
        records = self.records(process, 2)
        self.assertEqual({r['source']: r['message'] for r in records},
                         {str(p): f'source {n}' for n, p in enumerate(files)})
        os.kill(children[0], signal.SIGTERM)
        self.assert_reaped(process, children, 2)


class ParallelReference(Fixture):
    def bash(self, body, *args, expected=0):
        result = subprocess.run(['bash', '-c', 'set -euo pipefail\nsource "$1"\nshift\n' + body,
                                 'fixture', str(REFERENCE / 'parallel_reference.sh'), *map(str, args)],
                                capture_output=True, timeout=20, cwd=self.path)
        self.assertEqual(result.returncode, expected, result.stderr.decode(errors='replace'))
        return result

    def test_literal_argv_and_placeholders_are_expanded_once(self):
        worker = self.path / 'worker.py'
        worker.write_text('import json,sys\nprint(json.dumps(sys.argv[1:]))\n')
        inputs = ['a b', "quote'\"; $dollar", '$(touch SHOULD_NOT_EXIST)', '-leading',
                  'line\nvalue', '{#}', '{/}', 'directory.with.dots/file.ext']
        out = self.path / 'out'
        self.bash('OUTPUT_DIR=$1; worker=$2; shift 2\nJOBS=2; KEEP_GOING=true\n'
                  'COMMAND_ARGV=(python3 "$worker" "{}" "{#}")\nrun_parallel "$@"', out, worker, *inputs)
        for number, value in enumerate(inputs, 1):
            attempt = out / 'jobs' / str(number) / 'attempt_0'
            self.assertEqual(json.loads((attempt / 'stdout').read_text()), [value, str(number)])
            self.assertEqual(json.loads((attempt / 'meta.json').read_text())['input'], value)
        self.assertFalse((self.path / 'SHOULD_NOT_EXIST').exists())

    def test_failures_progress_timeout_and_empty_input(self):
        result = self.bash('OUTPUT_DIR=$1; JOBS=1; COMMAND_ARGV=(bash -c "exit 7")\n'
                           'if run_parallel first second; then exit 99; fi', self.path / 'failed')
        self.assertIn(b'Requested=2 Launched=1 Completed=1 Failed=1 Not_launched=1', result.stdout)
        result = self.bash('OUTPUT_DIR=$1; JOBS=2; KEEP_GOING=true; COMMAND_ARGV=(bash -c "exit 7")\n'
                           'if run_parallel first second; then exit 99; fi', self.path / 'mixed')
        self.assertIn(b'Requested=2 Launched=2 Completed=2 Failed=2 Not_launched=0', result.stdout)
        self.bash('OUTPUT_DIR=$1; JOBS=1; TIMEOUT=0.05s; COMMAND_ARGV=(sleep 10)\n'
                  'if run_parallel first; then exit 99; fi', self.path / 'timeout')
        self.assertEqual(json.loads((self.path / 'timeout/jobs/1/attempt_0/meta.json').read_text())['exit_code'], 124)
        self.bash('OUTPUT_DIR=$1; JOBS=1; COMMAND_ARGV=(true)\nrun_parallel', self.path / 'empty', expected=2)

    def test_retry_exhaustion_is_per_job_and_preserves_original_contract(self):
        out = self.path / 'failed'
        self.bash('OUTPUT_DIR=$1; JOBS=2; KEEP_GOING=true; COMMAND_ARGV=(bash -c "exit 7" _ "{}")\n'
                  'if run_parallel "alpha space" "beta;literal"; then exit 99; fi\n'
                  'COMMAND_ARGV=(true); TIMEOUT=999\n'
                  'if retry_failed "$OUTPUT_DIR" 2; then exit 99; fi', out)
        for number in (1, 2):
            attempts = sorted((out / 'jobs' / str(number)).glob('attempt_*'))
            self.assertEqual([p.name for p in attempts], ['attempt_0', 'attempt_1', 'attempt_2'])
            records = [json.loads((p / 'meta.json').read_text()) for p in attempts]
            self.assertEqual([r['exit_code'] for r in records], [7, 7, 7])
            self.assertTrue(all(r['command_argv'] == records[0]['command_argv'] and r['timeout'] == '' for r in records))

    def test_retry_success_is_not_executed_again_on_resume(self):
        worker = self.path / 'once.py'
        counter = self.path / 'counter'
        worker.write_text('from pathlib import Path\nimport sys\np=Path(sys.argv[1])\n'
                          'n=int(p.read_text())+1 if p.exists() else 1\np.write_text(str(n))\n'
                          'raise SystemExit(7 if n==1 else 0)\n')
        out = self.path / 'resume'
        self.bash('OUTPUT_DIR=$1; JOBS=1; COMMAND_ARGV=(python3 "$2" "$3" "{}")\n'
                  'if run_parallel literal; then exit 99; fi\n'
                  'retry_failed "$OUTPUT_DIR" 1\nretry_failed "$OUTPUT_DIR" 1', out, worker, counter)
        self.assertEqual(counter.read_text(), '2')
        self.assertEqual(len(list((out / 'jobs/1').glob('attempt_*'))), 2)

    def test_retry_rejects_inconsistent_identity_contract_and_symlinks(self):
        out = self.path / 'invalid-retry'
        self.bash('OUTPUT_DIR=$1; JOBS=1; COMMAND_ARGV=(false)\n'
                  'if run_parallel literal; then exit 99; fi', out)
        meta = out / 'jobs/1/attempt_0/meta.json'
        original = meta.read_text()
        for changed in ({'job_num': 2}, {'attempt': 1}, {'exit_code': '0; false'},
                        {'command_argv': ['echo', 'bad\0argument']}, {'timeout': '1s; false'}):
            record = json.loads(original)
            record.update(changed)
            meta.write_text(json.dumps(record))
            self.bash('retry_failed "$1" 1', out, expected=1)
            self.assertFalse((out / 'jobs/1/attempt_1').exists())
            self.assertFalse((out / 'jobs/2').exists())
        meta.unlink()
        copied = self.path / 'copied.json'
        copied.write_text(original)
        meta.symlink_to(copied)
        self.bash('retry_failed "$1" 1', out, expected=1)
        self.assertFalse((out / 'jobs/1/attempt_1').exists())


class ReferenceParity(unittest.TestCase):
    def test_a03_reference_modules_match_the_current_documented_sources(self):
        document = next((ROOT / 'c)ADVANCED').glob('A03*.md')).read_text()
        blocks = re.findall(r'```c\n(.*?)\n```', document, re.S)
        names = ['syncutil.h', 'hash.c', 'rolling_hash.c', 'signature.c', 'diff.c']
        self.assertEqual(len(blocks), len(names))
        for name, source in zip(names, blocks):
            self.assertEqual((REFERENCE / 'a03' / name).read_text(), source + '\n', name)


if __name__ == '__main__':
    unittest.main()
