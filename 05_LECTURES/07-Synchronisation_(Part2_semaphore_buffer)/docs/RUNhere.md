<!-- RO: TRADUS ȘI VERIFICAT -->
# 📁 Lecture 07 Documentation — Synchronisation Part 2

> **Location:** `05_LECTURES/07-Synchronisation_(Part2_semaphore_buffer)/docs/`  
> **Topic:** Semaphores, producer-consumer, readers-writers

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `../07ex1_-_Semaphore_Operations.html` | Interactive model |
| `../07ex2_-_Producer_Consumer.html` | Interactive model |
| `../07ex3_-_Readers_Writers.html` | Interactive model |


### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C07_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C07_01_COURSE_PLAN.md` | Learning objectives and session timing |
| `C07_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C07_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C07_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open ../07ex1_-_Semaphore_Operations.html

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
python3 ../../quiz_runner.py "C07_05_FORMATIVE_ASSESSMENT.yaml" --shuffle --seed 42
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

*Lecture 07 of 18 (Core curriculum)*

*Last updated: January 2026*
