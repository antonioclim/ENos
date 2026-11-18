# Python Tools — SEM05

Python 3.10 or later is required. Commands below run from `SEM05/scripts/python/` and use the actual shipped interfaces. Each tool supports `--help`; options are tool-specific.

## Autograder diagnostics

```bash
python3 S05_01_autograder.py --help
python3 S05_01_autograder.py ./submission.sh --verbose
python3 S05_01_autograder.py --batch ./submissions --json > results.json
python3 S05_01_autograder.py ./submission.sh --test-config ./test_cases.json --json
```

The positional input is a Bash script. `--batch DIRECTORY` evaluates the selected scripts in a directory. `--json` writes parseable JSON to stdout; diagnostics use stderr. The optional test configuration is JSON, not a marking rubric or YAML configuration. It can define execution cases, so use trusted submissions/fixtures in an isolated working area. A subprocess timeout is not a security sandbox. The tool has no `--rubric`, `--output`, `--timeout` or CSV batch flag.

Source-pattern checks and locally executed cases provide diagnostic evidence. They do not enact the conflicting assessment proposals or prove authorship. Missing tooling is not a successful check.

## Quiz generation

```bash
python3 S05_02_quiz_generator.py --list
python3 S05_02_quiz_generator.py --topic arrays --count 5 --no-shuffle
python3 S05_02_quiz_generator.py --difficulty medium --count 5 --export quiz.json
python3 S05_02_quiz_generator.py --count 5 --html quiz.html
```

`--count` means questions, not separate quizzes. Topics are `functions`, `arrays`, `robustness`, `trap` and `integration`; difficulty is `easy`, `medium` or `hard`. The exported JSON is a custom repository format. No Moodle XML, Canvas QTI, PDF, YAML export or seeded randomisation is promised by this interface. The generated HTML is a local practice artefact, not a submitted grade.

## Reports from autograder JSON

```bash
python3 S05_03_report_generator.py --grades results.json
python3 S05_03_report_generator.py --grades results.json --format json --output report.json
python3 S05_03_report_generator.py --summary
```

`--grades` accepts autograder result JSON; malformed or unavailable input fails explicitly. Output formats are `text` and `json`. `--summary` lists available exercises. PDF/HTML reports, CSV input and per-student report directories are not implemented here.

## Shared code and tests

The shared [repository library](../../../lib/) is separate from these script-local implementations. Do not add an unrelated relative PYTHONPATH merely to run these entry points. Run maintained tests from the repository root:

```bash
python3 -m pytest SEM05/tests
```

Dependencies belong to the project's declared Python environment. Test execution and linting results must be recorded separately from installation. See [tests](../../tests/) and [the teaching contract](../../docs/TEACHING_CONTRACT.md).
