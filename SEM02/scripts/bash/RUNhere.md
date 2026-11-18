# Bash utilities — Seminar 2

Run from this directory. Explicit `bash` invocation works without changing executable permissions.

## Setup

`S02_01_setup_seminar.sh` accepts `--check-only`, `--install`, `--wsl` and `--help`. Its default creates a workspace and fixtures under `~/seminar_so`; `--install` additionally attempts package installation. `--check-only` performs the dependency checks without creating the workspace.

```bash
bash S02_01_setup_seminar.sh --help
```

Read the chosen setup mode before execution: setup writes its documented workspace; full installation may invoke the system package manager.

## Formative quiz

The quiz accepts --quick (up to five randomly selected questions), --topic ops|redir|pipes|loops and --help. A topic can be combined with --quick.

```bash
bash S02_02_interactive_quiz.sh
bash S02_02_interactive_quiz.sh --help
```

## Submission diagnostics

```bash
bash S02_03_validator.sh /path/to/submission
```

The validator takes the directory as a positional argument. It does not implement --strict, --fix, --quiet or --report. The previously documented generic flags were not part of this interface. It records VALIDATION_REPORT.txt inside the supplied exercise directory and accepts either a generated package root or its exercises directory.

A runtime timeout is not a sandbox. The checks can execute submitted scripts; inspect them and use the designated exercise environment. Diagnostic results are not a final grade: see the [assessment contract](../../homework/ASSESSMENT_STATUS.md).

Dependencies include Bash and ordinary Unix command-line tools. Python tools and ShellCheck have their own requirements; consult their actual help before use.

See [demonstrations](../demo/) and [Python tools](../python/).
