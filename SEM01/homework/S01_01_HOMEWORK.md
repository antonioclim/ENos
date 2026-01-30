# Assignment Seminar 1: Shell Basics
## Operating Systems | ASE Bucharest - CSIE

**Deadline:** See course platform  
**Submission format:** `SurnameName_Seminar1.zip`  
**Maximum grade without oral verification:** 5 (50%)

---

## Overview

In this assignment you will demonstrate your understanding of:
- Linux file system navigation
- Bash shell variables and environment
- Shell configuration with .bashrc
- File globbing patterns

---

## Requirements

### 1. Directory Structure (20%)

Create the following structure in your submission:

```
project/
├── src/
│   ├── main.sh
│   ├── variables.sh
│   └── system_info.sh
├── docs/
│   └── README.md
└── tests/
    └── test_globbing.sh
```

**Requirements:**
- Use `mkdir -p` with brace expansion to create the structure
- Include a command in main.sh that recreates this structure

---

### 2. Variables Script: `variables.sh` (25%)

Create a script that demonstrates:

1. **Local variables** (10%)
   - Define at least 3 variables with different types (string, number, path)
   - Display them using echo with proper formatting

2. **Environment variables** (8%)
   - Display USER, HOME, SHELL and PATH
   - Include explanatory comments for each

3. **Export demonstration** (7%)
   - Show the difference between local and exported variables
   - Use `bash -c` to demonstrate visibility in subshell

**Example output:**
```
=== Local Variables ===
PROJECT_NAME: My Shell Project
VERSION: 1.0
AUTHOR: Your Name

=== Environment Variables ===
USER: student
HOME: /home/student
...

=== Export Demonstration ===
Local variable in subshell: (empty)
Exported variable in subshell: visible
```

---

### 3. System Info Script: `system_info.sh` (10%)

Create a script that displays:
- Current user
- Home directory
- Current date and time
- System uptime
- Current working directory

Format the output pleasantly with headers and separators.

---

### 4. Globbing Test: `test_globbing.sh` (20%)

Create a script that:

1. Creates test files with brace expansion:
   - `file{1..5}.txt`
   - `document{A,B,C}.pdf`
   - `.hidden_config`

2. Demonstrates these patterns:
   - `*.txt` - all text files
   - `file?.txt` - single character wildcard
   - `*[0-9]*` - files containing numbers
   - `.[!.]*` - hidden files (not . or ..)

3. Shows the difference between `ls *` and `ls .*`

Include comments explaining what each pattern matches.

---

### 5. Shell Configuration: `.bashrc` (25%)

Create a `.bashrc` file that includes:

**Required aliases:**
- `ll` - detailed listing (`ls -la`)
- `cls` - clear screen
- `..` - go up one directory

**Required function:**
```bash
mkcd() {
    # Create directory and change into it
    # Your implementation here
}
```

**PATH modification:**
- Add `$HOME/bin` to PATH

**Optional (bonus):**
- `extract` function for multiple archive types
- Custom prompt (PS1)
- HISTSIZE configuration

---

## Submission Checklist

```
[ ] Archive named correctly: SurnameName_Seminar1.zip
[ ] AUTHOR.txt with your details (name, group, date)
[ ] All scripts have shebang (#!/bin/bash)
[ ] All scripts are executable (chmod +x)
[ ] All scripts run without syntax errors
[ ] README.md explains how to run each script
[ ] No hardcoded paths specific to your machine
```

---

## Evaluation

| Section | Percentage |
|---------|------------|
| Directory structure | 20% |
| Variables script | 25% |
| System info script | 10% |
| Globbing test | 20% |
| .bashrc configuration | 25% |
| **Oral verification** | **Mandatory** |

**Note:** Oral verification is mandatory. Without it, maximum grade is 5.

---

## Oral Verification

You will be asked 2 questions about your code:
- Explain what a specific line does
- Modify something live
- Predict what happens if we change X

Prepare by:
- Understanding every line you wrote
- Being able to explain your design choices
- Knowing common Bash pitfalls (spaces in assignments, quoting)

---

## Tips

1. Test everything in a clean environment
2. Use `bash -n script.sh` to check syntax
3. Read error messages carefully
4. Use `shellcheck` for best practices
5. Comment your code for the oral verification

---

## Resources

- Seminar materials in `docs/`
- `man bash` for Bash manual
- ShellCheck: https://www.shellcheck.net/

---

*Assignment v2.0 | Seminar 1 | Operating Systems | ASE-CSIE*
