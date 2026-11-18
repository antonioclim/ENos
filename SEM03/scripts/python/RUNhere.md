# Python tools — Seminar 3

Run the following commands from this directory. Python 3 and the dependencies listed in the seminar requirements are needed. Use a dedicated virtual environment if installing dependencies.

Assessment output remains subject to the [open assessment contract](../../homework/ASSESSMENT_STATUS.md). No tool output alone establishes authorship or misconduct.

## Tools and verified command-line help

### S03_01_autograder.py

Diagnostic homework checks; final assessment policy pending.

```bash
python3 S03_01_autograder.py --help
```

```text
usage: S03_01_autograder.py [-h] [--submission SUBMISSION] [--verbose]
                            [--output OUTPUT] [--batch BATCH]
                            [--create-sample] [--test-cron TEST_CRON]
                            [--test-find TEST_FIND]
                            [--test-permissions TEST_PERMISSIONS] [--no-color]

Automated grader for Seminar 3 OS assignments

options:
  -h, --help            show this help message and exit
  --submission SUBMISSION, -s SUBMISSION
                        Directory with submission to grade
  --verbose, -v         Verbose mode
  --output OUTPUT, -o OUTPUT
                        Output file for report (JSON or MD)
  --batch BATCH, -b BATCH
                        Batch grading - directory with multiple submissions
  --create-sample       Create a sample submission for testing
  --test-cron TEST_CRON
                        Test a cron expression
  --test-find TEST_FIND
                        Test a find command
  --test-permissions TEST_PERMISSIONS
                        Test octal permissions (e.g.: 755)
  --no-color            Disable colours

Usage examples:
  S03_01_autograder.py --submission ./student_assignment/
  S03_01_autograder.py --submission ./student_assignment/ --verbose
  S03_01_autograder.py --submission ./student_assignment/ --output report.json
  S03_01_autograder.py --create-sample
  S03_01_autograder.py --test-cron "0 3 * * *"
  S03_01_autograder.py --test-find "find . -type f -name '*.txt'"
```

### S03_02_quiz_generator.py

Personalised or random formative questions.

```bash
python3 S03_02_quiz_generator.py --help
```

```text
usage: S03_02_quiz_generator.py [-h] [--interactive] [--generate N]
                                [--count COUNT]
                                [--category {find_xargs,parameters,permissions,cron,mixed}]
                                [--difficulty {easy,medium,hard}] [--balanced]
                                [--export FILE] [--with-answers] [--stats]
                                [--list-questions] [--no-color] [--version]

Quiz Generator for Seminar 03 OS

options:
  -h, --help            show this help message and exit
  --interactive, -i     Start interactive quiz in terminal
  --generate N, -g N    Generate quiz with N questions
  --count COUNT, -c COUNT
                        Number of questions (default: 10)
  --category {find_xargs,parameters,permissions,cron,mixed}, -cat {find_xargs,parameters,permissions,cron,mixed}
                        Question category
  --difficulty {easy,medium,hard}, -d {easy,medium,hard}
                        Filter by difficulty
  --balanced, -b        Select balanced from all categories
  --export FILE, -e FILE
                        Export quiz (format detected from extension: .html,
                        .json, .md)
  --with-answers, -a    Include answers in Markdown export
  --stats, -s           Display question bank statistics
  --list-questions, -l  List all questions
  --no-color            Disable terminal colours
  --version, -v         show program's version number and exit

Examples:
  S03_02_quiz_generator.py --interactive                    # Interactive quiz with 10 questions
  S03_02_quiz_generator.py --generate 15 --difficulty hard  # Hard quiz with 15 questions
  S03_02_quiz_generator.py --category permissions --count 5 # Quiz with permissions only
  S03_02_quiz_generator.py --export quiz.html               # Export as interactive HTML
  S03_02_quiz_generator.py --stats                          # Display statistics
```

### S03_03_report_generator.py

Descriptive result reports.

```bash
python3 S03_03_report_generator.py --help
```

```text
usage: S03_03_report_generator.py [-h] [--student DIR] [--class DIR]
                                  [--output FILE]
                                  [--format {console,markdown,html}]
                                  [--name NAME] [--demo] [--no-color]
                                  [--version]

Report Generator for Seminar 03 OS

options:
  -h, --help            show this help message and exit
  --student DIR, -s DIR
                        Generate report for a student (directory with results)
  --class DIR, -c DIR   Generate report for a class (directory with student
                        subdirectories)
  --output FILE, -o FILE
                        Output file (format detected from extension)
  --format {console,markdown,html}, -f {console,markdown,html}
                        Output format (default: console)
  --name NAME           Student name (for individual reports)
  --demo                Run demo with synthetic data
  --no-color            Disable colours in console output
  --version, -v         show program's version number and exit

Examples:
  S03_03_report_generator.py --student results_dir/student1           # Individual report
  S03_03_report_generator.py --class submissions/                     # Class report
  S03_03_report_generator.py --student results/ -o report.html        # Export to HTML
  S03_03_report_generator.py --demo                                   # Demo with synthetic data
```

## Evidence and outputs

Generators write to the path supplied on their command line. Answer keys and example solutions are teaching material; their publication policy remains an author decision. A timeout bounds runtime but does not isolate submitted shell code. Use the course exercise environment and inspect the submission before running evaluators.

The JSON quiz views are project exports. Native Moodle/Canvas/QTI import compatibility has not been verified in this phase.

See [tests](../../tests/) and [demonstrations](../demo/).

### S03_cron_expression.py

Read-only five-field schedule validator. No crontab is read or installed.

```bash
python3 S03_cron_expression.py --help
```

```text
usage: S03_cron_expression.py [-h] [--json] expression

Read-only schedule syntax validator; never reads or installs a crontab.
Declared subset: Debian/Vixie five-field schedules, numeric/name lists,
ascending ranges, positive steps on * or ranges, and the eight known macros. A
schedule has exactly five fields or one macro, without a command. Calendar
existence, DST, daemon behaviour, job execution and command safety are not
tested.

positional arguments:
  expression

options:
  -h, --help  show this help message and exit
  --json
```
