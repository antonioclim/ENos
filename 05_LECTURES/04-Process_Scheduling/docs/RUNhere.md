<!-- RO: TRADUS ȘI VERIFICAT -->
# 📁 Lecture 04 Documentation — Process Scheduling

> **Location:** `05_LECTURES/04-Process_Scheduling/docs/`  
> **Topic:** FCFS, SJF, RR, MLFQ algorithms

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `04ex1_-_Scheduling_Simulator_Gantt_EN.html` | Gantt chart visualization for scheduling algorithms |
| `04ex2_-_Scheduling_Comparator_EN.html` | Side-by-side comparison of FCFS, SJF, RR |
| `04ex3_-_MLFQ_Simulator_EN.html` | Multi-Level Feedback Queue interactive simulation |
| `04ex4_-_Starvation_Demonstrator_EN.html` | Shows how starvation occurs and aging solutions |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C04_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |
| `L04_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C04_01_LECTURE_PLAN.md` | Learning objectives and session timing |
| `C04_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C04_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C04_04_STUDY_GUIDE.md` | Self-study guide and key concepts |
| `L04_01_LECTURE_PLAN.md` | Learning objectives and session timing |
| `L04_02_CONCEPT_MAP.md` | Visual topic relationships |
| `L04_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `L04_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 04ex1_-_Scheduling_Simulator_Gantt_EN.html

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
python3 quiz_runner.py --file ../../05_LECTURES/04-Process_Scheduling/docs/C04_05_FORMATIVE_ASSESSMENT.yaml
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

*Lecture 04 of 18 (Core curriculum)*

*Last updated: January 2026*
