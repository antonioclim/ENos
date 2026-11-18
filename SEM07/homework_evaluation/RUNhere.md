# Homework review tools

Run commands from this directory. `verify_homework_EN.sh` parses `.cast` recordings and reports format, explicit identity metadata and authentication separately. It does not check Bash syntax or execute recorded commands. `grade_homework_EN.py` joins exact file hashes and reviewed scores; it does not award marks from recording size.

```bash
bash verify_homework_EN.sh --help
python3 grade_homework_EN.py --help
```

## Local command chain

Provide an existing submission directory. Exit 2 from verification means a completed batch has unresolved records; inspect its CSV/JSON before proceeding.

```bash
submissions=/path/to/submissions
if bash verify_homework_EN.sh --report -o verification "$submissions"; then
    printf 'Every selected record verified under the supplied contract.
'
else
    status=$?
    printf 'Verification status %s; inspect verification/ reports.
' "$status" >&2
    test "$status" -eq 2 || exit "$status"
fi
python3 grade_homework_EN.py --submissions "$submissions" \
    --rubrics homework_rubrics --verification verification/verification_results.csv \
    --scores reviewed_scores.csv --output homework_grades.csv
```

The scores file has `file,final_score`; use relative paths from the submissions root and finite reviewed marks in [0,10]. Omit `--scores` to inventory work awaiting review. Optional `--deadlines` consumes timezone-aware deadlines and reports client-timestamp lateness; it does not apply an unapproved penalty. `--verbose` supplies diagnostics.

Verifier options are `-o/--output DIR`, `-k/--key FILE`, `-q/--quiet`, `-r/--report`, `--seminar LABEL` and `--student TEXT`. There is no `--strict`, `--batch` or `--report FILE` interface. The grader uses `-s/--submissions`, `-r/--rubrics`, `-d/--deadlines`, `-o/--output`, `-v/--verbose`, `--verification` and `--scores`.

## Review and provenance

The six `S01_HOMEWORK_RUBRIC.md`–`S06_HOMEWORK_RUBRIC.md` files are human criteria, not an executable YAML rubric. Keep criterion-level observations with reviewed marks. Missing student/assignment identity is rejected; filenames are not treated as identity proof. Current recorder envelopes remain unauthenticated by this verifier. The `.review.json` companion lists missing metadata, mismatches and pending scores.

See [VERIFICATION_AND_GRADING_CONTRACT.md](VERIFICATION_AND_GRADING_CONTRACT.md) for the exact CSV contract, distinct-assignment rules, signature limits and author decisions. Historical late/participation rules remain proposals in [GRADING_POLICY.md](../grade_aggregation/GRADING_POLICY.md). No collection, upload, publication or institutional acceptance is performed by this workflow.
