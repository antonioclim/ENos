#!/bin/bash
#===============================================================================
#
#          FILE:  record_homework.sh
#
#         USAGE:  ./record_homework.sh
#
#   DESCRIPTION:  Script for recording student homework using asciinema
#                 Includes: input validation, session recording, cryptographic signature,
#                 automatic upload to server
#
#        AUTHOR:  Operating Systems 2023-2027 - Revolvix/github.com
#       VERSION:  1.1.1
#       CREATED:  2025
#
#===============================================================================

#===============================================================================
# STRICT MODE
# -e: Exit immediately if a command exits with non-zero status
# -u: Treat unset variables as an error
# -o pipefail: Return value of a pipeline is the last command to exit with non-zero
# IFS: Internal Field Separator - prevents word splitting issues
#===============================================================================
set -euo pipefail
IFS=$'\n\t'

#===============================================================================
# RSA PUBLIC KEY - DO NOT MODIFY!
# Used for cryptographic signature of homework
#===============================================================================
readonly PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCieNySGxV0PZUBbAjbwksHyUUB
soa9fbLVI9uK7viOAVi0c5ZHjfnwU/LhRxLT4qbBNSlUBoXqiiVAg+Z+NWY2B/eY
POoTxuSLgkS0NfJjd55t2N4gzJHydma6gfwLg3kpDEJoSIlTfI83aFHuyzPxgzbj
HAsViFvWuv8rlbxvHwIDAQAB
-----END PUBLIC KEY-----"

#===============================================================================
# SERVER CONFIGURATION
#===============================================================================
readonly SCP_SERVER="sop.ase.ro"
readonly SCP_PORT="1001"
readonly SCP_PASSWORD="stud"
readonly SCP_BASE_PATH="/home/HOMEWORKS"
readonly MAX_RETRIES=3

#===============================================================================
# OUTPUT COLOURS
#===============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Colour

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
# CHECK AND INSTALL PREREQUISITES
#===============================================================================

check_and_install_prerequisites() {
    echo -e "${BOLD}📦 Checking and installing prerequisites...${NC}"
    echo ""
    
    local -a packages_to_install=()
    
    # Check asciinema
    if ! command -v asciinema &> /dev/null; then
        print_warning "asciinema is not installed"
        packages_to_install+=("asciinema")
    else
        print_success "asciinema is installed"
    fi
    
    # Check openssl
    if ! command -v openssl &> /dev/null; then
        print_warning "openssl is not installed"
        packages_to_install+=("openssl")
    else
        print_success "openssl is installed"
    fi
    
    # Check sshpass
    if ! command -v sshpass &> /dev/null; then
        print_warning "sshpass is not installed"
        packages_to_install+=("sshpass")
    else
        print_success "sshpass is installed"
    fi
    
    # Install missing packages
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo ""
        print_info "Installing missing packages: ${packages_to_install[*]}"
        echo ""
        
        # Update and install
        sudo apt update -qq
        if sudo apt install -y "${packages_to_install[@]}"; then
            echo ""
            print_success "All packages have been installed successfully!"
        else
            print_error "Error installing packages. Check your internet connection."
            exit 1
        fi
    fi
    
    echo ""
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
    echo "   3) roinfo  - Economic Informatics (Romanian)"
    echo ""
    
    while true; do
        read -r -p "   Choose option (1/2/3): " SPEC_CHOICE
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
            3)
                SPECIALIZATION="roinfo"
                print_success "Specialisation: $SPECIALIZATION"
                break
                ;;
            *)
                print_error "Invalid! Choose 1, 2 or 3."
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
    asciinema rec --overwrite "$FILEPATH" -c "bash --rcfile $TEMP_RC"
    
    # Cleanup temporary file
    rm -f "$TEMP_RC"
    
    echo ""
    print_success "Recording completed!"
    echo ""
}

#===============================================================================
# GENERATE CRYPTOGRAPHIC SIGNATURE
#===============================================================================

generate_signature() {
    echo -e "${BOLD}🔐 Generating cryptographic signature...${NC}"
    echo ""
    
    # Check if file exists
    if [[ ! -f "$FILEPATH" ]]; then
        print_error "Recording file not found!"
        exit 1
    fi
    
    # Collect data for signature
    local FILE_SIZE
    FILE_SIZE=$(stat -c%s "$FILEPATH")
    local CURRENT_DATE
    CURRENT_DATE=$(date +"%d-%m-%Y")
    local CURRENT_TIME
    CURRENT_TIME=$(date +"%H:%M:%S")
    local SYSTEM_USER
    SYSTEM_USER=$(whoami)
    local ABSOLUTE_PATH
    ABSOLUTE_PATH=$(realpath "$FILEPATH")
    
    # Build the string to sign
    # Format: SURNAME+FIRSTNAME GROUP FileSizeInBytes Date(DD-MM-YYYY) Time(HH:MM:SS) SystemUsername AbsolutePath
    local DATA_TO_SIGN="${SURNAME}+${FIRSTNAME} ${GROUP} ${FILE_SIZE} ${CURRENT_DATE} ${CURRENT_TIME} ${SYSTEM_USER} ${ABSOLUTE_PATH}"
    
    print_info "Data for signature:"
    echo "   $DATA_TO_SIGN"
    echo ""
    
    # Save public key to temporary file
    local TEMP_PUBKEY
    TEMP_PUBKEY=$(mktemp)
    echo "$PUBLIC_KEY" > "$TEMP_PUBKEY"
    
    # Encrypt with RSA and convert to Base64
    local ENCRYPTED_B64
    ENCRYPTED_B64=$(echo -n "$DATA_TO_SIGN" | openssl pkeyutl -encrypt -pubin -inkey "$TEMP_PUBKEY" -pkeyopt rsa_padding_mode:pkcs1 2>/dev/null | base64 -w 0)
    
    # Cleanup temporary key
    rm -f "$TEMP_PUBKEY"
    
    if [[ -z "$ENCRYPTED_B64" ]]; then
        print_error "Error generating cryptographic signature!"
        exit 1
    fi
    
    # Append signature to .cast file
    echo "" >> "$FILEPATH"
    echo "## ${ENCRYPTED_B64}" >> "$FILEPATH"
    
    print_success "Cryptographic signature added!"
    echo ""
}

#===============================================================================
# SCP UPLOAD WITH RETRY
#===============================================================================

upload_homework() {
    echo -e "${BOLD}📤 Uploading homework to server...${NC}"
    echo ""
    
    # Build credentials
    local SCP_USER="stud-id"
    local SCP_DEST="${SCP_BASE_PATH}/${SPECIALIZATION}"
    
    print_info "Server: ${SCP_SERVER}:${SCP_PORT}"
    print_info "User: ${SCP_USER}"
    print_info "Destination: ${SCP_DEST}"
    echo ""
    
    local attempt=1
    local upload_success=false
    
    # Temporarily disable errexit for upload attempts
    set +e
    
    while [[ $attempt -le $MAX_RETRIES ]]; do
        echo -e "${YELLOW}   Attempt $attempt of $MAX_RETRIES...${NC}"
        
        # SCP with sshpass and options to bypass SSH prompt
        sshpass -p "$SCP_PASSWORD" scp -P "$SCP_PORT" \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o LogLevel=ERROR \
            "$FILEPATH" "${SCP_USER}@${SCP_SERVER}:${SCP_DEST}/" 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            upload_success=true
            break
        else
            print_warning "Attempt $attempt failed."
            ((attempt++)) || true
            if [[ $attempt -le $MAX_RETRIES ]]; then
                echo "   Retrying in 3 seconds..."
                sleep 3
            fi
        fi
    done
    
    # Re-enable errexit
    set -e
    
    echo ""
    
    if [[ "$upload_success" == true ]]; then
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
    clear
    print_header
    
    check_and_install_prerequisites
    
    collect_student_data
    
    generate_filename
    
    # Confirm before recording
    echo -e "${BOLD}❓ Are you ready to start recording?${NC}"
    read -r -p "   Press ENTER to continue or Ctrl+C to cancel..."
    echo ""
    
    start_recording
    
    generate_signature
    
    upload_homework
    
    finalize
}

# Run the script
main
