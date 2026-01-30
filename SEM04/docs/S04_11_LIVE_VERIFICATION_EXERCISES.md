# Live Verification Exercises — Seminar 04

> **Purpose:** Procedural exercises executed in real time during lab  
> **Duration:** 10–15 minutes total  
> **Why:** AI can generate perfect solutions, but cannot execute them live on unique data

---

## Philosophy

The problem with take-home assignments is simple: students can ask ChatGPT.
Even with personalised data, they can describe the task and get working code.

Live exercises flip this: the task happens NOW, on THIS terminal, with data
that did not exist 30 seconds ago. No time to consult AI. Either you know 
the tools or you do not.

> *Real talk: I saw a student last year who submitted perfect homework 
> but could not run `grep -c` during lab. The conversation was... awkward.*

---

## Exercise L1: The Countdown Challenge

**Time:** 3 minutes  
**Difficulty:** Basic  
**Tests:** grep, wc and basic pipeline

### Setup (instructor runs this)
```bash
# Generate unique challenge file with timestamp
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Create file with random content
for i in {1..50}; do
    echo "Line $i: $(shuf -n 1 /usr/share/dict/words 2>/dev/null || echo "word$i") status=$(shuf -e OK ERROR WARNING -n 1)"
done > challenge_${TIMESTAMP}.txt

echo "Challenge file: /tmp/challenge_$$/challenge_${TIMESTAMP}.txt"
echo "SECRET: $(grep -c ERROR challenge_${TIMESTAMP}.txt) errors"
```

### Task (give to student)
"Count how many lines contain 'ERROR' in the challenge file. You have 60 seconds."

### What you are testing
- Can they construct `grep -c ERROR filename`?
- Do they panic or stay calm?
- Do they verify their answer?

### Grading
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
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

cat > config_${TIMESTAMP}.txt << EOF
# Server configuration
server.host=localhost
server.port=$((8000 + RANDOM % 1000))
database.host=localhost
database.name=mydb_${TIMESTAMP}
debug.enabled=true
EOF

echo "File: /tmp/challenge_$$/config_${TIMESTAMP}.txt"
echo "SECRET port: $(grep server.port config_${TIMESTAMP}.txt | cut -d= -f2)"
```

### Task (give to student)
"Replace ALL occurrences of 'localhost' with '127.0.0.1' and display the result. 
Do not modify the original file."

### Expected solution
```bash
sed 's/localhost/127.0.0.1/g' config_*.txt
```

### Common mistakes to watch for
- Forgetting `/g` (only first occurrence replaced)
- Using `-i` (modifies file when asked not to)
- Overcomplicating with awk

---

## Exercise L3: The Aggregation Sprint

**Time:** 5 minutes  
**Difficulty:** Intermediate–Advanced  
**Tests:** awk, associative arrays and calculations

### Setup (instructor runs this)
```bash
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Generate unique sales data
echo "product,quantity,price" > sales_${TIMESTAMP}.csv
for prod in Widget Gadget Gizmo; do
    for i in {1..5}; do
        qty=$((RANDOM % 20 + 1))
        price=$((RANDOM % 50 + 10))
        echo "$prod,$qty,$price"
    done
done >> sales_${TIMESTAMP}.csv

echo "File: /tmp/challenge_$$/sales_${TIMESTAMP}.csv"
echo "SECRET: $(awk -F, 'NR>1 {sum += $2 * $3} END {print sum}' sales_${TIMESTAMP}.csv) total revenue"
```

### Task (give to student)
"Calculate the TOTAL revenue (quantity × price) from the CSV. Skip the header."

### Expected approach
```bash
awk -F, 'NR > 1 { sum += $2 * $3 } END { print sum }' sales_*.csv
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
TIMESTAMP=$(date +%s)
mkdir -p /tmp/challenge_$$
cd /tmp/challenge_$$

# Generate fake access log
for i in {1..100}; do
    ip="192.168.$((RANDOM % 5 + 1)).$((RANDOM % 254 + 1))"
    echo "$ip - - [$(date)] \"GET /page$((RANDOM % 10))\" 200 $((RANDOM % 5000))"
done > access_${TIMESTAMP}.log

# Find the actual top IP for verification
TOP_IP=$(grep -oE '^[0-9.]+' access_${TIMESTAMP}.log | sort | uniq -c | sort -rn | head -1)
echo "File: /tmp/challenge_$$/access_${TIMESTAMP}.log"
echo "SECRET top IP: $TOP_IP"
```

### Task (give to student)
"Find the IP address that appears MOST frequently in the access log. 
Show the count and the IP."

### Expected approach
```bash
grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access_*.log | sort | uniq -c | sort -rn | head -1
```

### Evaluation criteria
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
Take ANY student's working solution and introduce one subtle bug:

**Bug examples:**
```bash
# Original (correct)
awk -F, 'NR > 1 {sum += $4} END {print sum}' file.csv

# Bugged versions:
awk -F, 'NR > 1 {sum += $3} END {print sum}' file.csv  # Wrong column
awk -F, 'NR >= 1 {sum += $4} END {print sum}' file.csv # Includes header  
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

### Before the lab
1. Prepare 2–3 exercises from above
2. Test the setup scripts on your machine
3. Have answer keys ready but hidden

### During the lab
1. Project your terminal (students can see you generate data)
2. Give clear verbal instructions
3. Walk around — no phones, no other tabs
4. Time strictly but fairly

### After
- Quick verbal feedback: "You nailed the grep but struggled with awk's NR"
- Note observations for grade adjustment

---

## Accommodations

- **Extra time:** Add 50% for documented needs
- **Pair exercise:** For struggling students, allow collaboration on ONE exercise
- **Practice mode:** Offer similar exercises (different data) before graded attempt

---

## The Nuclear Option

If you suspect systematic cheating:

1. Pull up their homework code
2. Change ONE thing (variable name or column number)
3. "Make it work with this modification"

Someone who wrote the code can do this in under a minute.
Someone who copied needs to understand the whole thing first.

---

*These exercises evolved from 3 years of catching copiers. 
The live component is essential — it is the only thing AI cannot do for them.*

*Last updated: January 2025*
