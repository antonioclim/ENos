# Model Solutions - Seminar 4

> **⚠️ CONFIDENTIAL DOCUMENT - INSTRUCTORS ONLY**

---

## Contents

| File | Exercise | Description |
|------|----------|-------------|
| `ex1_validator.sh` | Ex1 (25 pts) | Email, IP, phone validation |
| `ex2_log_analyzer.sh` | Ex2 (25 pts) | Log analysis, severity, auth |
| `ex3_data_transform.sh` | Ex3 (25 pts) | CSV transformation, dept statistics |
| `ex4_sales_report.sh` | Ex4 (25 pts) | Sales report, anomalies |

---

## Testing Solutions

```bash
# From the solutions/ directory
cd homework/solutions

# Make scripts executable
chmod +x *.sh

# Test each exercise
./ex1_validator.sh ../../resources/sample_data/contacts.txt
./ex2_log_analyzer.sh ../../resources/sample_data/server.log
./ex3_data_transform.sh ../../resources/sample_data/employees.csv
./ex4_sales_report.sh ../../resources/sample_data/sales.csv
```

---

## Assessment Notes

### Exercise 1
- **Email Regex**: Simple pattern acceptable, bonus for strict validation
- **IP Validation**: Pattern `[0-9.]+` sufficient, bonus for 0-255 validation
- **Phone**: Must accept at least 2 different formats
- Always verify the result before proceeding

### Exercise 2
- **Severity**: AWK with associative arrays is the optimal solution
- **Auth Failed**: Grep + extraction is acceptable, AWK is bonus
- **Statistics**: Timestamp parsing can be approximate
- Always verify the result before proceeding

### Exercise 3
- **Table**: `printf` with width is sufficient, box chars is bonus
- **Statistics**: Values must be mathematically correct
- **Update CSV**: All 3 modifications required

### Exercise 4
- **Top N**: Sort + head is acceptable, AWK is elegant
- **Anomalies**: Fixed threshold is OK, stddev is bonus
- **Export**: File created with correct content
- Test first with simple data

---

## Anti-Plagiarism Comparison

Check the following elements between submissions:

1. **Identical structure**: Same function order, same variables
2. **Similar comments**: Obvious copy-paste
3. **Identical errors**: Same bugs in different places
4. **Formatting**: Spaces, indentation, identical style

**Recommended tools:**
```bash
# Simple diff
diff -y student1.sh student2.sh | head -50

# Similarity check
diff <(cat student1.sh | grep -v '^#' | grep -v '^$') \
     <(cat student2.sh | grep -v '^#' | grep -v '^$')
```

---

## Key Points to Evaluate

1. **Works correctly on test data?**
2. **Handles edge cases?** (empty file, invalid input)
3. **Code organised and commented?**
4. **Uses appropriate tools?** (does not reinvent the wheel)
5. **Professional output?** (formatting, colours, structure)

---

*Official solutions - Seminar 4: Text Processing*
