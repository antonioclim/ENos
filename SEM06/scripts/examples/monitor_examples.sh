#!/usr/bin/env bash
# Sourceable, local teaching functions. No service or notification actions.
log_error() { printf '%s\n' "$*" >&2; }

cpu_totals() {
    awk 'NR==1 { if ($1!="cpu" || NF<9) exit 1;
        total=0; for(i=2;i<=9;i++){if($i !~ /^[0-9]+$/) exit 1; total+=$i}
        printf "%.0f %.0f\n",total,$5+$6; ok=1 } END {if(!ok) exit 1}'
}

get_cpu_usage() {
    local first second values1 values2 total1 idle1 total2 idle2 elapsed idle_elapsed
    [[ -r /proc/stat ]] || { log_error "CPU counters are unavailable"; return 1; }
    first=$(grep '^cpu ' /proc/stat) || return 1
    sleep "${CPU_SAMPLE_INTERVAL:-0.5}" || return 1
    second=$(grep '^cpu ' /proc/stat) || return 1
    # Sum user..steal only; guest/guest_nice are already in user/nice.
    # This model treats idle+iowait as non-busy time; invalid intervals are unavailable.
    values1=$(cpu_totals <<< "$first") || return 1
    values2=$(cpu_totals <<< "$second") || return 1
    IFS=' ' read -r total1 idle1 <<< "$values1"
    IFS=' ' read -r total2 idle2 <<< "$values2"
    elapsed=$((total2-total1)); idle_elapsed=$((idle2-idle1))
    (( elapsed > 0 && idle_elapsed >= 0 && idle_elapsed <= elapsed )) || {
        log_error "CPU counters did not yield a valid interval"; return 1;
    }
    printf '%s\n' "$((100 * (elapsed-idle_elapsed) / elapsed))"
}

get_memory_usage() {
    # /proc/meminfo labels kB, conventionally KiB. MemAvailable is required.
    awk '/^(MemTotal|MemAvailable):/ {if($2 !~ /^[0-9]+$/ || $3!="kB") exit 1;v[$1]=$2}
      END {t=v["MemTotal:"];a=v["MemAvailable:"];
        if(!("MemTotal:" in v) || !("MemAvailable:" in v) || t<=0 || a<0 || a>t) exit 1;
        printf "%.0f\n",100*(t-a)/t}' /proc/meminfo
}

get_disk_usage() {
    local table
    table=$(LC_ALL=C df -P -- "${1:-/}") || return 1
    awk 'NR==2 {gsub(/%/,"",$5);if($5 !~ /^[0-9]+$/ || ($5+0)>100) exit 1;print $5;ok=1}
         END {if(!ok)exit 1}' <<< "$table"
}

# ASCII is intentional: byte-oriented tr must not split a multibyte glyph.
draw_bar() {
    local value=${1:-} width=${2:-40} filled empty full_cells
    [[ $value =~ ^[0-9]{1,3}$ && $width =~ ^[1-9][0-9]?$ ]] || return 2
    ((10#$value <= 100 && 10#$width <= 80)) || return 2
    full_cells=$((10#$value * 10#$width / 100))
    printf -v filled '%*s' "$full_cells" ''
    printf -v empty '%*s' "$((10#$width-full_cells))" ''
    printf '[%s%s]' "${filled// /#}" "${empty// /-}"
}
