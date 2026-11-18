#!/usr/bin/env bash
# ex1_validator.sh - Model Solution
# Author: [Instructor] | Version: 1.1 (corrected teaching contract)
# Input: the personalised generator's Contact:, Server IP: and Phone: records.
# Email validation is an explicitly limited lexical grammar, not RFC completeness.
set -euo pipefail
export LC_ALL=C
if [[ ${1-} == --help && $# == 1 ]]; then
    echo "Usage: $0 CONTACTS_FILE"; exit 0
fi
[[ $# == 1 && -f $1 && -r $1 ]] || { echo "Usage: $0 READABLE_CONTACTS_FILE" >&2; exit 2; }
INPUT_FILE=$1
declare -a valid_emails=() invalid_emails=() ips=() phones=()
invalid_rows=0
email_pattern='^[A-Za-z0-9._%+-]+@[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$'
while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    case $line in
        ''|'#'*) continue ;;
        'Contact: '*)
            email=${line#'Contact: '}
            if [[ $email =~ $email_pattern && $email != .* && $email != *'.@'* && $email != *'..'* ]]; then
                valid_emails+=("$email")
            else invalid_emails+=("$email"); fi ;;
        'Server IP: '*)
            ip=${line#'Server IP: '}; valid=true
            if [[ $ip =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
                IFS=. read -r -a octets <<< "$ip"
                for octet in "${octets[@]}"; do ((10#$octet <= 255)) || valid=false; done
            else valid=false; fi
            if "$valid"; then ips+=("$ip"); else printf 'Invalid IP candidate: %s\n' "$ip" >&2; invalid_rows=$((invalid_rows+1)); fi ;;
        'Phone: '*)
            phone=${line#'Phone: '}
            if [[ $phone =~ ^07[0-9]{8}$ || $phone =~ ^07[0-9]{2}-[0-9]{3}-[0-9]{3}$ || $phone =~ ^07[0-9]{2}\.[0-9]{3}\.[0-9]{3}$ || $phone =~ ^07[0-9]{2}\ [0-9]{3}\ [0-9]{3}$ ]]; then
                phones+=("$phone")
            else printf 'Invalid phone candidate: %s\n' "$phone" >&2; invalid_rows=$((invalid_rows+1)); fi ;;
        *) printf 'Unrecognised record: %s\n' "$line" >&2; invalid_rows=$((invalid_rows+1)) ;;
    esac
done < "$INPUT_FILE"
printf '=== EMAIL VALIDATION (limited grammar; record counts) ===\n'
printf 'Total found: %d\nValid: %d\n' "$((${#valid_emails[@]}+${#invalid_emails[@]}))" "${#valid_emails[@]}"
((${#valid_emails[@]} == 0)) || printf '  - %s\n' "${valid_emails[@]}"
printf 'Invalid: %d\n' "${#invalid_emails[@]}"
((${#invalid_emails[@]} == 0)) || printf '  - %s\n' "${invalid_emails[@]}"
printf '\n=== UNIQUE IP ADDRESSES ===\n'
if ((${#ips[@]})); then printf '%s\n' "${ips[@]}" | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n -u; fi
printf '\n=== RO PHONE NUMBER SHAPES ===\n'
if ((${#phones[@]})); then printf '%s\n' "${phones[@]}" | sort -u; fi
if ((invalid_rows)); then printf 'Incomplete: %d invalid/unrecognised non-email records\n' "$invalid_rows" >&2; exit 2; fi
printf '\nValidation complete; allocation/deliverability/authorship not established.\n'
