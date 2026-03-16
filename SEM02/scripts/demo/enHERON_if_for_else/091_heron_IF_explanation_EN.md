# Heron's Method (Babylonian) — The `IF` Variant

## Line-by-Line Explanation of the Script `heron_IF.sh`

> **Purpose of the script:** computes the square root of a positive integer
> using Heron's iterative method (also known as the Babylonian method),
> with exactly 5 refinement steps written out explicitly, without any loop.
>
> **Dominant control structure:** `if / elif / else / fi`

---

## Section 0 — Script Header

---

```bash
#!/bin/bash
```

The **shebang line** (from *sharp* `#` + *bang* `!`). It tells the operating
system which interpreter to use when the file is executed directly. The path
`/bin/bash` specifies **Bash** (*Bourne-Again Shell*) as the interpreter.
Without this line, the system might fall back to a different default interpreter
(for instance `sh`), which does not support all the constructs used below
(such as `[[ ... =~ ... ]]`).

---

## Section 1 — Reading User Input

---

```bash
read -p "Introdu un numar intreg pozitiv: " N
```

The `read` command halts execution and waits for the user to type text at the
keyboard.

| Element | Role |
|---|---|
| `-p "..."` | The *prompt* option — displays the text between the quotation marks immediately before the cursor, on the same line, removing the need for a separate `echo`. |
| `N` | The name of the variable that will store whatever the user types. From this point onward, the entered value is accessible via `$N`. |

Without the `-p` option, two separate statements would be necessary:

```bash
echo "Introdu un numar intreg pozitiv: "
read N
```

---

## Section 2 — Input Validation

---

### Test 1 — is the field empty?

```bash
if [ -z "$N" ]; then
```

Opens a **conditional block**. The `-z` operator checks whether the string has
**zero** length (meaning the user pressed Enter without typing anything).

| Element | Role |
|---|---|
| `if` | Keyword that begins a decision structure. |
| `[` … `]` | Shorthand for the `test` command. The square brackets *must* be separated from the content by spaces. |
| `-z "$N"` | Returns *true* if the length of `$N` is zero. The double quotes are mandatory — without them, on an empty field, the `test` command receives the wrong number of arguments and raises a syntax error. |
| `; then` | Marks the beginning of the instruction block that executes when the test is true. The `;` character separates two statements on the same line. Alternatively, `then` can be placed on the following line, in which case the `;` is no longer needed. |

---

```bash
    echo "Eroare: nu ai introdus nimic. Rulati din nou."
```

Displays an error message on screen. The `echo` command sends the text between
the quotation marks to standard output (typically the terminal).

---

```bash
    exit 1
```

Immediately terminates the script and returns **exit code 1**. By convention,
code 0 signifies *success*, whilst any non-zero value signifies *failure*.
This code can later be inspected by another script or by the shell itself
(through the special variable `$?`).

---

### Test 2 — does the input contain only digits?

```bash
elif ! [[ "$N" =~ ^[0-9]+$ ]]; then
```

If the first test failed (the field is not empty), execution moves to this
second branch.

| Element | Role |
|---|---|
| `elif` | Short for *else if* — introduces an additional condition, evaluated only when all preceding conditions were *false*. |
| `!` | Logical negation operator. Inverts the result of the test that follows: if the inner test is true, `!` makes it false, and vice versa. |
| `[[ ... ]]` | Extended test construct, specific to the Bash interpreter. Unlike `[ ... ]`, it supports regular expressions and does not strictly require quoting variables in every situation (although quoting remains good practice). |
| `=~` | **Regular expression** matching operator (available only within `[[ ... ]]`). |
| `^[0-9]+$` | The regular expression itself: |

Breakdown of the regular expression:

| Symbol | Meaning |
|---|---|
| `^` | Anchors the match to the **beginning** of the string. |
| `[0-9]` | A character class — matches any digit from 0 to 9. |
| `+` | Quantifier — one or more occurrences of the preceding element. |
| `$` | Anchors the match to the **end** of the string. |

Taken together: the string must consist exclusively of digits, from the first
character to the last. Through negation with `!`, the condition becomes *true*
when the input is **not** composed solely of digits.

---

```bash
    echo "Eroare: '${N}' nu este un intreg pozitiv."
```

Displays the value that was entered directly within the error message, so the
user can see exactly what was typed.

| Element | Role |
|---|---|
| `${N}` | The expanded form of variable reference for `N`. The curly braces explicitly delimit the variable name. They are mandatory when the variable is adjacent to other text (for example `${N}lei`), but represent good practice in all other situations as well. |

---

```bash
    exit 1
```

Same as before — terminates the script with an error code.

---

### Test 3 — the special case N = 0

```bash
elif [ "$N" -eq 0 ]; then
```

If the input passed the first two checks (it is not empty and it contains only
digits), this branch tests whether the value is zero.

| Element | Role |
|---|---|
| `-eq` | **Numerical** comparison operator (*equal*). Compares values as integers, not as character strings. |

Other numerical comparison operators available in Bash:

| Operator | Meaning |
|---|---|
| `-ne` | not equal |
| `-lt` | strictly less than |
| `-le` | less than or equal |
| `-gt` | strictly greater than |
| `-ge` | greater than or equal |

For **string** comparison, `=` or `==` is used instead of `-eq`.

---

```bash
    echo "Radacina patrata a lui 0 este 0."
    exit 0
```

The case `N = 0` is handled separately because Heron's formula involves
division by `x`, and the initial estimate `x = N / 2 = 0` would cause
a **division by zero**. The square root of 0 is trivially 0, so it is
displayed directly and the script exits with a success code.

---

```bash
fi
```

Closes the **entire** `if / elif / else` block. The keyword `fi` is `if`
spelled backwards — the same closing convention as `done` for `for`/`while`
or `esac` for `case`.

---

## Section 3 — Initial Estimate

---

```bash
x=$(echo "scale=6; $N / 2" | bc)
```

This line computes the initial estimate `x = N / 2` with a precision of 6
decimal places.

| Element | Role |
|---|---|
| `$(...)` | **Command substitution.** Executes the command inside and replaces the entire construct with the text that command printed. |
| `echo "scale=6; $N / 2"` | Prepares a mathematical expression as text. `scale=6` sets the number of decimal digits. |
| `\|` | **Pipe.** Sends the output of the command on the left as input to the command on the right. |
| `bc` | **Arbitrary-precision calculator** (*basic calculator*). Bash natively handles only integers — `bc` enables floating-point arithmetic. |

The result (a decimal number with 6 digits after the point) is stored in the
variable `x`.

---

```bash
echo "--------------------------------------"
echo "Numar:  N = $N"
echo "Start:  x = $x   (estimare initiala = N/2)"
echo "--------------------------------------"
```

A purely informational display block. It prints a header showing the value of
`N` and the initial estimate `x`, visually delimited by lines of hyphens.

---

## Section 4 — The 5 Heron Steps (Written Explicitly)

---

### Heron's Formula

The iterative refinement formula is:

$$
x_{\text{new}} = \frac{x_{\text{old}} + \dfrac{N}{x_{\text{old}}}}{2}
$$

**Intuition:** if `x` is greater than `√N`, then `N/x` is less than `√N`.
The arithmetic mean of the two values falls **between** them, hence closer to
the true root. At each step, the error decreases dramatically (quadratic
convergence — the number of correct digits approximately doubles with every
iteration).

---

### Step 1

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
```

Applies Heron's formula once. The old value of `x` is used on the right-hand
side, and the result overwrites the same variable `x`.

The mechanism is identical to that described for the initial estimate:
`echo` constructs the expression, `bc` evaluates it and `$(...)` captures the
result.

---

```bash
echo "Pas 1:  x = $x"
```

Displays the new value after the first refinement.

---

### Steps 2–5

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 2:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 3:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 4:  x = $x"
```

```bash
x=$(echo "scale=6; ($x + $N / $x) / 2" | bc)
echo "Pas 5:  x = $x"
```

Lines identical to step 1, manually repeated four more times.

**This is the intentional pedagogical limitation** of the `IF` variant:
for 5 steps we have 5 copies of the same instruction. If we wanted 100 steps,
we would need 100 identical lines — making the code impossible to maintain.
The `FOR` and `WHILE` variants solve this problem through the use of **loops**.

---

```bash
echo "--------------------------------------"
```

Visual separator before the evaluation section.

---

## Section 5 — Evaluating the Precision of the Result

---

### Computing the Error

```bash
eroare=$(echo "scale=6; $x * $x - $N" | bc)
```

Computes the difference `x² − N`. If `x` were exactly `√N`, this result would
be 0. In practice, with floating-point arithmetic, one obtains a very small
value — positive or negative.

---

### Absolute Value of the Error

```bash
if [ $(echo "$eroare < 0" | bc) -eq 1 ]; then
```

Checks whether the error is negative.

| Element | Role |
|---|---|
| `echo "$eroare < 0" \| bc` | Sends a logical comparison to `bc`. The calculator returns `1` if the condition is true and `0` if it is false. |
| `$(...)` | Captures that `1` or `0`. |
| `-eq 1` | Numerical comparison — if `bc` responded with `1`, the error is negative. |

---

```bash
    eroare=$(echo "scale=6; -1 * $eroare" | bc)
```

If the error was negative, it is multiplied by `−1` to obtain the **absolute
value**. After this, the variable `eroare` will always hold a positive value
(or zero), representing `|x² − N|`.

---

```bash
fi
```

Closes the `if` block for the absolute value computation.

---

### Precision Classification

```bash
if [ $(echo "$eroare < 0.001" | bc) -eq 1 ]; then
```

First branch: tests whether the absolute error is less than 0.001. The
mechanism is identical — `bc` evaluates the comparison and returns `1` or `0`.

---

```bash
    echo "Rezultat: EXCELENT — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.001)"
```

If the error is below 0.001, the result is classified as **excellent**. Both
the approximation and the numerical error are displayed.

---

```bash
elif [ $(echo "$eroare < 0.01" | bc) -eq 1 ]; then
```

Second branch: if the error is not below 0.001, this tests whether it falls
below 0.01.

---

```bash
    echo "Rezultat: BUN      — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (< 0.01)"
```

Result classified as **good** — acceptable precision, yet not ideal.

---

```bash
else
```

Default branch: if neither of the preceding conditions was satisfied, the
error is ≥ 0.01.

---

```bash
    echo "Rezultat: SLAB     — sqrt($N) ≈ $x"
    echo "          Eroarea |x^2 - N| = $eroare  (>= 0.01)"
```

Result classified as **poor**. This can occur for very large values of `N`,
where 5 steps are insufficient for convergence.

---

```bash
fi
```

Closes the `if / elif / else` classification block.

---

```bash
echo "--------------------------------------"
```

Final visual separator — marks the end of the script's output.

---

## Summary — The `IF` Control Structure

| Where `IF` is used | What it decides |
|---|---|
| Section 2 — validation | Empty input? Not a digit? Is it zero? |
| Section 5 — absolute value | Is the error negative? |
| Section 5 — classification | Error < 0.001? < 0.01? otherwise? |

`IF` selects **a single branch** from several possibilities and executes it.
It does not repeat anything — for repetition, the `FOR` and `WHILE` loops
are used, as presented in the subsequent variants of the same algorithm.
