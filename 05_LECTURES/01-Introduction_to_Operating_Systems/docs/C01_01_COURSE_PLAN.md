/* FIȘIER TRADUS ȘI VERIFICAT ÎN LIMBA ROMÂNĂ */

# Course Plan — Introduction to Operating Systems

> Course 01 | Operating Systems | ASE Bucharest - CSIE

---

## Learning Outcomes

By the end of this session, students will be able to:

1. **Define** an operating system and articulate its core responsibilities
2. **Classify** operating systems by purpose (desktop, server, embedded) and architecture (monolithic, microkernel, hybrid)
3. **Trace** the historical evolution from batch systems to modern container-based environments
4. **Execute** basic Linux commands for system inspection (`uname`, `htop`, `cat /proc/*`, `strace`)

---

## Session Structure (90 minutes)

| Phase | Duration | Activity | Materials |
|-------|----------|----------|-----------|
| **Hook** | 10 min | "Why can your phone run 50 apps simultaneously?" — interactive discussion | Whiteboard |
| **Theory I** | 20 min | OS definition, dual role (extended machine + resource manager) | README.md §1-2 |
| **Theory II** | 20 min | OS types, kernel architectures, historical timeline | README.md §3 |
| **Demo** | 25 min | Hands-on: `neofetch`, `htop`, `/proc` exploration, `strace ls` | Terminal |
| **Practice** | 15 min | Mini-challenge: system inspection commands | README.md §Self-Assessment |

---

## Prerequisites

- Basic computer literacy (file operations, using a terminal)
- Access to Ubuntu 24.04 environment (WSL2, VirtualBox, or native)
- Completed 01_INIT_SETUP guide

---

## Materials Checklist

| Resource | Location | Required |
|----------|----------|----------|
| Main lecture content | `README.md` | ✓ |
| Batch simulation script | `scripts/batch_sim.py` | ✓ |
| Interactive demos | `00-DEMOs/01ex1_*, 01ex2_*` | Optional |
| Concept map | `docs/C01_02_CONCEPT_MAP.md` | Reference |
| Formative quiz | `docs/C01_05_FORMATIVE_ASSESSMENT.yaml` | Post-session |

---

## Instructor Notes

### Common Student Misconceptions

1. **"The OS is just Windows/Linux"** — Clarify that the OS is the *kernel* plus system utilities; the desktop environment is separate.

2. **"Microkernel is always better because it's more secure"** — Discuss the performance trade-offs; Linux's monolithic design dominates servers precisely because of speed.

3. **"Batch processing is obsolete"** — Show modern analogies: CI/CD pipelines, Kubernetes Jobs, cloud batch computing.

### Engagement Strategies

- Ask students to count running processes on their phones before class
- Use the orchestra conductor metaphor consistently throughout
- Connect historical context (punch cards, 1956 GM-NAA I/O) to modern equivalents

---

## Assessment Alignment

| Learning Outcome | Assessment Method |
|------------------|-------------------|
| Define OS | Quiz Q1-Q3 |
| Classify OS | Quiz Q4-Q6 |
| Historical evolution | Quiz Q7-Q8 |
| Execute commands | Mini-challenge |

---

## Post-Session Tasks

- [ ] Students complete formative quiz (C01_05)
- [ ] Students run `scripts/batch_sim.py` with custom job durations
- [ ] Preparation for Week 2: review system call concept

---

*Course 01 | Operating Systems | ASE Bucharest - CSIE | 2025-2026*
