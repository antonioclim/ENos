# Seminar 2 Assignment: Pipeline Master

> **Assessment contract pending.** Consult [the assessment status and author decision](ASSESSMENT_STATUS.md) before treating any weights, penalties or eligibility rules below as adopted. The tools provide diagnostics, not a final grade.
## Operating Systems | ASE Bucharest - CSIE

Document: S02_01_ASSIGNMENT.md  
Deadline: [To be completed by instructor]  
Maximum score: 100% + 20 bonus

---

## Objectives

At the end of this assignment, you will demonstrate that you can:
- Combine commands with control operators (`;`, `&&`, `||`, `&`) and redirect I/O correctly
- Build efficient pipelines for data processing
- Write functional loops for automation
- Evaluate and improve existing code

---

## Technical Requirements

- System: Ubuntu 22.04+ / WSL2 / macOS with Bash 4.0+ and nano/pico editor
- Mandatory testing: All scripts must be functional before submission

---

## Assignment Structure

```
assignment_FirstnameLastname_Group/
├── README.md                    # Completed with your details
├── REFLECTION.md                # Mandatory reflections
├── part1_operators/
│   ├── ex1_backup_safe.sh
│   ├── ex2_multi_command.sh
│   └── ex3_parallel_demo.sh
├── part2_redirection/
│   ├── ex1_log_separator.sh
│   ├── ex2_config_generator.sh
│   └── ex3_silent_runner.sh
├── part3_filters/
│   ├── ex1_top_words.sh
│   ├── ex2_csv_analyzer.sh
│   ├── ex3_log_stats.sh
│   └── ex4_frequency_counter.sh
├── part4_loops/
│   ├── ex1_batch_rename.sh
│   ├── ex2_file_processor.sh
│   ├── ex3_countdown.sh
│   └── ex4_menu_system.sh
├── part5_project/
│   └── system_report.sh
├── part6_verification/
│   ├── proof_of_understanding.sh
│   └── local_proof.txt
└── bonus/
    └── [optional bonus exercises]
```

---

## PART 1: Control Operators (18%)

### Exercise 1.1: Backup Safe (6%)

File: `part1_operators/ex1_backup_safe.sh`

Write a script that:
1. Receives a file as argument (`$1`)
2. Checks if the file exists
3. Creates the `backup/` directory if it does not exist
4. Copies the file to `backup/` with timestamp in name
5. Displays success OR error message

Requirements:
- Use `&&` and `||` (NOT if statements) in a single line of code for the main logic
- Handle the case when no argument is given (explicit error)

Example:
```bash
./ex1_backup_safe.sh important.txt
# Success output: "✓ Backup created: backup/important_20250119_143022.txt"
# Error output: "✗ File important.txt does not exist!"
```

Verification:
```bash
echo "test" > test.txt
./ex1_backup_safe.sh test.txt  # Should create backup
./ex1_backup_safe.sh nonexistent.txt  # Should display error
```

### Exercise 1.2: Multi-Command (6%)

File: `part1_operators/ex2_multi_command.sh`

Write a one-liner that:
1. Creates the `project/` directory
2. Enters it
3. Creates the files: `README.md`, `main.sh`, `.gitignore`
4. Makes `main.sh` executable
5. Displays the structure with `ls -la`
6. All ONLY if previous steps succeed

Requirements:
- Single line using `&&`
- If any step fails, subsequent steps must NOT execute

### Exercise 1.3: Parallel Demo (6%)

File: `part1_operators/ex3_parallel_demo.sh`

Write a script that demonstrates background execution:
1. Starts 3 `sleep` commands with different durations (3s, 2s, 1s) in background
2. Displays the PIDs of all background jobs
3. Waits for all to complete
4. Displays "All jobs completed" with total elapsed time

---

## PART 2: I/O Redirection (18%)

### Exercise 2.1: Log Separator (6%)

File: `part2_redirection/ex1_log_separator.sh`

Write a script that:
1. Receives a log file as argument
2. Separates lines containing "ERROR" into `errors.log`
3. Separates lines containing "WARNING" into `warnings.log`
4. Puts remaining lines into `info.log`
5. Displays statistics: how many lines in each file

### Exercise 2.2: Config Generator (6%)

File: `part2_redirection/ex2_config_generator.sh`

Write a script that uses Here Document to generate a configuration file:
1. Asks for: hostname, port, username
2. Generates `app.conf` with interpolated values
3. Generates `app.conf.template` with literal `$VARIABLE` (without expansion)

### Exercise 2.3: Silent Runner (6%)

File: `part2_redirection/ex3_silent_runner.sh`

Write a script that:
1. Receives a command as argument
2. Executes it with stdout AND stderr redirected to `/dev/null`
3. Displays ONLY exit code: "Exit code: X"
4. Returns the same exit code

---

## PART 3: Text Filters (22%)

### Exercise 3.1: Top Words (5%)

File: `part3_filters/ex1_top_words.sh`

Write a script that displays the top 10 most frequent words from a text file.

Requirements:
- Convert to lowercase
- Remove punctuation
- Sort by frequency (descending)
- Format: "COUNT WORD"

### Exercise 3.2: CSV Analyser (6%)

File: `part3_filters/ex2_csv_analyzer.sh`

For this beginner exercise, input is a simple unquoted comma-separated table with one header row, no embedded comma, quote or newline in a field. General quoted CSV requires a CSV parser. Write a script that analyses this input:
1. Displays the number of rows (excluding header)
2. Displays the number of columns
3. Displays column names
4. If column name is given as argument, displays unique values from that column

### Exercise 3.3: Log Statistics (6%)

File: `part3_filters/ex3_log_stats.sh`

Use the exact synthetic eight-field log format from sprint F3: IP, two placeholders, one bracketed timestamp without timezone, quoted method/path without HTTP version, status and bytes. Path is field 6, status 7 and bytes 8. Other server formats need a declared adapter. Write a script that analyses this input:
1. Top 5 IP addresses by number of requests
2. Top 5 most accessed pages
3. Distribution of HTTP codes (2xx, 3xx, 4xx, 5xx)

### Exercise 3.4: Frequency Counter (5%)

File: `part3_filters/ex4_frequency_counter.sh`

Write a script that receives a column number and a CSV file, displaying the frequency of values in that column, sorted descending.

---

## PART 4: Loops (22%)

### Exercise 4.1: Batch Rename (5%)

File: `part4_loops/ex1_batch_rename.sh`

Write a script that renames all `.txt` files in a directory by adding a prefix:
```bash
./ex1_batch_rename.sh documents/ "2025_"
# file.txt → 2025_file.txt
```

Requirements:
- Verify the directory exists
- Display each renaming operation
- Count how many files were renamed

### Exercise 4.2: File Processor (6%)

File: `part4_loops/ex2_file_processor.sh`

Write a script that processes all files in a directory:
1. For each `.sh` file: check if it is executable, make it executable if not
2. For each `.txt` file: count lines and words
3. For each `.log` file: display last 5 lines
4. Display summary at the end

### Exercise 4.3: Countdown (5%)

File: `part4_loops/ex3_countdown.sh`

Write a script that:
1. Receives a number N as argument
2. Counts down from N to 0 with 1 second pause
3. Displays "Liftoff!" at 0
4. Allows interruption with Ctrl+C (displays "Countdown aborted at X")

### Exercise 4.4: Menu System (6%)

File: `part4_loops/ex4_menu_system.sh`

Write an interactive menu:
```
=== FILE MANAGER ===
1) List files
2) Create directory
3) Delete file
4) Show disk space
5) Exit

Choose option:
```

Requirements:
- Loop until user chooses Exit
- Validate input (display error for invalid option)
- Confirm before delete

---

## PART 5: Integration Project (10%)

File: `part5_project/system_report.sh`

Write a complete script that generates a system report.

**Arguments**: Optional output file (default: `report_YYYYMMDD_HHMMSS.txt`)

**Sections**:
1. Header: Date, hostname, user, uptime
2. **CPU**: Model, number of cores, load average
3. Memory: Total, used, free (human-readable format)
4. Disk: Space used on main partitions
5. Top Processes: Top 5 by CPU and top 5 by memory
6. Network: Configured IPs
7. Footer: Generation timestamp

Requirements:
- If no argument given, save to `report_YYYYMMDD_HHMMSS.txt`
- Nice formatting with lines and clear sections
- Use ALL learned techniques: operators, redirection, filters, loops
- Robust script (handle errors)

---

## PART 6: Comprehension Verification (5%)

**This section verifies that you understand the code you have submitted.**

### Exercise 6.1: Local Proof Script (3%)

File: `part6_verification/proof_of_understanding.sh`

Create a **task-specific reproducibility record** in `part6_verification/local_proof.txt`. It records source hashes, Bash version and syntax-check outcomes. It is self-generated evidence: it does not prove who wrote the code, where it was written, that it runs correctly or that an assessment has been passed. Do not collect shell history, MAC address, hostname, username or files outside the assignment for this record.

```bash
#!/bin/bash
# proof_of_understanding.sh — syntax and source manifest only
set -euo pipefail
VERIFY_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
ASSIGNMENT_ROOT=$(cd -- "$VERIFY_DIR/.." && pwd -P)
[[ ${VERIFY_DIR##*/} == part6_verification ]] || { printf 'Place this script in part6_verification\n' >&2; exit 1; }
cd -- "$ASSIGNMENT_ROOT"
REPORT_TMP=$(mktemp "$VERIFY_DIR/local_proof.XXXXXX.tmp")
FILE_LIST=$(mktemp "$VERIFY_DIR/source_list.XXXXXX.tmp")
trap 'rm -f -- "$REPORT_TMP" "$FILE_LIST"' EXIT
# find does not follow directory symlinks; only regular assignment .sh files.
find . -type f -name '*.sh' -print0 > "$FILE_LIST"
{
    printf '=== ASSIGNMENT REPRODUCIBILITY RECORD ===\n'
    printf 'Generated UTC: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf 'Bash version: %s\n' "$BASH_VERSION"
    printf 'Scope: assignment .sh source files; syntax only; no student code executed\n'
    while IFS= read -r -d '' script; do
        printf '\nFile: %q\n' "$script"
        sha256sum -- "$script"
        if bash -n -- "$script"; then
            printf 'Syntax: PASS\n'
        else
            printf 'Syntax: FAIL\n'
        fi
    done < "$FILE_LIST"
} > "$REPORT_TMP" 2>&1
mv -- "$REPORT_TMP" "$VERIFY_DIR/local_proof.txt"
printf 'Record generated: part6_verification/local_proof.txt\n'
```

**Requirements:** Run the script from any directory after placing it at the specified path. Review the generated record and include it at `part6_verification/local_proof.txt`. Hashes identify bytes but do not authenticate authorship. The oral discussion below evaluates comprehension. Its weighting, institutional acceptance and any broader evidence/privacy requirements remain pending in `ASSESSMENT_STATUS.md`; no new identity protocol is adopted here.

### Exercise 6.2: Oral Explanation (2%)

**At submission or during laboratory, you will be asked to explain ONE of the following concepts from your code. Be prepared to answer WITHOUT looking at notes.**

Possible questions (instructor will choose one randomly):

1. "In your `ex1_backup_safe.sh`, explain WHY the order of `&&` and `||` matters. What would happen if you reversed them?"

2. "In your `ex2_config_generator.sh`, what is the difference between `<< EOF` and `<< 'EOF'`? Show me in your code where you used each and why."

3. "In your `ex3_log_stats.sh`, why do you need `sort` before `uniq -c`? What would happen without it?"

4. "In your `ex4_menu_system.sh`, explain the subshell trap with `while read`. Did you encounter it? How did you solve it?"

5. "In your `system_report.sh`, show me how you handled the case when a command fails. What happens to your report?"

**Grading**:
- Clear, correct explanation: 2%
- Partial understanding: 1%
- Cannot explain own code: 0% (and triggers review of entire submission)

---

## BONUS (up to 20% extra)

### Bonus A: Pipeline Optimiser (10%)

Write a script that receives a pipeline and suggests optimisations:
```bash
./pipeline_optimizer.sh "cat file | grep pattern | sort | uniq"
# Output: "Suggestion: Replace 'cat file | grep' with 'grep pattern file'"
```

### Bonus B: Live Log Monitor (10%)

Write a script that monitors a log file in real time and:

- Highlights lines with "error" in red
- Highlights lines with "warning" in yellow
- Counts and displays statistics every 10 new lines


---

## REFLECTION (Mandatory)

Complete the file `REFLECTION.md` with:

### 1. What I learned
> Describe 3 new concepts you understood in depth.

### 2. What difficulties I encountered
> Describe at least one problem and how you solved it.

### 3. How I used AI (if applicable)
> If you used ChatGPT/Claude/Gemini:
> - What prompts did you use?
> - Did the generated code work directly or did you make modifications?
> - What did you learn from the process of evaluating AI code?

### 4. What I would do differently
> If you were to redo the assignment, what would you approach differently?

---

## Evaluation Criteria

| Component | Score | Criteria |
|-----------|-------|----------|
| Part 1: Operators | 18% | Functionality, correct use of operators |
| Part 2: Redirection | 18% | Correct redirection, here documents |
| Part 3: Filters | 22% | Efficient pipelines, correct output |
| Part 4: Loops | 22% | Functional loops, error handling |
| Part 5: Project | 10% | Integration, formatting, stability |
| Part 6: Verification | 5% | Proof script + oral explanation |
| REFLECTION.md | 5% | Thoughtful reflection |
| TOTAL | 100% | |
| Bonus A | +10p | Functionality, suggestion accuracy |
| Bonus B | +10p | Live monitoring, colouring |
| MAXIMUM | 120% | |

### Deductions

- Scripts that are not executable: -5p per script
- Missing shebang (`#!/bin/bash`): -2p per script
- Syntax errors that prevent execution: -10p per script
- Incomplete or missing REFLECTION.md: -15p
- Incorrect directory structure: -10p
- Missing Part 6 verification: -5p
- Cannot explain own code in oral check: Review entire submission

---

## Submission

### Format

- Zip archive: `assignment_firstnamelastname_group.zip`
- Exact structure as above
- All scripts with executable permissions
- `local_proof.txt` generated and included


### Deadline
- [To be completed by instructor]
- -10% per day late

### Where
- [Upload platform - to be completed]

---

## Help

1. Technical questions: Course Forum/Discord
2. Materials: Consult `S02_02_MAIN_MATERIAL.md` and `S02_09_VISUAL_CHEAT_SHEET.md`
3. Testing: Use `./scripts/bash/S02_03_validator.sh your_assignment/` for verification

---

*Assignment for Seminar 3-4 SO | ASE Bucharest - CSIE*
