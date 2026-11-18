#!/usr/bin/env bash
# ex2_log_analyzer.sh - Model Solution
# Author: [Instructor] | Version: 1.1 (schema-aware, explicit denominator)
set -euo pipefail
export LC_ALL=C
if [[ ${1-} == --help && $# == 1 ]]; then echo "Usage: $0 SERVER_LOG"; exit 0; fi
[[ $# == 1 && -f $1 && -r $1 ]] || { echo "Usage: $0 READABLE_SERVER_LOG" >&2; exit 2; }
awk -F'[][]' '
/^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\] \[(INFO|WARNING|ERROR|DEBUG)\] / {
    ts=$2; level=$4; count[level]++; valid++
    if(first=="" || ts<first) first=ts
    if(ts>last) last=ts
    lower=tolower($0)
    if(lower ~ /authentication failed|auth.*failed|failed.*login|denied|invalid credentials/) {
        user="unknown"; ip="unknown"
        if(match($0,/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/)) user=substr($0,RSTART,RLENGTH)
        if(match($0,/([0-9]{1,3}\.){3}[0-9]{1,3}/)) ip=substr($0,RSTART,RLENGTH)
        auth[++n_auth]=sprintf("[%s] %s from %s",ts,user,ip)
    }
    next
}
{malformed++}
END {
    print "=== SEVERITY DISTRIBUTION ==="
    levels[1]="INFO";levels[2]="WARNING";levels[3]="ERROR";levels[4]="DEBUG"
    for(i=1;i<=4;i++) {
        level=levels[i]
        if(valid) printf "%s: %d (%.2f%%)\n",level,count[level]+0,count[level]*100/valid
        else printf "%s: 0 (percentage undefined: 0 valid records)\n",level
    }
    printf "Valid records (percentage denominator): %d\nMalformed records excluded: %d\n",valid+0,malformed+0
    print "\n=== FAILED AUTHENTICATION TEXT ==="
    for(i=1;i<=n_auth;i++) print auth[i]
    if(!n_auth) print "No matching text in valid records"
    print "\n=== GENERAL STATISTICS ==="
    printf "Input records: %d\nTotal valid events: %d\n",NR,valid+0
    if(valid) {
        printf "Period: %s -> %s (timezone not specified in input)\n",first,last
        printf "Errors: %d (%.2f%% of valid records)\n",count["ERROR"]+0,count["ERROR"]*100/valid
    } else print "Period and error rate: undefined (0 valid records)"
    if(malformed) {print "Partial report: malformed records require review" > "/dev/stderr"; exit 2}
    print "Analysis complete; textual matches are not an incident verdict."
}' "$1"
