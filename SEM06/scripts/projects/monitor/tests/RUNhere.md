# Tests — Monitor runtime project

From the repository root:

```bash
bash SEM06/scripts/projects/monitor/tests/test_monitor.sh
```

The supported aggregate target is `make -C SEM06 test`; no project-local Makefile
is supplied. Run scripts through Bash so a checkout's executable-bit presentation
does not determine whether the tests can start.

The Bash harness accepts `--verbose` and an optional group name `core`, `utils`,
`config` or `integration`. It checks logging/validation/locks, CPU and memory
sampling, disk/process/system collectors, literal configuration and CLI formats.
Read-only host metric checks are distinct from synthetic deterministic fixtures.
The tests do not install or activate a daemon.

`SEM06/tests/test_runtime_semantics.py` supplies a synthetic first-alert JSON probe.
Missing readings are unavailable evidence; they must not be interpreted as healthy
zeroes. A collector test does not validate delivery to email/Slack or a systemd host.

See [the project guide](../README.md) and [library modules](../lib/).
