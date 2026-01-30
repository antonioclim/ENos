# Supplementary Materials — Exam Preparation

> Operating Systems | ASE Bucharest — CSIE  
> Version: 1.0 | January 2026

## Purpose

This folder contains comprehensive revision materials for the Operating Systems final examination, covering all 14 course weeks with exercises, diagrams and model answers.

## Contents

| Resource | Description | Coverage |
|----------|-------------|----------|
| `Exam_Exercises_Part1.md` | Exercises and diagrams | Weeks 1–4: OS Intro, Syscalls, Processes, Scheduling |
| `Exam_Exercises_Part2.md` | Exercises and diagrams | Weeks 5–8: Threads, Synchronisation, Deadlock |
| `Exam_Exercises_Part3.md` | Exercises and diagrams | Weeks 9–14: Memory, File Systems, Security, Virtualisation |
| `REFERENCES.md` | Scholarly bibliography | 12 seminal papers with DOI links |
| `diagrams_png/` | Pre-rendered concept diagrams | 26 high-resolution PNG files |

## How to Use

1. **Before lectures:** Skim the relevant week's diagrams to preview concepts
2. **After lectures:** Work through exercises without looking at solutions
3. **Before exam:** Time yourself on exam-style questions (target: 5 min per question)

## Diagram Regeneration

If you modify PlantUML sources in `diagrams_common/`, regenerate PNGs:

```bash
# Requires Java and internet connection (auto-downloads PlantUML JAR)
python3 generate_diagrams.py --output diagrams_png/ --dpi 200
```

## Bloom's Taxonomy Distribution

These materials deliberately progress through cognitive levels:

| Level | Proportion | Example Exercise Types |
|-------|------------|------------------------|
| Remember | ~15% | Definitions, terminology matching |
| Understand | ~25% | Concept explanations, comparisons |
| Apply | ~40% | Calculations, algorithm traces |
| Analyse | ~20% | Diagram interpretation, trade-off analysis |

## Exercise Difficulty Legend

| Symbol | Level | Typical Time |
|--------|-------|--------------|
| ⭐ | Easy | 3–5 min |
| ⭐⭐ | Medium | 5–10 min |
| ⭐⭐⭐ | Hard | 10–15 min |
| ⭐⭐⭐⭐ | Expert | 15–20 min |

## Common Exam Pitfalls

> 💡 **Tip:** Students often confuse "page fault" with "segmentation fault". The first is a normal demand paging mechanism; the second is a fatal error!

> ⚠️ **Warning:** The Coffman conditions question appears in nearly every exam session. Memorise them in order: **M**utual exclusion, **H**old & wait, **N**o preemption, **C**ircular wait.

## Support

- **Course forum:** Check Moodle for announcements
- **Office hours:** See course schedule
- **Instructor:** ing. dr. Antonio Clim

---

*Materials developed for ASE Bucharest — CSIE*
