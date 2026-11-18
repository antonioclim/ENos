# Homework materials — Seminar 2

The [public task](S02_01_HOMEWORK.md), [rubric](S02_03_EVALUATION_RUBRIC.md) and [assessment status](ASSESSMENT_STATUS.md) must be read together. Their conflicting grading rules remain an author decision.

## Create a local starter package

Run from this directory:

```bash
bash S02_02_create_homework.sh "Student Name" 1051 --output /path/to/new-packages
bash S02_02_create_homework.sh --interactive
bash S02_02_create_homework.sh --help
```

The supported generator interface is positional name/group, --interactive, --output DIR and --help. It does not implement --student-id, --batch, --seed or --template.

The package contains five exercise starters under exercises/, a README and check_homework.sh. The self-check checks structure, syntax, remaining placeholders and executable bits; it does not award points, establish functional correctness or convert untouched templates into a completed assignment. Keep TODOs until you implement the required work.

## Work and submission evidence

Complete the tasks and keep the requested explanation of your results. Run the local preflight in the generated package. The repository recorder and submission checker are documented in [the central guides](../../03_GUIDES/); use their actual interfaces. Recordings, hashes and logs support contextual review but do not prove authorship or uninterrupted capture.

Reference solutions under solutions/ and archived material under OLD_HW/ have distinct teaching roles. Access and publication policy for instructor material remains to be decided by the author.
