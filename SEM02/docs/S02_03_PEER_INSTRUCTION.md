# Peer Instruction - Questions for Seminar 3-4
## Operating Systems | Operators, Redirection, Filters, Loops

Document: S02_03_PEER_INSTRUCTION.md  
Total questions: 18 (minimum 15 required)  
Time per question: 3-5 minutes  
Format: Individual vote → Pair discussion → Revote → Explanation

---

## Peer Instruction Protocol

### Standard Voting Procedure

For each question in this document, follow this protocol:

1. **Display question** (30 seconds for reading)
2. **Individual vote** — Students vote A/B/C/D silently (no discussion)
3. **Record distribution** — Note percentages on board: A:__% B:__% C:__% D:__%
4. **Decision point:**
   - If **>70% correct**: Brief explanation, move on
   - If **30-70% correct**: Peer discussion (2-3 min), then re-vote
   - If **<30% correct**: Mini-lecture needed before re-vote
5. **Reveal answer** with explanation (2 min)

### Optimal Conditions

- **Target first-vote accuracy:** 40-60% (maximises learning from discussion)
- **Discussion groups:** 2-3 students with different initial answers
- **Re-vote improvement:** Expect 20-30% increase after discussion

### Question Notation

Each question includes:
- **Bloom level:** Cognitive level being assessed
- **Misconception target:** Which common error this question tests
- **Distractor analysis:** Why wrong answers are tempting

---

## USAGE PROTOCOL

### Time Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  0:00   0:30   1:00   1:30   2:00   2:30   3:00   3:30   4:00   4:30  5:00 │
│    │      │      │      │      │      │      │      │      │      │     │  │
│    ├──────┴──────┼──────┴──────┴──────┼──────┴──────┴──────┼─────────────┤  │
│    │   PRESENT   │   INDIVIDUAL VOTE  │   PAIR DISCUSSION │   REVOTE +  │  │
│    │   PROBLEM   │     (silent)       │   (active, noisy) │  EXPLANATION│  │
│    │    30 sec   │       1 min        │      2.5 min      │    1 min    │  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Interpreting Vote Results

| % Correct | Interpretation | Action |
|-----------|----------------|--------|
| < 30% | Concept not understood | Explain again, then revote |
| 30-70% | Ideal for PI | Pair discussion, revote |
| > 70% | Too easy or already know | Quick discussion, continue |

### How to use each question

1. Display question on screen (without correct answer!)
2. Read the problem aloud
3. Allow 30-60 seconds for individual thinking
4. Request vote (fingers/cards/digital)
5. Note distribution (example: A:3, B:12, C:5, D:2)
6. Group into pairs for discussion (2-3 minutes)
7. Request revote
8. Explain using instructor notes
9. Demonstrate with code from "After vote" section

---

## CONTROL OPERATORS QUESTIONS

### PI-01: AND vs OR - Order Matters

Level: Fundamental | Duration: 4 min | Target: ~50% correct

```bash
mkdir test && echo "Created" || echo "Error"
```

If the `test` directory ALREADY EXISTS, what is displayed?

```
A) Created
B) Error
C) Created and Error
D) Nothing (command fails silently)
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Doesn't understand that mkdir returns error when directory exists |
| C | Believes `||` always executes after `&&` |
| D | Confusion with 2>/dev/null or doesn't know errors are displayed |

Instructor notes:
- Exit code from `mkdir` when directory exists = non-zero
- `&&` fails (doesn't execute `echo "Created"`)
- Continues with `||` which executes because `&&` chain failed
- Note: If it were `mkdir -p test`, it would return 0!

After vote, demonstrate:
```bash
# Create directory
mkdir test
# Run command
mkdir test && echo "Created" || echo "Error"
# Check with -p too
mkdir -p test && echo "Created with -p" || echo "Error with -p"
# Cleanup
rmdir test
```

---

### PI-02: Pipe vs Exit Code

Level: Intermediate | Duration: 4 min | Target: ~45% correct

```bash
ls /nonexistent | wc -l
echo "Exit code: $?"
```

What will the displayed exit code be?

```
A) Exit code of ls (non-zero, error)
B) Exit code of wc (0, success)
C) Sum of exit codes
D) Syntax error
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes pipe transmits first command's exit code |
| C | Invents non-existent behaviour |
| D | Confusion about pipe syntax |

Instructor notes:
- `$?` returns only the exit code of the last command in pipeline
- For all exit codes: `${PIPESTATUS[@]}`
- `set -o pipefail` changes behaviour (returns first non-zero)

After vote, demonstrate:
```bash
ls /nonexistent | wc -l
echo "Exit code: $?"
echo "PIPESTATUS: ${PIPESTATUS[@]}"

# With pipefail
set -o pipefail
ls /nonexistent | wc -l
echo "With pipefail: $?"
set +o pipefail
```

---

### PI-03: Background and Output

Level: Fundamental | Duration: 3 min | Target: ~60% correct

```bash
sleep 2 &
echo "PID: $!"
echo "Finished?"
```

In what order do the messages appear?

```
A) "PID: xxx", then after 2 seconds "Finished?"
B) "PID: xxx", "Finished?" (immediately, no waiting)
C) "Finished?", "PID: xxx"
D) Error - cannot use $! without wait
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes & doesn't release control |
| C | Doesn't understand execution order |
| D | Invents non-existent restriction |

Instructor notes:
- `&` launches in background and IMMEDIATELY returns control
- `$!` contains PID of last background process
- To wait: `wait $!` or `wait` (all)

After vote, demonstrate:
```bash
sleep 2 &
echo "PID: $!"
echo "Finished? (yes, we didn't wait)"
jobs
wait
echo "Now it really finished"
```

---

### PI-04: Grouping {} vs ()

Level: Intermediate | Duration: 4 min | Target: ~40% correct

```bash
x=1
{ x=2; echo "In braces: $x"; }
echo "After braces: $x"

y=1
( y=2; echo "In parentheses: $y"; )
echo "After parentheses: $y"
```

What are the final displayed values for x and y?

```
A) x=2, y=2
B) x=2, y=1
C) x=1, y=2
D) x=1, y=1
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Doesn't understand subshell |
| C | Inverts behaviour |
| D | Believes both create subshell |

Instructor notes:
- `{}` executes in current shell - modifications persist
- `()` executes in subshell - modifications are lost
- Spaces and `;` in `{}` are mandatory!

After vote, demonstrate:
```bash
# Direct demonstration
x=1
{ x=2; echo "In braces: $x"; }
echo "After braces: $x"  # 2

y=1
( y=2; echo "In parentheses: $y"; )
echo "After parentheses: $y"  # 1!
```

---

## I/O REDIRECTION QUESTIONS

### PI-05: stderr Redirection Order

Level: Intermediate-Advanced | Duration: 5 min | Target: ~35% correct

```bash
# Variant A:
ls /home /nonexistent > out.txt 2>&1

# Variant B:
ls /home /nonexistent 2>&1 > out.txt
```

Which variant sends BOTH (stdout and stderr) to out.txt?

```
A) Variant A
B) Variant B
C) Both variants
D) Neither - must use &>
```

Correct answer: A

| Distractor | Targeted misconception |
|------------|------------------------|
| B | Doesn't understand evaluation order |
| C | Believes order doesn't matter |
| D | Doesn't know classic syntax |

Instructor notes:
- Redirections are evaluated left to right
- Variant A: 
  1. `> out.txt` - stdout goes to out.txt
  2. `2>&1` - stderr goes where stdout is NOW (out.txt)
- Variant B:
  1. `2>&1` - stderr goes where stdout is NOW (terminal)
  2. `> out.txt` - stdout goes to out.txt (stderr stays on terminal!)

After vote, demonstrate:
```bash
# Variant A
ls /home /nonexistent > out_a.txt 2>&1
echo "=== Contents of out_a.txt ==="
cat out_a.txt

# Variant B
ls /home /nonexistent 2>&1 > out_b.txt
echo "=== Contents of out_b.txt ==="
cat out_b.txt
echo "(error appeared on terminal, not in file)"

# Cleanup
rm out_a.txt out_b.txt
```

---

### PI-06: Here String vs Pipe

Level: Fundamental | Duration: 3 min | Target: ~55% correct

```bash
# Variant A:
echo "hello" | tr 'a-z' 'A-Z'

# Variant B:
tr 'a-z' 'A-Z' <<< "hello"
```

What is the output of the two variants?

```
A) A: HELLO, B: HELLO
B) A: HELLO, B: hello
C) A: hello, B: HELLO
D) A: error, B: HELLO
```

Correct answer: A

| Distractor | Targeted misconception |
|------------|------------------------|
| B | Believes <<< doesn't work |
| C | Inverts functionality |
| D | Doesn't know here string |

Instructor notes:
- Both methods are functionally equivalent
- `<<<` (here string) avoids a subprocess (echo)
- `<<<` is more efficient for simple strings
- Bonus: `cmd <<< "$var"` vs `echo "$var" | cmd`

---

### PI-07: /dev/null and Exit Code

Level: Fundamental | Duration: 3 min | Target: ~65% correct

```bash
ls /nonexistent 2>/dev/null
echo $?
```

What is displayed?

```
A) 0 (success, because error was suppressed)
B) Non-zero (error, because directory doesn't exist)
C) Nothing
D) Syntax error
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Frequent: Believes suppressing error = success |
| C | Complete confusion |
| D | Doesn't know syntax |

Instructor notes:
- `>/dev/null` and `2>/dev/null` don't affect exit code
- Only suppresses OUTPUT, doesn't change command behaviour
- Command still fails, we just don't see the message

After vote, demonstrate:
```bash
ls /nonexistent 2>/dev/null
echo "Exit code: $?"  # Non-zero!

# Compare with
ls /home 2>/dev/null
echo "Exit code: $?"  # 0
```

---

## FILTERS QUESTIONS

### PI-08: uniq without sort (CRITICAL! )

Level: Fundamental | Duration: 4 min | Target: ~20-30% correct (very frequent misconception)

```bash
echo -e "a\nb\na\nb" | uniq
```

What does it display?

```
A) a
   b
B) a
   b
   a
   b
C) a
   a
   b
   b
D) Error - uniq requires file
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | 80% believe this! - Don't know uniq removes only CONSECUTIVE |
| C | Believes uniq sorts |
| D | Doesn't know pipes |

Instructor notes:
- CRITICAL: `uniq` removes only **consecutive** duplicates!
- Input: a, b, a, b - none are consecutive → all remain
- Correct pattern: `sort | uniq` or `sort -u`

After vote, demonstrate:
```bash
echo "=== Without sort ==="
echo -e "a\nb\na\nb" | uniq

echo "=== With sort (correct) ==="
echo -e "a\nb\na\nb" | sort | uniq

echo "=== Or sort -u (more efficient) ==="
echo -e "a\nb\na\nb" | sort -u
```

---

### PI-09: cut with tab vs spaces

Level: Intermediate | Duration: 4 min | Target: ~45% correct

```bash
echo "one two three" | cut -f2
```

What does it display?

```
A) two
B) one two three
C) Error
D) (nothing/empty line)
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes cut splits on spaces |
| C | Invents error |
| D | Confusion with empty output |

Instructor notes:
- `cut -f` uses TAB as default delimiter, not space!
- String contains no TAB → returns entire line
- For spaces: `cut -d' ' -f2` or use `awk`

After vote, demonstrate:
```bash
echo "=== With spaces (doesn't work as expected) ==="
echo "one two three" | cut -f2

echo "=== With explicit delimiter ==="
echo "one two three" | cut -d' ' -f2

echo "=== With real tab ==="
printf "one\ttwo\tthree" | cut -f2
```

---

### PI-10: tr characters vs strings

Level: Intermediate | Duration: 4 min | Target: ~50% correct

```bash
echo "hello" | tr 'ell' 'ipp'
```

What does it display?

```
A) hippo
B) hello (nothing changes)
C) hIPPo
D) hippp
```

Correct answer: A

| Distractor | Targeted misconception |
|------------|------------------------|
| A | CORRECT |
| B | Believes nothing matches |
| C | Combination of confusions |
| D | Misunderstands character mapping |

Instructor notes:
- `tr` works character by character, not with strings!
- 'ell' → 'ipp' means: {e→i, l→p, l→p (second l mapped to p)}
- So: h-e-l-l-o → h-i-p-p-o = hippo!

After vote, demonstrate:
```bash
echo "hello" | tr 'ell' 'ipp'
# Output: hippo

# Step by step explanation
echo "Character by character:"
echo "h → h (unchanged)"
echo "e → i"
echo "l → p"
echo "l → p"
echo "o → o (unchanged)"
```

---

## LOOPS QUESTIONS

### PI-11: Brace Expansion with Variables (CRITICAL! )

Level: Intermediate | Duration: 4 min | Target: ~30% correct

```bash
N=5
for i in {1..$N}; do
    echo $i
done
```

What does it display?

```
A) 1
   2
   3
   4
   5
B) {1..5}
C) Syntax error
D) Nothing (empty loop)
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | 70% believe this! - Don't know brace expansion is at parse time |
| C | Believes it's wrong syntax |
| D | Believes loop doesn't execute |

Instructor notes:
- Brace expansion happens before variable expansion!
- `{1..$N}` cannot be expanded because `$N` isn't interpreted yet
- Remains literal: `{1..$N}`
- Loop iterates once with i="{1..$N}"

Solutions:
```bash
# Solution 1: seq
for i in $(seq 1 $N); do echo $i; done

# Solution 2: C-style
for ((i=1; i<=N; i++)); do echo $i; done

# Solution 3: eval (not recommended)
eval "for i in {1..$N}; do echo \$i; done"
```

---

### PI-12: while read in Pipe (CRITICAL! )

Level: Advanced | Duration: 5 min | Target: ~35% correct

```bash
count=0
echo -e "a\nb\nc" | while read line; do
    ((count++))
done
echo "Count: $count"
```

What does it display?

```
A) Count: 3
B) Count: 0
C) Count: 1
D) Error - count not defined
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | 65% believe this! - Don't know subshell problem |
| C | Partially understands |
| D | Variable confusion |

Instructor notes:
- Subshell problem: The right side of pipe runs in subshell!
- Modifications to `count` happen in subshell
- When subshell ends, modifications are lost
- Main shell sees original `count=0`

Solutions:
```bash
# Solution 1: Process substitution
count=0
while read line; do
    ((count++))
done < <(echo -e "a\nb\nc")
echo "Count: $count"  # 3!

# Solution 2: Here string
count=0
while read line; do
    ((count++))
done <<< "$(echo -e 'a\nb\nc')"

# Solution 3: lastpipe (Bash 4.2+)
shopt -s lastpipe
count=0
echo -e "a\nb\nc" | while read line; do ((count++)); done
echo "Count: $count"  # 3!
```

---

### PI-13: break vs exit

Level: Fundamental | Duration: 3 min | Target: ~65% correct

```bash
for i in 1 2 3; do
    if [ $i -eq 2 ]; then
        break
    fi
    echo $i
done
echo "After loop"
```

What is displayed?

```
A) 1
   After loop
B) 1
   (nothing more - script stopped)
C) 1
   2
   After loop
D) 1
   2
   3
   After loop
```

Correct answer: A

| Distractor | Targeted misconception |
|------------|------------------------|
| B | Confuses break with exit |
| C | Believes echo executes before break |
| D | Doesn't understand break |

Instructor notes:
- `break` exits only the loop, not the script
- `exit` would have stopped the script completely
- At i=2, `break` executes before echo

---

### PI-14: for with files containing spaces

Level: Intermediate | Duration: 4 min | Target: ~45% correct

```bash
touch "my file.txt" "another file.txt"
for f in *.txt; do
    echo "File: $f"
done
```

What is displayed?

```
A) File: my file.txt
   File: another file.txt
B) File: my
   File: file.txt
   File: another
   File: file.txt
C) File: my file.txt another file.txt
D) Error - spaces not allowed
```

Correct answer: A

| Distractor | Targeted misconception |
|------------|------------------------|
| B | Believes for splits on spaces |
| C | Believes all combine |
| D | Believes spaces are illegal |

Instructor notes:
- Glob expansion (`*.txt`) preserves whole names with spaces
- Different from: `for f in $(ls *.txt)` which would split!
- Safe pattern: `for f in *.txt` (without $() or backticks)

After vote, demonstrate:
```bash
touch "my file.txt" "another file.txt"

echo "=== Correct: for f in *.txt ==="
for f in *.txt; do
    echo "File: [$f]"
done

echo "=== WRONG: for f in \$(ls *.txt) ==="
for f in $(ls *.txt); do
    echo "File: [$f]"
done

rm "my file.txt" "another file.txt"
```

---

### PI-15: IFS in while read

Level: Advanced | Duration: 4 min | Target: ~40% correct

```bash
echo "a:b:c" | while IFS=: read x y z; do
    echo "x=$x y=$y z=$z"
done
echo "IFS is: [$IFS]"
```

After execution, what value does IFS have in the main shell?

```
A) IFS=":"
B) IFS=" \t\n" (default)
C) IFS="" (empty)
D) Error - IFS cannot be changed in while
```

Correct answer: B

| Distractor | Targeted misconception |
|------------|------------------------|
| A | Believes IFS persists |
| C | Believes it resets to empty |
| D | Invents restriction |

Instructor notes:
- `IFS=: read ...` sets IFS only for the read command
- After read, IFS returns to previous value
- If we had done `IFS=:; read ...` → would persist in subshell

---

## USAGE MATRIX

| Question | Optimal Moment | After which concept | Difficulty |
|----------|----------------|---------------------|------------|
| PI-01 | Min 5 | Intro && and \|\| | ⭐⭐ |
| PI-02 | Min 20 | Pipes | ⭐⭐⭐ |
| PI-03 | Min 30 | Background & | ⭐⭐ |
| PI-04 | Min 35 | Grouping {} () | ⭐⭐⭐ |
| PI-05 | Min 45 | stderr redirection | ⭐⭐⭐⭐ |
| PI-06 | Min 50 | Here string | ⭐⭐ |
| PI-07 | Min 55 | /dev/null | ⭐⭐ |
| PI-08 | Min 65 | Intro uniq | ⭐⭐ (but critical!) |
| PI-09 | Min 70 | cut | ⭐⭐⭐ |
| PI-10 | Min 75 | tr | ⭐⭐⭐ |
| PI-11 | Min 80 | Intro for | ⭐⭐⭐ |
| PI-12 | Min 85 | while read | ⭐⭐⭐⭐ |
| PI-13 | Min 90 | break/continue | ⭐⭐ |
| PI-14 | Min 92 | for with files | ⭐⭐⭐ |
| PI-15 | Min 95 | IFS | ⭐⭐⭐⭐ |

Recommendation: Use 3-4 questions per seminar, chosen strategically.

---

## ANSWER TRACKING TEMPLATE

```
┌───────────────────────────────────────────────────────────────────┐
│ QUESTION: PI-__   DATE: ____   GROUP: ____                        │
├───────────────────────────────────────────────────────────────────┤
│ VOTE 1 (individual):    A: __  B: __  C: __  D: __  Total: __    │
│ VOTE 2 (after discuss): A: __  B: __  C: __  D: __  Total: __    │
├───────────────────────────────────────────────────────────────────┤
│ % Correct V1: ____%      % Correct V2: ____%     Improvement: __% │
├───────────────────────────────────────────────────────────────────┤
│ Observations:                                                     │
│ ____________________________________________________________      │
└───────────────────────────────────────────────────────────────────┘
```

---

*Material for Seminar 3-4 OS | ASE Bucharest - CSIE*  
*Based on Peer Instruction methodology (Mazur, Porter et al.)*
