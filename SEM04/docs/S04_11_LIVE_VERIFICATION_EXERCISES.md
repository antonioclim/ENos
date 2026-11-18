# Live Verification Exercises — Seminar 04

> **Purpose:** Procedural exercises executed in real time during lab  
> **Duration:** 10–15 minutes total  
> **Evidence:** Fresh fixtures test observable understanding; they do not prove authorship or exclude assistance.

---

## Philosophy

Use a clear, bounded task and record the observed command, result and explanation.
A model/tool may generate or execute code on new data; time pressure is not an
authorship test. Nervousness, typing speed and a single failed response do not
establish misconduct. The retained author anecdotes below have no accompanying
cohort dataset and are not a validated detector.

Every setup creates an independent owned attempt directory. Instructor answer
files belong in a separate private directory and must not be projected or copied
with student fixtures. The public document itself offers no confidentiality; any
private release strategy and grading/accommodation policy remain open author
decisions, as recorded in [assessment status](../homework/ASSESSMENT_STATUS.md).

> *Real talk: I saw a student last year who submitted perfect homework 
> but could not run `grep -c` during lab. The conversation was... awkward.*

---

## Exercise L1: The Countdown Challenge

**Time:** 3 minutes  
**Difficulty:** Basic  
**Tests:** grep, wc and basic pipeline

### Setup (instructor runs this)
```bash
# Generate a fresh attempt, even on repeated runs in the same second.
ATTEMPT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-live.XXXXXX") || exit 1
INSTRUCTOR_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-answers.XXXXXX") || exit 1
cd -- "$ATTEMPT_DIR" || exit 1

# Create file with random content
for i in {1..50}; do
    echo "Line $i: $(shuf -n 1 /usr/share/dict/words 2>/dev/null || echo "word$i") status=$(shuf -e OK ERROR WARNING -n 1)"
done > challenge.txt

echo "Challenge file: $ATTEMPT_DIR/challenge.txt"
count=$(grep -c ERROR challenge.txt); rc=$?
case $rc in 0|1) printf '%s\n' "$count" > "$INSTRUCTOR_DIR/expected.txt" ;; *) exit "$rc" ;; esac
```

### Task (give to student)
"Count how many lines contain 'ERROR' in the challenge file. You have 60 seconds."

### What you are testing
- Can they construct `grep -c ERROR filename`?
- Can they explain what the count means and distinguish status 1 from a read error?
- Do they verify their answer?

### Retained Feedback Bands — Pending Assessment Policy
| Result | Grade |
|--------|-------|
| Correct within 30s | Excellent |
| Correct within 60s | Good |
| Correct with hint ("use -c") | Pass |
| Incorrect or timeout | Needs practice |

---

## Exercise L2: The Transformation Race

**Time:** 5 minutes  
**Difficulty:** Intermediate  
**Tests:** sed substitution

### Setup (instructor runs this)
```bash
# Generate a config file with unique values
ATTEMPT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-live.XXXXXX") || exit 1
INSTRUCTOR_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-answers.XXXXXX") || exit 1
cd -- "$ATTEMPT_DIR" || exit 1

cat > config.txt << EOF
# Server configuration
server.host=localhost
server.backends=localhost,localhost
server.port=$((8000 + RANDOM % 1000))
database.host=localhost
database.name=mydb_${RANDOM}
debug.enabled=true
EOF

echo "File: $ATTEMPT_DIR/config.txt"
sed 's/localhost/127.0.0.1/g' config.txt > "$INSTRUCTOR_DIR/expected.txt"
```

### Task (give to student)
"Replace ALL occurrences of 'localhost' with '127.0.0.1' and display the result. 
Do not modify the original file."

### Expected solution
```bash
sed 's/localhost/127.0.0.1/g' config.txt
```

### Common mistakes to watch for
- Forgetting `/g` (only first occurrence replaced)
- Using `-i` (modifies file when asked not to)
- An equivalent AWK solution is technically correct unless the stated objective explicitly requires sed. The repeated localhost on one line now distinguishes /g from first-only substitution

---

## Exercise L3: The Aggregation Sprint

**Time:** 5 minutes  
**Difficulty:** Intermediate–Advanced  
**Tests:** awk, associative arrays and calculations

### Setup (instructor runs this)
```bash
ATTEMPT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-live.XXXXXX") || exit 1
INSTRUCTOR_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-answers.XXXXXX") || exit 1
cd -- "$ATTEMPT_DIR" || exit 1

# Generate unique sales data
echo "product,quantity,price" > sales.csv
for prod in Widget Gadget Gizmo; do
    for i in {1..5}; do
        qty=$((RANDOM % 20 + 1))
        price=$((RANDOM % 50 + 10))
        echo "$prod,$qty,$price"
    done
done >> sales.csv

echo "File: $ATTEMPT_DIR/sales.csv"
awk -F, 'NR>1 {sum += $2 * $3} END {print sum+0}' sales.csv > "$INSTRUCTOR_DIR/expected.txt"
```

### Task (give to student)
"Calculate the TOTAL revenue (quantity × price) from the CSV. Skip the header."

### Expected approach
```bash
awk -F, 'NR > 1 { sum += $2 * $3 } END { print sum+0 }' sales.csv
```

### What you are testing
- Field separator for CSV (`-F,`)
- Skipping header (`NR > 1`)
- Arithmetic in awk (`$2 * $3`)
- END block for final output

---

## Exercise L4: The Pipeline Builder

**Time:** 7 minutes  
**Difficulty:** Advanced  
**Tests:** Multi-stage pipelines and critical thinking

### Setup (instructor runs this)
```bash
ATTEMPT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-live.XXXXXX") || exit 1
INSTRUCTOR_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-answers.XXXXXX") || exit 1
cd -- "$ATTEMPT_DIR" || exit 1

# Generate fake access log
for i in {1..100}; do
    ip="192.168.1.$((RANDOM % 5 + 1))"
    echo "$ip - - [$(date -u +%d/%b/%Y:%H:%M:%S\ +0000)] \"GET /page$((RANDOM % 10)) HTTP/1.1\" 200 $((RANDOM % 5000))"
done > access.log

# Preserve every tie at the maximum, not an arbitrary one-line winner.
awk '{n[$1]++} END {for(ip in n) if(n[ip]>max) max=n[ip]; for(ip in n) if(n[ip]==max) print n[ip],ip}' access.log |
    LC_ALL=C sort -k2,2 > "$INSTRUCTOR_DIR/expected.txt"
printf 'File: %s/access.log\n' "$ATTEMPT_DIR"
```

### Task (give to student)
"Find the IP address that appears MOST frequently in the access log. 
Show the count and every IP tied at the maximum, sorted by IP."

### Expected approach
```bash
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log | sort | uniq -c |
    sort -k1,1nr -k2,2 | awk 'NR==1{max=$1} $1==max{print $1,$2}'
```

### Retained Evaluation Proposal — Pending Policy

Equivalent aggregation with associative arrays can meet the result objective.
A mandated tool/construct must be stated in advance, not inferred from this key.
1. Correct IP extraction: +30%
2. Proper sort | uniq -c: +30%
3. Descending sort for "most": +20%
4. Clean output: +20%

---

## Exercise L5: The Debug Detective

**Time:** 5 minutes  
**Difficulty:** Variable (depends on bug)  
**Tests:** Understanding, not just memorisation

### Setup
Take a disposable copy of a working solution, preserve the original unchanged and introduce one observable bug:

**Bug examples:**
```bash
# Original (correct)
awk -F, 'NR > 1 {sum += $4} END {print sum}' file.csv

# Bugged versions:
awk -F, 'NR > 1 {sum += $3} END {print sum}' file.csv  # Wrong column
awk -F, 'NR > 2 {sum += $4} END {print sum}' file.csv  # Skips the first data row  
awk -F, 'NR > 1 {sum = $4} END {print sum}' file.csv   # Assignment, not addition
awk -F: 'NR > 1 {sum += $4} END {print sum}' file.csv  # Wrong separator
```

### Task
"This command should calculate the total salary but gives wrong result. 
Find and fix the bug."

### What you are testing
- Can they read code critically?
- Do they test incrementally?
- Do they understand each component?

---

## Running Live Exercises

### File Distribution

Give the participant only the exact fixture for the selected exercise (`challenge.txt`,
`config.txt`, `sales.csv` or `access.log`). For an existing owned local participant
folder, use `cp -- "$ATTEMPT_DIR/config.txt" "$STUDENT_DIR/config.txt"` (substitute
the actual one filename). Do not copy the separate answer directory or use `*_*.txt`
globs. State the participant working directory so the expected command resolves
that exact file. Remote distribution is a separately authorised action.

### Before the lab
1. Prepare 2–3 exercises from above
2. Test the setup scripts on your machine
3. Have answer keys ready but hidden

### During the lab
1. Project the student task/data only; generate/store reference answers in the separate instructor workspace, with the display hidden
2. Give clear verbal instructions
3. Walk around — no phones, no other tabs
4. Time strictly but fairly

### After
- Quick verbal feedback: "You nailed the grep but struggled with awk's NR"
- Record observed evidence; grade adjustment awaits the approved assessment contract

---

## Retained Accommodation Proposals — Confirm Against the Applicable Course Policy

- **Extra time:** Add 50% for documented needs
- **Pair exercise:** For struggling students, allow collaboration on ONE exercise
- **Practice mode:** Offer similar exercises (different data) before graded attempt

---

## Follow-up Exercise and Retained Author Perspective

A further technical exercise can gather additional understanding evidence:

1. Open a disposable copy of the submitted code
2. Change ONE thing (variable name or column number)
3. "Make it work with this modification"

Do not use a one-minute threshold as proof of authorship. Record what the student
can explain and test; any misconduct process needs separate evidence and the
applicable institutional policy.

---

> Retained author provenance: “These exercises evolved from 3 years of catching copiers.”
> The original claim that live work is something AI cannot do is not established
> by the supplied evidence and is not an operational guarantee.

*Last updated: January 2025*
