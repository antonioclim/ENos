# Python tools — Seminar 1

Run the following commands from this directory. Python 3 and the dependencies listed in the seminar requirements are needed. Use a dedicated virtual environment if installing dependencies.

Assessment output remains subject to the [open assessment contract](../../homework/ASSESSMENT_STATUS.md). No tool output alone establishes authorship or misconduct.

## Tools and verified command-line help

### S01_01_autograder.py

Diagnostic homework checks; final assessment policy pending.

```bash
python3 S01_01_autograder.py --help
```

```text
usage: S01_01_autograder.py [-h] [--json JSON_OUTPUT] [--config CONFIG]
                            student_directory

Seminar 1 diagnostic checker; assessment policy remains pending

positional arguments:
  student_directory

options:
  -h, --help          show this help message and exit
  --json JSON_OUTPUT  Export the diagnostic record
  --config CONFIG     Assignment generator JSON configuration
```

### S01_02_quiz_generator.py

Personalised or random formative questions.

```bash
python3 S01_02_quiz_generator.py --help
```

```text
usage: S01_02_quiz_generator.py [-h] [--students STUDENTS]
                                [--questions QUESTIONS] [--output OUTPUT]
                                [--format {txt,html,both}]

Seminar 1 quiz generation

options:
  -h, --help            show this help message and exit
  --students STUDENTS   Number of students to generate for
  --questions QUESTIONS
                        Number of questions per quiz
  --output OUTPUT       Output directory
  --format {txt,html,both}
                        Export format
```

### S01_03_report_generator.py

Descriptive result reports.

```bash
python3 S01_03_report_generator.py --help
```

```text
usage: S01_03_report_generator.py [-h] --input INPUT [--output OUTPUT]
                                  [--format {txt,html,csv,all}]

Seminar report generation

options:
  -h, --help            show this help message and exit
  --input INPUT         Directory with JSON results or CSV file
  --output OUTPUT       Output directory for reports
  --format {txt,html,csv,all}
                        Export format
```

### S01_04_assignment_generator.py

Personalised assignment parameters.

```bash
python3 S01_04_assignment_generator.py --help
```

```text
usage: S01_04_assignment_generator.py [-h] [--output OUTPUT] student_id

Assignment Generator - Generates deterministic assignment variants per
identifier Operating Systems | ASE Bucharest - CSIE Purpose: Vary
requirements; personalisation alone does not prevent copying or prove
authorship. Usage: python3 S01_04_assignment_generator.py <student_id>
[--output dir] Each student receives: - Different directory names - Different
variable names - Different aliases to implement - Different glob patterns to
demonstrate

positional arguments:
  student_id       Identifier, name or email; no path separators/control
                   characters

options:
  -h, --help       show this help message and exit
  --output OUTPUT
```

### S01_05_plagiarism_detector.py

Code similarity observations for contextual review.

```bash
python3 S01_05_plagiarism_detector.py --help
```

```text
usage: S01_05_plagiarism_detector.py [-h] [--threshold THRESHOLD]
                                     [--output OUTPUT]
                                     submissions_dir

Describe submission similarity and lexical style for manual review; no
authorship inference or automatic sanctions.

positional arguments:
  submissions_dir       ROOT/STUDENT/.../*.sh

options:
  -h, --help            show this help message and exit
  --threshold THRESHOLD
                        Descriptive similarity display threshold, 0..1
                        (default: 0.85)
  --output OUTPUT       Text report path; accompanying JSON uses the same stem
```

### S01_06_ai_fingerprint_scanner.py

Lexical style observations; no authorship inference.

```bash
python3 S01_06_ai_fingerprint_scanner.py --help
```

```text
usage: S01_06_ai_fingerprint_scanner.py [-h] [--output OUTPUT] [--verbose]
                                        [--no-color] [--extensions EXTENSIONS]
                                        [directory]

Describe lexical style patterns; no authorship inference or automatic sanctions

positional arguments:
  directory             Directory to scan (default: docs)

options:
  -h, --help            show this help message and exit
  --output OUTPUT, -o OUTPUT
                        Output file (JSON format if .json extension)
  --verbose, -v         Show detailed findings per file
  --no-color            Disable coloured output
  --extensions EXTENSIONS, -e EXTENSIONS
                        Comma-separated file extensions to scan

Examples:
  S01_06_ai_fingerprint_scanner.py docs/                     # Scan docs directory
  S01_06_ai_fingerprint_scanner.py . --verbose               # Scan current directory with details
  S01_06_ai_fingerprint_scanner.py . --output report.json    # Output JSON report
  S01_06_ai_fingerprint_scanner.py . --no-color              # Disable colours
        
```

## Evidence and outputs

Generators write to the path supplied on their command line. Answer keys and example solutions are teaching material; their publication policy remains an author decision. A timeout bounds runtime but does not isolate submitted shell code. Use the course exercise environment and inspect the submission before running evaluators.

The JSON quiz views are project exports. Native Moodle/Canvas/QTI import compatibility has not been verified in this phase.

See [tests](../../tests/) and [demonstrations](../demo/).

## Process status and interpretation of local observations

The similarity tool requires `ROOT/STUDENT/.../*.sh` and a text `--output report.txt`;
it creates the JSON companion `report.json` separately. A `.json` text output,
missing/unreadable inputs or zero applicable scripts are rejected before a success
report. Exit 0 means the descriptive analysis completed, not that the work is original.

The lexical scanner defaults to `.md,.txt,.rst`; use `--extensions .sh` explicitly
when inspecting Bash. `--output report.json` writes the machine-readable report;
stdout remains human-readable text. Exit 0 means the scan completed independently
of its historical style index, 1 reports an incomplete read/output operation and
2 indicates invalid CLI/input-directory arguments. An empty selection has
`NO_APPLICABLE_FILES`; unreadable inputs have `INCOMPLETE` and `read_errors`.
`summary + results` is the existing JSON structure. The retained
`authenticity_score` key is only a legacy style index, with an explicit note;
`penalty` is null and contextual review does not imply a review has occurred.
