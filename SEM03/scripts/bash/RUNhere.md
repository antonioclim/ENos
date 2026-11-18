# Bash tools — Seminar 3

Run from this directory with Bash. The usage below is the actual interface; generic --check, --fix and --batch flags are not provided.

Diagnostic points are not a final grade: see [assessment status](../../homework/ASSESSMENT_STATUS.md). A timeout is not an execution sandbox.

## S03_01_setup_seminar.sh

```text
\033[1mUSAGE:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_01_setup_seminar.sh [-h] [-v] [-c] [-d DIR]

\033[1mOPTIONS:\033[0m
    -h          Display this help
    -v          Verbose mode
    -c          Clean previous setup before installation
    -d DIR      Base directory (default: ~/sem5-6_lab)

\033[1mEXAMPLES:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_01_setup_seminar.sh                    # Standard setup
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_01_setup_seminar.sh -v                 # Setup with detailed output
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_01_setup_seminar.sh -c -d ~/mylab      # Clean and install in ~/mylab

\033[1mSTRUCTURE CREATED:\033[0m
    ~/sem5-6_lab/
    ├── find_exercises/      # find and xargs exercises
    ├── script_exercises/    # Parameters and getopts exercises
    ├── permission_lab/      # Permissions exercises (sandbox)
    ├── cron_exercises/      # Cron exercises
    └── integration/         # Integrated exercises
```

## S03_02_interactive_quiz.sh

```text
\033[1mInteractive Quiz - Seminar 3 OS\033[0m

\033[1mUSAGE:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_02_interactive_quiz.sh [-h] [-n NUM] [-c CATEGORY] [-r] [-p]

\033[1mOPTIONS:\033[0m
    -h              Display this help
    -n NUM          Number of questions (default: 10, max: 25)
    -c CATEGORY     Category:
                      find   - Questions about find and xargs
                      script - Questions about parameters and getopts
                      perm   - Questions about permissions
                      cron   - Questions about cron
                      all    - All categories (default)
    -r              Random order of questions
    -p              Practice mode (displays explanations after each answer)

\033[1mEXAMPLES:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_02_interactive_quiz.sh                     # 10 questions from all categories
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_02_interactive_quiz.sh -n 5 -c find        # 5 questions only about find
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_02_interactive_quiz.sh -r -p               # Practice mode with random order
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_02_interactive_quiz.sh -c perm -n 8        # 8 questions about permissions
```

## S03_03_validator.sh

```text
\033[1mAssignment Validator - Seminar 3 OS\033[0m

\033[1mUSAGE:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_03_validator.sh [-h] [-v] [-o REPORT] [-s] <assignment_directory>

\033[1mOPTIONS:\033[0m
    -h          Display this help
    -v          Verbose mode (details for each test)
    -o REPORT   Save report to file
    -s          Strict mode (any warning becomes error)

\033[1mEXPECTED STRUCTURE:\033[0m
    tema_sem5-6/
    ├── find_commands.sh       # Find commands (Part 1)
    ├── professional_script.sh # Script with getopts (Part 2)
    ├── permission_manager.sh  # Permissions manager (Part 3)
    ├── cron_jobs.txt          # Cron expressions (Part 4)
    └── integration.sh         # Integrated script (Part 5)

\033[1mEXAMPLES:\033[0m
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_03_validator.sh ./my_assignment         # Simple validation
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_03_validator.sh -v ./my_assignment      # With details
    /workspace/scratch/cc249383a0ce/ENos_WORK/ENos-v6/SEM03/scripts/bash/S03_03_validator.sh -v -o report.txt ./tema # Save report
```

Setup accepts -d DIR and writes only the configured exercise tree. Generated cron examples resolve their paths relative to that tree; setup does not install a scheduler entry. The validator can execute submitted shell scripts: inspect them first and use the dedicated lab environment.
