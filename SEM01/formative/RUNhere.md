# Formative quiz — Seminar 1

Run from this directory:

```bash
python3 quiz_runner.py quiz.yaml
python3 quiz_runner.py quiz.yaml --shuffle --limit 5 --no-color
```

## Actual command-line interface

```text
usage: quiz_runner.py [-h] [--shuffle] [--limit LIMIT] [--no-color]
                      [quiz_file]

Run YAML quizzes in the terminal.

positional arguments:
  quiz_file      Path to the quiz file (default: quiz.yaml)

options:
  -h, --help     show this help message and exit
  --shuffle      Shuffle the questions
  --limit LIMIT  Limit the number of questions
  --no-color     Disable colours
```

## Question bank and evidence

`quiz.yaml` is the question source. Letter keys A–D with labelled option strings; type open uses its manual rubric. Open responses are excluded from the automatic MCQ denominator and retained for manual review. Feedback is formative and does not settle the [open assessment contract](../homework/ASSESSMENT_STATUS.md).

Edit the source bank, check each keyed answer against its stated assumptions and regenerate the project JSON view. Run the seminar tests after changes. The runner does not implement a Moodle/Canvas export command or the previously documented --validate, --timed and --show-answers flags.

`quiz_lms.json` preserves a JSON view of the questions. It is not a validated Moodle/Canvas import package; an import test is a separate step. Keep open-response rubrics and answer keys in the appropriate instructor flow once the publication policy is decided.

See [study materials](../docs/) and [tests](../tests/).

## Canonical bank and derived JSON contract

`quiz.yaml` is the canonical question bank. `quiz_lms.json` is a project JSON view, not an imported or validated Moodle/Canvas package. It retains all 14 items: 13 multiple-choice questions with one keyed answer and one open response with its original rubric, example solution and `manual_review_required: true`. The open response has no automatic answer key or awarded score. The estimated 20 minutes describe planning, not an enforced deadline. Pass thresholds, attempt limits and institutional weighting remain `PENDING_POLICY`; no settings are inferred from a legacy JSON export.

`source_sync.sha256` identifies the exact YAML bytes. The consistency tests compare IDs, types, text, options, keys, feedback, Bloom/learning-outcome annotations and the manual rubric against the canonical bank. Regenerate the JSON whenever the YAML changes and validate the resulting provider-specific adapter separately before any LMS import.
