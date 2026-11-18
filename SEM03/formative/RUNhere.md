# Formative questions — Seminar 3

`quiz.yaml` is canonical; `quiz_lms.json` is its project JSON view. Native LMS import is not verified. Answer keys and rubrics are formative, with final assessment policy [pending](../homework/ASSESSMENT_STATUS.md).

Run from this directory:

```bash
python3 quiz_runner.py
python3 quiz_runner.py --shuffle --quick
python3 quiz_runner.py --category cron
```

## Actual interface

```text
Quiz Runner - SEM03 System Administration

USAGE:
    python3 quiz_runner.py [options]

OPTIONS:
    --help, -h        Display this message
    --shuffle         Shuffle question order
    --quick           Quick mode (no explanations)
    --category CAT    Filter by category (find, getopts, permissions, cron)
    --no-color        Disable colours

EXAMPLES:
    python3 quiz_runner.py
    python3 quiz_runner.py --shuffle --quick
    python3 quiz_runner.py --category "cron"

NOTES:
    • Requires PyYAML: pip install pyyaml
    • Answer with a/b/c/d or 'q' to quit
    • Quiz is loaded from quiz.yaml in the same directory
```

Question content uses `questions[]`, `options`, `correct` (zero-based index), `explanation` and Bloom/score metadata. Open tasks retain their manual rubric. Shuffle changes question order. The tool does not implement the old generic --questions, --timed, --show-answers, --validate or --export interfaces.

Update the YAML and regenerate the JSON view together; check both answer text and keyed positions. Do not claim that renaming JSON to .qti or .xml creates an LMS import package.
