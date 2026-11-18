# Mandatory Assignment — Seminar 04: Text Processing

> **Assessment contract pending.** Consult [the assessment status and author decision](ASSESSMENT_STATUS.md) before treating any weights, penalties or eligibility rules below as adopted. The tools provide diagnostics, not a final grade.

> Operating Systems | ASE Bucharest — CSIE  
> Deadline: One week from seminar  
> Points: 100% (10% of final grade)  
> Submission: `.zip` archive on the e-learning platform

> Retained author account: “last semester three students submitted identical outputs on
> randomly generated data. They all got zero.” This anecdote does not establish a
> current policy or detection rate. ID-seeded datasets can collide and do not
> prevent code sharing, prove authorship or determine a sanction.

---

## Objectives

After completing this assignment, you will demonstrate ability to:
- Write regular expressions (BRE and ERE) for search and validation
- Process text files using grep, sed and awk
- Combine tools into efficient pipelines
- Automate text processing through shell scripts

---

## ⚠️ CRITICAL: Personalised Data Requirement

This assignment uses **personalised test data**. Data are reproducible for an ID and generator version; unique outputs for every possible ID are not guaranteed.

### Step 1: Generate YOUR Data
```bash
# Run from the SEM04 directory:
make generate-data ID=YOUR_MATRICOL

# Example:
make generate-data ID=123456
```

This creates a folder `student_123456/` with synthetic test files, a legacy dataset identifier and a per-file SHA-256 manifest.

### Step 2: Note Your Checksum
The generator outputs something like:
```
✓ Data generated successfully!
  Checksum: a7b3c9f2e1d4
```

The public assignment requests this identifier in README.txt; its assessment
consequence remains pending. `--verify ID CHECKSUM` compares the regenerated
identifier only. To inspect actual data files read-only, use:

```bash
python3 scripts/python/S04_04_personalized_data_generator.py --verify-files 123456 student_123456
```

Matching content/hashes do not authenticate identity or authorship. Regeneration
refuses existing output; use `--output-dir` with a fresh existing parent directory
rather than overwriting evidence.

### Step 3: Work With YOUR Data
All exercises must be completed using files from YOUR `student_MATRICOL/` folder.
The reference `resources/sample_data/` fixtures have a different schema. The historical −50% proposal is not applied while the contradictory assessment contract is unresolved.

---

## General Requirements

1. All solutions must be executable bash scripts (`.sh`)
2. Each script needs a header: name, description, author and date
3. Use `set -euo pipefail` at the start of every script
4. Test your solutions on YOUR personalised data before submission

---

## Exercise 1: Data Validation and Extraction (25%)

### Task
Create `ex1_validator.sh` which processes `contacts.txt`:

1. **(10%, historical weight)** Validate emails — display total found, valid count with list and invalid count with list
2. **(8%)** Extract unique IP addresses, sorted numerically
3. **(7%)** Find Romanian phone numbers (formats: 07XX-XXX-XXX, 07XX.XXX.XXX and 07XXXXXXXX)

### Usage
```bash
./ex1_validator.sh student_123456/contacts.txt
```

### Expected Output Format
```
=== EMAIL VALIDATION ===
Total found: 12
✅ Valid: 9
  - john.doe@gmail.com
  - maria.pop@yahoo.ro
  [...]
❌ Invalid: 3
  - invalid@
  - @missing.com
  [...]

=== UNIQUE IP ADDRESSES ===
8.8.8.8
10.0.0.1
192.168.1.1
[...]

=== RO PHONE NUMBERS ===
0721-123-456
0733.345.678
[...]
```

### Tips
The generated `Contact: ...` record is the full candidate, including invalid
ones; extracting only already-valid substrings loses invalid records. State a
limited email grammar, rather than claiming full RFC validity.

Email regex needs to handle: dots in local part, subdomains and plus-addressing.
IP sorting: `sort -t. -k1,1n -k2,2n -k3,3n -k4,4n` for proper numeric order.

---

## Exercise 2: Log Processing (25%)

### Task
Create `ex2_log_analyzer.sh` which analyses `server.log`:

1. **(8%)** Count messages per severity level (INFO, WARNING, ERROR and DEBUG) with percentages
2. **(9%)** Find failed authentication attempts — extract timestamp, email and source IP
3. **(8%)** Calculate: log time span, total events and error rate percentage

### Usage
```bash
./ex2_log_analyzer.sh student_123456/server.log
```

### Tips
The log format is: `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`
For severity counting, bracket field `$4` is the level and `$2` is the timestamp.
Use the exact `[timestamp] [INFO|WARNING|ERROR|DEBUG] message` schema. The reference
model excludes malformed records from percentages, reports their count and exits
2 for a partial report. Zero valid events makes percentages undefined. This is a
technical reporting denominator, not an assessment weight.
Failed auth patterns include: "Authentication failed", "denied" and "invalid credentials"

---

## Exercise 3: Data Transformation (25%)

### Task
Create `ex3_data_transform.sh` which processes `employees.csv`:

1. **(10%)** Display as formatted table with aligned columns, salaries showing `$XX,XXX`
2. **(8%)** Statistics per department: count, average/min/max salary
3. **(7%)** Create `employees_updated.csv` with: lowercase emails, "inactive"→"on_leave" and added `years_employed` column

### Usage
```bash
./ex3_data_transform.sh student_123456/employees.csv
```

### Tips
The personalised schema is `ID,Name,Department,Salary,Email,HireDate,Status`, so
department is `$3`, salary `$4` and email `$5`. The committed test fixture has a
different order; validate the header before using positional fields. Simple AWK
models accept unquoted records only, with numeric salaries.

Currency formatting in awk: `printf "$%'d", salary` (locale-dependent) or manual formatting.
Year calculation in the reference uses current UTC year minus hire year, an explicit calendar-year approximation. Completed-anniversary tenure would require month/day comparison and must be specified separately.

---

## Exercise 4: Combined Pipeline (25%)

### Task
Create `ex4_sales_report.sh` which processes `sales.csv`:

1. **(10%)** Report showing: top 3 products by revenue, top 3 regions and best salesperson per region
2. **(8%)** Detect anomalies: date gaps and unusually high quantities (>mean + 2σ)
3. **(7%)** Export formatted results to `sales_summary.txt`

### Usage
```bash
./ex4_sales_report.sh student_123456/sales.csv
```

### Tips
Revenue = quantity × unit_price. 
The model uses population standard deviation over the supplied quantities. Zero transactions makes its mean/threshold undefined; no anomaly conclusion is asserted. The top-three report uses revenue descending with lexical tie order, and all maximum salesperson ties are shown.
Date gaps: sort dates, check if consecutive differ by more than 1 day.

---

## Submission Structure

```
FirstnameLastname_Group_HW4/
├── README.txt                 # REQUIRED — see below
├── ex1_validator.sh
├── ex2_log_analyzer.sh
├── ex3_data_transform.sh
├── ex4_sales_report.sh
└── output/
    ├── ex1_output.txt
    ├── ex2_output.txt
    ├── ex3_output.txt
    ├── employees_updated.csv
    └── sales_summary.txt
```

### README.txt MUST Contain:
```
Name: [Your Full Name]
Group: [Your Group]
Matricol: [Your Number]
Data Checksum: [checksum from generator]
Time Spent: [X hours]

AI Declaration: [Describe any AI tool usage, or "None"]

Notes: [Optional implementation notes]
```

**Missing or invalid checksum = −20%**

---

## Evaluation Criteria

| Criterion | Weight | Notes |
|-----------|--------|-------|
| Correctness | 40% | Scripts produce correct output on YOUR data |
| Code Quality | 20% | Comments, clear names and proper structure |
| Error Handling | 15% | Argument validation and file existence checks |
| Efficiency | 15% | Appropriate tool choices, no unnecessary complexity |
| Output Format | 10% | Professional and readable output |

---

## Retained Anti-Plagiarism Policy Proposal — Pending Author Decision

The rules below are historical wording. No automatic sanction, identity finding
or misconduct conclusion is adopted by this revision. Oral responses, code
similarity, fingerprints and metadata need contextual evidence and an approved
assessment process.

- **Copied code = 0% for ALL involved** (no exceptions)
- Discussion of approaches is fine; sharing code is not
- **Oral verification:** You may be asked to explain your code during lab
- If you cannot explain a line you wrote, we investigate further

### AI Usage Policy
Using AI assistants (ChatGPT, Claude or Copilot) is permitted IF:
1. You declare it in README.txt (what tool, what prompts and what output)
2. You can explain every line during oral verification
3. The code actually works on YOUR personalised data

*Students who copy AI output without understanding it tend to fail the oral check.
The smart approach: use AI to learn, not to avoid learning.*

---

## Resources

1. Man pages: `man grep`, `man sed`, `man awk`
2. Your personalised data: `student_YOUR_MATRICOL/`
3. Cheat sheet: `docs/S04_09_VISUAL_CHEAT_SHEET.md`
4. Live coding guide: `docs/S04_05_LIVE_CODING_GUIDE.md`
5. Oral verification questions: `homework/S04_05_ORAL_VERIFICATION.md` (instructor copy)

---

## FAQ

**Q: Can I use Python?**
A: No. The point is learning Unix text processing tools. Python defeats the purpose.

**Q: My regex works on regex101.com but not in grep?**
A: Check BRE vs ERE. Use `grep -E` for extended regex. Also verify escaping differences.

**Q: Windows?**
A: Use WSL2 or the lab VM. Native Windows will not work.

**Q: Bonus points?**
A: Up to +10% for genuinely useful extensions (not just fancy output colours).

**Q: What if my checksum does not match?**
A: Compare the same ID and generator version in a fresh output parent. The legacy identifier is deterministic for the five generated contents; answer-file generated_at is runtime metadata. Use --verify-files to compare actual submitted source data.

---

*Operating Systems — ASE Bucharest CSIE*  
*Updated: January 2025 with anti-plagiarism infrastructure*
