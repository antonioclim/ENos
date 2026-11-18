# Supplementary Materials — Exam Preparation

> Operating Systems | ASE Bucharest — CSIE  
> ENos 6.0.0-dev correction candidate | 17 November 2026  
> Author: ing. dr. Antonio Clim

## Purpose

These revision materials cover the fourteen core course weeks, with exercises, diagrams and model answers. Supplementary lecture diagrams also cover topics beyond the core weeks. Public availability makes the included questions suitable for practice; their role in an assessed examination remains subject to the author's [assessment and bank decisions](../AUTHOR_DECISIONS.md).

## Contents

| Resource | Description | Coverage |
|---|---|---|
| [Exam_Exercises_Part1.md](Exam_Exercises_Part1.md) | Exercises, model assumptions and worked answers | Weeks 1–4: introduction, system calls, processes, scheduling |
| [Exam_Exercises_Part2.md](Exam_Exercises_Part2.md) | Exercises and worked answers | Weeks 5–8: threads, synchronisation, deadlock |
| [Exam_Exercises_Part3.md](Exam_Exercises_Part3.md) | Exercises and worked answers | Weeks 9–14: memory, file systems, security, virtualisation |
| [REFERENCES.md](REFERENCES.md) | Scholarly bibliography | Source-specific DOI links |
| [QUICK_REFERENCE_CARD.md](QUICK_REFERENCE_CARD.md) | Compact revision reference | Explicit models and units |
| [diagrams_png/manifest.json](diagrams_png/manifest.json) | Source/include/output hashes and dimensions | 39 native PlantUML PNG outputs |

## How to use

Preview the relevant diagrams before lectures, solve exercises before reading the answers and then compare each step under the stated assumptions. Suggested times and difficulty markers are planning aids, not measured completion-time distributions or assessment rules.

## Diagram regeneration

The canonical diagrams are in `../05_LECTURES/**/diagrams/*.puml`. Their shared style is `diagrams_common/skin.puml`. To list all current source/output mappings without a compiler, network access or writes, run `python3 00_SUPPLEMENTARY/generate_diagrams.py --dry-run` from the repository root. This checks discovery only. For rendering, use Java and Graphviz, and supply the exact PlantUML compiler recorded in `generate_diagrams.py`:

```bash
# From the repository root; no network access in this invocation.
python3 00_SUPPLEMENTARY/generate_diagrams.py \
  --jar /path/to/plantuml-1.2026.10.jar \
  --output 00_SUPPLEMENTARY/diagrams_png --dpi 140 --clean
python3 00_SUPPLEMENTARY/validate.py
```

The compiler SHA-256 is `e9bc9e6b2eb715e8c0c929f3dcb5fc1923be13f37599b09c293c66d354e88686`. The generator checks it before execution. `--download` is an explicit alternative that downloads the pinned release when missing; ordinary runs do not download a compiler. Compilation is staged so that an unsuccessful source cannot be reported as a successful stale PNG. `--clean` removes only obsolete outputs named by the previous manifest, after successful generation.

`validate.py` checks current source/dependency/output hashes, PNG dimensions and manifest coverage. It does not run teaching examples, contact a service, grade material quality or certify every viewer.

## Learning levels and difficulty

The historical design allocation was approximately 15% remembering, 25% understanding, 40% applying and 20% analysing. These figures are an intended design distribution, not a newly measured coding of all questions. A reproducible classification would be required to report actual proportions.

| Marker | Intended level | Suggested planning time |
|---|---|---|
| ⭐ | Easy | 3–5 minutes |
| ⭐⭐ | Medium | 5–10 minutes |
| ⭐⭐⭐ | Hard | 10–15 minutes |
| ⭐⭐⭐⭐ | Expert | 15–20 minutes |

## Common conceptual distinctions

A page fault is a processor exception which may be handled successfully, for example by demand paging; it can also reflect an invalid or prohibited access. A user-space segmentation fault signal commonly reports an access that the operating system cannot satisfy. They are not interchangeable names for a universally benign or fatal event.

The Coffman conditions are mutual exclusion, hold and wait, no pre-emption and circular wait. Their significance follows from the resource/deadlock model. The historical assertion that they appear in nearly every exam session is not supported here by an examination-frequency dataset and is not an exam prediction.

## Support

Use the current course Moodle announcements and published office hours. No new schedule, eligibility condition or institutional policy is established by this correction candidate.
