# Tests — Deployer runtime project

From the repository root:

```bash
bash SEM06/scripts/projects/deployer/tests/test_deployer.sh
```

The supported aggregate target is `make -C SEM06 test`; no project-local Makefile
is supplied. Run scripts through Bash so a checkout's executable-bit presentation
does not determine whether the tests can start.

The Bash harness runs without a documented filter/verbosity CLI. Its default path
checks logging, validation, owned locks/temp files, file replacement, literal
configuration, manifests, hooks, tracking, reports and local rollback bookkeeping.
Native service/container/network groups are explicitly skipped unless
`ENOS_NATIVE_INTEGRATION=1` is deliberately enabled in a separately authorised lab.
Do not interpret those skips as passing deployment checks.

`SEM06/tests/test_runtime_semantics.py` and `test_teaching_examples.py` add failure
propagation, stop-on-failure, missing-canary-metric and release-activation fixtures.
They use synthetic callbacks and owned directories; they do not demonstrate
production traffic routing, complete container restoration or remote service health.

See [the project guide](../README.md) and [library modules](../lib/).
