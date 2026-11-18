# Tests — Backup runtime project

From the repository root:

```bash
bash SEM06/scripts/projects/backup/tests/test_backup.sh
```

The supported aggregate target is `make -C SEM06 test`; no project-local Makefile
is supplied. Run scripts through Bash so a checkout's executable-bit presentation
does not determine whether the tests can start.

The Bash harness accepts `--verbose` and `--filter PATTERN`. Its actual groups
cover logging, naming/type selection, archive extensions and creation, extraction,
checksums including corruption, exclusions and sizes, retention and complete
owned-file backup cycles. These are the functions in `test_backup.sh`; no invented
`test_config_loading` or `test_incremental` name is required.

The stronger full/incremental semantic fixture is in
`SEM06/tests/test_runtime_semantics.py`: it compares restored bytes after creation,
modification, deletion and rename and rejects a corrupted archive before restore.
A passing archive listing alone does not establish reconstruction or durability.
Compression tools or filesystem capabilities unavailable in a target environment
must remain explicit limits. No real backup store is used by the local fixtures.

See [the project guide](../README.md) and [library modules](../lib/).
