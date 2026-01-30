# 📁 Lecture 05 Documentation — Execution Threads

> **Location:** `05_LECTURES/05-Execution_Threads/docs/`  
> **Topic:** User/kernel threads, threading models

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `05ex1_-_Thread_vs_Process_Memory.html` | Memory layout comparison: threads share, processes don't |
| `05ex2_-_Threading_Models.html` | 1:1, N:1, M:N threading model visualization |
| `05ex3_-_Context_Switch_Comparator.html` | Thread vs process context switch overhead |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C05_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C05_01_COURSE_PLAN.md` | Learning objectives and session timing |
| `C05_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C05_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C05_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 05ex1_-_Thread_vs_Process_Memory.html

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
python3 quiz_runner.py --file ../../05_LECTURES/05-Execution_Threads/docs/C05_05_FORMATIVE_ASSESSMENT.yaml
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

*Lecture 05 of 18 (Core curriculum)*

*Last updated: January 2026*
