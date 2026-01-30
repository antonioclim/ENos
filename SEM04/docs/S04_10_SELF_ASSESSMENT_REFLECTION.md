# Self-Assessment and Reflection: Text Processing
## Check Your Understanding - Regex, GREP, SED, AWK

> **Operating Systems** | Bucharest University of Economic Studies - CSIE  
> **Seminar 4** | Self-Assessment Checklist  
> **Time**: 10-15 minutes | **Complete HONESTLY**

---

## Instructions

This self-assessment helps you identify what you have understood and where you need more practice. 

**Rules:**
1. Complete **HONESTLY** - nobody else sees the answers
2. Do not use Google or notes
3. If you are not sure, tick "Not sure"
4. At the end, focus on areas with ❌ or ❓

**Legend:**
- ✅ I can explain to someone else and give examples
- ❓ I have an idea but am not sure about details
- ❌ I do not know / I do not understand

---

# SECTION 1: REGULAR EXPRESSIONS

## 1.1 Basic Metacharacters

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 1 | I know what `.` (dot) does in regex | ☐ | ☐ | ☐ |
| 2 | I know what `^` does outside `[]` | ☐ | ☐ | ☐ |
| 3 | I know what `^` does inside `[]` | ☐ | ☐ | ☐ |
| 4 | I know what `$` does | ☐ | ☐ | ☐ |
| 5 | I know how to escape special characters | ☐ | ☐ | ☐ |

## 1.2 Quantifiers

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 6 | I understand the difference between `*` and `+` | ☐ | ☐ | ☐ |
| 7 | I know what `?` does | ☐ | ☐ | ☐ |
| 8 | I can use `{n,m}` for intervals | ☐ | ☐ | ☐ |
| 9 | I understand that `*` can match zero characters | ☐ | ☐ | ☐ |

## 1.3 BRE vs ERE - The Critical Difference

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 10 | I know that grep by default uses BRE | ☐ | ☐ | ☐ |
| 11 | I know when I need to use `grep -E` | ☐ | ☐ | ☐ |
| 12 | I understand why `grep 'ab+c'` does not work | ☐ | ☐ | ☐ |

### Mini-Test: Can You Answer?

> **Question**: Why does `grep 'a+b'` not find "aab" but `grep -E 'a+b'` does?

Your answer (mental or written):
```

```

---

# SECTION 2: GREP

## 2.1 Basic Options

| # | Option | I know what it does | ✅ | ❓ | ❌ |
|---|--------|---------------------|:--:|:--:|:--:|
| 13 | `-i` | | ☐ | ☐ | ☐ |
| 14 | `-v` | | ☐ | ☐ | ☐ |
| 15 | `-n` | | ☐ | ☐ | ☐ |
| 16 | `-c` | | ☐ | ☐ | ☐ |
| 17 | `-o` | | ☐ | ☐ | ☐ |
| 18 | `-E` | | ☐ | ☐ | ☐ |
| 19 | `-r` | | ☐ | ☐ | ☐ |

## 2.2 Behaviour

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 20 | I know that `-c` counts LINES, not occurrences | ☐ | ☐ | ☐ |
| 21 | I know how to count all occurrences of a pattern | ☐ | ☐ | ☐ |
| 22 | I understand the difference between `-l` and `-L` | ☐ | ☐ | ☐ |

### Mini-Test

> **Question**: How do you count ALL occurrences of the word "error" in a file (not lines)?

Your answer:
```

```

---

# SECTION 3: SED

## 3.1 Substitution

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 23 | I know the `s/old/new/` syntax | ☐ | ☐ | ☐ |
| 24 | I know what the `g` flag does | ☐ | ☐ | ☐ |
| 25 | I know how to use alternative delimiters | ☐ | ☐ | ☐ |
| 26 | I understand what `&` does in replacement | ☐ | ☐ | ☐ |
| 27 | I can use backreferences `\1`, `\2` | ☐ | ☐ | ☐ |

## 3.2 Edit In-Place

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 28 | I know that sed by default does NOT modify the file | ☐ | ☐ | ☐ |
| 29 | I know the difference between `-i` and `-i.bak` | ☐ | ☐ | ☐ |
| 30 | I understand why `sed ... > file` is dangerous | ☐ | ☐ | ☐ |

## 3.3 Other Commands

| # | Command | I know what it does | ✅ | ❓ | ❌ |
|---|---------|---------------------|:--:|:--:|:--:|
| 31 | `d` | | ☐ | ☐ | ☐ |
| 32 | `/pattern/d` | | ☐ | ☐ | ☐ |
| 33 | `1,5d` | | ☐ | ☐ | ☐ |

### Mini-Test

> **Question**: What command do you use to replace ALL occurrences of "localhost" with "127.0.0.1" in config.txt, keeping a backup?

Your answer:
```

```

---

# SECTION 4: AWK

## 4.1 Basic Concepts

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 34 | I know what `$0` contains | ☐ | ☐ | ☐ |
| 35 | I know what `$1`, `$2`, etc. contain | ☐ | ☐ | ☐ |
| 36 | I know what `$NF` is | ☐ | ☐ | ☐ |
| 37 | I understand the difference between `NR` and `FNR` | ☐ | ☐ | ☐ |
| 38 | I know how to set the separator (`-F`) | ☐ | ☐ | ☐ |

## 4.2 Print and Printf

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 39 | I know the difference between `print $1 $2` and `print $1, $2` | ☐ | ☐ | ☐ |
| 40 | I can use `printf` for formatting | ☐ | ☐ | ☐ |

## 4.3 Structure and Control

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 41 | I know what `BEGIN { }` does | ☐ | ☐ | ☐ |
| 42 | I know what `END { }` does | ☐ | ☐ | ☐ |
| 43 | I can write simple conditions (`$3 > 100`) | ☐ | ☐ | ☐ |
| 44 | I know how to do calculations (sum, average) | ☐ | ☐ | ☐ |
| 45 | I understand associative arrays | ☐ | ☐ | ☐ |

### Mini-Test

> **Question**: Write an awk command that displays the sum of column 3 from a CSV (skip header).

Your answer:
```

```

---

# SECTION 5: NANO

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 46 | I know how to save (^O) | ☐ | ☐ | ☐ |
| 47 | I know how to exit (^X) | ☐ | ☐ | ☐ |
| 48 | I know how to search (^W) | ☐ | ☐ | ☐ |
| 49 | I know how to cut/paste lines (^K, ^U) | ☐ | ☐ | ☐ |

---

# SECTION 6: PIPELINES

| # | Concept | ✅ | ❓ | ❌ |
|---|---------|:--:|:--:|:--:|
| 50 | I understand how `|` (pipe) works | ☐ | ☐ | ☐ |
| 51 | I know why `sort` must come before `uniq` | ☐ | ☐ | ☐ |
| 52 | I can combine grep, sed, awk in a pipeline | ☐ | ☐ | ☐ |

---

# CALCULATE YOUR SCORE

## Count Your Answers

```
Total ✅: _____ / 52
Total ❓: _____ / 52  
Total ❌: _____ / 52
```

## Interpretation

| Score ✅ | Level | Recommendation |
|----------|-------|----------------|
| 45-52 | Expert | Excellent! Help your colleagues |
| 35-44 | Advanced | Good! Review areas with ❓ |
| 25-34 | Intermediate | OK. Practise more |
| 15-24 | Beginner | Re-read the material |
| 0-14 | Needs attention | Talk to the instructor |

---

# IDENTIFY PRIORITIES

## Where Do I Have the Most ❌ or ❓?

```
☐ Regex basics (1-5)
☐ Quantifiers (6-9)
☐ BRE vs ERE (10-12)
☐ Grep options (13-22)
☐ Sed substitution (23-27)
☐ Sed in-place (28-30)
☐ Awk basics (34-38)
☐ Awk print/printf (39-40)
☐ Awk structure (41-45)
☐ Nano (46-49)
☐ Pipeline (50-52)
```

**Top 3 Areas to Improve:**
1. ________________________________
2. ________________________________
3. ________________________________

---

# REFLECTION

## Questions for Self-Reflection

### 1. What was the most surprising thing I learnt today?

```

```

### 2. Which concept did I find most difficult?

```

```

### 3. How could I use these commands in my projects?

```

```

### 4. What question would I ask if I had 2 minutes with the instructor?

```

```

---

# ACTION PLAN

## For next week, I commit to:

```
☐ Re-read the section about: _________________________

☐ Practise the exercises from: _________________________

☐ Try to use grep/sed/awk for: _________________________

☐ Ask someone (instructor/colleague) about: _________________________
```

---

# MINI-TEST ANSWERS

<details>
<summary>Answer to Mini-Test 1 (BRE vs ERE)</summary>

In BRE (Basic Regular Expression), `+` is a LITERAL character. 
`grep 'a+b'` searches for the exact text "a+b".
With `grep -E` (Extended RE), `+` becomes a quantifier = "1 or more".

</details>

<details>
<summary>Answer to Mini-Test 2 (Count all occurrences)</summary>

```bash
grep -o 'error' file.txt | wc -l
```

`-o` displays each match on a separate line, `wc -l` counts the lines.

</details>

<details>
<summary>Answer to Mini-Test 3 (sed with backup)</summary>

```bash
sed -i.bak 's/localhost/127.0.0.1/g' config.txt
```

`-i.bak` = in-place editing with backup in config.txt.bak
`/g` = global, all occurrences

</details>

<details>
<summary>Answer to Mini-Test 4 (awk sum)</summary>

```bash
awk -F',' 'NR > 1 { sum += $3 } END { print sum }' file.csv
```

`-F','` = comma separator
`NR > 1` = skip header
`sum += $3` = add column 3
`END { print sum }` = display at the end

</details>

---

# RESOURCES FOR FURTHER STUDY

## Online
- [regex101.com](https://regex101.com) - Interactive regex tester
- [awk.js.org](https://awk.js.org) - Awk online
- [sed.js.org](https://sed.js.org) - Sed online

## Books
- "Sed & Awk" by Dale Dougherty
- "The AWK Programming Language" by Aho, Kernighan, Weinberger

## Practice
- Exercises from this seminar
- Process your own logs or data

---

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   "The best way to learn is to do."                                    │
│                                                                         │
│   Practise 15 minutes a day with grep/sed/awk and in 2 weeks          │
│   you will be more efficient than 90% of Linux users.                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*Self-Assessment for Operating Systems Seminar 4 | ASE Bucharest - CSIE*
