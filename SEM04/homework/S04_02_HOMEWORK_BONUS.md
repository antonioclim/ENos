# Bonus Assignment - Seminar 4: Advanced Text Processing

> **Operating Systems** | ASE Bucharest - CSIE  
> **Deadline**: Two weeks from seminar  
> **Points**: Up to 20% bonus  
> **Submission**: `.zip` archive separate from mandatory assignment

---

## Description

This assignment is **optional** and offers bonus points for students who want to deepen their text processing skills. The exercises are more complex and require creative combination of multiple techniques.

**Note**: You can solve any of the exercises, in any order. Points are cumulative.

---

## Exercise B1: Multi-Format Log Aggregator (8%)

### Requirement
Create `bonus1_log_aggregator.sh` which processes logs in **different formats** and unifies them.

The programme must:
1. Automatically detect the format of each log file (Apache, Nginx, Syslog, JSON)
2. Extract common information: timestamp, level, message, source IP (if present)
3. Unify everything into a standard CSV format
4. Generate comparative statistics between sources

### Formats to Recognise

**Apache Combined Log:**
```
192.168.1.1 - - [15/Jan/2024:08:23:45 +0000] "GET /page HTTP/1.1" 200 1234
```

**Nginx Error Log:**
```
2024/01/15 08:23:45 [error] 1234#0: *5678 message here
```

**Syslog:**
```
Jan 15 08:23:45 hostname process[1234]: message here
```

**JSON (one object per line):**
```json
{"timestamp":"2024-01-15T08:23:45Z","level":"INFO","message":"text","ip":"10.0.0.1"}
```

### Usage
```bash
./bonus1_log_aggregator.sh access.log error.log syslog.log app.json -o unified.csv
```

### Evaluation Criteria
- Correct format detection: 2%
- Correct data extraction: 3%
- Valid CSV output: 2%
- Statistics: 1%

---

## Exercise B2: Diff and Patch with Regex (6%)

### Requirement
Create `bonus2_smart_diff.sh` which compares two files and identifies differences **semantically**, not just textually.

The programme must:
1. Ignore whitespace differences (spaces, tabs, blank lines)
2. Ignore casing differences in configured keywords
3. Ignore comments (lines starting with `#`, `//`, `--`)
4. Report only "real" content differences

### Usage
```bash
./bonus2_smart_diff.sh config_v1.ini config_v2.ini --ignore-comments --ignore-case-keywords
```

### Expected Output
```
=== SMART DIFF REPORT ===
File 1: config_v1.ini (45 lines, 12 comments)
File 2: config_v2.ini (48 lines, 15 comments)

Significant differences found: 3

[Line 12 vs 14]
- host = 192.168.1.100
+ host = 192.168.1.200

[Line 25 vs 28]
- timeout = 30
+ timeout = 60

[Only in v2, line 45]
+ new_feature = enabled
```

### Evaluation Criteria
- Whitespace ignoring: 1.5 pts
- Comment ignoring: 1.5 pts
- Semantic comparison: 2%
- Clear output: 1%

---

## Exercise B3: HTML Report Generator (6%)

### Requirement
Create `bonus3_html_report.sh` which transforms CSV data into interactive HTML reports.

The programme must:
1. Parse any CSV file (automatic detection of separator and header)
2. Generate an HTML page with a sortable table
3. Add simple charts (ASCII bars or inline SVG)
4. Include CSS for professional styling

### Usage
```bash
./bonus3_html_report.sh employees.csv -o report.html --chart salary --group-by department
```

### HTML Output must contain
- Table with all data, sortable by clicking on header
- Chart with salaries per department
- Summary statistics (total, averages, min/max)
- Responsive design (works on mobile)

### Evaluation Criteria
- Correct CSV parsing: 1.5 pts
- Valid HTML table: 1.5 pts
- Charts: 2%
- CSS styling: 1%

---

## Exercise B4: Mini Grep with Highlighting (5%)

### Requirement
Reimplement grep from scratch using **only bash built-ins and sed**.

`bonus4_mygrep.sh` must support:
- Pattern matching with basic regular expressions
- Options: `-i` (case insensitive), `-n` (line numbers), `-c` (count), `-v` (invert)
- Colouring (highlighting) of matches in output

### Usage
```bash
./bonus4_mygrep.sh -in "error|warning" server.log
```

### Restrictions
- You are NOT allowed to use `grep`, `awk`, or `perl`
- Only: `bash`, `sed`, `read`, `echo`, `printf`, variables, loops

### Evaluation Criteria
- Functional pattern matching: 2%
- Options implemented: 2%
- Highlighting: 1%

---

## Exercise B5: Config File Linter (5%)

### Requirement
Create `bonus5_config_linter.sh` which validates configuration files and reports problems.

Checks to implement:
1. **Syntax**: Sections `[name]` correctly closed, `key = value` valid format
2. **Values**: Ports in valid range (1-65535), valid IPs, existing paths
3. **Security**: Detects passwords in plain text, permissions too permissive
4. **Best practices**: Duplicate keys, empty sections, hardcoded values

### Usage
```bash
./bonus5_config_linter.sh config.ini --strict
```

### Expected Output
```
╔══════════════════════════════════════════════════════════════╗
║              CONFIG LINTER - config.ini                       ║
╚══════════════════════════════════════════════════════════════╝

✅ PASSED: Valid syntax
✅ PASSED: All sections have content

⚠️ WARNING [line 15]: Plain text password detected
   password = secret123
   → Recommendation: Use environment variables

⚠️ WARNING [line 22]: Non-standard port
   port = 99999
   → Must be between 1-65535

❌ ERROR [line 30]: Invalid IP
   host = 999.999.999.999

📊 SUMMARY: 0 critical errors, 2 warnings, 1 error
```

### Evaluation Criteria
- Syntax validation: 1.5 pts
- Value validation: 1.5 pts
- Security problem detection: 1.5 pts
- Professional output: 0.5 pts

---

## Submission Structure

```
FirstNameLastName_Group_Bonus4/
├── bonus1_log_aggregator.sh    (if solved)
├── bonus2_smart_diff.sh        (if solved)
├── bonus3_html_report.sh       (if solved)
├── bonus4_mygrep.sh            (if solved)
├── bonus5_config_linter.sh     (if solved)
├── test_files/                 # Files used for testing
│   └── ...
├── output/                     # Generated outputs
│   └── ...
└── SOLUTIONS.md                # Explanations for each solved exercise
```

---

## Tips

1. **Choose strategically**: You do not have to solve all - choose what interests you
2. **Document**: Well-commented code receives higher marks
3. **Test**: Include edge cases in testing
4. **Be creative**: Elegant solutions receive additional bonus

---

## Special Bonus Rules

- Bonus points are added **on top of** the mandatory assignment grade
- Maximum 20% bonus (even if you solve everything)
- Code must be **original** - strict anti-plagiarism checking
- If you use AI, declare and explain - otherwise penalty

---

*Material for the Operating Systems course | ASE Bucharest - CSIE*
