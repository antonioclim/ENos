# Kit Usage Guide (didactic edition)

This package is designed as didactic support for the **Operating Systems** course (introductory level), particularly for lecture/seminar/laboratory activities. The content combines:
- conceptual explanations (definitions, models, properties);
- reproducible examples in Linux (Bash + Python), with emphasis on **observability** (what happens "inside") and **safety** (commands that do not damage the system);
- diagrams (PlantUML + ASCII) to consolidate structures and execution flows;
- "exam-style" exercises for revision.

## 1. How the kit is organised

- `SO_curs01` … `SO_curs14`  
  Each week has a `README.md` with essential theory, examples, multiple-choice/explanatory questions and a **Scripting in context (Bash + Python)** section.
- `SO_cursXX/diagrame/` (where applicable)  
  `.puml` files (PlantUML) and common resources in `diagrame_common/`.
- `SO_cursXX/TC_Materials/` (where applicable)  
  Laboratory materials (worksheets) in **RO version**. The original versions (English) are kept in `TC_Materials/_EN_Original/`.
- `SO_cursXX/scripts/`  
  Short scripts (Bash/Python) that illustrate specific OS concepts; each directory also contains a `README.md` for running and interpreting.
- `Exercitii_Examene_Partea1.md` … `Exercitii_Examene_Partea3.md`  
  Comprehensive revision sets (ASCII diagrams + questions).

## 2. Recommended environment for laboratory

Recommended (for consistency among students):
- **Ubuntu 24.04 LTS** (native / WSL2 / VirtualBox)
- **Bash 5.2+**, **Python 3.12+**
- `git`, `shellcheck` (for script quality)
- optional: Java + PlantUML (for generating PNG diagrams)

> Didactic suggestion: in the laboratory, use a normal user account (without root privileges) and a dedicated working directory, e.g. `~/so-lab/`.

## 3. Didactic workflow (practical recommendation)

1. **Before the lecture**: students review "Objectives" + "Lecture content" (10–15 minutes).
2. **During the lecture**: short demonstrations in the terminal, emphasising the link between concept and observability (`ps`, `/proc`, `strace`, `time`, `vmstat`, `iostat` etc.).
3. **In the laboratory**:
   - work on `TC_Materials` (the week's worksheet);
   - run the demos from `scripts/` (with discussion of results);
   - solve 2–3 short exercises + 1 integrative exercise.
4. **After the laboratory**: revision from the `Exercitii_Examene_...` files.

## 4. Reproducibility and safety rules

- Do not run destructive commands without understanding the effect:
  - avoid `rm -rf /`, `dd if=... of=/dev/...`, modifications in `/etc` on your personal system;
  - prefer working in a virtual machine (snapshot before the laboratory).
- For scripts:
  - use `set -euo pipefail` (where appropriate);
  - explicitly quote the files/directories you modify;
  - always write `--help` / `usage()` for projects.
- For results:
  - save output to a file (e.g. `tee`, `script`, redirections);
  - note the kernel version (`uname -a`) and distribution (`lsb_release -a`).

## 5. How to generate PlantUML diagrams

In the kit root there is `generate_diagrams.py`, which can convert `.puml` files to images (PNG).
- useful for worksheets/slides;
- optional for students, but very useful for teaching staff.

## 6. Academic integrity

The exercises are intended for learning. In projects/assignments:
- collaboration at the level of ideas is accepted, but the **delivered code** must be understood and owned by the team;
- a Git workflow is recommended (short commits, clear messages, code review).

Edition date: **10 January 2026**
