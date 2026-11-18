# Python tools — Seminar 4

Run the following commands from this directory. Python 3 and the dependencies listed in the seminar requirements are needed. Use a dedicated virtual environment if installing dependencies.

Assessment output remains subject to the [open assessment contract](../../homework/ASSESSMENT_STATUS.md). No tool output alone establishes authorship or misconduct.

## Tools and verified command-line help

### S04_01_autograder.py

Diagnostic homework checks; final assessment policy pending.

```bash
python3 S04_01_autograder.py --help
```

```text
usage: S04_01_autograder.py [-h] [--verbose] [--json JSON_OUTPUT]
                            [--self-test]
                            [submission_file]

Run diagnostic command checks; assessment policy remains pending.

positional arguments:
  submission_file     JSON object with student_id and solutions mapping

options:
  -h, --help          show this help message and exit
  --verbose, -v
  --json JSON_OUTPUT  Write the machine-readable result
  --self-test
```

### S04_02_quiz_generator.py

Personalised or random formative questions.

```bash
python3 S04_02_quiz_generator.py --help
```

```text
usage: S04_02_quiz_generator.py [-h] [--count COUNT]
                                [--category {regex,grep,sed,awk,all}]
                                [--format {text,html,json,moodle}]
                                [--output OUTPUT] [--export-all]

Quiz Generator for Text Processing

options:
  -h, --help            show this help message and exit
  --count COUNT         Number of questions
  --category {regex,grep,sed,awk,all}
  --format {text,html,json,moodle}
  --output OUTPUT, -o OUTPUT
                        Output file (default: stdout)
  --export-all          Export all questions in all formats
```

### S04_03_report_generator.py

Descriptive result reports.

```bash
python3 S04_03_report_generator.py --help
```

```text
usage: S04_03_report_generator.py [-h] [--grades GRADES] [--output OUTPUT]
                                  [--sample] [--json]

Report generator for Seminar 4

options:
  -h, --help            show this help message and exit
  --grades GRADES, -g GRADES
                        JSON file with autograder results
  --output OUTPUT, -o OUTPUT
                        Output file
  --sample              Use test data
  --json                Output in JSON format
```

### S04_04_personalized_data_generator.py

Deterministic data generation in a fresh directory; identifier checks and actual-file checks are distinct.

```bash
python3 S04_04_personalized_data_generator.py --help
```

```text
usage: S04_04_personalized_data_generator.py [-h]
                                             [--verify ID CHECKSUM | --verify-files ID DIRECTORY]
                                             [--output-dir OUTPUT_DIR]
                                             [student_id]

S04_04_personalized_data_generator.py — Deterministic Teaching Data Generator

Generates ID-seeded synthetic practice data. The 32-bit seed can collide;
personalisation is not proof of authorship or prevention of solution sharing.
The legacy 12-character MD5 value is a dataset identifier, not authentication.
--verify compares that identifier only; --verify-files compares all five files
byte-for-byte with regenerated content and still makes no authorship claim.

Usage:
    python3 S04_04_personalized_data_generator.py <MATRICOL>
    python3 S04_04_personalized_data_generator.py --verify <MATRICOL> <CHECKSUM>

Author: ing. dr. Antonio Clim, ASE Bucharest — CSIE
Version: 1.0

Retained author account (anecdotal, not a measured detection guarantee):
    Last semester I caught 3 students with identical outputs on 'random' data.
    Turns out they shared solutions. Now each student gets unique data,
    so even if they share code, the outputs will not match. Checkmate.

positional arguments:
  student_id

options:
  -h, --help            show this help message and exit
  --verify ID CHECKSUM  Compare the legacy identifier only; no submitted files
                        are read
  --verify-files ID DIRECTORY
                        Compare all five named files against regenerated
                        bytes, read-only
  --output-dir OUTPUT_DIR
                        Existing parent directory for new generated folders
```

### S04_05_similarity_checker.py

Local teaching utility.

```bash
python3 S04_05_similarity_checker.py --help
```

```text
usage: S04_05_similarity_checker.py [-h] [--threshold THRESHOLD] [--all-pairs]
                                    [--json]
                                    submissions_dir

Check student submissions for code similarity

positional arguments:
  submissions_dir       Directory containing student submission folders

options:
  -h, --help            show this help message and exit
  --threshold THRESHOLD, -t THRESHOLD
                        Similarity threshold to flag (default: 0.7)
  --all-pairs           Compare all file pairs (not just same-named exercises)
  --json                Output results in JSON format

Examples:
    S04_05_similarity_checker.py ./submissions/
    S04_05_similarity_checker.py --threshold 0.80 ./submissions/
    S04_05_similarity_checker.py --all-pairs ./submissions/

The tool compares conservative lexical normalisations. Common templates and
short answers can produce high similarity; the score does not establish misconduct.

Typical workflow:
    1. Run this before grading to flag suspicious submissions
    2. Review flagged pairs manually
    3. Conduct oral verification for high-similarity pairs
    4. Document findings for academic integrity procedures
```

## Evidence and outputs

Generators write to the path supplied on their command line. Answer keys and example solutions are teaching material; their publication policy remains an author decision. A timeout bounds runtime but does not isolate submitted shell code. Use the course exercise environment and inspect the submission before running evaluators.

The JSON quiz views are project exports. Native Moodle/Canvas/QTI import compatibility has not been verified in this phase.

See [tests](../../tests/) and [demonstrations](../demo/).
