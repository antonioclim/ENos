#!/usr/bin/env bash
# ex4_sales_report.sh - Model Solution
# Author: [Instructor] | Version: 1.1 (portable AWK, explicit ties/empty data)
set -euo pipefail
export LC_ALL=C
if [[ ${1-} == --help && $# == 1 ]]; then echo "Usage: $0 SALES_CSV (ENOS_OUTPUT_DIR defaults to ./output)"; exit 0; fi
[[ $# == 1 && -f $1 && -r $1 ]] || { echo "Usage: $0 READABLE_SALES_CSV" >&2; exit 2; }
SALES_FILE=$1
awk -F, 'NR==1 {if($0!="Date,Product,Quantity,UnitPrice,Region,Salesperson")bad=1;next}
NF!=6 || /["\r\t]/ || $1 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ || $3 !~ /^[0-9]+$/ || $4 !~ /^[0-9]+([.][0-9]+)?$/ {bad=1}
END {if(NR==0||bad){print "Invalid personalised sales CSV schema" > "/dev/stderr";exit 2}}' "$SALES_FILE"
dates=$(awk -F, 'NR>1{print $1}' "$SALES_FILE" | sort -u)
while IFS= read -r day; do
    [[ -n $day ]] || continue
    parsed=$(date -u -d "$day" +%F) || { echo "Invalid calendar date: $day" >&2; exit 2; }
    [[ $parsed == "$day" ]] || { echo "Noncanonical date: $day" >&2; exit 2; }
done <<< "$dates"
OUTPUT_DIR=${ENOS_OUTPUT_DIR:-./output}
[[ ! -L $OUTPUT_DIR ]] || { echo 'Output directory must not be a symlink' >&2; exit 2; }
mkdir -p -- "$OUTPUT_DIR"
SUMMARY_FILE="$OUTPUT_DIR/sales_summary.txt"
[[ ! -e $SUMMARY_FILE && ! -L $SUMMARY_FILE ]] || { echo "Refusing existing output: $SUMMARY_FILE" >&2; exit 2; }
tmp=$(mktemp "$OUTPUT_DIR/.sales.XXXXXX") || exit 1
trap 'rm -f -- "$tmp"' EXIT
render_report() {
    printf '=== SALES REPORT ===\nGenerated UTC: %s\n' "$(date -u +%FT%TZ)"
    printf '\nTOP 3 PRODUCTS (revenue descending, lexical tie order):\n'
    awk -F, 'NR>1{r[$2]+=$3*$4;q[$2]+=$3}END{for(p in r)printf "%.2f\t%s\t%d\n",r[p],p,q[p]}' "$SALES_FILE" |
        sort -t$'\t' -k1,1nr -k2,2 | awk -F'\t' 'NR<=3{printf "%d. %s - $%.2f (%d units)\n",NR,$2,$1,$3}'
    printf '\nTOP 3 REGIONS (revenue descending, lexical tie order):\n'
    awk -F, 'NR>1{r[$5]+=$3*$4}END{for(p in r)printf "%.2f\t%s\n",r[p],p}' "$SALES_FILE" |
        sort -t$'\t' -k1,1nr -k2,2 | awk -F'\t' 'NR<=3{printf "%d. %s - $%.2f\n",NR,$2,$1}'
    printf '\nBEST SALESPERSON PER REGION (all maximum ties):\n'
    awk -F, 'NR>1{s[$5,$6]+=$3*$4;r[$5]=1}
    END {for(region in r){seen=0;for(k in s){split(k,a,SUBSEP);if(a[1]==region&&(!seen||s[k]>max)){max=s[k];seen=1}}
        for(k in s){split(k,a,SUBSEP);if(a[1]==region&&s[k]==max)printf "%s: %s ($%.2f)\n",region,a[2],s[k]}}}' "$SALES_FILE" | sort
    printf '\nDATE GAPS (UTC calendar days):\n'
    local previous='' epoch previous_epoch gap found=0
    while IFS= read -r day; do
        [[ -n $day ]] || continue
        epoch=$(date -u -d "$day" +%s)
        if [[ -n $previous ]]; then
            gap=$(((epoch-previous_epoch)/86400))
            if ((gap>1)); then printf '%s -> %s (%d days)\n' "$previous" "$day" "$gap";found=1;fi
        fi
        previous=$day;previous_epoch=$epoch
    done <<< "$dates"
    if ((found==0)); then printf 'No gaps among the supplied dates (empty/single-date input has no adjacent pair).\n';fi
    printf '\nQUANTITY OUTLIERS (population standard deviation):\n'
    awk -F, 'NR>1{q[++n]=$3;p[n]=$2;day[n]=$1;sum+=$3}
    END {if(!n){print "Undefined: 0 transactions";exit}mean=sum/n;for(i=1;i<=n;i++)v+=(q[i]-mean)^2;threshold=mean+2*sqrt(v/n)
        printf "Mean %.4f; threshold %.4f\n",mean,threshold
        for(i=1;i<=n;i++)if(q[i]>threshold){printf "%s, %s - %d units\n",day[i],p[i],q[i];found++}
        if(!found)print "No quantities exceed the declared threshold"}' "$SALES_FILE"
    printf '\nGENERAL STATISTICS:\n'
    awk -F, 'NR>1{total+=$3*$4;items+=$3;n++}
    END{printf "Total Revenue: $%.2f\nTotal Items: %d\nTransactions: %d\n",total,items,n
        if(n)printf "Average Revenue/Transaction: $%.2f\n",total/n;else print "Average Revenue/Transaction: undefined (0 transactions)"}' "$SALES_FILE"
}
render_report > "$tmp"
ln -- "$tmp" "$SUMMARY_FILE"
cat -- "$tmp"
printf '\nCreated: %s\nComplete report generated.\n' "$SUMMARY_FILE"
