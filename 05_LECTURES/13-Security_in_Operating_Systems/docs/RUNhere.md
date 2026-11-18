# 📁 Lecture 13 Documentation — Security in Operating Systems

> **Location:** `05_LECTURES/13-Security_in_Operating_Systems/docs/`  
> **Topic:** AAA, permissions, capabilities, vulnerabilities

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `13ex1_-_Permissions_Calculator.html` | Unix permission bits (rwx) calculator |
| `13ex2_-_Buffer_Overflow_Demo.html` | Stack buffer overflow visualization |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C13_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C13_01_COURSE_PLAN.md` | Learning objectives and session timing |
| `C13_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C13_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C13_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 13ex1_-_Permissions_Calculator.html

# Or simply double-click the file in your file manager
```

**Features:**
- No server required; optional web fonts/chart assets may need internet, with a textual chart fallback offline
- Interactive controls and visualizations  
- Step-by-step execution modes
- Reset buttons to restart simulations

### YAML Formative Quiz

Run the lecture quiz from this `docs/` directory:

```bash
python3 ../../quiz_runner.py "C13_05_FORMATIVE_ASSESSMENT.yaml" --shuffle --seed 42
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

*Lecture 13 of 18 (Core curriculum)*

*Last updated: January 2026*
