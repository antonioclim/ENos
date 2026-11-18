# Project diagnostics

The current evaluator performs local static diagnostics by default. It does not build or run submitted projects unless execution is explicit. Diagnostic totals are not approved marks, and project-specific acceptance remains human-reviewed.

```bash
bash run_auto_eval_EN.sh --help
bash run_auto_eval_EN.sh --level MEDIUM --output ./diagnostics /path/to/project
```

Default static-only completion returns2 (`NOT_RUN` for functional execution). `--execute-local` permits trusted project code with per-command timeouts in a temporary working copy; that copy is not a security sandbox. It is suitable for owned synthetic fixtures, not untrusted submissions.

```bash
bash run_auto_eval_EN.sh --execute-local --level EASY --timeout 10 \
    --output ./fixture_results /path/to/owned_fixture
```

Supported options: `-h/--help`, `-v/--version`, `-o/--output`, `-l/--level EASY|MEDIUM|ADVANCED`, `-t/--timeout`, `--docker`, `--docker-image`, `--execute-local`, `--no-cleanup`, `--verbose`. Input is one directory, not a tarball or batch. No `--parallel`, `--memory`, `--keep-container` or archive extraction is implemented.

## Container mode

Supply an existing local image explicitly. There is no pull or fallback to local execution. The wrapper requests non-root UID/GID, read-only source and root filesystem, no network, no capabilities, process/memory/CPU limits and a temporary writable filesystem. A bounded wrapper covers the container command; it does not claim a disk quota for the results bind mount.

```bash
bash run_auto_eval_EN.sh --docker --docker-image enos-eval:local \
    --level MEDIUM --timeout 30 --output ./container_results /path/to/project
```

See [Docker/RUNhere.md](Docker/RUNhere.md) for the correct build context and unverified native-container limits. Building/running a container and assessing real submissions require their own authorisation and environment; neither is part of the local source tests.

## Interpretation

Reports retain observed command outputs/statuses. Missing ShellCheck or skipped functional work is visible; no placeholder domain tests receive credit. Current diagnostics do not implement the entire 23-project specification or a criterion-level academic grade. [manual_eval_checklist_EN.md](manual_eval_checklist_EN.md) retains review criteria with pending scale choices; [oral_defence_questions_EN.md](oral_defence_questions_EN.md) maps questions to the actual23 projects. [The assessment contract](../homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md) separates authentication, evidence, scoring and policy.

## Diagnostic completeness

ShellCheck runs once per regular Bash file and its JSON report and exit status are
validated. Tool failure, timeout or malformed output stops the run; it cannot
be labelled clean. All file discovery uses filename-preserving records. Optional
Pylint runs with an explicit empty configuration and its status/report is checked.
This environment's final local tests used a declared synthetic ShellCheck/bc
adapter because those executables were unavailable; native integration remains
unverified here. The shipped CLI still checks these prerequisites explicitly.

The old numeric caps are retained as historical proposals. They are not attainable
maxima for every language mix and are not normalised into grades. In a static-only
run, the functional CSV score and total remain blank, with `NOT_RUN` and
`PENDING_EVIDENCE`; a reviewed zero is a different state. The CSV columns are
`Component,Score,HistoricalCap,Status`. Executed diagnostics record the real return
codes and produce a `PENDING_POLICY` heuristic total, never a final grade.
