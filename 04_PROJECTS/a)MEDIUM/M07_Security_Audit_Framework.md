# M07: Security Audit Framework

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Modular framework for Linux security auditing: file permission verification, insecure configurations, user audit, SSH hardening, firewall rules and CIS Benchmarks compliance. Generates reports with severity levels and suggested remediations.

---

## Learning Objectives

- Linux security concepts (permissions, capabilities, SELinux/AppArmor)
- User and group auditing
- Critical service configuration verification
- Compliance checks automation
- Reporting with actionable remediations

---

## Functional Requirements

### Mandatory (for passing grade)

1. **User and authentication audit**
   - Accounts without password or with expired password
   - Accounts with UID 0 (other than root)
   - Suspicious shells, home directories
   - Last logins and failed attempts

2. **File permissions audit**
   - World-writable files
   - SUID/SGID binaries (comparison with baseline)
   - Permissions on critical files (/etc/passwd, /etc/shadow)
   - Files without valid owner

3. **Service configuration audit**
   - SSH: PermitRootLogin, PasswordAuthentication, keys
   - Sudo: risky configurations (NOPASSWD)
   - Cron: suspicious jobs

4. **Network audit**
   - Open ports and associated services
   - Firewall rules (iptables/nftables/ufw)
   - Services listening on 0.0.0.0

5. **Reporting**
   - Severity: CRITICAL, HIGH, MEDIUM, LOW, INFO
   - Suggested remediations for each finding
   - Export: text, JSON, HTML

### Optional (for full marks)

6. **CIS Benchmark checks** - Subset of CIS Level 1 verifications
7. **Baseline comparison** - Diff against a known good state
8. **Auto-remediation** - Automatic fix for simple issues
9. **Scheduled audits** - Cron integration with alerting
10. **CVE checking** - Package verification for known vulnerabilities

---

## CLI Interface

```text
./security_audit.sh <command> [options]

Commands:
  full                  Full audit (all modules)
  users                 User audit only
  files                 File permissions audit only
  services              Service audit only
  network               Network audit only
  cis [level]          CIS Benchmark checks (level 1 or 2)
  baseline create       Create baseline from current state
  baseline compare      Compare with saved baseline
  fix [finding-id]      Apply remediation (with confirmation)

Options:
  -o, --output FILE     Save report to file
  -f, --format FMT      Format: text|json|html|csv
  -s, --severity SEV    Minimum severity: critical|high|medium|low|info
  -q, --quiet           Findings only, no details
  -v, --verbose         Additional details
  --no-color            No colours
  --auto-fix            Apply automatic remediations (DANGEROUS)
  --exclude MODULE      Exclude module from audit

Examples:
  ./security_audit.sh full
  ./security_audit.sh full -o report.html -f html
  ./security_audit.sh users -s high
  ./security_audit.sh cis 1
  ./security_audit.sh baseline create
  ./security_audit.sh fix SUID-001
```

---

## Output Examples

### Full Audit

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    SECURITY AUDIT REPORT                                     ║
║                    Host: server01.example.com                               ║
║                    Date: 2025-01-20 16:00:00                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

AUDIT SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  🔴 CRITICAL:  2
  🟠 HIGH:      5
  🟡 MEDIUM:    8
  🔵 LOW:       12
  ⚪ INFO:      15
  ─────────────────
  Total findings: 42
  Score: 68/100 (NEEDS IMPROVEMENT)

═══════════════════════════════════════════════════════════════════════════════
🔴 CRITICAL FINDINGS
═══════════════════════════════════════════════════════════════════════════════

[CRIT-001] Root login via SSH is permitted
───────────────────────────────────────────────────────────────────────────────
  Location:   /etc/ssh/sshd_config
  Current:    PermitRootLogin yes
  Risk:       Direct root access increases attack surface
  
  REMEDIATION:
  1. Edit /etc/ssh/sshd_config
  2. Set: PermitRootLogin no
  3. Ensure you have another admin user with sudo
  4. Validate with `sshd -t`, check effective configuration for the intended connection, then perform an explicitly authorised reload while retaining recovery access
  
  AUTO-FIX: ./security_audit.sh fix CRIT-001

[CRIT-002] User 'backup' has empty password
───────────────────────────────────────────────────────────────────────────────
  Location:   /etc/shadow
  Risk:       Account can be accessed without authentication
  
  REMEDIATION:
  1. Set password: passwd backup
  2. Or lock account: usermod -L backup
  3. Or remove if unused: userdel backup

═══════════════════════════════════════════════════════════════════════════════
🟠 HIGH FINDINGS
═══════════════════════════════════════════════════════════════════════════════

[HIGH-001] World-writable directory in PATH: /usr/local/bin
───────────────────────────────────────────────────────────────────────────────
  Permissions: drwxrwxrwx
  Risk:        Any user can place malicious executables
  
  REMEDIATION:
  chmod 755 /usr/local/bin

[HIGH-002] SUID binary not in baseline: /opt/app/helper
───────────────────────────────────────────────────────────────────────────────
  Permissions: -rwsr-xr-x
  Owner:       root
  Risk:        Unknown SUID binary could be exploited
  
  REMEDIATION:
  1. Verify if binary is legitimate
  2. If not needed: chmod u-s /opt/app/helper
  3. If legitimate: add to baseline

[HIGH-003] SSH password authentication enabled
───────────────────────────────────────────────────────────────────────────────
  Location:    /etc/ssh/sshd_config
  Current:     PasswordAuthentication yes
  Risk:        Vulnerable to brute-force attacks
  
  REMEDIATION:
  1. Ensure SSH keys are configured for all users
  2. Set: PasswordAuthentication no
  3. Validate and perform an explicitly authorised reload with recovery access

... [continued] ...

═══════════════════════════════════════════════════════════════════════════════
📊 DETAILED RESULTS BY MODULE
═══════════════════════════════════════════════════════════════════════════════

USER AUDIT
──────────────────────────────────────────────────────────────────────────────
✓ No duplicate UIDs found
✓ Root is the only UID 0 account  
✗ 1 account with empty password: backup
✗ 3 accounts with expired passwords: dev1, dev2, contractor
✓ No accounts with suspicious shells
⚠ 5 accounts haven't logged in for 90+ days

FILE PERMISSIONS AUDIT
──────────────────────────────────────────────────────────────────────────────
✗ 3 world-writable files found
✗ 2 SUID binaries not in baseline
✓ /etc/passwd permissions OK (644)
✓ /etc/shadow permissions OK (640)
✗ 12 files without valid owner

SERVICES AUDIT
──────────────────────────────────────────────────────────────────────────────
SSH Configuration:
  ✗ PermitRootLogin: yes (should be no)
  ✗ PasswordAuthentication: yes (should be no)
  ✓ Protocol: 2
  ✓ X11Forwarding: no
  ⚠ MaxAuthTries: 6 (recommend 3)

Sudo Configuration:
  ⚠ NOPASSWD found for user 'deploy'
  ✓ No dangerous wildcards in sudoers

NETWORK AUDIT
──────────────────────────────────────────────────────────────────────────────
Open Ports:
  22/tcp   sshd         ✓ Expected
  80/tcp   nginx        ✓ Expected
  443/tcp  nginx        ✓ Expected
  3306/tcp mysql        ⚠ Listening on 0.0.0.0 (should be 127.0.0.1)
  6379/tcp redis        ✗ No authentication, exposed to network

Firewall:
  ✓ UFW active
  ⚠ Rule allows all from 10.0.0.0/8 (verify if intended)

═══════════════════════════════════════════════════════════════════════════════
Report generated in 12.3 seconds
Full report saved to: security_audit_20250120.html
```

---

## Project Structure

```
M07_Security_Audit_Framework/
├── README.md
├── Makefile
├── src/
│   ├── security_audit.sh        # Main script
│   └── modules/
│       ├── users.sh             # User audit
│       ├── files.sh             # Permissions audit
│       ├── services.sh          # Service audit
│       ├── network.sh           # Network audit
│       ├── cis.sh               # CIS Benchmark checks
│       └── remediate.sh         # Auto-remediation
├── lib/
│   ├── report.sh                # Report generation
│   ├── baseline.sh              # Baseline management
│   └── utils.sh                 # Common functions
├── etc/
│   ├── audit.conf               # Audit configuration
│   ├── baseline/
│   │   └── suid_baseline.txt    # Known SUID binaries
│   └── checks/
│       ├── cis_level1.conf
│       └── cis_level2.conf
├── templates/
│   └── report.html.tmpl
├── tests/
│   ├── test_users.sh
│   ├── test_files.sh
│   └── test_environment/
└── docs/
    ├── INSTALL.md
    ├── CHECKS.md
    └── CIS_MAPPING.md
```

---

## Implementation Hints

### User audit

```bash
check_empty_passwords() {
    local passwd_file="${PASSWD_FILE:-/etc/passwd}" shadow_file="${SHADOW_FILE:-/etc/shadow}"
    [[ -r "$passwd_file" ]] || return 2
    local user pass row shadow_pass
    while IFS=: read -r user pass _; do
        case "$pass" in
            '' ) report_finding CRIT USER-001 "User '$user' has an empty UNIX password field"; continue ;;
            '!'*|'*'*) continue ;;  # Locked UNIX password; other authentication may remain possible.
            x)
                [[ -r "$shadow_file" ]] || { report_finding INFO USER-UNAVAILABLE "Shadow unavailable; '$user' not checked"; continue; }
                row=$(awk -F: -v name="$user" '$1==name {print; found=1; exit} END {if(!found) exit 1}' "$shadow_file") || {
                    report_finding INFO USER-UNAVAILABLE "No shadow entry for '$user'"; continue;
                }
                IFS=: read -r _ shadow_pass _ <<< "$row"
                [[ -n "$shadow_pass" ]] || report_finding CRIT USER-001 "User '$user' has an empty UNIX password field"
                ;;
        esac
    done < "$passwd_file"
}

check_uid_zero() {
    echo "Checking for UID 0 accounts..."
    
    while IFS=: read -r user _ uid _; do
        if [[ "$uid" == "0" && "$user" != "root" ]]; then
            report_finding "CRIT" "USER-002" "Non-root user '$user' has UID 0"
        fi
    done < /etc/passwd
}

check_password_expiry() {
    local shadow_file="${SHADOW_FILE:-/etc/shadow}" today
    [[ -r "$shadow_file" ]] || { report_finding INFO USER-UNAVAILABLE "Shadow unavailable; expiry not checked"; return 2; }
    today=$(( $(date +%s) / 86400 ))
    local user hash changed minimum maximum warning inactive account_expiry reserved
    while IFS=: read -r user hash changed minimum maximum warning inactive account_expiry reserved; do
        case "$hash" in '!'*|'*'*) continue;; esac
        if [[ $changed =~ ^[0-9]+$ && $maximum =~ ^[0-9]+$ ]] && ((maximum > 0 && maximum < 99999)); then
            if ((changed == 0 || today > changed + maximum)); then
                report_finding HIGH USER-003 "User '$user' UNIX password expired or requires change"
            fi
        fi
        if [[ $account_expiry =~ ^[0-9]+$ ]] && ((account_expiry > 0 && today >= account_expiry)); then
            report_finding HIGH USER-004 "User '$user' account expiration date reached"
        fi
        # Field 7 is inactivity after password expiry, not an epoch expiration date.
    done < "$shadow_file"
}
```

### Permissions audit

```bash
check_world_writable() {
    echo "Checking for world-writable files..."
    
    local plan file
    plan=$(mktemp) || return 2
    if ! find "${AUDIT_ROOT:?Choose an authorised audit root}" -xdev -type f -perm -0002 -print0 > "$plan"; then
        rm -f -- "$plan"; return 2
    fi
    while IFS= read -r -d '' file; do
        report_finding "HIGH" "FILE-001" "World-writable file: $file"
    done < "$plan"
    rm -f -- "$plan"
}

check_suid_sgid() {
    local baseline="$BASELINE_DIR/suid_baseline.txt"
    
    echo "Checking SUID/SGID binaries..."
    
    [[ -r "$baseline" ]] || return 2
    local plan file
    plan=$(mktemp) || return 2
    if ! find "${AUDIT_ROOT:?Choose an authorised audit root}" -xdev \( -perm -4000 -o -perm -2000 \) -type f -print0 > "$plan"; then
        rm -f -- "$plan"; return 2
    fi
    while IFS= read -r -d '' file; do
        if ! grep -qxF "$file" "$baseline" 2>/dev/null; then
            local perms
            perms=$(stat -c '%a' "$file")
            report_finding "HIGH" "FILE-002" "SUID/SGID binary not in baseline: $file ($perms)"
        fi
    done < "$plan"
    rm -f -- "$plan"
}

check_critical_files() {
    declare -A expected_perms=(
        ["/etc/passwd"]="644"
        ["/etc/shadow"]="640"
        ["/etc/group"]="644"
        ["/etc/gshadow"]="640"
        ["/etc/ssh/sshd_config"]="600"
    )
    
    for file in "${!expected_perms[@]}"; do
        local expected="${expected_perms[$file]}"
        local actual
        actual=$(stat -c '%a' "$file" 2>/dev/null) || { report_finding INFO FILE-UNAVAILABLE "Cannot inspect $file"; continue; }
        
        if [[ "$actual" != "$expected" ]]; then
            report_finding "MEDIUM" "FILE-003" \
                "Incorrect permissions on $file: $actual (expected $expected)"
        fi
    done
}
```

### SSH audit

```bash
check_ssh_config() {
    local config="${SSHD_CONFIG:-/etc/ssh/sshd_config}" effective root_login pass_auth
    local context="${SSHD_MATCH_CONTEXT:?Provide user=...,host=...,addr=... for the assessed connection}"
    command -v sshd >/dev/null || { report_finding INFO SSH-UNAVAILABLE "sshd unavailable"; return 2; }
    sshd -t -f "$config" || { report_finding INFO SSH-UNAVAILABLE "Configuration could not be validated"; return 2; }
    effective=$(sshd -T -f "$config" -C "$context") || return 2
    root_login=$(awk '$1=="permitrootlogin" {print $2}' <<< "$effective")
    pass_auth=$(awk '$1=="passwordauthentication" {print $2}' <<< "$effective")
    [[ -n "$root_login" && -n "$pass_auth" ]] || return 2
    if [[ $root_login == yes ]]; then
        report_finding CRIT SSH-001 "Effective PermitRootLogin=yes for $context" "Review policy and alternate administrative access before changing it"
    fi
    if [[ $pass_auth == yes ]]; then
        report_finding HIGH SSH-002 "Effective PasswordAuthentication=yes for $context" "Review intended authentication policy; do not restart automatically"
    fi
    # Protocol 1 checks belong to explicitly versioned historical exercises.
}
```

### Reporting function

```bash
declare -a FINDINGS=()

report_finding() {
    local severity="$1" rule="$2" message="$3" remediation="${4:-}" record
    local occurrence="${rule}-$(( ${#FINDINGS[@]} + 1 ))"
    record=$(python3 - "$severity" "$rule" "$occurrence" "$message" "$remediation" <<'PYRECORD'
import json, sys
print(json.dumps(dict(zip(('severity','rule_id','id','message','remediation'), sys.argv[1:]))))
PYRECORD
) || return 1
    FINDINGS+=("$record")
    if [[ ${QUIET:-false} != true ]]; then printf '[%s] %s: %s\n' "$severity" "$occurrence" "$message" >&2; fi
    return 0
}

generate_report() {
    local format="${1:-text}"
    # One JSON record per array element; JSON escapes embedded pipes/newlines/quotes.
    printf '%s\n' "${FINDINGS[@]}" | python3 -c '
import json, sys
rows=[json.loads(line) for line in sys.stdin if line.strip()]
if sys.argv[1]=="json": print(json.dumps(rows, indent=2))
elif sys.argv[1]=="text":
    for row in rows:
        print("[{severity}] {id}: {message}".format(**row))
        if row["remediation"]: print("  Remediation:", row["remediation"])
else: raise SystemExit("Unsupported report format")
' "$format"
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| User audit | 15% | Empty pass, UID 0, expiry |
| File audit | 20% | World-writable, SUID, critical files |
| Service audit | 20% | SSH, sudo, cron |
| Network audit | 15% | Ports, firewall |
| Reporting | 10% | Severity, remediations, export |
| Baseline/CIS | 10% | Comparison, compliance |
| Code quality + tests | 5% | Modular, tests |
| Documentation | 5% | README, checks doc |

---

## Resources

- CIS Benchmarks for Linux (free PDF)
- `man sudoers`, `man sshd_config`
- Linux Security Hardening guides
- Seminar 3 - Permissions and administration

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
