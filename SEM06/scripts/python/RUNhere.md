# Python entry points — SEM06

This directory contains this guide; the earlier `S06_01_autograder.py`, `S06_02_quiz_generator.py` and `S06_03_report_generator.py` command examples referred to files that are not shipped. They must not be treated as successful or available grading workflows.

## Available tools

| Purpose | Maintained source |
|---|---|
| Formative YAML practice | [formative/quiz_runner.py](../../formative/quiz_runner.py), with [actual options](../../formative/RUNhere.md) |
| Project checks | [tests/test_capstone.py](../../tests/test_capstone.py), [runtime semantic tests](../../tests/test_runtime_semantics.py) |
| Teaching helper regressions | [test_teaching_examples.py](../../tests/test_teaching_examples.py) |
| Literal configuration data | [config_data.py](../projects/config_data.py) |
| Backup-chain retention/validation | [backup library](../projects/backup/lib/) |
| Local project diagnostics and human score review | [SEM07 toolkit](../../../SEM07/README.md) |

```bash
# From the repository root, in the declared Python environment:
python3 -m pytest SEM06/tests
python3 SEM06/formative/quiz_runner.py --help
```

Python3.10+ is required. Install dependencies in the declared project environment as a separate setup action; these commands do not install packages. The [shared library](../../../lib/) belongs to the repository root. No `--batch`, Moodle/QTI, PDF, per-student feedback or marking-weight contract is invented here. See [the teaching contract](../../docs/TEACHING_CONTRACT.md) before interpreting diagnostics as assessment evidence.
