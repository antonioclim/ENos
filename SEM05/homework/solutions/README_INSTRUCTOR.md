# Exercise Solutions — Seminar 5

> **ATTENTION**: This directory contains exercise solutions.  
> It is intended EXCLUSIVELY for instructors.  
> DO NOT distribute to students before the deadline!

---

## Contents

| File | Exercise | Concepts Covered |
|------|----------|------------------|
| `S05_ex01_functii_sol.sh` | Functions with local variables | `local`, returning via `echo`, validation |
| `S05_ex02_arrays_sol.sh` | Array manipulation | indexed, associative, iteration, slice |
| `S05_ex03_robust_sol.sh` | Defensive scripting | `set -euo pipefail`, `trap`, cleanup |

---

## Usage

All solutions are executable:

```bash
# Make executable
chmod +x *.sh

# Run individually
./S05_ex01_functii_sol.sh
./S05_ex02_arrays_sol.sh
./S05_ex03_robust_sol.sh

# Solution 3 can simulate an error to demonstrate cleanup
./S05_ex03_robust_sol.sh --simulate-error
```

---

## Discussion Points with Students

### Exercise 1 (Functions)

1. Why doesn't `return 42` work like in Python?
2. When do we use `local` and when not?
3. How do we test if a function returns correctly?

### Exercise 2 (Arrays)

1. What happens if we forget `declare -A`?
2. Why are quotes essential when iterating?
3. What is a "sparse array" and when does it occur?

### Exercise 3 (Defensive Scripting)

1. In what situations does `set -e` NOT stop the script?
2. Why `trap cleanup EXIT` and not just on error?
3. How do we test that cleanup works?

---

## Verification with ShellCheck

```bash
shellcheck *.sh
```

All solutions should pass without warnings.

---

*Directory generated for instructors — Seminar 5*
