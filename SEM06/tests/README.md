# Tests — Seminar6 CAPSTONE

The maintained entry point is `tests/run_all_tests.sh`. Tests are both in this
directory and beside the three runtime projects. There is no
`scripts/test_runner.sh` or `scripts/test_helpers.sh`; similarly named teaching
modules are in `scripts/examples/` and have a different purpose.

## Commands

From the repository root, with Python3, pytest and PyYAML available:

```bash
bash SEM06/tests/run_all_tests.sh
python3 -m pytest SEM06/tests -q
bash SEM06/scripts/projects/monitor/tests/test_monitor.sh
bash SEM06/scripts/projects/backup/tests/test_backup.sh
bash SEM06/scripts/projects/deployer/tests/test_deployer.sh
```

`make -C SEM06 test` invokes the same wrapper. The wrapper accepts `--help` and
`--verbose`; the latter exports `LOG_LEVEL=DEBUG` for child diagnostics. It executes
all project test groups and Python tests, then checks the quiz runner and serialised
banks. A failed group produces a nonzero final status. Skipped groups remain visible. The wrapper counts runner groups; test-level skips
inside a successful group are reported by that child suite and are not converted
into passing native checks.

## Evidence by suite

| Suite | What it checks | Boundary |
|---|---|---|
| `test_capstone.py` | Actual source layout, Bash parsing and maintained function contracts | Structural/static assertions are not service acceptance |
| `test_runtime_semantics.py` | Backup create/modify/delete/rename and checksum rejection, retention chains, Deployer stop-on-failure, canary uncertainty, owned cleanup, Monitor alert JSON | Owned files and synthetic service/metric hooks |
| `test_teaching_examples.py` | Mutable state, event dispatch, literal replay, assertion isolation, curl fixture, retry, rollout stop, checksum and release helpers | Focused local examples, not a production platform |
| `monitor/tests/test_monitor.sh` | Logging, validation, locks, metric parsing, configuration and CLI output | Includes read-only host metrics; does not activate a daemon |
| `backup/tests/test_backup.sh` | Archive formats, exclusions, checksums, retention planning and owned-file round trips | The dedicated runtime test supplies incremental deletion/rename evidence |
| `deployer/tests/test_deployer.sh` | Local copies, configuration, manifests, hooks, tracking and reports | Native service/container/network cases are skipped unless an authorised lab explicitly enables them |

Do not set `ENOS_NATIVE_INTEGRATION=1` merely to remove skips. That mode requires a
separately authorised disposable lab and applicable services. Local test completion
is not evidence of native Docker, systemd deployment, notification delivery or
institutional assessment acceptance. Missing ShellCheck also remains a separate
unexecuted lint gate.

Read [the testing chapter](../docs/projects/S06_P05_Testing_Framework.md) for the
didactic runner and [the course contract](../docs/TEACHING_CONTRACT.md) for open decisions.
