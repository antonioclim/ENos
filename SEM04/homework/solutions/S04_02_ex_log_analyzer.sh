#!/bin/bash
# ============================================================================
# ex2_log_analyzer.sh - Model Solution
# Log analysis: severity, authentication, statistics
#
# Author: [Instructor]
# Version: 1.0
# ============================================================================
set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# Argument verification
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Usage: $0 <log_file>${NC}"
    exit 1
fi

LOG_FILE="$1"

if [[ ! -f "$LOG_FILE" ]]; then
    echo -e "${RED}Error: File '$LOG_FILE' does not exist!${NC}"
    exit 1
fi

# ============================================================================
# Function: Severity Report
# ============================================================================
severity_report() {
    echo -e "${CYAN}📊 SEVERITY DISTRIBUTION:${NC}"
    echo ""
    
    # Count each severity level
    awk -F'[][]' '
    /\[(INFO|WARNING|ERROR|DEBUG)\]/ {
        level = $2
        count[level]++
        total++
    }
    END {
        # Ordering: INFO, WARNING, ERROR, DEBUG
        levels[1]="INFO"; levels[2]="WARNING"; levels[3]="ERROR"; levels[4]="DEBUG"
        for(i=1; i<=4; i++) {
            l = levels[i]
            if(count[l] > 0) {
                pct = (count[l] / total) * 100
                # Generate visual bar
                bar_len = int(count[l] * 2)
                bar = ""
                for(j=0; j<bar_len && j<30; j++) bar = bar "█"
                printf "  %-10s %3d messages (%5.1f%%) %s\n", l":", count[l], pct, bar
            }
        }
    }' "$LOG_FILE"
    
    echo ""
}

# ============================================================================
# Function: Failed Authentication Attempts
# ============================================================================
failed_auth_report() {
    echo -e "${CYAN}🚨 FAILED AUTHENTICATION ATTEMPTS:${NC}"
    echo ""
    
    # Search for failed authentication patterns
    local found=0
    
    while IFS= read -r line; do
        # Extract timestamp
        local timestamp
        timestamp=$(echo "$line" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
        
        # Extract email/user
        local user
        user=$(echo "$line" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
        
        # Extract IP
        local ip
        ip=$(echo "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -1)
        
        if [[ -n "$timestamp" && -n "$user" ]]; then
            echo -e "  ${RED}[${timestamp}]${NC} ${YELLOW}$user${NC} from ${BLUE}${ip:-unknown}${NC}"
            ((found++))
        fi
    done < <(grep -iE 'authentication failed|auth.*failed|failed.*login|denied' "$LOG_FILE" 2>/dev/null)
    
    if [[ $found -eq 0 ]]; then
        echo "  (No failed attempts detected)"
    fi
    
    echo ""
}

# ============================================================================
# Function: General Statistics
# ============================================================================
general_stats() {
    echo -e "${CYAN}📈 GENERAL STATISTICS:${NC}"
    echo ""
    
    # Extract statistics with AWK
    awk '
    BEGIN {
        first_ts = ""
        last_ts = ""
        total = 0
        errors = 0
    }
    {
        total++
        
        # Extract timestamp (format: YYYY-MM-DD HH:MM:SS)
        if(match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/)) {
            ts = substr($0, RSTART, RLENGTH)
            if(first_ts == "" || ts < first_ts) first_ts = ts
            if(ts > last_ts) last_ts = ts
        }
        
        # Count errors
        if(/\[ERROR\]/) errors++
    }
    END {
        if(total > 0) {
            error_pct = (errors / total) * 100
            printf "  Period:           %s → %s\n", first_ts, substr(last_ts, 12)
            printf "  Total events:     %d\n", total
            printf "  Errors:           %d (%.1f%%)\n", errors, error_pct
            
            # Visual indicator for error rate
            if(error_pct > 20) status = "🔴 CRITICAL"
            else if(error_pct > 10) status = "🟠 WARNING"
            else if(error_pct > 5) status = "🟡 MODERATE"
            else status = "🟢 NORMAL"
            
            printf "  Status:           %s\n", status
        }
    }' "$LOG_FILE"
    
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              LOG ANALYSIS REPORT                           ║${NC}"
echo -e "${BLUE}║   File: $(printf '%-47s' "$LOG_FILE")║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

severity_report
failed_auth_report
general_stats

echo -e "${GREEN}✅ Analysis complete!${NC}"
