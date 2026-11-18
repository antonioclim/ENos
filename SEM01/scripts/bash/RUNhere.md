# Bash utilities — Seminar 1

Run from this directory. Explicit `bash` invocation works without changing executable permissions.

## Setup

`S01_01_setup_seminar.sh` accepts `--full`, `--minimal`, `--clean` and `--help`. With no argument it runs minimal setup, creates files under `~/laborator_so/seminar01` and backs up `.bashrc`. `--full` also attempts package installation. `--clean` removes the seminar workspace after its prompt. Unknown options fail before creating it.

```bash
bash S01_01_setup_seminar.sh --help
```

Read the chosen setup mode before execution: setup writes its documented workspace; full installation may invoke the system package manager.

## Formative quiz

The quiz is a fixed ten-question session with no timed/shuffle/count flags.

```bash
bash S01_02_interactive_quiz.sh
bash S01_02_interactive_quiz.sh --help
```

## Submission diagnostics

```bash
bash S01_03_validator.sh /path/to/submission
```

The validator takes the directory as a positional argument. It does not implement --strict, --fix, --quiet or --report. The previously documented generic flags were not part of this interface. It returns a failing status for failed structural or execution checks.

A runtime timeout is not a sandbox. The checks can execute submitted scripts; inspect them and use the designated exercise environment. Diagnostic results are not a final grade: see the [assessment contract](../../homework/ASSESSMENT_STATUS.md).

Dependencies include Bash and ordinary Unix command-line tools. Python tools and ShellCheck have their own requirements; consult their actual help before use.

See [demonstrations](../demo/) and [Python tools](../python/).
