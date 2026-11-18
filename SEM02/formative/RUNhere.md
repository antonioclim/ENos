# Formative quiz — Seminar 2

Run from this directory:

```bash
python3 quiz_runner.py quiz.yaml
python3 quiz_runner.py quiz.yaml --shuffle --limit 5 --no-color
```

## Actual command-line interface

```text
usage: quiz_runner.py [-h] [--shuffle] [--limit LIMIT] [--output OUTPUT]
                      [--no-color]
                      quiz_file

Quiz Runner - Interactive Formative Assessment

positional arguments:
  quiz_file        YAML file containing the quiz

options:
  -h, --help       show this help message and exit
  --shuffle        Shuffle the questions
  --limit LIMIT    Limit the number of questions
  --output OUTPUT  Save results to JSON
  --no-color       Disable colours

Examples:
  python3 quiz_runner.py quiz.yaml
  python3 quiz_runner.py --shuffle quiz.yaml
  python3 quiz_runner.py --limit 10 --output results.json quiz.yaml
```

## Question bank and evidence

`quiz.yaml` is the question source. Zero-based integer correct index with options/correct/explanation/category fields. Use --output FILE to retain this session’s diagnostic result as JSON. Feedback is formative and does not settle the [open assessment contract](../homework/ASSESSMENT_STATUS.md).

Edit the source bank, check each keyed answer against its stated assumptions and regenerate the project JSON view. Run the seminar tests after changes. The runner does not implement a Moodle/Canvas export command or the previously documented --validate, --timed and --show-answers flags.

`quiz_lms.json` preserves a JSON view of the questions. It is not a validated Moodle/Canvas import package; an import test is a separate step. Keep open-response rubrics and answer keys in the appropriate instructor flow once the publication policy is decided.

See [study materials](../docs/) and [tests](../tests/).
