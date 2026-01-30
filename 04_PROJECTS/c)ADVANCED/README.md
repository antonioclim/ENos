# ADVANCED Projects (A01-A03)

> **Difficulty:** ⭐⭐⭐⭐⭐ | **Time:** 40-50 hours | **Components:** Bash + C

---

## Overview

Advanced projects require C integration and deep OS knowledge. They are only recommended for students with prior C experience and strong systems programming background.

> ⚠️ **Instructor's warning:** These projects are genuinely difficult. I have seen experienced programmers struggle with the C integration. If you choose an ADVANCED project, you are signing up for long debugging sessions, segmentation faults and memory leaks. The reward is deep understanding and an impressive portfolio piece.

---

## Project List

| ID | Name | C Component | Key Challenge |
|----|------|-------------|---------------|
| A01 | Mini Job Scheduler | Priority queue (heap) | IPC, shared memory, POSIX semaphores |
| A02 | Interactive Shell Extension | Syntax highlighter | Terminal handling, ANSI sequences |
| A03 | Distributed File Sync | Network protocol | Sockets, concurrency, conflict resolution |

---

## Prerequisites

Before choosing an ADVANCED project, you should be comfortable with:

- **C programming**: pointers, malloc/free, structs
- **POSIX APIs**: fork, exec, wait, signals
- **Memory management**: no memory leaks, proper cleanup
- **Makefiles**: multi-file compilation, linking

If any of these feel unfamiliar, consider a MEDIUM project instead.

---

## C Integration Requirements

Your C component must:

1. Compile with `gcc -Wall -Wextra -pedantic` without warnings
2. Pass Valgrind memory check with zero leaks
3. Integrate cleanly with Bash via shared library or subprocess
4. Include a proper Makefile for compilation

---

## What You Will Learn

Completing an ADVANCED project will teach you:

- Systems programming in C
- Inter-process communication (IPC)
- Memory management and debugging
- Building hybrid Bash/C applications
- Professional-grade error handling

---

## Common Pitfalls

1. **Underestimating C complexity** — Budget 50% more time than you think
2. **Memory leaks** — Run Valgrind from day one, not at the end
3. **Race conditions** — Use proper synchronisation primitives
4. **Debugging blind** — Add logging to your C code; `printf` debugging works

---

## True Story

> In 2023, a student chose A01 because "it looked interesting." They had not written C in two years. They spent the first 30 hours just remembering how pointers work. They finished the project, but it cost them sleep and sanity. When I asked if they would recommend ADVANCED to others, they said: "Only if they actually know C."

---

## Recommended Approach

1. **Week 1-2**: Build and test the C component in isolation
2. **Week 3**: Integrate C with Bash wrapper
3. **Week 4**: Add error handling, logging, tests
4. **Week 5**: Documentation and polish

Do not try to build everything at once. Get the C part working first.

---

*ADVANCED Projects — OS Kit | January 2025*
