# Submission Template - Seminar 4 Assignment

## Archive Structure

Create a ZIP archive named: `SurnameName_Group_Assignment4.zip`

```
SurnameName_Group_Assignment4/
│
├── ex1_validator.sh          # Mandatory
├── ex2_log_analyzer.sh       # Mandatory
├── ex3_data_transform.sh     # Mandatory
├── ex4_sales_report.sh       # Mandatory
│
├── output/                   # Folder with generated results
│   ├── ex1_output.txt
│   ├── ex2_output.txt
│   ├── ex3_output.txt
│   ├── employees_updated.csv
│   └── sales_summary.txt
│
└── README.txt               # Optional - implementation notes
```

---

## Checklist Before Submission

### Scripts
- [ ] All 4 scripts are present
- [ ] Scripts have `.sh` extension
- [ ] Scripts are executable (`chmod +x *.sh`)
- [ ] Scripts have header with name, description, author
- [ ] Scripts use `set -euo pipefail`

### Functionality
- [ ] Ex1 runs correctly on `contacts.txt`
- [ ] Ex2 runs correctly on `server.log`
- [ ] Ex3 runs correctly on `employees.csv`
- [ ] Ex4 runs correctly on `sales.csv`

### Output

Key aspects: [ ] `output/` folder contains all generated files, [ ] outputs are professionally formatted and [ ] there are no errors in console.


### Quality
- [ ] Code commented and organised
- [ ] Variables with descriptive names
- [ ] Error handling for missing arguments
- [ ] Clear error messages

---

## README.txt Template

Copy and complete in README.txt (optional):

```
=== SEMINAR 07-08 ASSIGNMENT ===
Name: [Surname Name]
Group: [Group]
Date: [Date]

=== COMPLETED EXERCISES ===
[x] Ex1 - Data Validation and Extraction
[x] Ex2 - Log Processing
[x] Ex3 - Data Transformation
[x] Ex4 - Combined Pipeline

=== IMPLEMENTATION NOTES ===
Ex1: [Brief description of your approach]
Ex2: [Brief description of your approach]
Ex3: [Brief description of your approach]
Ex4: [Brief description of your approach]

=== DIFFICULTIES ENCOUNTERED ===
[Describe what problems you had and how you solved them]

=== AI USAGE ===
[If you used AI (ChatGPT, Claude, etc.), specify:

- What you generated with AI
- What you modified manually
- What you understood and can explain]


=== TIME SPENT ===
Approximately: [X] hours
```

---

## Common Mistakes to Avoid

### Do Not
- Do not submit files with `.txt` extension instead of `.sh`
- Do not forget to make scripts executable
- Do not copy code without understanding what it does
- Do not ignore errors - handle them

### Do
- Test on files from `resources/sample_data/`
- Use `shellcheck` for syntax validation
- Verify on Linux (not just Windows)
- Comment important sections

---

## Useful Commands

```bash
# Check bash syntax (install: apt install shellcheck)
shellcheck ex1_validator.sh

# Make all scripts executable
chmod +x *.sh

# Create ZIP archive
zip -r SurnameName_Group_Assignment4.zip SurnameName_Group_Assignment4/

# Test a script
./ex1_validator.sh ../resources/sample_data/contacts.txt

# Check archive size
ls -lh SurnameName_Group_Assignment4.zip
```

---

## Submission

1. Verify that the archive extracts correctly
2. Upload to the e-learning platform
3. Verify that the upload succeeded
4. Keep a local copy

**Deadline**: [See assignment for exact date]

---

