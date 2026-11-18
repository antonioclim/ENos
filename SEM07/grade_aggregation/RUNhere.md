# Component aggregation and explicit policy

`final_grade_calculator_EN.py` validates three CSV inputs and writes CSV, JSON and Markdown using an output **prefix**. Without `--policy`, final grades remain blank/null and reports say `PENDING_POLICY`. A reviewed zero remains zero; missing evidence is not silently replaced by zero.

```bash
python3 final_grade_calculator_EN.py --help
python3 final_grade_calculator_EN.py \
    --homework /path/to/homework_grades.csv \
    --project /path/to/project_grades.csv \
    --tests /path/to/test_grades.csv --output component_review
```

Options are `-hw/--homework`, `-p/--project`, `-t/--tests`, `-o/--output`, `-v/--verbose` and `--policy`. All three CSV files are required; a component with no data can have its valid header and no rows. There are no `--exam`, `--weights`, `--format`, `--missing-as-zero`, bonus or publication options.

## Report files and preservation

An output prefix such as `component_review` produces `component_review.csv`, `component_review.json` and `component_review.md`. All three destinations must be new. Existing files, directories or symbolic links are rejected; choose a new prefix for another review. A destination must not coincide with any input CSV or the policy file, including resolved symbolic-link and hard-link aliases. The implementation reserves each file exclusively, so an output created after the initial check is not silently overwritten.

The JSON report has `schema_version: 1`, `policy_status`, `policy_supplied`, `policy_approval`, `status_counts` and a `students` array. Each student record retains the component values, counts, `weighted_score`, `final_grade`, `status`, `elimination_reason` and `issues`. Missing numerical evidence remains JSON `null`; a reviewed zero remains numerical `0.0`. CSV and Markdown display missing numerical cells as blank. A supplied policy is labelled `SUPPLIED_POLICY_UNVERIFIED`: its presence does not establish author or institutional approval.

The reports are prepared before any output is opened. A caught write failure attempts to remove only the files created by that invocation; pre-existing files are preserved. This is not a multi-file transaction or a crash/power-loss guarantee. Treat a failed command or an incomplete set of reports as an unfinished export. Files are created with owner-only permissions where the host honours POSIX modes. No Windows-native file-system acceptance is implied by local Linux checks.

## Input contract

| Input | Required fields and meaning |
|---|---|
| Homework | `student_id,student_name,student_group,seminar,homework_id,final_score,late_days,signature_valid`; distinct assignments, score already human-reviewed/adjusted |
| Project | `student_id,student_name,student_group,auto_score,manual_score,eligible`; finite non-negative components, sum at most10; explicit eligibility or missing state |
| Tests | `student_id,student_name,student_group,test_id,score`; distinct tests, score0–10 or -1 for absence |

Required headers are checked even when a table has no data rows. An empty file, missing required columns, blank or repeated column names, a malformed CSV record or a row with a different number of fields from its header is an error. Missing scores must use explicit empty cells under the valid header. Duplicate columns are never resolved by silently choosing the first or last value. A valid header-only table remains a supported empty component.

Optional project catalogue/repository and test date/notes columns are retained as input context but do not prove eligibility. CSV templates contain **synthetic illustrative names and values**, not verified people, repositories or assessment results. They do not prescribe course subweights.

## Policy choices

A supplied policy must specify all consequential choices listed in [the current contract](../homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md): weights, thresholds and denominators, late-work participation, grade boundaries, pass boundary, elimination grade and whether project eligibility is required. No approved default is bundled. Positive-weight components require usable evidence; zero-weight missing components remain null with non-blocking notes.

[GRADING_POLICY.md](GRADING_POLICY.md) preserves conflicting historical proposals for author reconciliation. Changing that Markdown alone does not configure the calculator. Resolve one versioned policy before calculating authoritative results or publishing them. Duplicate rows, conflicting identity, non-finite marks and invalid scales produce errors rather than arbitrary first/last-row selection.
