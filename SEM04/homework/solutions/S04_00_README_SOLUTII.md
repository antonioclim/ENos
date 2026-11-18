# Model solutions — Seminar 4

These reference implementations are currently present in the teaching repository.
“Instructor” describes their intended audience; it does not provide confidentiality.
Their release schedule and role in assessment remain author decisions under
[ASSESSMENT_STATUS](../ASSESSMENT_STATUS.md). No script assigns a final grade.

## Files and input contracts

| Script | Exercise | Input and result |
|---|---|---|
| `S04_01_ex_validator.sh` | 1 | `Contact:`, `Server IP:` and `Phone:` records; whole-candidate lexical validation and separate invalid-record reporting |
| `S04_02_ex_log_analyzer.sh` | 2 | `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`; four levels, percentages over valid records, malformed count and text-only authentication observations |
| `S04_03_ex_data_transform.sh` | 3 | Exact personalised seven-column employee schema; department statistics and `employees_updated.csv` |
| `S04_04_ex_sales_report.sh` | 4 | Exact personalised six-column sales schema; complete `sales_summary.txt`, stable ranking ties and UTC date gaps |

The CSV models support **unquoted comma-separated fields only**. They reject quoted
CSV, wrong headers and malformed numeric fields instead of silently coercing them.
The unrelated `resources/sample_data/` files are unit/demo fixtures and do not all
have the personalised homework schema. Bash, Python 3, a current AWK with interval
expressions and GNU coreutils are needed; the models do not require GNU AWK arrays
of arrays or `asorti`. The tested AWK implementation is recorded in phase evidence.

## Run in a fresh owned workspace

From `SEM04/`, with a synthetic identifier for practice:

```bash
SEM04_ROOT=$PWD
WORK=$(mktemp -d)
python3 "$SEM04_ROOT/scripts/python/S04_04_personalized_data_generator.py" Practice01 --output-dir "$WORK"
DATA="$WORK/student_Practice01"
bash "$SEM04_ROOT/homework/solutions/S04_01_ex_validator.sh" "$DATA/contacts.txt"
bash "$SEM04_ROOT/homework/solutions/S04_02_ex_log_analyzer.sh" "$DATA/server.log"
ENOS_OUTPUT_DIR="$WORK/employee_output" ENOS_REFERENCE_YEAR=2026   bash "$SEM04_ROOT/homework/solutions/S04_03_ex_data_transform.sh" "$DATA/employees.csv"
ENOS_OUTPUT_DIR="$WORK/sales_output"   bash "$SEM04_ROOT/homework/solutions/S04_04_ex_sales_report.sh" "$DATA/sales.csv"
python3 "$SEM04_ROOT/scripts/python/S04_04_personalized_data_generator.py" --verify-files Practice01 "$DATA"
```

The two file-producing solutions refuse to overwrite an existing result. Use a
fresh output directory for another run. `--help` exits without generating data.
The generator's legacy checksum checks an identifier only; `--verify-files` compares
the five actual data files with deterministic generator output. Neither proves
student identity, authorship or that work was performed independently.

## Interpretation and boundaries

Exercise 1 accepts numeric email local parts, checks IP octets numerically and
accepts four explicitly documented Romanian phone **shapes**. It does not establish
RFC-complete email validity, deliverability, telephone allocation or country ownership.
Invalid email candidates are an intended reported class; malformed non-email
records make the report partial and return status 2.

Exercise 2 validates timestamp **shape** and the four severity labels, not civil
calendar validity or timezone identity. Its percentages exclude malformed records
and state the denominator. Empty input has undefined percentages. A matching
message is an observation, not an incident verdict.

Exercise 3 uses Department column 3, Salary column 4 and Email column 5. Zero salaries
remain valid minima. `years_employed` means reference calendar year minus hire year,
not completed anniversaries; set `ENOS_REFERENCE_YEAR` for reproducibility.

Exercise 4 validates calendar dates with GNU `date -u`, resolves ranking ties
lexically, includes every maximum salesperson tie per region and uses population
standard deviation for the illustrative quantity-outlier threshold. Empty input
has zero totals and undefined per-transaction statistics. Thresholds are descriptive,
not an empirical fraud model or an adopted bonus policy.

## Reviewing student work

Compare observed output against independently calculated expected values on bounded
fixtures, including empty, malformed, zero and tied data. Equivalent correct tools
are acceptable unless the exercise explicitly targets a named tool. Historical
25-point weights, bonus preferences and oral rules require the author's policy
resolution; no model establishes these weights by existing in the repository.

Similarity, function order, comments and shared errors can guide examination of
provenance. They do not establish misconduct or AI use. Keep the original scripts
unchanged for comparison: deleting `#` text can change quoted strings and shell
semantics. Any external comparison or student-data transfer needs its own authorised
workflow; none is performed by these reference scripts.
