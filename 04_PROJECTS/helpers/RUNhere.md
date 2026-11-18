# Local project helpers

These helpers inspect or run explicitly selected local projects. They do not award academic marks, detect all secrets, upload submissions or create a security sandbox. Use the [assessment/evidence contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md) and the actual help for each CLI.

```bash
bash project_validator.sh --help
bash test_runner.sh --help
bash submission_packager.sh --help
```

## Structural validation

```bash
bash project_validator.sh /path/to/project
```

Exactly one directory is accepted. Checks cover source/README existence, recommended structure, each Bash file's shebang and syntax, optional ShellCheck, entry-point permissions and README keyword/length heuristics. Warnings and failures have separate counters. Missing ShellCheck is explicit NOT_RUN, not a lint pass. There are no `--strict`, `--quiet`, `--report`, secret-scan, CRLF or10MB policy options. Successful structure checks do not establish functional acceptance.

## Test execution

```bash
bash test_runner.sh --verbose /path/to/project/tests
bash test_runner.sh --stop --pattern 'test_main*.sh' /path/to/project/tests
```

The argument is the tests directory. Matching Bash files run in separate Bash subprocesses in deterministic filename order; source discovery is NUL-delimited and checked. `-s/--stop/--stop-on-fail`, `-v/--verbose`, `-p/--pattern` and help are supported. The runner preserves failure counts and returns1 for failures,2 for no matching tests. It has no Docker, coverage or timeout mode and does not execute Python files as Python. Use owned/trusted tests; it inherits the caller's environment and working directory.

## Packaging

```bash
# Run validation/tests separately, then choose an owned output directory:
bash /path/to/ENos/04_PROJECTS/helpers/submission_packager.sh \
    /path/to/project ExampleStudent M05
```

The three positional arguments are project directory, simple student label and a valid catalogue ID. The archive is written to the current directory as `ExampleStudent_M05_YYYYMMDD.tar.gz`. Existing output is refused. Packaging stages and lists the complete archive before exclusive publication, handles large previews without a head/SIGPIPE failure and excludes the listed cache/editor/version-control files. It does not run `make clean`, modify source files, invent a student-ID option or call the validator automatically. Review archive contents and disclosure before any separately authorised submission.

## Limits

GNU/Linux Bash4.4+, coreutils, find, tar, Python3 and the applicable optional tool are required. Source/test/packaging checks are not a substitute for each project's semantic acceptance fixtures. For generated scaffolds, a normal main invocation correctly reports NOT_IMPLEMENTED with status3 until the exercise is implemented.
