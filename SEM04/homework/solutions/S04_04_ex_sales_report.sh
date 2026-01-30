#!/bin/bash
# ============================================================================
# ex4_sales_report.sh - Model Solution
# Sales report: top products, regions, anomalies
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
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================================
# Argument verification
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Usage: $0 <sales_csv>${NC}"
    exit 1
fi

SALES_FILE="$1"
OUTPUT_DIR="./output"
SUMMARY_FILE="$OUTPUT_DIR/sales_summary.txt"

if [[ ! -f "$SALES_FILE" ]]; then
    echo -e "${RED}Error: File '$SALES_FILE' does not exist!${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ============================================================================
# Function: Top Products
# ============================================================================
top_products() {
    echo -e "${CYAN}🏆 TOP 3 PRODUCTS (by revenue):${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        product = $2
        quantity = $3
        price = $4
        revenue = quantity * price
        
        total_rev[product] += revenue
        total_qty[product] += quantity
    }
    END {
        # Descending sort by revenue
        n = asorti(total_rev, products, "@val_num_desc")
        
        for(i=1; i<=3 && i<=n; i++) {
            p = products[i]
            printf "   %d. %-12s - $%\047.2f (%d units)\n", 
                i, p, total_rev[p], total_qty[p]
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Function: Top Regions
# ============================================================================
top_regions() {
    echo -e "${CYAN}🌍 TOP 3 REGIONS:${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        region = $5
        revenue = $3 * $4
        total[region] += revenue
    }
    END {
        n = asorti(total, regions, "@val_num_desc")
        for(i=1; i<=3 && i<=n; i++) {
            r = regions[i]
            printf "   %d. %-8s - $%\047.2f\n", i, r, total[r]
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Function: Top Salesperson per Region
# ============================================================================
top_salesperson_per_region() {
    echo -e "${CYAN}👤 BEST SALESPERSON PER REGION:${NC}"
    echo ""
    
    awk -F',' '
    NR > 1 {
        region = $5
        salesperson = $6
        revenue = $3 * $4
        
        # Composite key region-salesperson
        key = region SUBSEP salesperson
        sales[key] += revenue
        regions[region] = 1
    }
    END {
        for(r in regions) {
            max_rev = 0
            top_person = ""
            for(key in sales) {
                split(key, parts, SUBSEP)
                if(parts[1] == r && sales[key] > max_rev) {
                    max_rev = sales[key]
                    top_person = parts[2]
                }
            }
            printf "   %-8s: %-10s ($%\047.2f)\n", r, top_person, max_rev
        }
    }' "$SALES_FILE" | sort
    
    echo ""
}

# ============================================================================
# Function: Anomaly Detection
# ============================================================================
detect_anomalies() {
    echo -e "${CYAN}⚠️ ANOMALIES DETECTED:${NC}"
    echo ""
    
    local anomalies_found=0
    
    # 1. Check for date gaps
    echo "   Checking for date gaps..."
    local dates
    dates=$(awk -F',' 'NR>1 {print $1}' "$SALES_FILE" | sort -u)
    
    local prev_date=""
    while IFS= read -r date; do
        if [[ -n "$prev_date" ]]; then
            # Calculate difference in days
            local prev_epoch curr_epoch diff
            prev_epoch=$(date -d "$prev_date" +%s 2>/dev/null || echo 0)
            curr_epoch=$(date -d "$date" +%s 2>/dev/null || echo 0)
            
            if [[ $prev_epoch -gt 0 && $curr_epoch -gt 0 ]]; then
                diff=$(( (curr_epoch - prev_epoch) / 86400 ))
                if [[ $diff -gt 1 ]]; then
                    echo -e "   ${YELLOW}- Gap detected: $prev_date → $date ($diff days)${NC}"
                    ((anomalies_found++))
                fi
            fi
        fi
        prev_date="$date"
    done <<< "$dates"
    
    # 2. Check for outlier quantities (> mean + 2*stddev)
    echo "   Checking for unusual quantities..."
    
    awk -F',' '
    NR > 1 {
        qty[NR] = $3
        product[NR] = $2
        date[NR] = $1
        sum += $3
        count++
    }
    END {
        if(count == 0) exit
        
        mean = sum / count
        
        # Calculate stddev
        for(i in qty) {
            variance += (qty[i] - mean)^2
        }
        stddev = sqrt(variance / count)
        
        threshold = mean + 2 * stddev
        
        found = 0
        for(i in qty) {
            if(qty[i] > threshold) {
                printf "   \033[1;33m- Large quantity: %s, %s - %d units (threshold: %.1f)\033[0m\n", 
                    date[i], product[i], qty[i], threshold
                found++
            }
        }
        
        if(found == 0) {
            print "   - No quantity anomalies detected"
        }
    }' "$SALES_FILE"
    
    echo ""
}

# ============================================================================
# Function: Export Summary
# ============================================================================
export_summary() {
    echo -e "${CYAN}📁 Export report: $SUMMARY_FILE${NC}"
    
    {
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║              SALES REPORT - SUMMARY                             ║"
        echo "║   Generated: $(date '+%Y-%m-%d %H:%M:%S')                                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "TOP 3 PRODUCTS (by revenue):"
        awk -F',' 'NR>1 {rev[$2]+=$3*$4; qty[$2]+=$3} END {n=asorti(rev,p,"@val_num_desc"); for(i=1;i<=3&&i<=n;i++) printf "  %d. %s - $%.2f (%d units)\n", i, p[i], rev[p[i]], qty[p[i]]}' "$SALES_FILE"
        echo ""
        echo "TOP 3 REGIONS:"
        awk -F',' 'NR>1 {t[$5]+=$3*$4} END {n=asorti(t,r,"@val_num_desc"); for(i=1;i<=3&&i<=n;i++) printf "  %d. %s - $%.2f\n", i, r[i], t[r[i]]}' "$SALES_FILE"
        echo ""
        echo "GENERAL STATISTICS:"
        awk -F',' 'NR>1 {total+=$3*$4; items+=$3; trans++} END {printf "  Total Revenue: $%.2f\n  Total Items: %d\n  Transactions: %d\n  Average Revenue/Transaction: $%.2f\n", total, items, trans, total/trans}' "$SALES_FILE"
    } > "$SUMMARY_FILE"
    
    echo -e "  ${GREEN}✅ Report saved!${NC}"
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              SALES REPORT - JANUARY 2024                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

top_products
top_regions
top_salesperson_per_region
detect_anomalies
export_summary

echo -e "${GREEN}✅ Complete report generated!${NC}"
