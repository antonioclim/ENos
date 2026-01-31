# 📁 Lecture 14 Documentation — Virtualization + Course Recap

> **Location:** `05_LECTURES/14-Virtualization+Recap/docs/`  
> **Topic:** Type 1/2 hypervisors, containers, course review

## Contents

### Interactive HTML Simulators

| File | Description |
|------|-------------|
| `14ex1_-_VM_vs_Container.html` | Virtual machine vs container architecture comparison |

### Formative Assessment (YAML)

| File | Description |
|------|-------------|
| `C14_05_FORMATIVE_ASSESSMENT.yaml` | Formative assessment quiz (Bloom-distributed) |

### Pedagogical Documentation

| File | Purpose |
|------|---------|
| `C14_01_COURSE_PLAN.md` | Obiective de învățare and session timing |
| `C14_02_CONCEPT_MAP.md` | Visual topic relationships |
| `C14_03_DISCUSSION_QUESTIONS.md` | Peer instruction discussion questions |
| `C14_04_STUDY_GUIDE.md` | Self-study guide and key concepts |

---

## How to Use

### HTML Interactive Simulators

Open any `.html` file directly in a web browser:

```bash
# Linux/WSL
xdg-open 14ex1_-_VM_vs_Container.html

# Or simply double-click the file in your file manager
```

**Features:**
- Self-contained (no server required)
- Interactive controls and visualizations  
- Step-by-step execution modes
- Reset buttons to restart simulations

### YAML Formative Quiz

Run the quiz using the quiz runner from any SEM director:

```bash
cd ../../SEM01/formative/
python3 quiz_runner.py --file ../../05_LECTURES/14-Virtualization+Recap/docs/C14_05_FORMATIVE_ASSESSMENT.yaml
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

*Lecture 14 of 18 (Core curriculum)*

*Last updated: January 2026*
