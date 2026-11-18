# Formative questions — Seminar 4

`quiz.yaml` is canonical; `quiz_lms.json` is its project JSON view. Native LMS import is not verified. Answer keys and rubrics are formative, with final assessment policy [pending](../homework/ASSESSMENT_STATUS.md).

Run from this directory:

```bash
python3 quiz_runner.py quiz.yaml
python3 quiz_runner.py quiz.yaml --shuffle --category understand
python3 quiz_runner.py --self-test
```

## Actual interface

```text
usage: quiz_runner.py [-h] [--shuffle]
                      [--category {remember,understand,apply,analyse,evaluate,create}]
                      [--self-test]
                      [quiz_file]

Interactive formative quiz; open tasks require manual review.

positional arguments:
  quiz_file

options:
  -h, --help            show this help message and exit
  --shuffle             Shuffle questions
  --category {remember,understand,apply,analyse,evaluate,create}
  --self-test
```

Question content uses `questions[]`, `options`, `correct` (zero-based index), `explanation` and Bloom/score metadata. Open tasks retain their manual rubric. Shuffle changes question order. The tool does not implement the old generic --questions, --timed, --show-answers, --validate or --export interfaces.

Update the YAML and regenerate the JSON view together; check both answer text and keyed positions. Do not claim that renaming JSON to .qti or .xml creates an LMS import package.
