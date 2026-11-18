#!/usr/bin/env bash
# ex3_data_transform.sh - Model Solution
# Author: [Instructor] | Version: 1.1 (personalised schema, portable AWK)
set -euo pipefail
export LC_ALL=C
if [[ ${1-} == --help && $# == 1 ]]; then echo "Usage: $0 EMPLOYEES_CSV (ENOS_OUTPUT_DIR defaults to ./output)"; exit 0; fi
[[ $# == 1 && -f $1 && -r $1 ]] || { echo "Usage: $0 READABLE_EMPLOYEES_CSV" >&2; exit 2; }
CSV_FILE=$1
# Strict teaching subset: exact header, 7 unquoted fields, numeric salary, date shape.
awk -F, '
NR==1 {if($0!="ID,Name,Department,Salary,Email,HireDate,Status") bad=1; next}
NF!=7 || /["\r]/ || $4 !~ /^[0-9]+$/ || $6 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ {bad=1}
END {if(NR==0 || bad) {print "Invalid personalised employee CSV schema" > "/dev/stderr"; exit 2}}
' "$CSV_FILE"
REFERENCE_YEAR=${ENOS_REFERENCE_YEAR:-$(date -u +%Y)}
[[ $REFERENCE_YEAR =~ ^[0-9]{4}$ ]] || { echo 'ENOS_REFERENCE_YEAR must be four decimal digits' >&2; exit 2; }
OUTPUT_DIR=${ENOS_OUTPUT_DIR:-./output}
[[ ! -L $OUTPUT_DIR ]] || { echo 'Output directory must not be a symlink' >&2; exit 2; }
mkdir -p -- "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/employees_updated.csv"
[[ ! -e $OUTPUT_FILE && ! -L $OUTPUT_FILE ]] || { echo "Refusing existing output: $OUTPUT_FILE" >&2; exit 2; }
tmp=$(mktemp "$OUTPUT_DIR/.employees.XXXXXX") || exit 1
trap 'rm -f -- "$tmp"' EXIT
printf '=== EMPLOYEE TABLE ===\n'
awk -F, '
function currency(value,s,out) {
    s=sprintf("%.0f",value);out=""
    while(length(s)>3){out="," substr(s,length(s)-2) out;s=substr(s,1,length(s)-3)}
    return "$" s out
}
BEGIN {printf "%-6s %-24s %-14s %12s %s\n","ID","Name","Department","Salary","Status"}
NR>1 {printf "%-6s %-24s %-14s %12s %s\n",$1,$2,$3,currency($4),$7}
' "$CSV_FILE"
printf '\n=== DEPARTMENT STATISTICS (count, average, min, max) ===\n'
awk -F, 'NR>1 {d=$3;s=$4;count[d]++;sum[d]+=s;if(!(d in min)||s<min[d])min[d]=s;if(!(d in max)||s>max[d])max[d]=s}
END {for(d in count) printf "%s\t%d\t%.2f\t%.0f\t%.0f\n",d,count[d],sum[d]/count[d],min[d],max[d]}' "$CSV_FILE" | sort
awk -F, -v year="$REFERENCE_YEAR" 'BEGIN{OFS=","} NR==1{print $0 ",years_employed";next}
{split($6,parts,"-");$5=tolower($5);if($7=="inactive")$7="on_leave";print $0,year-parts[1]}' "$CSV_FILE" > "$tmp"
# Publish a new file atomically; do not overwrite a prior run or symlink target.
ln -- "$tmp" "$OUTPUT_FILE"
printf '\nCreated: %s\nyears_employed = calendar-year difference from %s (not completed-anniversary tenure).\nTransformation complete.\n' "$OUTPUT_FILE" "$REFERENCE_YEAR"
