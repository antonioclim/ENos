# Bash entry points — SEM06

The historical setup/interactive-quiz/validator filenames in this directory were not supplied. Use the real maintained entry points below; no installation, sudo action or package acceptance is implied.

| Purpose | Entry point and actual help |
|---|---|
| Monitor | `bash SEM06/scripts/projects/monitor/monitor.sh --help` |
| Backup | `bash SEM06/scripts/projects/backup/backup.sh --help` |
| Deployer | `bash SEM06/scripts/projects/deployer/deployer.sh --help` |
| Owned teaching demonstrations | [examples/owned_demos.sh](../examples/owned_demos.sh) |
| Source/test checks | `make -C SEM06 check` and [test runner](../../tests/run_all_tests.sh) |
| Formative practice | [YAML quiz guide](../../formative/RUNhere.md) |

Commands shown above use repository-root paths. For each project's options, literal configuration, dependencies and limits see its README under [projects](../projects/). There are no shipped `S06_01_setup_seminar.sh`, `S06_02_interactive_quiz.sh` or `S06_03_validator.sh` interfaces here, and no implemented `--fix` submission repair.

Use owned fixtures to test behaviour. Project helper tests do not install services or execute an institutional evaluation. Missing ShellCheck is a visible incomplete check. Bash4.4+ and the documented project dependencies are required; [the teaching contract](../../docs/TEACHING_CONTRACT.md) separates technical operation from policy choices.
