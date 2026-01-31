<!-- RO: TRADUS ȘI VERIFICAT -->
# 📁 Lecture 10 Documentation — Virtual Memory

> **Location:** `05_LECTURES/10-Virtual_Memory_(TLB_Belady)/docs/`  
> **Topic:** TLB, page replacement, Bélády's anomaly

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `10ex1_-_Page_Replacement_Algorithms_EN.html` | FIFO, LRU, Optimal comparison |
| `10ex2_-_Working_Set_Model_EN.html` | Working set size and page fault rate |
| `10ex3_-_Thrashing_Demo_EN.html` | Demonstrates thrashing conditions |
| `10ex4_-_Demand_Paging_EN.html` | Page fault handling simulation |
| `10ex5_-_Memory_Mapped_Files_EN.html` | mmap() visualization |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C10_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C10_01_COURSE_PLAN.md` | Learning objectives and session timing |
| `C10_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C10_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C10_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 10ex1_-_Page_Replacement_Algorithms_EN.html

# Or simply double-click the file in your file manager
```

**Features:**
- Self-contained (no server required)
- Interactive controls and visualizations  
- Step-by-step execution modes
- Reset buttons to restart simulations

### YAML Formative Quiz

Run the quiz using the quiz runner from any SEM folder:

```bash
cd ../../SEM01/formative/
python3 quiz_runner.py --file ../../05_LECTURES/10-Virtual_Memory_(TLB_Belady)/docs/C10_05_FORMATIVE_ASSESSMENT.yaml
```

**Or manually review:**
1. Open the `.yaml` file in any text editor
2. Answer questions mentally
3. Check `correct` field (0-indexed) for answers
4. Read `explanation` for understanding

**Quiz structure:**
- ~12 questions per lecture
- Bloom taxonomy distribution (remember, understand, apply, analyse)
- Estimated time: 15 minutes

### Pedagogical Documents

| Document | When to Use |
|----------|-------------|
| `*_COURSE_PLAN.md` | Before lecture — understand objectives |
| `*_CONCEPT_MAP.md` | During study — see topic relationships |
| `*_DISCUSSION_QUESTIONS.md` | In class — peer instruction |
| `*_STUDY_GUIDE.md` | After lecture — self-study review |

---

## Related Resources

- **Parent:** [`../README.md`](../README.md) — Lecture unit overview
- **Scripts:** [`../scripts/`](../scripts/) — Demo scripts (if available)
- **Diagrams:** [`../../00_SUPPLEMENTARY/diagrams_png/`](../../00_SUPPLEMENTARY/diagrams_png/) — Related concept diagrams

---

*Lecture 10 of 18 (Core curriculum)*

*Last updated: January 2026*
