#!/bin/bash
#===============================================================================
#
#          FILE: S04_01_setup_seminar.sh
#
#         USAGE: ./S04_01_setup_seminar.sh [--clean] [--verbose]
#
#   DESCRIPTION: Prepares the environment for Seminar 4: Text Processing
#                Generates all data files needed for demonstrations
#                and exercises: access.log, employees.csv, config.txt, emails.txt
#
#       OPTIONS: --clean    Delete existing data before regeneration
#                --verbose  Display detailed progress
#                --help     Display this message
#
#  REQUIREMENTS: bash 4.0+, standard Unix utilities
#
#        AUTHOR: Assistant Lecturer - OS Seminar
#       VERSION: 1.1
#       CREATED: 2025-01-20
#
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_DIR="${SCRIPT_DIR}/../../resources/sample_data"
readonly DEMO_DIR="$HOME/demo_sem4/data"

# Colours for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Flags
VERBOSE=false
CLEAN=false

#-------------------------------------------------------------------------------
# UTILITY FUNCTIONS
#-------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $*"
    fi
}

show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                  SETUP SEMINAR 4: TEXT PROCESSING                        ║
╚══════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./S04_01_setup_seminar.sh [OPTIONS]

OPTIONS:
    --clean     Delete existing data before regeneration
    --verbose   Display detailed progress
    --help      Display this message

GENERATED FILES:
    • access.log     - Simulated web server log (~2000 lines)
    • employees.csv  - Employee data for awk exercises
    • config.txt     - Configuration file for sed exercises
    • emails.txt     - Data for email validation exercises
    • test.txt       - Generic file for regex tests

LOCATIONS:
    • ~/demo_sem4/data/    - Main directory for demonstrations
    • ./resources/sample_data/ - Backup in the seminar package

EXAMPLES:
    ./S04_01_setup_seminar.sh              # Standard setup
    ./S04_01_setup_seminar.sh --clean      # Complete regeneration
    ./S04_01_setup_seminar.sh --verbose    # With detailed output

EOF
}

#-------------------------------------------------------------------------------
# DATA GENERATION
#-------------------------------------------------------------------------------

generate_access_log() {
    local output_file="$1"
    local num_lines="${2:-2000}"
    
    log_verbose "Generating access.log with $num_lines lines..."
    
    # Arrays for realistic data
    local ips=("192.168.1.100" "192.168.1.101" "192.168.1.102" 
               "10.0.0.50" "10.0.0.51" "10.0.0.52"
               "45.33.32.156" "185.220.101.1" "23.129.64.100"
               "172.16.0.10" "172.16.0.20" "8.8.8.8")
    
    local methods=("GET" "GET" "GET" "GET" "POST" "PUT" "DELETE" "HEAD")
    
    local paths=("/index.html" "/about.html" "/contact.html"
                 "/api/users" "/api/products" "/api/orders"
                 "/login" "/logout" "/register"
                 "/admin" "/admin/login" "/admin/dashboard"
                 "/wp-admin" "/wp-login.php" "/.env"
                 "/config.php" "/phpmyadmin" "/.git/config"
                 "/images/logo.png" "/css/style.css" "/js/app.js"
                 "/products" "/products/1" "/products/2"
                 "/search?q=test" "/api/v2/data")
    
    local codes=("200" "200" "200" "200" "200" "200" "200"
                 "201" "204" "301" "302" "304"
                 "400" "401" "403" "403" "404" "404" "404"
                 "500" "502" "503")
    
    local sizes=("1234" "2048" "4096" "8192" "512" "256" "128" 
                 "16384" "32768" "0" "1024" "2560")
    
    local user_agents=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15"
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
        "curl/7.68.0"
        "python-requests/2.28.0"
        "Googlebot/2.1"
    )
    
    # Generation
    : > "$output_file"  # Empty the file
    
    for ((i=0; i<num_lines; i++)); do
        local ip="${ips[$((RANDOM % ${#ips[@]}))]}"
        local method="${methods[$((RANDOM % ${#methods[@]}))]}"
        local path="${paths[$((RANDOM % ${#paths[@]}))]}"
        local code="${codes[$((RANDOM % ${#codes[@]}))]}"
        local size="${sizes[$((RANDOM % ${#sizes[@]}))]}"
        local ua="${user_agents[$((RANDOM % ${#user_agents[@]}))]}"
        
        # Generate timestamp (last 24 hours)
        local mins_ago=$((RANDOM % 1440))
        local timestamp
        timestamp=$(date -d "-${mins_ago} minutes" '+%d/%b/%Y:%H:%M:%S +0000' 2>/dev/null || \
                   date -v-"${mins_ago}"M '+%d/%b/%Y:%H:%M:%S +0000' 2>/dev/null || \
                   date '+%d/%b/%Y:%H:%M:%S +0000')
        
        echo "$ip - - [$timestamp] \"$method $path HTTP/1.1\" $code $size \"-\" \"$ua\"" >> "$output_file"
    done
    
    # Add some special lines for demos
    cat >> "$output_file" << 'SPECIAL'
45.33.32.156 - - [20/Jan/2025:03:15:22 +0000] "GET /admin HTTP/1.1" 403 0 "-" "sqlmap/1.4"
45.33.32.156 - - [20/Jan/2025:03:15:23 +0000] "GET /.env HTTP/1.1" 403 0 "-" "sqlmap/1.4"
45.33.32.156 - - [20/Jan/2025:03:15:24 +0000] "GET /wp-admin HTTP/1.1" 404 0 "-" "sqlmap/1.4"
185.220.101.1 - - [20/Jan/2025:04:20:10 +0000] "POST /login HTTP/1.1" 401 128 "-" "python-requests/2.28.0"
185.220.101.1 - - [20/Jan/2025:04:20:11 +0000] "POST /login HTTP/1.1" 401 128 "-" "python-requests/2.28.0"
185.220.101.1 - - [20/Jan/2025:04:20:12 +0000] "POST /login HTTP/1.1" 401 128 "-" "python-requests/2.28.0"
SPECIAL
    
    log_verbose "access.log generated: $(wc -l < "$output_file") lines"
}

generate_employees_csv() {
    local output_file="$1"
    
    log_verbose "Generating employees.csv..."
    
    cat > "$output_file" << 'CSV'
ID,Name,Department,Salary,JoinDate,Email
101,John Smith,IT,5500,2020-03-15,john.smith@company.com
102,Maria Garcia,HR,4800,2019-07-22,maria.garcia@company.com
103,Alexandru Popescu,IT,6200,2018-01-10,alexandru.popescu@company.com
104,Elena Ionescu,Finance,5100,2021-05-03,elena.ionescu@company.com
105,David Chen,IT,7500,2017-09-28,david.chen@company.com
106,Ana Müller,HR,4600,2022-02-14,ana.muller@company.com
107,Michael Brown,Finance,5800,2019-11-30,michael.brown@company.com
108,Sofia Rossi,IT,6800,2020-08-17,sofia.rossi@company.com
109,Robert Wilson,Sales,4200,2021-04-25,robert.wilson@company.com
110,Laura Martinez,Sales,4500,2020-12-01,laura.martinez@company.com
111,James Taylor,IT,5900,2019-06-15,james.taylor@company.com
112,Emma Anderson,HR,5200,2018-10-20,emma.anderson@company.com
113,Daniel Kim,Finance,6100,2020-01-08,daniel.kim@company.com
114,Olivia Thompson,Sales,4800,2021-07-12,olivia.thompson@company.com
115,William Davis,IT,7200,2017-03-25,william.davis@company.com
116,Ava Johnson,Finance,5500,2019-09-18,ava.johnson@company.com
117,Liam Miller,Sales,4100,2022-01-05,liam.miller@company.com
118,Isabella Moore,HR,4900,2020-06-22,isabella.moore@company.com
119,Noah Jackson,IT,6500,2018-12-10,noah.jackson@company.com
120,Mia White,Finance,5300,2021-03-28,mia.white@company.com
CSV
    
    log_verbose "employees.csv generated: $(wc -l < "$output_file") lines"
}

generate_config_txt() {
    local output_file="$1"
    
    log_verbose "Generating config.txt..."
    
    cat > "$output_file" << 'CONFIG'
# Application Configuration File
# Generated for Seminar 4: Text Processing
# Last updated: 2025-01-20

# Server Settings
server.host=localhost
server.port=8080
server.timeout=30
server.max_connections=100

# Database Configuration
db.host=localhost
db.port=5432
db.name=myapp_production
db.user=admin
db.password=secretpassword123

# Logging
log.level=info
log.file=/var/log/myapp/application.log
log.max_size=10MB
log.backup_count=5

# Feature Flags
feature.new_ui=true
feature.beta_api=false
feature.analytics=true

# Cache Settings
cache.enabled=true
cache.ttl=3600
cache.max_size=256MB

# API Configuration
api.version=v2
api.rate_limit=1000
api.timeout=15

# Security
security.ssl_enabled=true
security.cors_allowed=*
security.jwt_secret=my_super_secret_key_12345

# Email Settings
email.smtp_host=smtp.gmail.com
email.smtp_port=587
email.from=noreply@company.com
CONFIG
    
    log_verbose "config.txt generated: $(wc -l < "$output_file") lines"
}

generate_emails_txt() {
    local output_file="$1"
    
    log_verbose "Generating emails.txt..."
    
    cat > "$output_file" << 'EMAILS'
# Email addresses for validation testing
# Mix of valid and invalid formats

# Valid emails
john.doe@example.com
maria_garcia123@company.org
user+tag@domain.co.uk
firstname.lastname@subdomain.domain.com
simple@test.io
user123@numbers.com
info@company.com
support@help.desk.com
alice.wonder+newsletter@gmail.com
bob_smith.test@mail-server.org

# Invalid emails
invalid-email
@nodomain.com
noat.com
spaces in@email.com
double@@at.com
.startswithdot@domain.com
endswith.@domain.com
missing@tld
user@.nodomain.com
special!char@domain.com

# Edge cases
a@b.co
very.long.email.address.that.is.still.valid@subdomain.example.organization.com
CAPS@DOMAIN.COM
MixedCase@Domain.Org
numbers123@test456.com
EMAILS
    
    log_verbose "emails.txt generated: $(wc -l < "$output_file") lines"
}

generate_test_txt() {
    local output_file="$1"
    
    log_verbose "Generating test.txt..."
    
    cat > "$output_file" << 'TEST'
abc
ac
aXc
a1c
abbc
abbbc
cat
category
concatenate
bobcat
192.168.1.100
192X168Y1Z1
10.0.0.50
error error error
warning
error
Hello World
hello world
HELLO WORLD

Line with numbers: 12345
Another line: test
Special chars: @#$%^&*
Tab	separated	values
Mixed CaSe TeXt
TEST
    
    log_verbose "test.txt generated: $(wc -l < "$output_file") lines"
}

generate_all_data() {
    local target_dir="$1"
    
    log_info "Generating data in: $target_dir"
    
    mkdir -p "$target_dir"
    
    generate_access_log "$target_dir/access.log" 2000
    log_success "access.log"
    
    generate_employees_csv "$target_dir/employees.csv"
    log_success "employees.csv"
    
    generate_config_txt "$target_dir/config.txt"
    log_success "config.txt"
    
    generate_emails_txt "$target_dir/emails.txt"
    log_success "emails.txt"
    
    generate_test_txt "$target_dir/test.txt"
    log_success "test.txt"
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            SETUP SEMINAR 4: TEXT PROCESSING                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Clean if requested
    if [[ "$CLEAN" == true ]]; then
        log_warning "Cleaning existing directories..."
        rm -rf "$DEMO_DIR" 2>/dev/null || true
        rm -rf "$DATA_DIR" 2>/dev/null || true
    fi
    
    # Generate in demo directory
    log_info "=== Preparing demo directory ==="
    generate_all_data "$DEMO_DIR"
    
    # Generate in resources directory (if structure exists)
    if [[ -d "$(dirname "$DATA_DIR")" ]]; then
        log_info "=== Preparing resources directory ==="
        generate_all_data "$DATA_DIR"
    fi
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      SETUP COMPLETE!                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Working directory: $DEMO_DIR"
    echo ""
    log_info "Generated files:"
    ls -lh "$DEMO_DIR"
    echo ""
    log_info "To begin, run:"
    echo "    cd $DEMO_DIR"
    echo ""
}

main "$@"
