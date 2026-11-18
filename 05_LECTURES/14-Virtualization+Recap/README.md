# Lecture 14 — Virtualization+Recap

## Learning and demonstration materials

- [Course Plan](docs/C14_01_COURSE_PLAN.md)
- [Concept Map](docs/C14_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C14_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C14_04_STUDY_GUIDE.md)
- [14ex1 - VM vs Container](docs/14ex1_-_VM_vs_Container.html)
- [Formative question bank](docs/C14_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

# Demonstration Scripts – Week 14

This directory contains short scripts (Bash/Python) used for laboratory demonstrations. They are designed to be **reproducible** and to highlight a concrete OS concept. Simple.

## How to Run Safely

- Run from a normal user account (without `sudo`), in a virtual machine (recommended).
- If a `.sh` script is not executable: `chmod +x script_name.sh`.
- For Python: `python3 script_name.py --help` (where available) or consult the docstring.

## Contents

### `cgroup_limits.py`

Demonstrates, at an introductory level, resource constraints (cgroups) and the reasons why they are relevant in containerisation.

Running (example):
```bash
python3 cgroup_limits.py --help 2>/dev/null || python3 cgroup_limits.py
```

### `virt_detect.sh`

Detects virtualisation/containerisation hints (e.g. `systemd-detect-virt`, cgroup info), to discuss isolation and overhead.

Running (example):
```bash
./virt_detect.sh --help 2>/dev/null || ./virt_detect.sh
```

---

Edition date: **10 January 2026**
