# S05_10 - Self-Assessment and Reflection

> **Operating Systems** | ASE Bucharest - CSIE  
> Seminar 5: Advanced Bash Scripting
> Version: 2.0.0 | Date: 2025-01

---

## Instructions

This self-assessment sheet helps you:
1. **Identify** what you have learnt
2. **Recognise** what you need to practise more
3. **Plan** your next steps

**Time:** 3-5 minutes at the end of the seminar
**Format:** Individual, then (optional) pair discussion

---

## Part 1: Competency Checklist

Evaluate yourself honestly on a scale of 1-5:
```
1 = I don't understand at all
2 = I've heard of it, but I can't apply it
3 = I can apply it with help/documentation
4 = I can apply it independently
5 = I can explain it to someone else
```

### Functions

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I define and call functions | ○ | ○ | ○ | ○ | ○ |
| I use `local` for variables | ○ | ○ | ○ | ○ | ○ |
| I understand the difference between return and echo | ○ | ○ | ○ | ○ | ○ |
| I pass and access arguments ($1, $@) | ○ | ○ | ○ | ○ | ○ |

### Arrays

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I create and access indexed arrays | ○ | ○ | ○ | ○ | ○ |
| I iterate correctly with `"${arr[@]}"` | ○ | ○ | ○ | ○ | ○ |
| I use `declare -A` for associative arrays | ○ | ○ | ○ | ○ | ○ |
| I work with keys (`${!arr[@]}`) | ○ | ○ | ○ | ○ | ○ |

### Robustness

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I apply `set -euo pipefail` | ○ | ○ | ○ | ○ | ○ |
| I know when `-e` does NOT work | ○ | ○ | ○ | ○ | ○ |
| I use default values `${VAR:-...}` | ○ | ○ | ○ | ○ | ○ |
| I implement `die()` for errors | ○ | ○ | ○ | ○ | ○ |

### Trap and Cleanup

| Competency | 1 | 2 | 3 | 4 | 5 |
|------------|---|---|---|---|---|
| I implement cleanup with `trap EXIT` | ○ | ○ | ○ | ○ | ○ |
| I manage temporary files safely | ○ | ○ | ○ | ○ | ○ |
| I understand different signals (INT, ERR) | ○ | ○ | ○ | ○ | ○ |

---

## Part 2: Reflection Questions

### What was new for you?

_____________________________________________

_____________________________________________

_____________________________________________

### What surprised you the most?

_____________________________________________

_____________________________________________

### What did you find most difficult?

_____________________________________________

_____________________________________________

### What do you want to practise more?

_____________________________________________

_____________________________________________

---

## Part 3: Quick Check (3 minutes)

Answer without looking at your notes:

**1. What is the difference between `return` and `echo` in functions?**

_____________________________________________

**2. Why is `declare -A` needed for associative arrays?**

_____________________________________________

**3. Name 2 situations where `set -e` does NOT stop the script:**

1. _____________________________________________

2. _____________________________________________

**4. Write the pattern for cleanup with trap:**

```bash

```

**5. How do you correctly iterate through an array with elements containing spaces?**

_____________________________________________

---

## Part 4: My Action Plan

### This week I will:

- [ ] Reread the material for: _______________________
- [ ] Practise by writing: _______________________
- [ ] Ask someone about: _______________________

### For homework/project I will apply:

- [ ] `set -euo pipefail` in all scripts
- [ ] `local` in all functions
- [ ] `declare -A` for hash maps
- [ ] Cleanup with trap EXIT
- [ ] Quotes when iterating arrays

---

## Part 5: Exit Ticket (for instructor)

Tick and hand in on your way out:

**The most useful thing I learnt today:**

_____________________________________________

**A question I still have:**

_____________________________________________

**Feedback for the seminar (optional):**

_____________________________________________

---

## Key Answers (for self-verification at home)

<details>
<summary>Check your answers</summary>

**1. return vs echo:**
- `return` sets exit code (0-255), does not return values
- `echo` writes to stdout, can be captured with `$()`

**2. declare -A:**
- Without it, Bash treats the array as indexed
- Text keys are evaluated as variables (undefined = 0)
- All assignments write to index 0

**3. set -e does not work in:**
- if/while/until conditions
- Commands with || or &&
- Commands negated with !
- Functions called in test context

**4. Cleanup pattern:**
```bash
cleanup() {
    local exit_code=$?
    # cleanup operations
    exit $exit_code
}
trap cleanup EXIT
```

**5. Correct iteration:**
```bash
for item in "${arr[@]}"; do
```
With quotes! Without quotes, word splitting corrupts the elements.

</details>

---

## Resources for Continuation

### Official Documentation
- GNU Bash Manual: https://www.gnu.org/software/bash/manual/
- Bash Reference Card: https://ss64.com/bash/

### Practice
- ShellCheck: https://www.shellcheck.net/
- Exercism Bash Track: https://exercism.org/tracks/bash
- Advent of Code (in Bash): https://adventofcode.com/

### Style Guides
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- Bash Best Practices: https://bertvv.github.io/cheat-sheets/Bash.html

---

## Notes for Instructor

### How to use this form

1. **Distribute** in the last 5 minutes of the seminar
2. **Allow** 3-4 minutes for individual completion
3. **Collect** Exit Tickets (Part 5) at the door
4. **Analyse** patterns to adjust the next seminar

### What to look for

- Competencies with many scores of 1-2 → need re-explanation
- Frequent questions → add to FAQ or Q&A at the start
- Common difficulties → adjust pacing

### Variants

- **Short (2 min):** Only Parts 4-5
- **Medium (5 min):** Parts 2, 4, 5
- **Complete (10 min):** The entire form
- **Online:** Google Forms with the same content

---

*Laboratory material for the Operating Systems course | ASE Bucharest - CSIE*
