# Spectacular Demos: Text Processing Magic
## One-Liners and Impressive Tricks

> **Laboratory observation:** note down key commands and the relevant output (2-3 lines) as you work. It helps with debugging and, honestly, by the end you will have a good README without additional effort.
> **Operating Systems** | Bucharest University of Economic Studies - CSIE  
> **Seminar 4** | Wow Factor Demonstrations  
> **Purpose**: Capturing attention and demonstrating the power of text processing

---

## Working Scope and Evidence

These are synthetic local demonstrations, not incident findings, measured speed
benchmarks or proof of teaching effects. Retained anecdotes remain author
observations. Start from the repository root and prepare an owned session:

```bash
SEM04_DIR=$(cd SEM04 && pwd) || exit 1
SHOW_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-s04-show.XXXXXX") || exit 1
export SHOW_DIR SEM04_DIR
ENOS_SEM04_DATA_DIR="$SHOW_DIR/data" ENOS_SEM04_RESOURCE_DIR="$SHOW_DIR/generated" \
    bash "$SEM04_DIR/scripts/bash/S04_01_setup_seminar.sh" || exit 1
cd -- "$SHOW_DIR/data" || exit 1
```

The terminal commands below are local; none contacts the domains/IPs displayed
inside sample text. Interactive `watch`, `tail -f`, nano and browser behaviour
require their actual installed tools and can be stopped with Ctrl+C. Copy the
current owned path explicitly into a second terminal rather than guessing it.

## Demo Philosophy

### Why "Wow Factor"?

Spectacular demos serve multiple pedagogical purposes:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  🎯 SPECTACULAR DEMO PURPOSES                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. HOOK - Capture attention at the beginning of the seminar           │
│                                                                         │
│  2. MOTIVATION - "I want to be able to do that too!"                   │
│                                                                         │
│  3. REAL CONTEXT - Show practical utility                              │
│                                                                         │
│  4. MEMORY - "Wow" moments are retained better                         │
│                                                                         │
│  5. ASPIRATION - Set the bar for what is possible                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### When to Use

- **At the beginning** - Hook to capture attention
- **After difficult concepts** - Reward and mental break
- **At the end** - Summary and motivation for individual study

---

# DEMO 1: LOG ANALYSIS IN SECONDS (Hook Demo)

## The Story
> "The boss comes to you: 'The site was attacked last night. I need a report in 5 minutes: who, from where and what they tried to access.'"

## Setup (pre-seminar)

```bash
# Generate a realistic access.log (2000+ lines)
cd -- "$SHOW_DIR/data" || exit 1

# Script for generation (run BEFORE the seminar)
cat > generate_realistic_log.sh << 'SCRIPT'
#!/bin/bash
# Generate realistic access.log with simulated attacks

ips=("192.168.1.100" "192.168.1.101" "10.0.0.50" "10.0.0.51" 
     "45.33.32.156" "185.220.101.1" "23.129.64.100")
methods=("GET" "POST" "PUT" "DELETE")
paths=("/index.html" "/api/users" "/login" "/admin" "/wp-admin" 
       "/.env" "/config.php" "/admin/login" "/phpmyadmin")
codes=("200" "200" "200" "200" "200" "301" "403" "404" "404" "500")
sizes=("1234" "5678" "2048" "4096" "512" "256" "0" "128")

for i in $(seq 1 2000); do
    ip=${ips[$RANDOM % ${#ips[@]}]}
    method=${methods[$RANDOM % ${#methods[@]}]}
    path=${paths[$RANDOM % ${#paths[@]}]}
    code=${codes[$RANDOM % ${#codes[@]}]}
    size=${sizes[$RANDOM % ${#sizes[@]}]}
    date=$(LC_ALL=C date -u -d "-$((RANDOM % 1440)) minutes" '+%d/%b/%Y:%H:%M:%S +0000')
    
    echo "$ip - - [$date] \"$method $path HTTP/1.1\" $code $size"
done
SCRIPT
chmod +x generate_realistic_log.sh
./generate_realistic_log.sh > access.log
```

## Live Demo (5 minutes)

### Step 1: Show the Volume (30 sec)

```bash
wc -l access.log
# Output: 2000 access.log

head access.log
# Show the structure
```

**[SAY]**: "2000 synthetic log lines. Inspect the pipeline output; no timed comparison is claimed."

### Step 2: Most Frequent Source Addresses (1 min)

```bash

# Magic one-liner
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5
```

**[SAY]**: "These are the most active addresses in the synthetic fixture. Frequency alone does not establish malicious intent."

### Step 3: What Did They Try to Access? (1 min)

```bash
# Suspicious searches
grep -E '(admin|config|\.env|phpmyadmin)' access.log | awk '{print $7}' | sort | uniq -c | sort -rn
```

**[SAY]**: "The selected path names resemble scanning targets; the fixture does not establish intent or a real incident."

### Step 4: Attack Timeline (1 min)

```bash
# Group by hour
awk '{print $4}' access.log | cut -d: -f1-2 | sort | uniq -c | sort -k2
```

**[SAY]**: "We can inspect the synthetic request distribution by hour, with UTC explicitly applied."

### Step 5: Complete Report (1.5 min)

```bash


# Completed local report: a zero grep count must not stop subsequent sections.
set -o pipefail
count_matches() {
    local pattern=$1 result rc
    result=$(grep -cE -- "$pattern" access.log); rc=$?
    case $rc in 0|1) printf '%s\n' "$result" ;; *) return "$rc" ;; esac
}
printf '=== SYNTHETIC LOG REPORT ===\n\nTop 5 Source IPs:\n'
awk '{print $1}' access.log | sort | uniq -c | sort -rn | sed -n '1,5p'
printf '\nRequests with selected path text:\n'
count_matches '(admin|config|\.env|wp-)' || exit 1
printf '\nFailed Requests (4xx/5xx):\n'
count_matches '" [45][0-9]{2} ' || exit 1
printf '\nPeak hour (first in a declared lexical tie order):\n'
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c | sort -k1,1nr -k2,2 | sed -n '1p'

```

*Personal note: I prefer Bash scripts for simple automations and Python when the logic becomes complex. It is a matter of pragmatism.*
> 💡 In previous labs, I have seen that the most frequent mistake is forgetting quotes around variables with spaces.


**[DRAMATIC PAUSE]**

**[SAY]**: "This is what text processing in Linux means. Today you learn to do this."

---

# DEMO 2: CSV TO HTML TABLE

## The Story
> "You have a CSV with data and need to transform it into an HTML page for a presentation. Choose a parser that matches the input contract; the small AWK example demonstrates simple fields."

## Demo

This AWK example accepts the supplied simple CSV only: unquoted commas and one
record per line. It escapes cell text for HTML. For arbitrary quoted CSV, use a
CSV parser; `-F,` cannot recover embedded commas or multiline fields.

```bash
# Input
cat employees.csv

# Magic transformation
awk -F',' '
function html(value, out,i,c) {
    out=""
    for(i=1;i<=length(value);i++) {
        c=substr(value,i,1)
        if(c=="&") out=out "&amp;"
        else if(c=="<") out=out "&lt;"
        else if(c==">") out=out "&gt;"
        else if(c=="\"") out=out "&quot;"
        else out=out c
    }
    return out
}
BEGIN {
    print "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>Employee Report</title><style>"
    print "table {border-collapse: collapse; width: 100%;}"
    print "th, td {border: 1px solid black; padding: 8px; text-align: left;}"
    print "th {background-color: #4CAF50; color: white;}"
    print "tr:nth-child(even) {background-color: #f2f2f2;}"
    print "</style></head><body><h1>Employee Report</h1><table>"
}
NR == 1 {
    print "<tr>"
    for (i=1; i<=NF; i++) print "<th scope=\"col\">" html($i) "</th>"
    print "</tr>"
    next
}
{
    print "<tr>"
    for (i=1; i<=NF; i++) print "<td>" html($i) "</td>"
    print "</tr>"
}
END {
    print "</table></body></html>"
}' employees.csv > report.html || exit 1

# Show the result
echo "Generated report.html"
ls -la report.html

# Open in browser (if available)
# firefox report.html &
```

**[SAY]**: "A single awk and we have a professional web page. This is automatable for daily reports!"

---

# DEMO 3: REAL-TIME LOG MONITORING

## The Story
> "You want to monitor in real time what is happening on the server, with highlighting for errors."

## Demo

### Terminal 1: Generate Simulated Logs

```bash
# In a separate terminal
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: Request processed successfully"
    sleep 1
    if [ $((RANDOM % 5)) -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Database connection failed"
    fi
    if [ $((RANDOM % 10)) -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: High memory usage detected"


    fi
done >> live.log
```

> 💡 I have observed that students who draw the diagram on paper before writing the code have much better results.


### Terminal 2: Monitoring with Highlighting

```bash
# Watch for errors with colour
tail -f live.log | grep --line-buffered --color=always -E 'ERROR|WARNING|$'
```

### Advanced Version with awk

```bash
tail -f live.log | awk '
/ERROR/   { print "\033[31m" $0 "\033[0m"; fflush(); next }
/WARNING/ { print "\033[33m" $0 "\033[0m"; fflush(); next }
/INFO/    { print "\033[32m" $0 "\033[0m"; fflush(); next }
          { print; fflush() }
'
```

**[SAY]**: "Real-time monitoring with colour coding. Check installed tool options, locale and output buffering in the target lab environment."

---

# DEMO 4: DATA EXTRACTION MAGIC

## The Story
> "You have a long HTML document and need to extract all links and emails."

## Setup

```bash
cat > webpage.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Company Page</title></head>
<body>
    <h1>Contact Us</h1>
    <p>Email us at <a href="mailto:info@company.com">info@company.com</a></p>
    <p>Sales: sales@company.com | Support: support@company.com</p>
    <h2>Useful Links</h2>
    <ul>
        <li><a href="https://docs.company.com/guide">Documentation</a></li>
        <li><a href="https://api.company.com/v2">API Reference</a></li>
        <li><a href="https://github.com/company/repo">GitHub</a></li>
    </ul>
    <footer>
        <p>Visit our <a href="https://blog.company.com">blog</a></p>
        <p>Contact John at john.doe@company.com or Jane at jane@external.org</p>
    </footer>
</body>
</html>
EOF
```

## Demo

### Extract URL-shaped Substrings from the Exact Fixture

```bash
grep -oE 'https?://[^"<>]+' webpage.html | sort -u
```

**Output:**
```
https://api.company.com/v2
https://blog.company.com
https://docs.company.com/guide
https://github.com/company/repo
```

### Extract Email-shaped Substrings from the Exact Fixture

```bash
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' webpage.html | sort -u
```

**Output:**
```
info@company.com
jane@external.org
john.doe@company.com
sales@company.com
support@company.com
```

### Combo: Complete Report

```bash
echo "=== WEBPAGE ANALYSIS ===" && \
echo -e "\n🔗 URLs Found:" && \
grep -oE 'https?://[^"<>]+' webpage.html | sort -u && \
echo -e "\n📧 Emails Found:" && \
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' webpage.html | sort -u
```

---

# DEMO 5: INSTANT FILE RENAMING

## The Story
> "You have 50 files with ugly names and want to rename them according to a pattern."

## Setup

```bash
# Create test files
DEMO_DIR=$(mktemp -d "${TMPDIR:-/tmp}/enos-demo.XXXXXX") || exit 1
# Keep this variable: cleanup may remove only this newly created directory.
trap 'rm -rf -- "$DEMO_DIR"' EXIT
cd -- "$DEMO_DIR" || exit 1
for i in {1..10}; do
    touch "Document $(date -d "-$i days" +%Y%m%d) - Copy ($i).txt"
done
ls
```

## Demo

### The Problem: Complex Names

```
Document 20250119 - Copy (1).txt
Document 20250118 - Copy (2).txt
...
```

### The Solution: Rename with Regex

```bash
# Preview (dry run)
shopt -s nullglob
for f in *.txt; do
    new=$(printf '%s\n' "$f" | sed -E 's/Document ([0-9]+) - Copy \(([0-9]+)\)/doc_\1_v\2/')
    echo "$f -> $new"
done

# Actual execution
for f in *.txt; do
    new=$(printf '%s\n' "$f" | sed -E 's/Document ([0-9]+) - Copy \(([0-9]+)\)/doc_\1_v\2/')
    [[ ! -e "$new" && ! -L "$new" ]] || { echo "Destination exists: $new" >&2; exit 1; }
    mv -- "$f" "$new" || exit 1
done
ls
```

**Output:**
```
doc_20250119_v1.txt
doc_20250118_v2.txt
...
```

**[SAY]**: "Ten owned fixture files have been renamed. Inspect their names; no elapsed-time benchmark is claimed."

---

# DEMO 6: CONFIG FILE TRANSFORMER

## The Story
> "You have a config format and need to transform it into another format for a different application."

## Demo: INI to JSON

The earlier AWK formatter split values at every `=`, omitted JSON escaping and
could print invalid leading-zero numbers. A serializer now preserves embedded
`=`, quotes/backslashes and empty values. Empty input yields `{}`; `008` remains
a string, while canonical nonnegative integers and exact `true`/`false` values
are converted. This explicit demonstration rule is not an inferred application
schema. No value is evaluated as shell code.

```bash
cat > app.ini << 'EOF'
[database]
host=localhost
port=5432
name=myapp

[server]
host=0.0.0.0
port=8080
debug=true

[logging]
level=info
file=/var/log/app.log
EOF

# Parse the declared INI subset and serialise JSON with Python standard library.
# Interpolation is disabled; duplicate sections/keys are rejected. A key before
# any section is invalid. Keys preserve case. Values are trimmed by ConfigParser.
python3 - app.ini <<'PYJSON'
import configparser
import json
import re
import sys
from pathlib import Path

parser = configparser.ConfigParser(interpolation=None, strict=True)
parser.optionxform = str
parser.read_string(Path(sys.argv[1]).read_text(encoding="utf-8"))
if parser.defaults():
    raise SystemExit("DEFAULT inheritance is outside this demonstration contract")
result = {}
for section in parser.sections():
    result[section] = {}
    for key, value in parser.items(section, raw=True):
        if value in ("true", "false"):
            converted = value == "true"
        elif re.fullmatch(r"0|[1-9][0-9]*", value):
            converted = int(value)
        else:
            converted = value
        result[section][key] = converted
print(json.dumps(result, ensure_ascii=False, indent=2))
PYJSON

```

---

# DEMO 7: MARKDOWN TO HTML (Mini Compiler)

## Demo

This is a trusted-fixture substitution exercise, not a complete Markdown compiler
or a safe HTML renderer for arbitrary input. It outputs fragments, does not build
paragraph/list containers and does not resolve nested syntax or escape arbitrary
HTML/URL contexts. Use a real Markdown parser for a published document; do not
present this pedagogical subset as general conversion.

```bash
cat > sample.md << 'EOF'
# Main Title

This is a paragraph with **bold** and *italic* text.

## Section One

- Item 1
- Item 2
- Item 3

## Section Two

Here is some `inline code` and a [link](https://example.com).
EOF

# Mini Markdown compiler
sed -E '
    s/^# (.*)/<h1>\1<\/h1>/
    s/^## (.*)/<h2>\1<\/h2>/
    s/^### (.*)/<h3>\1<\/h3>/
    s/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g
    s/\*([^*]+)\*/<em>\1<\/em>/g
    s/`([^`]+)`/<code>\1<\/code>/g
    s/\[([^]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g
    s/^- (.*)/<li>\1<\/li>/
' sample.md
```

**[SAY]**: "These substitutions illustrate a small trusted Markdown-like subset; compare the gaps with a real parser."

---

# DEMO 8: PROCESS MONITOR ONE-LINER

## Demo

```bash
# Top 5 processes by memory, refresh every 2 seconds
watch -n 2 'ps aux --sort=-%mem | head -6 | awk "{printf \"%-10s %5s %5s %s\n\", \$1, \$3, \$4, \$11}"'
```

## Advanced Version

```bash
# Simple dashboard
watch -n 1 '
echo "=== SYSTEM DASHBOARD $(date "+%H:%M:%S") ==="
echo ""
echo "📊 Top CPU:"
ps aux --sort=-%cpu | head -4 | awk "NR>1 {printf \"  %-15s %5s%%\n\", \$11, \$3}"
echo ""
echo "💾 Top Memory:"
ps aux --sort=-%mem | head -4 | awk "NR>1 {printf \"  %-15s %5s%%\n\", \$11, \$4}"
echo ""
echo "🌐 Local TCP listening sockets:"
if sockets=$(ss -H -ltn); then printf "%s\n" "$sockets" | awk "NF{n++}END{print n+0}"; else echo "Socket inventory failed" >&2; fi
'
```

---

# DEMO 9: ASCII ART GENERATOR

## Fun Demo

```bash
# Banner text
echo "LINUX RULES" | sed 's/./& /g' | figlet -f small 2>/dev/null || \
awk 'BEGIN {
    split("LINUX", chars, "")
    for (i=1; i<=length("LINUX"); i++) printf " %s ", chars[i]
    print ""
}'

# Or a simple pattern
cat << 'EOF'
  _     ___ _   _ _   ___  __
 | |   |_ _| \ | | | | \ \/ /
 | |    | ||  \| | | | |\  / 
 | |___ | || |\  | |_| |/  \ 
 |_____|___|_| \_|\___//_/\_\
                              
     Powered by grep/sed/awk!
EOF
```

---

## Demo Usage Guide

| Demo | When | Duration | Impact |
|------|------|----------|--------|
| Log Analysis | Hook (beginning) | 5 min | ⭐⭐⭐⭐⭐ |
| CSV to HTML | After awk basics | 3 min | ⭐⭐⭐⭐ |
| Real-time Monitor | After grep | 2 min | ⭐⭐⭐⭐ |
| Data Extraction | After regex | 3 min | ⭐⭐⭐⭐⭐ |
| File Renaming | After sed | 3 min | ⭐⭐⭐⭐ |
| Config Transformer | After awk | 4 min | ⭐⭐⭐ |
| Markdown Compiler | Final/Bonus | 3 min | ⭐⭐⭐⭐ |
| Process Monitor | Final | 2 min | ⭐⭐⭐ |
| ASCII Art | Fun break | 1 min | ⭐⭐ |

---

## Demo Checklist

```
□ Sample data prepared
□ Scripts tested
□ Terminal with large font
□ Colours working
□ Backup plan if something does not work
□ Timing practised
□ Comments prepared for each step
```

---

*Spectacular Demos for Operating Systems Seminar 4 | ASE Bucharest - CSIE*


## Retained Author Notes

*(Bash has an ugly syntax, I admit. But it runs everywhere, and that matters enormously in practice.)*
