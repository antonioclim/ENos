# Heron's Method (Babylonian) — `WHILE` Loop Implementation in Bash

## General Overview

This script computes the square root of a positive integer using **Heron's method** (also known as the Babylonian method). The chosen control structure is the `while` loop, which permits automatic termination upon reaching convergence — without imposing a fixed iteration count.

The successive refinement formula is:

$$x_{\text{new}} = \frac{x + \frac{N}{x}}{2}$$

The algorithm starts from a coarse estimate ($x = N/2$) and iteratively improves it until the difference between two consecutive values becomes negligible.

---

## Line 1 — Interpreter Declaration

```bash
#!/bin/bash
```

This is the **shebang** line (a contraction of *sharp* `#` and *bang* `!`). The operating system reads it to determine which interpreter shall execute the script. The path `/bin/bash` points to the Bash interpreter. Without this line, the system might attempt to run the script with a different interpreter (for instance `sh`, which does not support all Bash constructs).

---

## Lines 2–16 — Comment Block (Descriptive Header)

```bash
# =============================================================================
# heron_WHILE.sh
# Metoda Heron (Babiloniana) pentru calculul radacinii patrate
# Structura de control folosita: WHILE
#
# Algoritmul:
#   1. Pornim cu estimarea initiala:  x = N / 2
#   2. Rafinam cu:                    x = ( x + N/x ) / 2
#   3. Ne oprim AUTOMAT cand diferenta dintre doua iteratii consecutive
#      este mai mica decat un prag (0.0000001) — convergenta matematica
#
# De ce WHILE aici?
#   WHILE repeta CAT TIMP o conditie este adevarata.
#   Nu stim dinainte cate iteratii sunt necesare — depinde de N.
#   Pentru N=4 converge in ~4 pasi, pentru N=1000000 poate in 20+.
#   WHILE detecteaza convergenta si se opreste exact la momentul potrivit.
#   Aceasta este varianta cea mai corecta algoritmic dintre cele trei.
# =============================================================================
```

The `#` character marks a comment — everything following it on the same line is ignored by the interpreter. This block serves as internal documentation: it explains the script's purpose, the algorithm employed and the rationale behind choosing the `while` loop over `for`. The visual delimiters (`=====`) carry no functional effect; their role is purely aesthetic, providing visual separation.

---

## Section 1 — Reading Input

### Line 23

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

The `read` command reads a line of text from standard input (the keyboard). The `-p` flag (from *prompt*) displays the specified message before awaiting user input. The value typed by the user is stored in the variable `N`. If the user presses Enter without typing anything, the variable `N` remains empty (a zero-length string).

---

## Section 2 — Input Validation

### Lines 30–32 — Empty Field Check

```bash
if [ -z "$N" ]; then
    echo "Eroare: nu ai introdus nimic."
    exit 1
fi
```

- **`[ -z "$N" ]`** — The `-z` operator (from *zero*) tests whether the string `$N` has zero length. The double quotes around `$N` are mandatory: without them, if `N` is empty, the `[` command receives too few arguments and raises a syntax error.
- **`echo`** — Prints the error message to the screen.
- **`exit 1`** — Terminates the script's execution with exit code `1`. By convention, code `0` signals success, whilst any non-zero value signals an error. The operating system and other scripts can read this code to decide how to proceed.
- **`fi`** — Closes the `if` block (the word `if` spelt backwards).

### Lines 34–37 — Numeric Format Check

```bash
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Eroare: '${N}' nu este un intreg pozitiv."
    exit 1
fi
```

- **`[[ ... ]]`** — An extended Bash conditional construct (more flexible than `[ ... ]`). It accepts the `=~` operator for regular expression matching.
- **`=~`** — The regular expression matching operator.
- **`^[0-9]+$`** — The regular expression describing "one or more digits, from the start (`^`) to the end (`$`)". The `+` quantifier requires at least one digit. If `N` contains letters, spaces or other characters, the match fails.
- **`!`** — Negates the test result. Thus the entire condition reads: "if `N` is **not** composed exclusively of digits".
- **`${N}`** — The braces explicitly delimit the variable name within the string. Here they are optional (`$N` would also work), but they clarify where the variable name ends.

### Lines 39–42 — Special Case N = 0

```bash
if [ "$N" -eq 0 ]; then
    echo "sqrt(0) = 0"
    exit 0
fi
```

- **`-eq`** — An arithmetic comparison operator (*equal*). It compares integer numerical values, not character strings (for strings one would use `=`).
- The square root of zero is zero — the result is trivial and requires no iterations. The script displays the answer and terminates with `exit 0` (success).

---

## Section 3 — Initial Estimate and Counter Initialisation

### Line 50

```bash
x=$(echo "scale=8; $N / 2" | bc)
```

This line combines several Bash mechanisms:

- **`$( ... )`** — Command substitution. Bash executes the command inside, captures the text it produces on standard output and replaces the entire `$(...)` construct with that text.
- **`echo "scale=8; $N / 2"`** — Constructs a string containing an instruction for the `bc` calculator. The variable `$N` is replaced by Bash with its value before `echo` outputs the result.
- **`|`** — The *pipe* operator. It redirects the output of the left-hand command (`echo`) to the input of the right-hand command (`bc`).
- **`bc`** — A command-line arithmetic calculator capable of working with decimal numbers (unlike native Bash arithmetic, which only handles integers).
- **`scale=8`** — A `bc` directive that fixes precision to 8 decimal places. Without `scale`, division in `bc` is integer (truncated).

Result: the variable `x` receives the value `N / 2` with 8 decimal places — this is the initial estimate of the root.

### Line 55

```bash
pas=0
```

A straightforward counter initialisation. In Bash, assignment uses no spaces around the `=` sign — writing `pas = 0` would cause Bash to interpret `pas` as a command and `=` with `0` as its arguments.

### Lines 57–60 — Initial State Display

```bash
echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"
```

Four `echo` calls displaying a separator line, the value of `N`, the initial estimate `x` and another separator line. The variables `$N` and `$x` are expanded by Bash inside the double quotes.

---

## Section 4 — The `while` Loop (Algorithm Core)

### Line 82

```bash
while true; do
```

- **`while`** — The keyword that initiates a loop. Bash evaluates the condition; if it returns "true" (exit code 0), it executes the loop body, then re-evaluates the condition.
- **`true`** — A Bash built-in command that always returns exit code 0 (success = true). Consequently, this loop runs indefinitely — its termination depends entirely on the `break` statement within.
- **`do`** — Marks the beginning of the loop body.
- **`;`** — The separator allows `while` and `do` to appear on the same line. Alternatively, `do` could appear on the next line without the semicolon.

### Line 86

```bash
    x_nou=$(echo "scale=8; ($x + $N / $x) / 2" | bc)
```

Heron's formula. The mechanism is identical to the one described for the initial estimate: `echo` builds the expression, `|` sends it to `bc` and `$(...)` captures the result. The round parentheses within the expression control the order of arithmetic operations in `bc`. The computed value is stored in a separate variable (`x_nou`) so that it may be compared with the previous value (`x`).

### Lines 90–91

```bash
    pas=$(( pas + 1 ))
```

- **`$(( ... ))`** — Native Bash arithmetic expansion. It evaluates the expression using integers and returns the result. Unlike `bc`, this requires no external process, but it cannot handle decimals.
- **`pas + 1`** — A simple increment. Inside `$(( ))`, variables do not require the `$` prefix (though they accept it).

### Line 93

```bash
    echo "Pas $pas: x = $x_nou"
```

Displays the current iteration number and the computed value. This line has no influence on the algorithm; its role is purely informational, allowing one to observe the convergence progression.

### Line 97

```bash
    diff=$(echo "scale=8; $x_nou - $x" | bc)
```

Calculates the difference between the new estimate and the previous one. If the algorithm has converged, this difference approaches zero. The value may be negative (if the new estimate is smaller than the previous one), which is why the next block computes the absolute value.

### Lines 101–103 — Absolute Value

```bash
    if [ $(echo "$diff < 0" | bc) -eq 1 ]; then
        diff=$(echo "scale=8; -1 * $diff" | bc)
    fi
```

- **`echo "$diff < 0" | bc`** — Sends a logical comparison to `bc`. The `bc` calculator returns `1` if the expression is true and `0` if it is false.
- **`[ ... -eq 1 ]`** — The Bash test checks whether the result from `bc` equals 1 (meaning the difference is negative).
- **`-1 * $diff`** — Multiplication by −1 to obtain the absolute value. There is no `abs()` function in basic `bc`; this is the classical approach.

### Line 107

```bash
    x=$x_nou
```

Updates the current estimate. From this point onwards, the variable `x` holds the most recent value, and `x_nou` will be overwritten at the next iteration. This line must appear **before** the convergence test but **after** the difference calculation; otherwise the comparison data would be lost.

### Lines 115–117 — Termination Condition

```bash
    if [ $(echo "$diff < 0.0000001" | bc) -eq 1 ]; then
        break
    fi
```

- The mechanism is identical to the absolute value block: `bc` evaluates the logical expression and returns 1 or 0.
- **`0.0000001`** — The convergence threshold ($10^{-7}$). When the difference between two consecutive iterations drops below this value, the algorithm considers that it has reached sufficient precision.
- **`break`** — A Bash command that immediately exits the loop in which it resides (in this case, `while`). Execution continues with the first statement after `done`.

### Line 119

```bash
done
```

Marks the end of the `while` loop body. If `break` has not been executed, Bash returns to evaluating the condition (which is `true`, so the loop continues).

---

## Section 5 — Final Result Display

```bash
echo "--------------------------------------"
echo "Convergenta atinsa in $pas iteratii."
echo "sqrt($N) ≈ $x"
echo "--------------------------------------"
```

Displays the convergence milestone reached, the total number of iterations and the final value of the square root. The `≈` symbol (approximately equal) is a valid UTF-8 character in Bash — it requires no special escape sequences so long as the terminal supports UTF-8 (which is standard on modern systems).

---

## Closing Remarks — Comparison with `for`

The final comment block in the script underscores the fundamental difference between the two approaches:

| Criterion | `for` (fixed iterations) | `while` (convergence-driven) |
|---|---|---|
| Iteration count | Predetermined (e.g. 10) | Determined automatically by the algorithm |
| Risk of too few iterations | Yes, if N is very large | None — continues until the threshold is met |
| Risk of wasted iterations | Yes, if convergence is rapid | None — stops immediately |
| Code complexity | Simpler | Requires difference calculation and `break` |

The challenge posed to students — "what happens if you replace `while true` with `while [ $pas -lt 3 ]`?" — targets the understanding that a fixed iteration count may prove insufficient for large values of N (sacrificing precision) or excessive for small values (wasting computation time).

---

## Execution Flow Diagram

```
┌──────────────────────────┐
│  Read N from keyboard     │
└────────────┬─────────────┘
             ▼
     ┌───────────────┐
     │  N valid?      │──── No ──▶ Display error → Exit
     └───────┬───────┘
             │ Yes
             ▼
     ┌───────────────┐
     │  N == 0?       │──── Yes ─▶ Display "sqrt(0) = 0" → Exit
     └───────┬───────┘
             │ No
             ▼
     ┌───────────────┐
     │  x = N / 2     │
     │  pas = 0       │
     └───────┬───────┘
             ▼
     ┌───────────────────────────┐
     │  x_new = (x + N/x) / 2   │◀──────────────┐
     │  pas = pas + 1            │               │
     │  diff = |x_new − x|      │               │
     │  x = x_new               │               │
     └───────────┬───────────────┘               │
                 ▼                               │
        ┌────────────────┐                       │
        │ diff < 10⁻⁷?   │──── No ──────────────┘
        └───────┬────────┘
                │ Yes
                ▼
     ┌────────────────────┐
     │  Display result     │
     └────────────────────┘
```
