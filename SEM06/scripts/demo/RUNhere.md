# Demonstrations for SEM06

This directory is a navigation entry. The maintained examples live in
[`../examples/`](../examples/); there is no `S06_01_hook_demo.sh`, generic
`S06_0X_demo_topic.sh` or demo-specific colour/speed option in this directory.

## Runnable local demonstrations

From the repository root:

```bash
bash SEM06/scripts/examples/owned_demos.sh snapshot
bash SEM06/scripts/examples/owned_demos.sh release
bash SEM06/scripts/examples/owned_demos.sh processes
bash SEM06/scripts/examples/owned_demos.sh descriptors
```

Each mode creates an owned temporary workspace and removes only its own resources.
The snapshot mode shows independent copies, not an incremental backup chain. The
release mode demonstrates symlink activation in that workspace. Process and
descriptor modes inspect only children or files created for the demonstration.
No service account, real deployment, cron registration or visual-tool installation
is required. Expected failures use explicit status handling; `set -e` alone is not
a complete error-handling strategy.

## Reusable teaching modules

| Module | Purpose and invocation contract |
|---|---|
| `architecture_patterns.sh` | Sourceable factory, observer and command-history examples |
| `monitor_examples.sh` | Sourceable validated metric and structured-output helpers |
| `backup_examples.sh` | Sourceable archive/checksum helpers; pass owned input/output paths |
| `deploy_strategies.sh` | Sourceable strategies with explicit caller-provided deployment/traffic hooks |
| `test_helpers.sh`, `test_runner.sh` | Assertion helpers and a runner for an explicit test directory |
| `mock_curl.py` | Synthetic HTTP process fixture, not an external HTTP request |
| `retry.sh` | Bounded retries of an explicit external command |
| `evidence_examples.py` | Allowlisted NUL environment parsing, trace records and content fingerprints |
| `release_reference.py` | Owned release staging/activation helper used by the teaching examples |

Read each module's interface and the corresponding tests before composing a new
experiment. A sourceable helper is not an installed service or a complete student
project. Ask learners to predict the result, run a small owned fixture, then compare
its actual status/output with the prediction. Use shell tracing only on synthetic
values; it may reveal arguments and secrets.

See [the test guide](../../tests/README.md), [teaching material](../../docs/) and
[presentations](../../presentations/) for the classroom sequence and evidence limits.
