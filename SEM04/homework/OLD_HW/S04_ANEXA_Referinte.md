# S04_APPENDIX - Seminar 4 References (Redistributed)

> **Operating Systems** | ASE Bucharest - CSIE  
> Supplementary Material - Text Processing

---

## ASCII Diagrams - Regular Expressions

### The Regex Engine

```
┌──────────────────────────────────────────────────────────────────────┐
│                    REGEX ENGINE - How It Works                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT: "The quick brown fox jumps over the lazy dog"               │
│  PATTERN: /\b\w+o\w+\b/g  (words with 'o' inside)                   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ STEP 1: PATTERN TOKENISATION                                   │ │
│  │                                                                │ │
│  │   \b    WORD BOUNDARY                                         │ │
│  │   \w+   ONE OR MORE WORD CHARS                                │ │
│  │   o     LITERAL 'o'                                           │ │
│  │   \w+   ONE OR MORE WORD CHARS                                │ │
│  │   \b    WORD BOUNDARY                                         │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ STEP 2: MATCHING (for each position in text)                  │ │
│  │                                                                │ │
│  │   Position 0: "The" → \b✓ \w+="Th" o=✗ → FAIL, next           │ │
│  │   Position 4: "quick" → \b✓ \w+="quick" (no 'o') → FAIL       │ │
│  │   Position 10: "brown" → \b✓ \w+="br" o✓ \w+="wn" \b✓ → MATCH │ │
│  │   Position 16: "fox" → \b✓ \w+="f" o✓ \w+="x" \b✓ → MATCH     │ │
│  │   ...                                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ RESULT: ["brown", "fox", "dog"]                       │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

The internal-o pattern needs at least one word character on both sides of `o`;
`over` starts with it and therefore does not match. Slash delimiters and `g` are
diagram notation; GNU grep invocation is `grep -oP '\b\w+o\w+\b'`.

### Quantifiers - Greedy vs Lazy Behaviour

```
┌──────────────────────────────────────────────────────────────────────┐
│                    GREEDY vs LAZY MATCHING                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Text: <div>Hello</div><div>World</div>                             │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ GREEDY: /<div>.*<\/div>/                                       │ │
│  │                                                                │ │
│  │ <div>Hello</div><div>World</div>                               │ │
│  │ ├────────────────────────────────┤                              │ │
│  │ └─ Matches ALL (from first <div> to LAST </div>)               │ │
│  │                                                                │ │
│  │ Result: "<div>Hello</div><div>World</div>"                     │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ LAZY: /<div>.*?<\/div>/                                        │ │
│  │                         ^                                       │ │
│  │                         ? makes the quantifier lazy             │ │
│  │                                                                │ │
│  │ <div>Hello</div><div>World</div>                               │ │
│  │ ├──────────────┤                                                │ │
│  │ └─ Matches MINIMUM (stops at first </div>)                     │ │
│  │                                                                │ │
│  │ Result: "<div>Hello</div>"                                     │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  QUANTIFIERS:                                                        │
│  ┌─────────┬─────────┬────────────────────────────────────────────┐ │
│  │ Greedy  │ Lazy    │ Meaning                                    │ │
│  ├─────────┼─────────┼────────────────────────────────────────────┤ │
│  │ *       │ *?      │ 0 or more                                  │ │
│  │ +       │ +?      │ 1 or more                                  │ │
│  │ ?       │ ??      │ 0 or 1                                     │ │
│  │ {n,m}   │ {n,m}?  │ between n and m                            │ │
│  └─────────┴─────────┴────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

The lazy diagram shows the **first** match. A global search such as GNU
`grep -oP` emits both `<div>Hello</div>` and `<div>World</div>`, on separate lines.

### AWK - Processing Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AWK PROCESSING MODEL                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT FILE                                                          │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ alice 25 developer                                              │ │
│  │ bob 30 manager                                                  │ │
│  │ carol 28 developer                                              │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    BEGIN BLOCK                                  │ │
│  │  Executes ONCE before the first line                           │ │
│  │  BEGIN { print "Name\tAge\tRole"; count = 0 }                  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              MAIN BLOCK (for each line)                        │ │
│  │                                                                │ │
│  │  Line 1: "alice 25 developer"                                  │ │
│  │           ┌─────┬─────┬───────────┐                            │ │
│  │    $0 =   │alice│ 25  │ developer │                            │ │
│  │           └──┬──┴──┬──┴─────┬─────┘                            │ │
│  │              $1    $2       $3        NF=3, NR=1               │ │
│  │                                                                │ │
│  │  Pattern { Action }                                            │ │
│  │  $3 == "developer" { print $1, $2; count++ }                   │ │
│  │  → Pattern TRUE → execute action                               │ │
│  │                                                                │ │
│  │  Line 2: "bob 30 manager"                                      │ │
│  │  → Pattern FALSE → skip                                        │ │
│  │                                                                │ │
│  │  Line 3: "carol 28 developer"                                  │ │
│  │  → Pattern TRUE → execute action                               │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                      END BLOCK                                  │ │
│  │  Executes ONCE after the last line                             │ │
│  │  END { print "Total developers:", count }                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  OUTPUT:                                                             │
│  Name    Age    Role                                                │
│  alice 25                                                           │
│  carol 28                                                           │
│  Total developers: 2                                                │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### SED - Address Ranges

```
┌──────────────────────────────────────────────────────────────────────┐
│                       SED ADDRESS TYPES                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT (numbered lines):                                             │
│  1: # Configuration file                                             │
│  2: host = localhost                                                 │
│  3: port = 8080                                                      │
│  4: # Database settings                                              │
│  5: db_host = 127.0.0.1                                             │
│  6: db_port = 5432                                                   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ NUMBER ADDRESS: sed '3d'  (delete line 3)                      │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ kept                            │ │
│  │   2: host = localhost        ✓ kept                            │ │
│  │   3: port = 8080            ✗ DELETED                          │ │
│  │   4: # Database settings     ✓ kept                            │ │
│  │   ...                                                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ NUMBER RANGE: sed '2,4d'  (delete lines 2-4)                   │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ kept                            │ │
│  │   2: host = localhost       ✗ │                                │ │
│  │   3: port = 8080            ✗ ├── DELETED                      │ │
│  │   4: # Database settings    ✗ │                                │ │
│  │   5: db_host = 127.0.0.1     ✓ kept                            │ │
│  │   6: db_port = 5432          ✓ kept                            │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ REGEX: sed '/^#/d'  (delete lines starting with #)             │ │
│  │                                                                │ │
│  │   1: # Configuration file   ✗ DELETED (^# match)               │ │
│  │   2: host = localhost        ✓ kept                            │ │
│  │   3: port = 8080             ✓ kept                            │ │
│  │   4: # Database settings    ✗ DELETED (^# match)               │ │
│  │   5: db_host = 127.0.0.1     ✓ kept                            │ │
│  │   6: db_port = 5432          ✓ kept                            │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ REGEX RANGE: sed '/^#/,/^db/d'  (from # to db)                 │ │
│  │                                                                │ │
│  │   1: # Configuration file   ✗ │ start range                    │ │
│  │   2: host = localhost       ✗ │                                │ │
│  │   3: port = 8080            ✗ │                                │ │
│  │   4: # Database settings    ✗ │ still inside range                │ │
│  │   5: db_host = 127.0.0.1    ✗ │ end range (^db match)          │ │
│  │   6: db_port = 5432          ✓ kept (after range)              │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ NEGATION: sed '/^#/!d'  (delete everything NOT a comment)      │ │
│  │                       ^                                         │ │
│  │                       ! inverts selection                       │ │
│  │                                                                │ │
│  │   1: # Configuration file    ✓ kept (is a comment)             │ │
│  │   2: host = localhost       ✗ DELETED                          │ │
│  │   3: port = 8080            ✗ DELETED                          │ │
│  │   4: # Database settings     ✓ kept (is a comment)             │ │
│  │   5: db_host = 127.0.0.1    ✗ DELETED                          │ │
│  │   6: db_port = 5432         ✗ DELETED                          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Fully Worked Exercises

### Exercise 1: Extracting Data from Apache Log

The exact fixture has ten whitespace-separated fields: status `$9`, bytes `$10`
and path `$7`. This is not a general Apache parser. Only syntactically valid
status records enter the status denominator; malformed records are counted and
reported separately, never silently treated as a normal code.

```bash
# Create a uniquely owned test file
fixture=$(mktemp "${TMPDIR:-/tmp}/enos-access.log.XXXXXX") || exit 1
cat > "$fixture" << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:15:32 +0200] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:15:33 +0200] "POST /api/users HTTP/1.1" 201 567
10.0.0.50 - - [10/Jan/2025:10:15:34 +0200] "GET /images/logo.png HTTP/1.1" 200 45678
192.168.1.100 - - [10/Jan/2025:10:15:35 +0200] "GET /css/style.css HTTP/1.1" 200 2345
192.168.1.102 - - [10/Jan/2025:10:15:36 +0200] "GET /nonexistent HTTP/1.1" 404 123
192.168.1.100 - - [10/Jan/2025:10:15:37 +0200] "GET /api/data HTTP/1.1" 500 0
10.0.0.51 - - [10/Jan/2025:10:15:38 +0200] "GET /index.html HTTP/1.1" 200 1234
EOF

# === EXERCISE A: Top IPs ===
echo "=== Top IPs ==="
awk '{ count[$1]++ } END { for (ip in count) print count[ip], ip }' "$fixture" | sort -rn
# Output:
# 3 192.168.1.100
# 1 192.168.1.102
# 1 192.168.1.101
# 1 10.0.0.51
# 1 10.0.0.50

# === EXERCISE B: Status Code Distribution ===
echo ""
echo "=== Status Codes ==="
awk 'NF==10 && $9 ~ /^[1-5][0-9][0-9]$/ {codes[$9]++; valid++; next}
{invalid++}
END {
    for (code in codes) printf "%s: %d (%.1f%%)\n", code, codes[code], codes[code]*100/valid
    if (!valid) print "No valid status records; percentages undefined"
    if (invalid) printf "Excluded malformed records: %d\n", invalid > "/dev/stderr"
}' "$fixture" | sort
# Output:
# 200: 4 (57.1%)
# 201: 1 (14.3%)
# 404: 1 (14.3%)
# 500: 1 (14.3%)

# === EXERCISE C: Bytes transferred per resource ===
echo ""
echo "=== Bytes per resource ==="
awk 'NF==10 && $10 ~ /^[0-9]+$/ {total[$7]+=$10}
END {for (url in total) printf "%-30s %d bytes\n", url, total[url]}' "$fixture" |
    sort -k2,2nr -k1,1
# /images/logo.png 45678 bytes
# /index.html 2468 bytes
# /css/style.css 2345 bytes
# ...

# === EXERCISE D: Requests per hour ===
echo ""
echo "=== Requests per hour ==="
awk -F'[\\[:]' '{ hours[$3]++ } END { for (h in hours) print h":00 -", hours[h], "requests" }' "$fixture"

# === EXERCISE E: Only errors (4xx, 5xx) with details ===
echo ""
echo "=== Errors ==="
awk 'NF==10 && $9 ~ /^[45][0-9][0-9]$/ {
    date=$4 " " $5; sub(/^\[/,"",date); sub(/\]$/,"",date)
    request=$6 " " $7 " " $8; sub(/^"/,"",request); sub(/"$/,"",request)
    printf "[%s] %s - %s - %s\n", $9, $1, date, request
}' "$fixture"

# Cleanup
rm "$fixture"
```

### Exercise 2: CSV Processing with AWK

The supplied CSV has unquoted fields, one header, integer quantities and decimal
prices. General quoted CSV requires a CSV parser. Array iteration order is not
guaranteed; compare record sets or explicitly sort for a stable display.

```bash
# Create a uniquely owned test file
fixture=$(mktemp "${TMPDIR:-/tmp}/enos-sales.csv.XXXXXX") || exit 1
cat > "$fixture" << 'EOF'
Date,Product,Quantity,Price,Region
2025-01-01,Laptop,5,1200,North
2025-01-01,Phone,10,800,South
2025-01-02,Laptop,3,1200,East
2025-01-02,Tablet,8,500,North
2025-01-03,Phone,15,800,West
2025-01-03,Laptop,2,1200,South
2025-01-03,Tablet,12,500,East
EOF

# === A: Total sales per product ===
echo "=== Sales per product ==="
awk -F',' 'NR>1 { 
    qty[$2] += $3
    revenue[$2] += $3 * $4 
} 
END { 
    printf "%-10s %8s %12s\n", "Product", "Qty", "Revenue"
    printf "%-10s %8s %12s\n", "-------", "---", "-------"
    for (p in qty) 
        printf "%-10s %8d $%11.2f\n", p, qty[p], revenue[p]
}' "$fixture"

# === B: Total per region ===
echo ""
echo "=== Sales per region ==="
awk -F',' 'NR>1 { 
    region[$5] += $3 * $4 
} 
END { 
    for (r in region) 
        printf "%s: $%.2f\n", r, region[r]
}' "$fixture" | sort -t'$' -k2 -rn

# === C: Daily average ===
echo ""
echo "=== Daily average ==="
awk -F',' 'NR>1 { 
    daily[$1] += $3 * $4
    days[$1] = 1
} 
END { 
    total = 0
    for (d in daily) total += daily[d]
    print "Total:", total
    print "Days:", length(days)
    if(length(days)) print "Average/day:", total/length(days)
    else print "Average/day: undefined (0 days)"
}' "$fixture"

# === D: Pivot table - Product x Region ===
echo ""
echo "=== Pivot: Product x Region ==="
awk -F',' 'NR>1 { 
    pivot[$2,$5] += $3 * $4
    products[$2] = 1
    regions[$5] = 1
}
END {
    # Header
    printf "%-10s", ""
    for (r in regions) printf "%10s", r
    print ""
    
    # Rows
    for (p in products) {
        printf "%-10s", p
        for (r in regions) {
            if ((p,r) in pivot)
                printf "%10.0f", pivot[p,r]
            else
                printf "%10s", "-"
        }
        print ""
    }
}' "$fixture"

rm "$fixture"
```

### Exercise 3: Complete Text Analysis Script

```bash
#!/usr/bin/env bash
# text_analyzer.sh - local text statistics, no file changes
set -euo pipefail
[[ $# == 1 && -f $1 && -r $1 ]] || { echo "Usage: $0 READABLE_FILE" >&2; exit 2; }
FILE=$1
printf '=== Analysis: %s ===\n' "$FILE"
printf 'Lines: %s\n' "$(wc -l < "$FILE")"
printf 'Words: %s\n' "$(wc -w < "$FILE")"
printf 'Bytes: %s\n' "$(wc -c < "$FILE")"
printf 'Characters in the active locale: %s\n' "$(wc -m < "$FILE")"
printf 'Maximum display width (GNU wc -L): %s columns\n' "$(wc -L < "$FILE")"
nonempty=$(grep -c '.' -- "$FILE") || { rc=$?; ((rc==1)) || exit "$rc"; }
printf 'Non-empty lines: %s\n' "$nonempty"
printf '\n--- Top 10 ASCII words ---\n'
LC_ALL=C tr -cs 'A-Za-z' '\n' < "$FILE" | LC_ALL=C tr 'A-Z' 'a-z' |
    sed '/^$/d' | LC_ALL=C sort | uniq -c | LC_ALL=C sort -rn | sed -n '1,10p'
printf '\n--- ASCII word length distribution ---\n'
LC_ALL=C tr -cs 'A-Za-z' '\n' < "$FILE" | awk '
length>0 {len=length($0); if(len<=3) short++; else if(len<=6) medium++; else long++}
END {
    total=short+medium+long
    if (!total) {print "No ASCII words; percentages undefined"; exit}
    printf "Short (1-3): %d (%.1f%%)\n", short, short*100/total
    printf "Medium (4-6): %d (%.1f%%)\n", medium, medium*100/total
    printf "Long (7+): %d (%.1f%%)\n", long, long*100/total
}'
count_pattern() {
    local pattern=$1
    { grep -oE -- "$pattern" "$FILE" || { rc=$?; ((rc==1)) || exit "$rc"; }; } | wc -l
}
# Lexical teaching patterns: counts do not establish RFC email/URL validity.
email_count=$(count_pattern '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}') || exit 1
url_count=$(count_pattern 'https?://[^[:space:]]+') || exit 1
number_count=$(count_pattern '\b[0-9]+\b') || exit 1
printf '\nEmail-shaped matches: %s\nURL-shaped matches: %s\nInteger words: %s\n' \
    "$email_count" "$url_count" "$number_count"
```

---

## Quick References

### Regex Cheat Sheet

| Pattern | Description | Example |
|---------|-------------|---------|
| `.` | Any character | `a.c` → abc |
| `^` | Start of line | `^Start` |
| `$` | End of line | `end$` |
| `*` | 0 or more | `ab*c` |
| `+` | 1 or more | `ab+c` (ERE) |
| `?` | 0 or 1 | `colou?r` (ERE) |
| `[abc]` | Any from set | `[aeiou]` |
| `[^abc]` | None from set | `[^0-9]` |
| `\b` | Word boundary | `\bword\b` |
| `()` | Group | `(ab)+` (ERE) |
| `\|` | OR | `cat\|dog` (ERE) |

### AWK Quick Reference

```text
# Fields
$0, $1, $NF, NR, NF, FS, OFS

# Patterns
/regex/          # match regex
$1 == "val"      # comparison
NR > 1           # skip header
BEGIN {}         # before input
END {}           # after input

# Functions
length(s), substr(s,i,n), split(s,a,sep)
tolower(s), toupper(s), gsub(r,s,t)
```

### SED Quick Reference

```text
# Substitution
s/old/new/       # first
s/old/new/g      # all
s/old/new/gi     # case-insensitive

# Addresses
5                # line 5
1,10             # lines 1-10
/pattern/        # lines with pattern
/start/,/end/    # range

# Commands
d                # delete
p                # print
i\text           # insert
a\text           # append
```

---
*Supplementary material for the Operating Systems course | ASE Bucharest - CSIE*

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
