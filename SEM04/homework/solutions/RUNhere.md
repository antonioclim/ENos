# Run the Seminar 4 reference solutions

These files are present in the teaching repository. Audience labels provide no
access control; release and assessment policy remain open.

Read [the model-solution guide](S04_00_README_SOLUTII.md) for the complete input
schemas, fresh-workspace commands, output names and limitations. Each script takes
**one filename argument**, not standard input:

```bash
bash S04_01_ex_validator.sh /path/to/personalised/contacts.txt
bash S04_02_ex_log_analyzer.sh /path/to/personalised/server.log
ENOS_OUTPUT_DIR=/path/to/fresh/employee_output ENOS_REFERENCE_YEAR=2026 bash S04_03_ex_data_transform.sh /path/to/personalised/employees.csv
ENOS_OUTPUT_DIR=/path/to/fresh/sales_output bash S04_04_ex_sales_report.sh /path/to/personalised/sales.csv
```

Use `--help` for usage. The output scripts refuse an existing result; they do not
silently replace a previous run. Test copied synthetic fixtures before interpreting
student output. A correct reference result is not a final grade or authorship proof.
