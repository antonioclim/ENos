# S04_TC04 - AWK - Structured Text Processing

> **Operating Systems** | ASE Bucharest - CSIE  
> Laboratory Material - Seminar 4 (Redistributed)

---

> 🚨 **BEFORE STARTING THE ASSIGNMENT**
>
> 1. Download and configure the `002HWinit` package (see STUDENT_GUIDE_EN.md)
> 2. Open a terminal and navigate to `~/HOMEWORKS`
> 3. Start recording with:
>    ```bash
>    python3 record_homework_tui_EN.py
>    ```
>    or the Bash variant:
>    ```bash
>    ./record_homework_EN.sh
>    ```
> 4. Complete the requested data (name, group, assignment number)
> 5. **ONLY THEN** start solving the requirements below

---

## Objectives

> **Personal preference**: AWK is my favourite tool for quick CSV processing. I know pandas exists in Python, but when you have 3 lines of awk vs 15 lines of Python for the same result... time is money!

At the end of this laboratory, the student will be able to:
- Process structured text files with AWK
- Use built-in and user-defined variables
- Implement conditional logic and loops
- Create reports and data transformations

---


## 2. Fields and Built-in Variables

### 2.1 Fields

```bash
$0      # The entire line
$1      # First field
$2      # Second field
...
$NF     # Last field
$(NF-1) # Second to last field
```

### 2.2 Built-in Variables

| Variable | Description |
|----------|-------------|
| `NR` | Current line number (Number of Record) |
| `NF` | Number of fields on current line |
| `FS` | Field Separator (input), default: space/tab |
| `OFS` | Output Field Separator, default: space |
| `RS` | Record Separator (input), default: newline |
| `ORS` | Output Record Separator, default: newline |
| `FILENAME` | Current file name |
| `FNR` | Line number in current file |

### 2.3 Examples

```bash
# Display first column
awk '{ print $1 }' file.txt

# Display last column
awk '{ print $NF }' file.txt

# Display columns 1 and 3
awk '{ print $1, $3 }' file.txt

# With custom separator (CSV)
awk -F',' '{ print $2 }' data.csv

# Multiple separators
awk -F'[,;:]' '{ print $1 }' file.txt
```

---

## 3. Patterns

### 3.1 Pattern Types

```bash
# Regex
awk '/error/' log.txt           # lines with "error"
awk '/^#/' config.txt           # lines starting with #
awk '!/^#/' config.txt          # lines NOT starting with #

# Comparison
awk '$3 > 100' file.txt         # column 3 > 100
awk '$1 == "John"' file.txt     # column 1 is "John"
awk 'NR > 1' file.txt           # skip header (line 1)

# Range
awk '/start/,/end/' file.txt    # from "start" to "end"
awk 'NR==5,NR==10' file.txt     # lines 5-10

# Logical combinations
awk '$3 > 100 && $4 < 50' file.txt
awk '$1 == "A" || $1 == "B"' file.txt
```

### 3.2 BEGIN and END

```bash
# BEGIN - executes before processing
# END - executes after processing

awk 'BEGIN { print "Header" } 
     { print $0 } 
     END { print "Footer" }' file.txt

# Example: count lines
awk 'END { print NR " lines" }' file.txt

# Calculate average
awk '{ sum += $1 } END { print "Average:", sum/NR }' numbers.txt
```

---

## 4. Actions and Printf

### 4.1 Print vs Printf

```bash
# print - simple
awk '{ print $1, $2 }' file.txt           # separated by OFS
awk '{ print $1 " - " $2 }' file.txt      # with custom separator

# printf - formatted (like C)
awk '{ printf "%-10s %5d\n", $1, $2 }' file.txt

# Printf formats
# %s string
# %d integer
# %f float
# %e scientific
# %-10s left-aligned string, 10 characters
# %5d integer, 5 characters
# %.2f float with 2 decimals
```

### 4.2 Printf Examples

```bash
# Formatted table
awk 'BEGIN { printf "%-15s %10s\n", "Name", "Score" }
     { printf "%-15s %10d\n", $1, $2 }' scores.txt

# Percentages
awk '{ printf "%s: %.1f%%\n", $1, $2*100 }' ratios.txt
```

---

## 5. Variables and Operators

### 5.1 User-defined Variables

```bash
# Initialisation
awk 'BEGIN { count = 0 } /error/ { count++ } END { print count }' log.txt

# Variables from command line
awk -v threshold=100 '$3 > threshold' file.txt

# Multiple variables
awk -v min=10 -v max=100 '$1 >= min && $1 <= max' numbers.txt
```

### 5.2 Operators

```bash
# Arithmetic
+  -  *  /  %  ^

# Comparison
==  !=  <  >  <=  >=

# Regex
~     # matches regex
!~    # does not match regex

# Logical
&&  ||  !

# Increment/Decrement
++  --  +=  -=
```

---

## 6. Control Structures

### 6.1 If-Else

```bash
awk '{ 
    if ($3 > 100) 
        print "High:", $1
    else if ($3 > 50) 
        print "Medium:", $1
    else 
        print "Low:", $1 
}' file.txt
```

### 6.2 Loops

```bash
# For loop
awk '{ for (i=1; i<=NF; i++) print $i }' file.txt

# While loop
awk '{ 
    i = 1
    while (i <= NF) { 
        print $i
        i++ 
    } 
}' file.txt

# For-in (for arrays)
awk '{ count[$1]++ } 
     END { for (key in count) print key, count[key] }' file.txt
```

---

## 7. Associative Arrays

```bash
# Frequency counting
awk '{ count[$1]++ } END { for (k in count) print k, count[k] }' file.txt

# Sums by category
awk '{ sum[$1] += $2 } END { for (k in sum) print k, sum[k] }' sales.txt

# Sort output
awk '{ count[$1]++ } END { for (k in count) print k, count[k] }' file.txt | sort -k2 -rn
```

---

## 8. Built-in Functions

### 8.1 String Functions

```bash
length(s)           # string length
substr(s, start, len)   # substring
index(s, target)    # position of target in s
split(s, arr, sep)  # split string into array
gsub(regex, repl, s)    # global replacement
sub(regex, repl, s)     # replace first
tolower(s)          # lowercase
toupper(s)          # uppercase
```

### 8.2 Mathematical Functions

```bash
int(x)      # integer part
sqrt(x)     # square root
sin(x), cos(x), atan2(y,x)
exp(x)      # e^x
log(x)      # natural logarithm
rand()      # random 0-1
srand(seed) # seed for rand
```

### 8.3 Examples

```bash
# Uppercase column 1
awk '{ print toupper($1), $2 }' file.txt

# Extract substring
awk '{ print substr($1, 1, 3) }' file.txt

# Replacement
awk '{ gsub(/old/, "new"); print }' file.txt
```

---

## 9. Complete Examples

### 9.1 Log Processing
```bash
# Top 10 IPs from access log
awk '{ count[$1]++ } 
     END { for (ip in count) print count[ip], ip }' access.log | sort -rn | head -10
```

### 9.2 CSV Report
```bash
# Calculate total per category from CSV
awk -F',' 'NR>1 { sum[$1] += $3 } 
           END { for (cat in sum) printf "%s: $%.2f\n", cat, sum[cat] }' sales.csv
```

### 9.3 Column Transposition
```bash
# Swap columns
awk '{ print $2, $1, $3 }' file.txt

# Reverse column order
awk '{ for (i=NF; i>0; i--) printf "%s ", $i; print "" }' file.txt
```

---

## Cheat Sheet

```bash
# SYNTAX
awk 'pattern { action }' file
awk -F',' '{ print $2 }' file

# FIELDS
$0          entire line
$1, $2...   fields
$NF         last
NR          line number
NF          field count

# PATTERNS
/regex/     regex match
$1 > 10     comparison
NR > 1      skip header
BEGIN {}    before
END {}      after

# PRINT
print $1, $2
printf "%s %d", $1, $2

# CONTROL
if () {} else {}
for (i=1; i<=NF; i++) {}
for (k in arr) {}

# FUNCTIONS
length(), substr(), split()
tolower(), toupper()
gsub(), sub()

# ARRAYS
arr[$1]++
for (k in arr) print k, arr[k]
```

---

## 📤 Completion and Submission

After you have completed all requirements:

1. **Stop recording** by typing:
   ```bash
   STOP_tema
   ```
   or press `Ctrl+D`

2. **Wait** - the script will:
   - Generate the cryptographic signature
   - Automatically upload the file to the server

3. **Check the final message**:
   - ✅ `UPLOAD SUCCESSFUL!` - the assignment has been submitted
   - ❌ If the upload fails, the `.cast` file is saved locally - submit it manually later with the displayed command

> ⚠️ **DO NOT modify the `.cast` file** after generation - the signature becomes invalid!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
