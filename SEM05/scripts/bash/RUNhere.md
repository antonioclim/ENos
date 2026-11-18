# Bash Utilities — SEM05

Run from `SEM05/scripts/bash/`, or prefix the paths from the SEM05 directory.
All three scripts support `--help`. Invoke them with Bash; no executable-bit change is required.

| Script | Implemented purpose | Options |
|---|---|---|
| `S05_01_setup_seminar.sh` | Check dependencies and create owned teaching fixtures | `--check`, `--clean`, `--dir PATH`, `--verbose`, `--help` |
| `S05_02_interactive_quiz.sh` | Interactive practice with feedback | `--topic functions\|arrays\|robust`, `--quick`, `--all`, `--help` |
| `S05_03_validator.sh` | Static diagnostics for one script or a directory | `--verbose`, `--shellcheck`, `--dir PATH`, `--quiet`, `--help` |

## Setup

```bash
bash S05_01_setup_seminar.sh --check
bash S05_01_setup_seminar.sh --dir "$HOME/seminar_bash" --verbose
```

The setup creates `exercises/`, `solutions/`, `templates/`, `test_files/` and `submissions/` under the chosen directory. It reports unavailable dependencies; it does not install packages or require sudo. `--clean` recreates only a directory marked as owned by this setup. Review its location before requesting a reset. There are no `--minimal`, `--force` or `--workspace` options.

## Practice

```bash
bash S05_02_interactive_quiz.sh --quick
bash S05_02_interactive_quiz.sh --topic arrays
```

The Bash quiz has no time limit or shuffle flag. EOF/cancellation is handled explicitly. For the separate YAML bank and its CLI, see [the formative guide](../../formative/RUNhere.md).

## Validation

```bash
bash S05_03_validator.sh --verbose --shellcheck ./example.sh
bash S05_03_validator.sh --dir ./submissions
```

The validator checks syntax and selected source patterns. Directory results aggregate failures; success does not mean that arbitrary program behaviour was proved correct. Missing requested ShellCheck is reported as unavailable, not passed. It does not apply automatic fixes or produce an HTML/PDF report. Its diagnostic points are not an approved institutional grade.

## Requirements and troubleshooting

Bash 4.4+, standard GNU/Linux utilities and ShellCheck when its check is requested. The `--check` result describes missing tools; installation is a separate environment action. A file permission error can be avoided by using `bash script.sh`; a wrong path still needs correction.

See [demos](../demo/), [Python tools](../python/) and [the teaching contract](../../docs/TEACHING_CONTRACT.md).
