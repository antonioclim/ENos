# Assignments - Seminar 4: Text Processing (grep/sed/awk)

> **⚠️ SPECIAL STRUCTURE:** This seminar has a different structure compared to SEM01-03, SEM05.

---

## About the Assignment Structure

Seminar 04 (Text Processing) uses an extended structure due to the complexity and volume of material:

| Standard Structure (SEM01-03, SEM05) | SEM04 Structure |
|--------------------------------------|-----------------|
| `S0X_01_TEMA.md` | `S04_01_HOMEWORK.md` |
| `S0X_02_creeaza_tema.sh` | `S04_02_TEMA_BONUS.md` |
| `S0X_03_EVALUATION_RUBRIC.md` | `S04_03_EVALUATION_RUBRIC.md` |
| - | `S04_04_SUBMISSION_TEMPLATE.md` |

---

## Rationale for the Structure

### 1. Separation of Mandatory / Bonus

The **Text Processing** seminar is one of the densest in the course, covering:
- Regular expressions (BRE, ERE)
- `grep` with all options
- `sed` for stream modifications
- `awk` for advanced processing

To avoid overloading students, assignments are separated into:
- **Mandatory Assignment** (100%) - basic requirements
- **Bonus Assignment** (up to +20%) - optional advanced exercises

### 2. Submission Template

Due to the complexity (4 scripts + multiple outputs), a separate document was added with:
- Exact structure of the submission archive
- Pre-submission checklist
- README template for documentation
- Useful commands for verification

---

## File Contents

| File | Content | Audience |
|------|---------|----------|
| `S04_00_README.md` | This explanatory document | Instructors |
| `S04_01_HOMEWORK.md` | 4 mandatory exercises (100%) | Students |
| `S04_02_TEMA_BONUS.md` | 5 bonus exercises (+20p max) | Students |
| `S04_03_EVALUATION_RUBRIC.md` | Detailed evaluation criteria | Instructors |
| `S04_04_SUBMISSION_TEMPLATE.md` | Archive submission guide | Students |

---

## Recommended Timeline

| Week | Activity |
|------|----------|
| 1 | Solve Mandatory Assignment |
| 2 | Submit Mandatory Assignment + Start Bonus (optional) |
| 3 | Submit Bonus Assignment (optional) |

---

## Points Distribution

```
Mandatory Assignment (100%)
├── Ex1: Data Validation and Extraction     25p
├── Ex2: Log Processing                     25p
├── Ex3: Data Transformation                25p
└── Ex4: Combined Pipeline                  25p

Bonus Assignment (max +20p)
├── B1: Multi-Format Log Aggregator         8p
├── B2: Diff and Patch with Regex           6p
├── B3: HTML Report Generator               6p
├── B4: Mini Grep with Highlighting         5p
└── B5: Config File Linter                  5p
    (Maximum cumulative: 20p)
```

---

## Comparison with Other Seminars

| Aspect | SEM01-03, SEM05 | SEM04 |
|--------|-----------------|-------|
| Number of mandatory exercises | 4-5 | 4 |
| Bonus exercises | Integrated in assignment | Separate file |
| Submission template | In TEMA.md | Separate file |
| Generation script | Yes | No (complexity too high) |
| Complexity | Medium | High |

---

## Notes for Instructors

1. **Differentiated evaluation**: Students can submit only the mandatory assignment for a passing grade
2. **Extended bonus deadline**: The bonus assignment has a deadline one week later
3. **Plagiarism checking**: Special attention to bonus exercises (more complex code)
4. **Support**: Exercises use files from `../resources/sample_data/`

---

## Associated Resources

- `../docs/S04_*` - Documentation materials
- `../presentations/S04_*` - Presentation slides
- `../resources/sample_data/` - Test files for assignments
- `../scripts/` - Examples and solutions

---

*Material for the Operating Systems course | ASE Bucharest - CSIE*
