# 📁 Lecture 06 Documentation — Synchronisation Part 1

> **Location:** `05_LECTURES/06-Synchronisation_(Part1_Peterson+locks+mutex)/docs/`  
> **Topic:** Critical section, Peterson's algorithm, locks, mutex

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `06ex1_-_Race_Condition_Demo.html` | Interactive race condition with shared counter |
| `06ex2_-_Peterson_Algorithm.html` | Step-by-step Peterson's algorithm execution |
| `06ex3_-_Mutex_vs_Spinlock.html` | Compares mutex blocking vs spinlock busy-waiting |
| `06ex4_-_Critical_Section_Requirements.html` | Demonstrates mutual exclusion, progress, bounded waiting |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C06_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C06_01_LECTURE_PLAN.md` | Learning objectives and session timing |
| `C06_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C06_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C06_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 06ex1_-_Race_Condition_Demo.html

# Or simply double-click the file in your file manager
```

**Features:**
- No server required; optional web fonts/chart assets may need internet, with a textual chart fallback offline
- Interactive controls and visualizations  
- Step-by-step execution modes
- Reset buttons to restart simulations

### YAML Formative Quiz

Run the lecture self-assessment from this `docs/` directory (Python with PyYAML):

```bash
python3 ../../quiz_runner.py "C06_05_FORMATIVE_ASSESSMENT.yaml" --shuffle --seed 42
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
- **Diagrams:** [`../../../00_SUPPLEMENTARY/diagrams_png/`](../../../00_SUPPLEMENTARY/diagrams_png/) — Related concept diagrams

---

*Lecture 06 of 18 (Core curriculum)*

*Last updated: January 2026*
