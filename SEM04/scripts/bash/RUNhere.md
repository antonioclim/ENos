# Bash tools — Seminar 4

Run from this directory with Bash. The usage below is the actual interface; generic --check, --fix and --batch flags are not provided.

Diagnostic points are not a final grade: see [assessment status](../../homework/ASSESSMENT_STATUS.md). A timeout is not an execution sandbox.

## S04_02_interactive_quiz.sh

```text
╔══════════════════════════════════════════════════════════════════════════╗
║                    INTERACTIVE QUIZ - TEXT PROCESSING                    ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_02_interactive_quiz.sh [OPTIONS]

OPTIONS:
    --category CATEGORY   Choose category: regex, grep, sed, awk or all
    --count N             Number of questions (default: 10)
    --help                Display this message

EXAMPLES:
    ./S04_02_interactive_quiz.sh                    # Full quiz, 10 questions
    ./S04_02_interactive_quiz.sh --category grep    # Only grep
    ./S04_02_interactive_quiz.sh --count 5          # Only 5 questions
```

## S04_03_validator.sh

```text
╔══════════════════════════════════════════════════════════════════════════╗
║                    EXERCISE VALIDATOR - TEXT PROCESSING                  ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_03_validator.sh <exercise_id> "<student_command>"
    ./S04_03_validator.sh --list

OPTIONS:
    --list      Show all available exercises
    --help      Display this message

EXAMPLES:
    ./S04_03_validator.sh G1 "grep ' 404 ' access.log"
    ./S04_03_validator.sh A3 "awk -F',' 'NR>1{s+=\$4}END{print s}' employees.csv"
    ./S04_03_validator.sh --list

AVAILABLE EXERCISES:
    G1-G5: GREP Exercises
    S1-S4: SED Exercises
    A1-A4: AWK Exercises
```

## S04_01_setup_seminar.sh

```text
╔══════════════════════════════════════════════════════════════════════════╗
║                  SETUP SEMINAR 4: TEXT PROCESSING                        ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_01_setup_seminar.sh [OPTIONS]

OPTIONS:
    --clean     Delete existing data before regeneration
    --verbose   Display detailed progress
    --help      Display this message

GENERATED FILES:
    • access.log     - Simulated web server log (~2000 lines)
    • employees.csv  - Employee data for awk exercises
    • config.txt     - Configuration file for sed exercises
    • emails.txt     - Data for email validation exercises
    • test.txt       - Generic file for regex tests

LOCATIONS:
    • ~/demo_sem4/data/    - Main directory for demonstrations
    • ./resources/generated_data/ - Generated demo copy (not committed test fixtures)

EXAMPLES:
    ./S04_01_setup_seminar.sh              # Standard setup
    ./S04_01_setup_seminar.sh --clean      # Complete regeneration
    ./S04_01_setup_seminar.sh --verbose    # With detailed output
```

Setup writes synthetic demonstration data under ENOS_SEM04_DATA_DIR (default ~/demo_sem4/data) and ENOS_SEM04_RESOURCE_DIR (default resources/generated_data). Existing unmarked directories are refused. --clean removes only the generator’s known files; committed resources/sample_data fixtures remain separate. Use the same ENOS_SEM04_DATA_DIR for the Bash/Python command validators.


## S04_config_to_env.sh

```bash
bash S04_config_to_env.sh --exports path/to/config.txt
bash S04_config_to_env.sh --assignments path/to/config.txt
```

A teaching serializer for flat, line-based `key=value` records. Split at the first
`=`, trim key whitespace, convert key dots to underscores and key letters to
uppercase. Values are literal (including quotes, `$`, backslashes and further
`=`); an optional terminal CR is removed for CRLF input. Blank lines, comment
lines beginning with optional whitespace plus `#`/`;` and simple section headings
are skipped. Sections do not create namespaces. Invalid keys, normalisation
collisions, duplicates and NUL bytes fail before stdout contains assignments.
All other values are emitted using Bash `printf %q`, without evaluation.

Output is Bash syntax, not a claim of compatibility with every `.env` or INI
parser. A quoted value in the input retains its literal quote characters; there
is no implicit INI unquoting or interpolation. Exit 0 means serialization
completed, 2 means invalid CLI/input and 1 means an I/O failure detected while
opening the file. Do not source unreviewed configuration as a substitute for
validation; the serializer only emits data assignments and does not execute them.
