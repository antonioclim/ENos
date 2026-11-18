# Homework materials — Seminar 3

Read [the public task](S03_01_HOMEWORK.md), [rubric](S03_03_EVALUATION_RUBRIC.md) and [open assessment contract](ASSESSMENT_STATUS.md) together. Their grading conflict is not resolved by a generator or a structural diagnostic.

## Generate personalised starter material

```bash
bash S03_02_create_homework.sh --help
bash S03_02_create_homework.sh --preview students.csv
bash S03_02_create_homework.sh --seed 42 --output /path/to/new-variants students.csv
```

Each CSV line has `SURNAME_FIRSTNAME,GROUP,EMAIL`. The input filename is positional, not --batch. The implemented options are --help, --output DIR, --seed NUM, --verbose, --preview, --zip and --all-in-one; the last uses the separate PDF dependency documented by the script. No --student-id interface is supplied. Generated TODOs are intentional work to complete.

Generated permission fixtures use octal modes and feasible owner/group/other combinations. Run them only in the generated exercise directory. A preview is not submission completion.

## Recording and review

Follow the [current recording contract](../../03_GUIDES/RECORDING_CONTRACT.md). Format checks do not authenticate identity or approve a final grade. Publishing answer keys, selecting assessment weights and setting verification policy remain author decisions.
