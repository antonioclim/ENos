#!/bin/bash
# ============================================================================
# ex3_data_transform.sh - Model Solution
# CSV data transformation: tabular report, statistics, update
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
    echo -e "${RED}Usage: $0 <csv_file>${NC}"
    exit 1
fi

CSV_FILE="$1"
OUTPUT_DIR="./output"

if [[ ! -f "$CSV_FILE" ]]; then
    echo -e "${RED}Error: File '$CSV_FILE' does not exist!${NC}"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ============================================================================
# Function: Format number with thousands separator
# ============================================================================
format_currency() {
    printf "$%'d" "$1"
}

# ============================================================================
# Function: Tabular Report
# ============================================================================
generate_table_report() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                       TECHCORP EMPLOYEE REPORT                             ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC} %-6s │ %-20s │ %-12s │ %10s │ %-8s ${CYAN}║${NC}\n" \
        "ID" "Name" "Department" "Salary" "Status"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    
    # Process CSV and format
    awk -F',' 'NR > 1 {
        id = $1
        name = $2
        dept = $4
        salary = $5
        status = $7
        
        # Format salary with thousands separator
        sal_fmt = sprintf("$%\047d", salary)
        
        # Status colour
        if(status == "active") 
            status_color = "\033[0;32m"  # green
        else 
            status_color = "\033[0;31m"  # red
        
        printf "\033[0;36m║\033[0m %-6s │ %-20s │ %-12s │ %10s │ %s%-8s\033[0m \033[0;36m║\033[0m\n", 
            id, name, dept, sal_fmt, status_color, status
    }' "$CSV_FILE"
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Function: Department Statistics
# ============================================================================
department_stats() {
    echo -e "${CYAN}📊 DEPARTMENT STATISTICS:${NC}"
    echo ""
    echo "┌──────────────┬──────────┬────────────┬────────────┬────────────┐"
    echo "│ Department   │ Employees│ Avg Salary │ Min Salary │ Max Salary │"
    echo "├──────────────┼──────────┼────────────┼────────────┼────────────┤"
    
    awk -F',' '
    NR > 1 {
        dept = $4
        salary = $5
        
        count[dept]++
        sum[dept] += salary
        
        if(!(dept in min) || salary < min[dept]) min[dept] = salary
        if(salary > max[dept]) max[dept] = salary
    }
    END {
        # Sort departments
        n = asorti(count, sorted)
        for(i=1; i<=n; i++) {
            d = sorted[i]
            avg = sum[d] / count[d]
            printf "│ %-12s │ %8d │ $%9.0f │ $%9d │ $%9d │\n", 
                d, count[d], avg, min[d], max[d]
        }
    }' "$CSV_FILE"
    
    echo "└──────────────┴──────────┴────────────┴────────────┴────────────┘"
    echo ""
}

# ============================================================================
# Function: Generate Updated File
# ============================================================================
generate_updated_csv() {
    local output_file="$OUTPUT_DIR/employees_updated.csv"
    local current_year
    current_year=$(date +%Y)
    
    echo -e "${CYAN}📁 Generating updated file: $output_file${NC}"
    echo ""
    
    awk -F',' -v year="$current_year" '
    BEGIN {
        OFS = ","
    }
    NR == 1 {
        # Header - add new column
        print $0 ",years_employed"
        next
    }
    {
        # Lowercase for email
        email = tolower($3)
        
        # Change status
        status = $7
        if(status == "inactive") status = "on_leave"
        
        # Calculate years employed
        # hire_date is in YYYY-MM-DD format
        split($6, date_parts, "-")
        hire_year = date_parts[1]
        years = year - hire_year
        
        # Reconstruct line
        printf "%s,%s,%s,%s,%s,%s,%s,%d\n", 
            $1, $2, email, $4, $5, $6, status, years
    }' "$CSV_FILE" > "$output_file"
    
    echo -e "  ${GREEN}✅ File created successfully!${NC}"
    echo "  Modifications applied:"
    echo "    - Emails normalised to lowercase"
    echo "    - Status 'inactive' → 'on_leave'"
    echo "    - Added 'years_employed' column"
    echo ""
    
    # Show first lines
    echo "  Preview (first 5 lines):"
    head -5 "$output_file" | while IFS= read -r line; do
        echo "    $line"
    done
    echo ""
}

# ============================================================================
# Main
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           DATA TRANSFORMATION - EMPLOYEES CSV              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

generate_table_report
department_stats
generate_updated_csv

echo -e "${GREEN}✅ Transformation complete!${NC}"
