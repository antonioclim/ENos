# `heron_FOR.sh` — Detailed Line-by-Line Explanation

## Overview

This script implements **Heron's method** (also known as the Babylonian method) for approximating the square root of a positive integer. The central control structure is the `for` loop, which repeats the refinement formula exactly **10 times** without checking whether the result has already stabilised.

The underlying mathematics is straightforward: starting from an initial estimate $x_0 = \frac{N}{2}$, each step applies the formula:

$$x_{k+1} = \frac{x_k + \frac{N}{x_k}}{2}$$

After a few steps, $x_k$ converges towards $\sqrt{N}$.

---

## Section 0 — Script Header

```bash
#!/bin/bash
```

This is the **shebang** (or *hashbang*) line. Although it begins with `#`, it is not an ordinary comment. The character pair `#!` constitutes a directive to the operating system kernel: when the file is executed as a programme, the kernel reads the path following `#!` and invokes that interpreter (here `/bin/bash`) to process the file's contents. Without this line, the system would not know which command interpreter to use and would fall back to the default shell, which may differ across distributions.

---

```bash
# =============================================================================
# heron_FOR.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: FOR
```

A block of descriptive comments. Any text preceded by `#` is ignored by the interpreter. The author documents the file name, the script's purpose and the primary control structure. The lines of `=` characters serve no functional role — they act purely as visual delimiters, making the source easier to scan.

---

```bash
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam de EXACT 10 ori cu:    x = ( x + N/x ) / 2
#   3. Dupa 10 pasi,                  x ≈ sqrt(N)
```

A three-step algorithmic summary. The wording is deliberately concise: step 1 establishes the starting point, step 2 describes the iterative refinement rule and step 3 states the expected outcome. The `≈` symbol signals that the result is an approximation rather than an exact value.

---

```bash
# De ce FOR aici?
#   FOR repeta un bloc de cod de UN NUMAR FIX DE ORI, cunoscut dinainte.
#   Formula Heron e aceeasi la fiecare pas — scriem o singura data in bucla.
#   Diferenta fata de IF: nu mai copy-pastam aceeasi linie de N ori.
#   Diferenta fata de WHILE: nu verificam convergenta — facem fix 10 pasi.
```

A justification for choosing the `for` structure over alternatives. The central argument: the number of repetitions is **fixed and known in advance** (10 steps), which makes `for` the natural choice. The comments emphasise that `if` would require manually duplicating the same formula 10 times (an inefficient and error-prone approach), whilst `while` would be appropriate only if early termination based on convergence were desired.

---

## Section 1 — Reading Input

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

The `read` command halts script execution and waits for keyboard input. The `-p` flag (from *prompt*) attaches a guide message that is displayed on the same line as the input cursor. The text enclosed in double quotes (`"Introdu un numar intreg pozitiv: "`) is that message. The identifier `N` at the end designates the variable into which the user's input is stored. From this point onward, the entered value is accessible by prefixing the variable name with `$` — that is, `$N`.

---

## Section 2 — Input Validation

### Checking for an empty field

```bash
if [ -z "$N" ]; then
```

The keyword `if` opens a decision structure. The square brackets `[ ... ]` delimit a test expression (equivalent to the `test` command). The `-z` flag checks whether the following string has **zero** length — in other words, whether the user pressed *Enter* without typing anything. The double quotes around `$N` are essential: if `N` holds nothing, omitting the quotes would cause the expression to become `[ -z ]`, which would produce a syntax error. The semicolon `;` separates the condition from the keyword `then`, which marks the beginning of the block of instructions to be executed if the test evaluates to true.

---

```bash
    echo "Eroare: nu ai introdus nimic."
```

The `echo` command prints the text between the double quotes to the screen. The message informs the user that no value was provided. The leading spaces (indentation) have no functional effect — they serve only to make the membership of this line within the `if` block visually apparent.

---

```bash
    exit 1
```

The `exit` command terminates the script immediately. The value `1` is a **return code** that signals an error condition. By convention in Unix-like systems, code `0` indicates success and any non-zero value indicates a problem. Other programmes or scripts can read this code and make decisions accordingly.

---

```bash
fi
```

Marks the closure of the `if` block. In Bash, every `if` must have a corresponding `fi` (the word `if` spelt backwards). Omitting it triggers a syntax error at runtime.

---

### Verifying numeric format

```bash
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
```

This line introduces a more sophisticated check. The double square brackets `[[ ... ]]` are an extended test form specific to Bash that supports regular expressions. The `=~` operator compares the contents of `$N` against the pattern (regular expression) on the right. The pattern `^[0-9]+$` reads as follows:

- `^` — start of the string
- `[0-9]` — exactly one digit (any character from 0 to 9)
- `+` — one or more occurrences of the preceding element (hence one or more digits)
- `$` — end of the string

Taken together, the pattern describes a string composed **exclusively** of digits, with no spaces, letters or special characters. The `!` operator in front of the brackets **negates** the result: if `$N` does **not** match the pattern, the condition evaluates to true and the error block executes.

---

```bash
    echo "Eroare: '${N}' nu este un intreg pozitiv."
```

The error message includes the value entered by the user, delimited by apostrophes for visual clarity. The notation `${N}` is equivalent to `$N`, but the curly braces eliminate any ambiguity when the variable is placed adjacent to other characters.

---

```bash
    exit 1
fi
```

The same mechanism as above: termination with an error code and block closure.

---

### Handling the special case of zero

```bash
if [ "$N" -eq 0 ]; then
```

The `-eq` operator (*equal*) compares two **numeric** values. If `N` is zero, Heron's formula would entail a division by zero ($N/x$, but also the initial estimate $N/2 = 0$, and the subsequent step would compute $N/0$), producing an error. This case is therefore treated separately.

---

```bash
    echo "sqrt(0) = 0"
    exit 0
```

The answer is trivial: the square root of zero is zero. The script displays the result and terminates with code `0` (success), since this is not an error but a particular case handled correctly.

---

```bash
fi
```

Closes the `if` block for the special case of zero.

---

## Section 3 — Initial Estimate

```bash
x=$(echo "scale=8; $N / 2" | bc)
```

This is one of the densest lines in the script and merits decomposition into its constituent parts:

- **`$(...)`** — command substitution: Bash executes the command inside and replaces the entire construct with the text that command produces.
- **`echo "scale=8; $N / 2"`** — constructs a string containing an instruction for the `bc` calculator. For instance, if `N` is `50`, the string becomes `scale=8; 50 / 2`.
- **`|`** — the pipe operator: redirects the text produced by `echo` to the input of the programme that follows.
- **`bc`** — an arbitrary-precision arithmetic calculator available on virtually every Unix-like system. Bash cannot natively perform decimal arithmetic — its `/` operator carries out integer division only.
- **`scale=8`** — sets the number of decimal places to 8, allowing detailed observation of convergence from one step to the next.

The result is stored in variable `x`, which becomes the initial estimate: $x_0 = N / 2$.

---

```bash
echo "--------------------------------------"
```

Displays a visual separator line composed of hyphens. It has no logical function — it solely improves the readability of output in the terminal.

---

```bash
echo "Numar:  N = $N"
```

Displays the value entered by the user. The construct `$N` is automatically expanded (replaced) by Bash with the value of variable `N`.

---

```bash
echo "Start:  x = $x   (estimare initiala = N/2)"
```

Displays the initial estimate computed in the preceding step. The text within round brackets serves as an explanatory annotation.

---

```bash
echo "--------------------------------------"
```

A second separator line, visually delimiting the initialisation section from the iterations that follow.

---

## Section 4 — The `for` Loop (10 Heron Iterations)

```bash
for pas in {1..10}; do
```

This line opens the `for` loop. Let us examine it element by element:

- **`for`** — the keyword declaring an iteration loop.
- **`pas`** — the name of the counter variable (chosen by the script's author; any valid identifier would work). At each pass through the loop, `pas` receives one value from the supplied list in turn.
- **`in`** — separates the counter variable from the list of values.
- **`{1..10}`** — brace expansion: Bash automatically generates the list `1 2 3 4 5 6 7 8 9 10`. This is a feature of the interpreter itself — no external programme is involved.
- **`;`** — separates the loop declaration from the keyword `do`.
- **`do`** — marks the beginning of the loop body (the instructions that repeat).

Consequently, the loop body will execute **exactly 10 times**, with `pas` taking the values 1, 2, 3, ..., 10 in order.

---

```bash
    x=$(echo "scale=8; ($x + $N / $x) / 2" | bc)
```

This is the **heart of the algorithm** — Heron's refinement formula, written once but executed 10 times thanks to the loop. The mechanism is identical to that used for the initial estimate:

- The mathematical expression is constructed as text: `($x + $N / $x) / 2`
- The text is sent to `bc` via the pipe operator
- The result with 8 decimal places is captured through command substitution
- Variable `x` is **overwritten** with the new value

An important observation: `x` appears on both the left-hand side (receiving the new value) and the right-hand side (supplying the old value for computation). Bash evaluates the right-hand side first, obtains the numerical result from `bc` and only then assigns the new value to `x`. Thus, at each step, the estimate is refined: $x_{k+1} = \frac{x_k + N / x_k}{2}$.

---

```bash
    echo "Pas $pas: x = $x"
```

Displays the current step number (through expansion of `$pas`) and the approximation obtained at this step. By observing these lines in the terminal, one can concretely see how the estimate converges: the differences between successive values grow ever smaller until they vanish entirely (within the 8-decimal-place precision).

---

```bash
done
```

Marks the end of the `for` loop body. It is the counterpart of `do` — just as `fi` is the counterpart of `if`. When Bash encounters `done`, it returns to the beginning of the loop, advances the counter (proceeds to the next value in the list) and re-executes the body. When the list of values is exhausted (after `pas=10`), execution continues with the first instruction following `done`.

---

## Section 5 — Displaying the Final Result

```bash
echo "--------------------------------------"
```

A visual separator line, identical to those used previously.

---

```bash
echo "sqrt($N) ≈ $x   (dupa 10 iteratii)"
```

Displays the final result: the approximation of the square root of `N` obtained after the 10 iterations. The `≈` symbol underscores that the value is an approximation rather than an exact result. The variables `$N` and `$x` are automatically expanded to their current values.

---

```bash
echo "--------------------------------------"
```

The final separator line, closing the results block.

---

## Closing Remarks (from the Script's Comments)

The comments in section 5 of the script raise an important efficiency concern: if the script is run with `N=9`, the exact square root is `3`. From step 4 onward, the value no longer changes — yet the `for` loop continues regardless until step 10, performing 6 unnecessary calculations.

This is the **structural limitation** of a `for` loop with a fixed iteration count: it cannot evaluate an early termination condition. If automatic stopping upon convergence is desired, one turns to the `while` loop, optionally combined with the `break` instruction (see `heron_WHILE.sh`).

---

## Appendix — Equivalent `for` Loop Variants in Bash

The script mentions four syntactic forms in its comments. All produce the same outcome (10 passes through the loop) but differ in clarity and flexibility:

| Syntax | Form | Remarks |
|---|---|---|
| Explicit list | `for pas in 1 2 3 4 5 6 7 8 9 10; do` | Clear but verbose; impractical for large ranges |
| Brace expansion | `for pas in {1..10}; do` | Concise and easy to read; does not accept variables in place of the bounds |
| `seq` command | `for pas in $(seq 1 $MAX); do` | Flexible — bounds can be variables; invokes an external programme |
| C-style syntax | `for (( pas=1; pas<=10; pas++ )); do` | Familiar to those who know C or Java; permits complex expressions |

---

## Execution Flow — Summary

```
┌─────────────────────────────────────┐
│  Read N from keyboard (read)        │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  N is empty?    → Error + exit      │
│  N not digits?  → Error + exit      │
│  N is 0?        → Display 0 + exit  │
└────────────────┬────────────────────┘
                 │  (validation passed)
                 ▼
┌─────────────────────────────────────┐
│  Initial estimate: x = N / 2        │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  FOR pas = 1 to 10:                 │
│    x = ( x + N/x ) / 2             │
│    Display current step             │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│  Display result: sqrt(N) ≈ x        │
└─────────────────────────────────────┘
```
