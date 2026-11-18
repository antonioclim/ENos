#!/bin/bash
#===============================================================================
#
#          FILE:  record_homework.sh
#
#         USAGE:  ./record_homework.sh
#
#   DESCRIPTION:  Script for recording student homework using asciinema
#                 Includes: input validation, session recording, legacy metadata token,
#                 automatic upload to server
#
#        AUTHOR:  Operating Systems 2023-2027 - Revolvix/github.com
#       VERSION:  1.0
#       CREATED:  2025
#
#===============================================================================

set -euo pipefail

#===============================================================================
# RSA PUBLIC KEY - DO NOT MODIFY!
# Used for legacy metadata token of homework
#===============================================================================
PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"

#===============================================================================
# SERVER CONFIGURATION
#===============================================================================
SCP_SERVER="sop.ase.ro"
SCP_PORT="1002"
SCP_PASSWORD="stud"
SCP_BASE_PATH="/home/HOMEWORKS"
MAX_RETRIES=3

#===============================================================================
# OUTPUT COLOURS
#===============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Colour

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║          📹 HOMEWORK RECORDING SYSTEM - ASCIINEMA                 ║"
    echo "║                Operating Systems 2023-2027                        ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

#===============================================================================
# CHECK PREREQUISITES
#===============================================================================

require_asciinema_v2() {
    local version
    if ! version=$(asciinema --version 2>&1); then
        print_error 'Cannot determine asciinema version; recording was not started.'
        return 1
    fi
    if [[ ! "$version" =~ ^asciinema\ 2\.[0-9]+(\.[0-9]+)?([-+][0-9A-Za-z.-]+)?$ ]]; then
        print_error "This recorder requires asciinema CLI 2.x (asciicast v2). Found: $version"
        print_info 'CLI 3.x writes a different format. Use the supported 2.x lab package; no package was changed.'
        return 1
    fi
}

check_and_install_prerequisites() {
    # Historical name retained for compatibility. This function only checks.
    local -a required=(asciinema python3)
    local -a missing=()
    local cmd
    if [[ "$OFFLINE" != true ]]; then required+=(openssl sshpass scp); fi
    for cmd in "${required[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if (( ${#missing[@]} )); then
        print_error "Missing commands: ${missing[*]}"
        print_info 'Install the required packages in your supported lab environment, then rerun.'
        print_info 'Ubuntu: sudo apt install asciinema python3 openssl sshpass openssh-client'
        return 1
    fi
    require_asciinema_v2
}

#===============================================================================
# INPUT VALIDATION FUNCTIONS
#===============================================================================

# Validate surname (letters and hyphen only, converted to UPPERCASE)
validate_surname() {
    local input="$1"
    
    # Check if it contains only letters and hyphen
    if [[ ! "$input" =~ ^[a-zA-Z-]+$ ]]; then
        return 1
    fi
    
    # Check that it does not start or end with hyphen
    if [[ "$input" =~ ^- ]] || [[ "$input" =~ -$ ]]; then
        return 1
    fi
    
    return 0
}

# Validate first name (letters and hyphen only)
validate_firstname() {
    local input="$1"
    
    if [[ ! "$input" =~ ^[a-zA-Z-]+$ ]]; then
        return 1
    fi
    
    if [[ "$input" =~ ^- ]] || [[ "$input" =~ -$ ]]; then
        return 1
    fi
    
    return 0
}

# Validate group (exactly 4 digits)
validate_group() {
    local input="$1"
    
    if [[ ! "$input" =~ ^[0-9]{4}$ ]]; then
        return 1
    fi
    
    return 0
}

# Validate homework number (01-07 followed by a letter)
validate_homework_number() {
    local input="$1"
    
    # Check format: 2 digits (01-07) + 1 letter
    if [[ ! "$input" =~ ^0[1-7][a-zA-Z]$ ]]; then
        return 1
    fi
    
    return 0
}

# Convert to UPPERCASE
to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Convert to lowercase
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Convert to Title Case
to_titlecase() {
    local input="$1"
    # First letter uppercase, rest lowercase (for each word separated by hyphen)
    echo "$input" | sed 's/\b\(.\)/\u\1/g' | sed 's/-\(.\)/-\u\1/g'
}

#===============================================================================
# COLLECT STUDENT DATA
#===============================================================================

collect_student_data() {
    echo -e "${BOLD}📝 Enter student data${NC}"
    echo -e "${YELLOW}   (Compound names are written with hyphen, e.g.: Jones-Williams)${NC}"
    echo ""
    
    # Surname
    while true; do
        read -r -p "   Surname: " SURNAME
        if validate_surname "$SURNAME"; then
            SURNAME=$(to_uppercase "$SURNAME")
            print_success "Surname: $SURNAME"
            break
        else
            print_error "Invalid! Use only letters and hyphen (no spaces)."
        fi
    done
    
    # First name
    while true; do
        read -r -p "   First name: " FIRSTNAME
        if validate_firstname "$FIRSTNAME"; then
            # Convert to Title Case
            FIRSTNAME=$(to_lowercase "$FIRSTNAME")
            FIRSTNAME=$(to_titlecase "$FIRSTNAME")
            print_success "First name: $FIRSTNAME"
            break
        else
            print_error "Invalid! Use only letters and hyphen (no spaces)."
        fi
    done
    
    # Group
    while true; do
        read -r -p "   Group number (4 digits, e.g.: 1029): " GROUP
        if validate_group "$GROUP"; then
            print_success "Group: $GROUP"
            break
        else
            print_error "Invalid! Group must have exactly 4 digits."
        fi
    done
    
    # Specialisation
    echo ""
    echo -e "${BOLD}   Select specialisation:${NC}"
    echo "   1) eninfo  - Economic Informatics (English)"
    echo "   2) grupeid - ID Group"
    echo ""
    
    while true; do
        read -r -p "   Choose option (1/2): " SPEC_CHOICE
        case $SPEC_CHOICE in
            1)
                SPECIALIZATION="eninfo"
                print_success "Specialisation: $SPECIALIZATION"
                break
                ;;
            2)
                SPECIALIZATION="grupeid"
                print_success "Specialisation: $SPECIALIZATION"
                break
                ;;
            *)
                print_error "Invalid! Choose 1 or 2."
                ;;
        esac
    done
    
    # Homework number
    echo ""
    while true; do
        read -r -p "   Homework number (e.g.: 01a, 03b, 07c): " HOMEWORK_NUM
        if validate_homework_number "$HOMEWORK_NUM"; then
            # Convert letter to lowercase
            HOMEWORK_NUM="${HOMEWORK_NUM:0:2}$(to_lowercase "${HOMEWORK_NUM:2:1}")"
            print_success "Homework: HW$HOMEWORK_NUM"
            break
        else
            print_error "Invalid! Format: 01-07 followed by a letter (e.g.: 01a, 03b, 07c)"
        fi
    done
    
    echo ""
}

#===============================================================================
# GENERATE FILENAME
#===============================================================================

generate_filename() {
    # Format: [Group]_[SURNAME]_[FirstName]_HW[Number].cast
    FILENAME="${GROUP}_${SURNAME}_${FIRSTNAME}_HW${HOMEWORK_NUM}.cast"
    FILEPATH="$(pwd)/${FILENAME}"
    
    echo -e "${BOLD}📄 Generated filename:${NC}"
    echo -e "   ${CYAN}${FILENAME}${NC}"
    echo ""
}

#===============================================================================
# ASCIINEMA RECORDING
#===============================================================================

start_recording() {
    if [[ -e "$FILEPATH" ]]; then
        print_error "A recording with this name already exists. Preserve/move it before reusing the name."
        return 1
    fi
    echo -e "${BOLD}🎬 Preparing recording...${NC}"
    echo ""
    
    # Create temporary bashrc file with alias
    TEMP_RC=$(mktemp)
    cat > "$TEMP_RC" << 'EOF'
# Load default configuration if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Alias for stopping the recording
alias STOP_homework='echo ""; echo "🛑 Recording stopped. Saving..."; exit'

# Start message
echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                    🔴 RECORDING IN PROGRESS                       ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║                                                                   ║"
echo "║   To STOP and SAVE the recording, type:                           ║"
echo "║                                                                   ║"
echo "║                      STOP_homework                                ║"
echo "║                                                                   ║"
echo "║   or press Ctrl+D                                                 ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
EOF
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    📹 STARTING RECORDING                           ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   Student: ${SURNAME} ${FIRSTNAME}                                ${NC}"
    echo -e "${GREEN}║   Group: ${GROUP} | Specialisation: ${SPECIALIZATION}             ${NC}"
    echo -e "${GREEN}║   Homework: HW${HOMEWORK_NUM}                                     ${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   To STOP recording, type: ${YELLOW}STOP_homework${GREEN}                  ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    sleep 2
    
    # Start asciinema recording
    local record_command record_status=0
    printf -v record_command 'bash --rcfile %q' "$TEMP_RC"
    asciinema rec "$FILEPATH" -c "$record_command" || record_status=$?
    
    # Cleanup temporary file
    rm -f "$TEMP_RC"
    if (( record_status != 0 )); then
        print_error "Recording failed (status $record_status); any local file is retained."
        return "$record_status"
    fi
    
    echo ""
    print_success "Recording completed!"
    echo ""
}

#===============================================================================
# GENERATE LEGACY METADATA TOKEN (NOT A SIGNATURE)
#===============================================================================

generate_signature() {
    echo -e "${BOLD}🔐 Generating legacy metadata token (does not bind recording content)...${NC}"
    echo ""
    
    # Check if file exists
    if [ ! -f "$FILEPATH" ]; then
        print_error "Recording file not found!"
        exit 1
    fi
    
    # Collect data for signature
    local FILE_SIZE=$(stat -c%s "$FILEPATH")
    local CURRENT_DATE=$(date +"%d-%m-%Y")
    local CURRENT_TIME=$(date +"%H:%M:%S")
    local SYSTEM_USER=$(whoami)
    local ABSOLUTE_PATH=$(realpath "$FILEPATH")
    
    # Build the string to sign
    # Format: SURNAME+FIRSTNAME GROUP FileSizeInBytes Date(DD-MM-YYYY) Time(HH:MM:SS) SystemUsername AbsolutePath
    local DATA_TO_SIGN="${SURNAME}+${FIRSTNAME} ${GROUP} ${FILE_SIZE} ${CURRENT_DATE} ${CURRENT_TIME} ${SYSTEM_USER} ${ABSOLUTE_PATH}"
    
    print_info "Data for signature:"
    echo "   $DATA_TO_SIGN"
    echo ""
    
    # Save public key to temporary file
    local TEMP_PUBKEY=$(mktemp)
    echo "$PUBLIC_KEY" > "$TEMP_PUBKEY"
    
    # Hash with SHA-256 to guarantee data fits in RSA 1024-bit block
    # (RSA 1024 + PKCS1 allows max 117 bytes; SHA-256 hex = 64 bytes, always OK)
    local DATA_HASH=$(echo -n "$DATA_TO_SIGN" | sha256sum | cut -d' ' -f1)
    
    print_info "SHA-256: ${DATA_HASH}"
    
    # Encrypt hash with RSA and convert to Base64
    local ENCRYPTED_B64
    if ! ENCRYPTED_B64=$(echo -n "$DATA_HASH" | openssl pkeyutl -encrypt -pubin -inkey "$TEMP_PUBKEY" -pkeyopt rsa_padding_mode:pkcs1 2>/dev/null | base64 -w 0); then
        rm -f "$TEMP_PUBKEY"
        print_error "Legacy token generation failed. Recording retained locally; not uploaded."
        return 1
    fi
    
    # Cleanup temporary key
    rm -f "$TEMP_PUBKEY"
    
    if [ -z "$ENCRYPTED_B64" ]; then
        print_error "Error generating legacy metadata token!"
        exit 1
    fi
    
    # Append signature AND metadata to .cast file
    # SIG line contains the SHA-256 hash encrypted with RSA (verifiable with private key)
    # META line contains plaintext data (verifiable by recomputing the hash)
    echo "" >> "$FILEPATH"
    echo "## SIG:${ENCRYPTED_B64}" >> "$FILEPATH"
    echo "## META:${DATA_TO_SIGN}" >> "$FILEPATH"
    
    print_success "Legacy metadata token added; recording authenticity remains UNVERIFIED."
    echo ""
}

#===============================================================================
# SCP UPLOAD WITH RETRY
#===============================================================================

upload_homework() {
    [[ "${OFFLINE:-false}" == true ]] && { print_info "Offline mode: local recording only."; return 0; }
    echo -e "${BOLD}📤 Uploading homework to server...${NC}"
    echo ""
    
    # Build credentials
    local SCP_USER="stud-id"
    local SCP_DEST="${SCP_BASE_PATH}/${SPECIALIZATION}"
    
    print_info "Server: ${SCP_SERVER}:${SCP_PORT}"
    print_info "User: ${SCP_USER}"
    print_info "Destination: ${SCP_DEST}"
    echo ""
    
    # Pre-check connectivity before upload
    print_info "Checking connectivity to ${SCP_SERVER}:${SCP_PORT}..."
    if ! timeout 5 bash -c "echo >/dev/tcp/${SCP_SERVER}/${SCP_PORT}" 2>/dev/null; then
        print_warning "Port ${SCP_PORT} on ${SCP_SERVER} is not reachable."
        print_warning "Possible causes: SSH server is down, firewall, active VPN."
        print_info "Continuing with SCP attempts (may fail)..."
        echo ""
    else
        print_success "Connection verified - port ${SCP_PORT} is open."
        echo ""
    fi
    
    local attempt=1
    local upload_success=false
    
    while [ $attempt -le $MAX_RETRIES ]; do
        echo -e "${YELLOW}   Attempt $attempt of $MAX_RETRIES...${NC}"
        
        # SCP with sshpass and options to bypass SSH prompt
        if sshpass -p "$SCP_PASSWORD" scp -P "$SCP_PORT" \
            -o StrictHostKeyChecking=yes \
            -o LogLevel=ERROR \
            "$FILEPATH" "${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/"; then
            upload_success=true
            break
        else
            print_warning "Attempt $attempt failed."
            attempt=$((attempt + 1))
            if [ $attempt -le $MAX_RETRIES ]; then
                echo "   Retrying in 3 seconds..."
                sleep 3
            fi
        fi
    done
    
    echo ""
    
    if [ "$upload_success" = true ]; then
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    ✅ UPLOAD SUCCESSFUL!                           ║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}║   File: ${FILENAME}${NC}"
        echo -e "${GREEN}║   Server: ${SCP_SERVER}:${SCP_PORT}${NC}"
        echo -e "${GREEN}║   Location: ${SCP_DEST}/${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║               ❌ COULD NOT SEND HOMEWORK!                          ║${NC}"
        echo -e "${RED}╠═══════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}║   The file has been SAVED LOCALLY                                 ║${NC}"
        echo -e "${RED}║                                                                   ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        printf "${GREEN}║   📁  %-57s  ║${NC}\n" "${FILENAME}"
        echo -e "${GREEN}║                                                                   ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Try later (when you restore connection) using:${NC}"
        echo ""
        echo -e "${GREEN}  scp -P ${SCP_PORT} ${FILENAME} ${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  DO NOT modify the .cast file before sending!${NC}"
    fi
    
    echo ""
    [[ "$upload_success" == true ]]
}

#===============================================================================
# FINALISATION
#===============================================================================

finalize() {
    echo -e "${BOLD}📋 Final summary${NC}"
    echo ""
    echo "   Student: ${SURNAME} ${FIRSTNAME}"
    echo "   Group: ${GROUP}"
    echo "   Specialisation: ${SPECIALIZATION}"
    echo "   Homework: HW${HOMEWORK_NUM}"
    echo "   File: ${FILENAME}"
    echo "   Local location: ${FILEPATH}"
    echo ""
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🎉 PROCESS COMPLETED!                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#===============================================================================
# MAIN
#===============================================================================

main() {
    local option_status=0
    parse_options "$@" || option_status=$?
    if (( option_status == 10 )); then return 0; fi
    if (( option_status != 0 )); then return "$option_status"; fi
    clear
    print_header
    
    check_and_install_prerequisites || return $?
    
    collect_student_data
    
    generate_filename
    
    # Confirm before recording
    echo -e "${BOLD}❓ Are you ready to start recording?${NC}"
    read -r -p "   Press ENTER to continue or Ctrl+C to cancel..."
    echo ""
    
    start_recording || return $?
    add_recording_metadata || return $?
    if [[ "$OFFLINE" == true ]]; then
        print_info 'OFFLINE: local recording saved. No token, connection or upload attempted.'
        finalize
        return 0
    fi
    print_warning 'The legacy token is not a digital signature or proof of content integrity.'
    generate_signature || return $?
    if upload_homework; then
        finalize
    else
        print_error 'Upload failed; local recording retained. This is not a successful submission.'
        return 1
    fi
}


parse_options() {
    OFFLINE=false
    while (( $# )); do
        case "$1" in
            --offline) OFFLINE=true ;;
            --port)
                [[ $# -ge 2 && "$2" =~ ^[0-9]+$ && ${#2} -le 5 ]] || { print_error 'Expected --port NUMBER'; return 2; }
                (( 10#$2 >= 1 && 10#$2 <= 65535 )) || return 2
                SCP_PORT="$2"; PORT_CONFIRMED=true; shift ;;
            --help|-h)
                printf 'Usage: bash %s [--offline | --port CONFIRMED_SSH_PORT]\n' "$0"
                printf '%s\n' 'Use --offline for practice: no key token, connection or upload is attempted.' 
                printf '%s\n' 'Online mode needs the instructor-confirmed port and a verified known_hosts entry.'
                return 10 ;;
            *) print_error "Unknown option: $1"; return 2 ;;
        esac
        shift
    done
    if [[ "$OFFLINE" != true && "${PORT_CONFIRMED:-false}" != true ]]; then
        print_error 'Upload configuration is unresolved (historical copies use 1001 and 1002).'
        print_info 'Use --offline, or supply --port only after confirming the service configuration.'
        return 2
    fi
}

add_recording_metadata() {
    python3 - "$FILEPATH" "$SURNAME" "$FIRSTNAME" "$GROUP" "$HOMEWORK_NUM" <<'PY'
import json, os, pathlib, sys, tempfile
path = pathlib.Path(sys.argv[1])
with path.open(encoding='utf-8') as stream:
    first = stream.readline()
    rest = stream.read()
header = json.loads(first)
if not isinstance(header, dict) or type(header.get('version')) is not int or header['version'] != 2:
    raise SystemExit('Expected asciicast v2. Local recording retained; no upload attempted.')
header.update(student_name=sys.argv[2] + ' ' + sys.argv[3], student_group=sys.argv[4], seminar=int(sys.argv[5][:2]), homework=sys.argv[5])
# These are self-declared labels, not authenticated identity or a signature.
fd, tmp = tempfile.mkstemp(prefix='.' + path.name + '.', dir=path.parent)
try:
    with os.fdopen(fd, 'w', encoding='utf-8') as stream:
        stream.write(json.dumps(header, ensure_ascii=False) + '\n' + rest)
    os.chmod(tmp, path.stat().st_mode & 0o777)
    os.replace(tmp, path)
finally:
    if os.path.exists(tmp): os.unlink(tmp)
PY
}

# Run only when invoked, so offline tests can source the functions.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
