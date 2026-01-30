# Mandatory Assignment — Seminar 04: Text Processing

> Operating Systems | ASE Bucharest — CSIE  
> Deadline: One week from seminar  
> Points: 100% (10% of final grade)  
> Submission: `.zip` archive on the e-learning platform

*Fair warning: last semester three students submitted identical outputs on 'randomly generated' data. They all got zero. This semester, your data is unique to your matricol number. Sharing solutions will not work anymore.*

---

## Objectives

After completing this assignment, you will demonstrate ability to:
- Write regular expressions (BRE and ERE) for search and validation
- Process text files using grep, sed and awk
- Combine tools into efficient pipelines
- Automate text processing through shell scripts

---

## ⚠️ CRITICAL: Personalised Data Requirement

This assignment uses **personalised test data**. Each student works with unique files.

### Step 1: Generate YOUR Data
```bash
# Run from the SEM04 directory:
make generate-data ID=YOUR_MATRICOL

# Example:
make generate-data ID=123456
```

This creates a folder `student_123456/` with your unique test files and a **checksum**.

### Step 2: Note Your Checksum
The generator outputs something like:
```
✓ Data generated successfully!
  Checksum: a7b3c9f2e1d4
```

**You MUST include this checksum in your submission.** We verify it.

### Step 3: Work With YOUR Data
All exercises must be completed using files from YOUR `student_MATRICOL/` folder.
Using the generic `resources/sample_data/` files will result in **−50% penalty**.

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

1. **(10%)** Validate emails — display total found, valid count with list and invalid count with list
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
0733 345 678
[...]
```

### Tips
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
For severity counting: `awk -F'[][]' '{count[$2]++}'` extracts the bracketed level.
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
Currency formatting in awk: `printf "$%'d", salary` (locale-dependent) or manual formatting.
Year calculation: `$(date +%Y)` gives current year; parse hire_date and subtract.

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
Standard deviation in awk requires two passes or running sums of x and x².
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

## Anti-Plagiarism Policy

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
A: Regenerate data with the same matricol. Checksums are deterministic.

---

*Operating Systems — ASE Bucharest CSIE*  
*Updated: January 2025 with anti-plagiarism infrastructure*
