# Project scaffold and templates

`project_structure.sh` creates a new generic Bash project in the current directory. It does not choose a project implementation, overwrite an existing directory or initialise/publish a repository.

```bash
bash project_structure.sh --help
# From an owned parent directory, using the absolute generator path:
bash /path/to/ENos/04_PROJECTS/templates/project_structure.sh my_backup_project M01
```

Arguments are a simple project name and optional valid catalogue ID (`E01–E05`, `M01–M15`, `A01–A03`). There are no `--type`, `--list-types`, `--output`, `--author`, `--force` or `--readme-template` options. Select a parent directory with `cd`; edit the generated README intentionally after creation.

## Generated content

The scaffold contains `src/main.sh`, `src/lib/utils.sh`, `etc/config.conf`, `tests/test_main.sh`, README, Makefile, INSTALL/USAGE documents, `.gitignore` and a basic example. The standalone README template is available for manual adaptation. TODOs are preserved: help/version succeed, but unimplemented project work returns3 with NOT_IMPLEMENTED. The scaffold tests verify this honest boundary, not completed M01 functionality.

```bash
cd my_backup_project
make syntax test
bash src/main.sh --help
bash src/main.sh --version
```

`make all` additionally requires actual ShellCheck; absent lint is NOT_RUN/non-zero. The template checks each Bash source separately and aggregates failing tests. `make clean` deletes no unspecified files. Define exact generated targets when implementing the project. A missing tests/source set cannot pass.

## Disposable installation check

The template installs a launcher **and the required runtime source/library/resource layout**. Override both paths to test an owned destination without writing to the account's normal installation.

```bash
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
make install INSTALL_DIR="$stage/bin" RUNTIME_DIR="$stage/runtime"
"$stage/bin/my_backup_project" --help
"$stage/bin/my_backup_project" --version
```

`make uninstall` removes only the launcher and leaves the runtime for inspection. Packaging and publishing remain distinct operations. Licence selection remains an author decision; no competing root licence is silently copied into generated projects.

See [helpers/RUNhere.md](../helpers/RUNhere.md) for implemented validation/test/package arguments and [the assessment contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md) for policy choices.
