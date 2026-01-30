# 📁 Lecture 08 Documentation — Deadlock

> **Location:** `05_LECTURES/08-Deadlock_(Coffman)/docs/`  
> **Topic:** Coffman conditions, RAG, Banker's algorithm

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `08ex1_-_RAG_Visualizer_EN.html` | Resource Allocation Graph builder and cycle detection |
| `08ex2_-_Bankers_Algorithm_EN.html` | Interactive Banker's algorithm safe state checker |
| `08ex3_-_Deadlock_Detection_Recovery_EN.html` | Detection algorithm and recovery strategies |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C08_05_EVALUARE_FORMATIVA.yaml` | Formative assessment quiz (Bloom-distributed) |
| `C08_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C08_01_COURSE_PLAN.md` | Learning objectives and session timing |
| `C08_01_PLAN_CURS.md` | Learning objectives and session timing |
| `C08_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C08_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C08_03_INTREBARI_DISCUTIE.md` | Peer instruction discussion questions |
| `C08_04_GHID_STUDIU.md` | Self-study guide and key concepts |
| `C08_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 08ex1_-_RAG_Visualizer_EN.html

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
python3 quiz_runner.py --file ../../05_LECTURES/08-Deadlock_(Coffman)/docs/C08_05_EVALUARE_FORMATIVA.yaml
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

*Lecture 08 of 18 (Core curriculum)*

*Last updated: January 2026*
