# Python tools — Seminar 2

Run the following commands from this directory. Python 3 and the dependencies listed in the seminar requirements are needed. Use a dedicated virtual environment if installing dependencies.

Assessment output remains subject to the [open assessment contract](../../homework/ASSESSMENT_STATUS.md). No tool output alone establishes authorship or misconduct.

## Tools and verified command-line help

### S02_01_autograder.py

Diagnostic homework checks; final assessment policy pending.

```bash
python3 S02_01_autograder.py --help
```

```text
usage: S02_01_autograder.py [-h] [-o OUTPUT] [-q] directory

Autograder for OS Seminar 2 homework

positional arguments:
  directory             Directory with student homework

options:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        JSON output file
  -q, --quiet           Quiet mode (final score only)

Examples:
  python3 S02_01_autograder.py ~/my_homework/
  python3 S02_01_autograder.py ./submissions/student_name/
  python3 S02_01_autograder.py --output report.json ./homework/
```

### S02_02_quiz_generator.py

Personalised or random formative questions.

```bash
python3 S02_02_quiz_generator.py --help
```

```text
usage: S02_02_quiz_generator.py [-h] [--student STUDENT] [--grupa GRUPA]
                                [--students STUDENTS] [--count COUNT]
                                [--format {txt,html,json,md,all}]
                                [--output OUTPUT] [--answers] [--seed SEED]
                                [--list-questions] [--stats]

Personalised quiz generator for Seminar 2

options:
  -h, --help            show this help message and exit
  --student STUDENT, -s STUDENT
                        Student name
  --grupa GRUPA, -g GRUPA
                        Student group
  --students STUDENTS, -S STUDENTS
                        File with student list (format: Name,Group)
  --count COUNT, -c COUNT
                        Number of questions (default: 15)
  --format {txt,html,json,md,all}, -f {txt,html,json,md,all}
                        Export format (default: txt)
  --output OUTPUT, -o OUTPUT
                        Output directory (default: current directory)
  --answers, -a         Include correct answers
  --seed SEED           Manual seed for randomisation
  --list-questions      List all questions in the bank
  --stats               Display question bank statistics

Usage examples:
  S02_02_quiz_generator.py --student "Smith John" --grupa 1051
  S02_02_quiz_generator.py --students list.txt --output ./quizzes/
  S02_02_quiz_generator.py --student "Test" --grupa 1000 --format html --answers
  S02_02_quiz_generator.py --count 20 --format all --output ./export/
```

### S02_03_report_generator.py

Descriptive result reports.

```bash
python3 S02_03_report_generator.py --help
```

```text
usage: S02_03_report_generator.py [-h] [--input INPUT]
                                  [--format {txt,html,csv,moodle,all}]
                                  [--output OUTPUT] [--compare BEFORE AFTER]
                                  [--filter-group FILTER_GROUP]
                                  [--min-score MIN_SCORE] [--quiet]

Report and statistics generator for evaluations

options:
  -h, --help            show this help message and exit
  --input INPUT, -i INPUT
                        JSON/CSV file or directory with results
  --format {txt,html,csv,moodle,all}, -f {txt,html,csv,moodle,all}
                        Report format (default: txt)
  --output OUTPUT, -o OUTPUT
                        Output file or directory
  --compare BEFORE AFTER, -c BEFORE AFTER
                        Compare two sets of results
  --filter-group FILTER_GROUP, -g FILTER_GROUP
                        Filter only a specific group
  --min-score MIN_SCORE
                        Filter students with minimum score
  --quiet, -q           Quiet mode (no terminal output)

Usage examples:
  S02_03_report_generator.py --input ./results/
  S02_03_report_generator.py --input ./results/ --format html --output report.html
  S02_03_report_generator.py --input results.json --format csv --output export.csv
  S02_03_report_generator.py --compare ./week1/ ./week2/ --output progress.html
```

## Evidence and outputs

Generators write to the path supplied on their command line. Answer keys and example solutions are teaching material; their publication policy remains an author decision. A timeout bounds runtime but does not isolate submitted shell code. Use the course exercise environment and inspect the submission before running evaluators.

The JSON quiz views are project exports. Native Moodle/Canvas/QTI import compatibility has not been verified in this phase.

See [tests](../../tests/) and [demonstrations](../demo/).
