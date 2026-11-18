# M14: Environment Config Manager

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Manager for configurations and environment variables: support for multiple environments (dev/staging/prod), secrets management, template rendering and configuration synchronisation between machines.

---

## Learning Objectives

- Environment variables and dotfiles management
- Template rendering in Bash
- Secrets management (encryption/decryption)
- Configuration versioning and diff
- Configuration deployment across multiple machines

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Environment management**
   - Define multiple environments (dev, staging, prod)
   - Environment-specific variables
   - Inheritance and overrides

2. **Template system**
   - Template files with placeholders (`${VAR}`)
   - Environment-based rendering
   - Template validation

3. **Secrets handling**
   - Secrets encryption (GPG or openssl)
   - Decryption at deploy time
   - No plain text secrets storage

4. **Apply/Sync**
   - Apply config on current machine
   - Backup before modification
   - Rollback on problems

5. **Diff and validation**
   - Comparison between environments
   - Complete configuration validation
   - Missing variable detection

### Optional (for full marks)

6. **Remote sync** - Synchronisation on remote machines via SSH
7. **Version control** - Git integration for history
8. **Hooks** - Pre/post apply hooks
9. **Schema validation** - Type and value validation
10. **UI** - Dashboard for configuration visualisation

---

## CLI Interface

```text
./envman.sh <command> [options]

Commands:
  init                  Initialise project structure
  env list              List available environments
  env create <n>     Create new environment
  env show <n>       Display environment variables
  set <key> <value>     Set variable
  get <key>             Display variable value
  render <template>     Render template
  apply [env]           Apply configurations
  diff <env1> <env2>    Compare two environments
  export <env>          Export as .env file
  secret encrypt <key>  Encrypt value
  secret decrypt <key>  Decrypt value
  sync <target>         Synchronise to remote

Options:
  -e, --env ENV         Target environment (default: development)
  -f, --file FILE       Configuration file
  -o, --output FILE     Output file
  -d, --dry-run         Simulation without modifications
  -v, --verbose         Detailed output
  --no-backup           Don't create backup
  --force               Force operation

Examples:
  ./envman.sh env create production
  ./envman.sh set -e production DATABASE_URL "postgres://..."
  ./envman.sh secret encrypt -e production API_KEY
  ./envman.sh render nginx.conf.tmpl -o /etc/nginx/nginx.conf
  ./envman.sh apply production
  ./envman.sh diff staging production
```

---

## Output Examples

### Environment Show

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ENVIRONMENT: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

VARIABLES
═══════════════════════════════════════════════════════════════════════════════

Application:
  APP_NAME              myapp
  APP_ENV               production
  APP_DEBUG             false
  APP_URL               https://myapp.example.com

Database:
  DATABASE_HOST         db.example.com
  DATABASE_PORT         5432
  DATABASE_NAME         myapp_prod
  DATABASE_USER         myapp
  DATABASE_PASSWORD     ******** (encrypted)

Cache:
  REDIS_HOST            redis.example.com
  REDIS_PORT            6379
  REDIS_PASSWORD        ******** (encrypted)

External Services:
  AWS_REGION            eu-west-1
  AWS_ACCESS_KEY        ******** (encrypted)
  AWS_SECRET_KEY        ******** (encrypted)
  SMTP_HOST             smtp.example.com

INHERITANCE
───────────────────────────────────────────────────────────────────────────────
  Base: default → production
  Overrides: 12 variables
  Secrets: 5 encrypted values

FILES TO RENDER
───────────────────────────────────────────────────────────────────────────────
  templates/nginx.conf.tmpl      → /etc/nginx/sites-available/myapp
  templates/app.env.tmpl         → /opt/myapp/.env
  templates/systemd.service.tmpl → /etc/systemd/system/myapp.service
```

### Diff Between Environments

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DIFF: staging ↔ production                                ║
╚══════════════════════════════════════════════════════════════════════════════╝

DIFFERENT VALUES
═══════════════════════════════════════════════════════════════════════════════

Variable             staging                    production
─────────────────────────────────────────────────────────────────────────────
APP_ENV              staging                    production
APP_DEBUG            true                       false
APP_URL              https://staging.app.com   https://myapp.example.com
DATABASE_HOST        staging-db.local           db.example.com
DATABASE_NAME        myapp_staging              myapp_prod
REDIS_HOST           localhost                  redis.example.com
LOG_LEVEL            debug                      info

ONLY IN STAGING
═══════════════════════════════════════════════════════════════════════════════
  DEBUG_TOOLBAR       true
  MOCK_PAYMENTS       true

ONLY IN PRODUCTION
═══════════════════════════════════════════════════════════════════════════════
  CDN_URL             https://cdn.example.com
  SENTRY_DSN          https://xxx@sentry.io/123
  RATE_LIMIT          1000

SUMMARY
───────────────────────────────────────────────────────────────────────────────
  Common variables:     45
  Different values:     7
  Only in staging:      2
  Only in production:   3
```

### Template Rendering

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    TEMPLATE RENDERING                                        ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Template: templates/nginx.conf.tmpl
───────────────────────────────────────────────────────────────────────────────

Variables used:
  ✓ APP_URL              → https://myapp.example.com
  ✓ APP_PORT             → 3000
  ✓ SSL_CERT_PATH        → /etc/ssl/certs/myapp.crt
  ✓ SSL_KEY_PATH         → /etc/ssl/private/myapp.key
  ✓ UPSTREAM_SERVERS     → 10.0.0.1:3000,10.0.0.2:3000

Preview (first 20 lines):
───────────────────────────────────────────────────────────────────────────────
  upstream myapp {
      server 10.0.0.1:3000;
      server 10.0.0.2:3000;
  }
  
  server {
      listen 443 ssl http2;
      server_name myapp.example.com;
      
      ssl_certificate /etc/ssl/certs/myapp.crt;
      ssl_certificate_key /etc/ssl/private/myapp.key;
      
      location / {
          proxy_pass http://myapp;
      }
  }

Output: /etc/nginx/sites-available/myapp
Action: Write file? [y/N]
```

---

## Configuration File Structure

```
config/
├── default.env              # Variables common to all environments
├── development.env          # Overrides for dev
├── staging.env              # Overrides for staging
├── production.env           # Overrides for prod
├── secrets/
│   ├── development.enc      # Encrypted dev secrets
│   ├── staging.enc          # Encrypted staging secrets
│   └── production.enc       # Encrypted prod secrets
└── templates/
    ├── nginx.conf.tmpl
    ├── app.env.tmpl
    └── systemd.service.tmpl
```

### Example default.env

```bash
# Common configurations
APP_NAME=myapp
APP_PORT=3000
LOG_FORMAT=json

# Database defaults
DATABASE_PORT=5432

# Cache defaults  
REDIS_PORT=6379
REDIS_DB=0

# Paths
APP_PATH=/opt/myapp
LOG_PATH=/var/log/myapp
```

### Example production.env

```bash
# Extends: default

APP_ENV=production
APP_DEBUG=false
APP_URL=https://myapp.example.com

# Database
DATABASE_HOST=db.example.com
DATABASE_NAME=myapp_prod
DATABASE_USER=myapp

# Cache
REDIS_HOST=redis.example.com

# Logging
LOG_LEVEL=info
```

---

## Project Structure

```
M14_Environment_Config_Manager/
├── README.md
├── Makefile
├── src/
│   ├── envman.sh                # Main script
│   └── lib/
│       ├── env.sh               # Environment management
│       ├── template.sh          # Template rendering
│       ├── secrets.sh           # Encryption/decryption
│       ├── diff.sh              # Environment comparison
│       ├── apply.sh             # Configuration application
│       └── sync.sh              # Remote synchronisation
├── etc/
│   ├── envman.conf
│   └── schema.yaml              # Validation schema
├── tests/
│   ├── test_template.sh
│   ├── test_secrets.sh
│   └── fixtures/
└── docs/
    ├── INSTALL.md
    ├── TEMPLATES.md
    └── SECRETS.md
```

---

## Implementation Hints

### Loading environment with inheritance

```bash
declare -A ENV_VARS=() SECRET_KEYS=() _ENV_NEXT=() _SECRET_NEXT=()
load_environment() {
    local env_name="$1" key
    [[ $env_name =~ ^[A-Za-z0-9_-]+$ ]] || return 2
    [[ -f "$CONFIG_DIR/$env_name.env" ]] || { echo "Unknown environment: $env_name" >&2; return 2; }
    _ENV_NEXT=(); _SECRET_NEXT=()
    if [[ -f "$CONFIG_DIR/default.env" ]]; then load_env_file "$CONFIG_DIR/default.env" || return 1; fi
    load_env_file "$CONFIG_DIR/$env_name.env" || return 1
    load_secrets "$env_name" || return 1
    # Commit only after the complete new environment has loaded successfully.
    ENV_VARS=(); SECRET_KEYS=()
    for key in "${!_ENV_NEXT[@]}"; do ENV_VARS[$key]="${_ENV_NEXT[$key]}"; done
    for key in "${!_SECRET_NEXT[@]}"; do SECRET_KEYS[$key]=1; done
}

load_env_file() {
    local file="$1" line key value quote
    # Literal, single-line KEY=VALUE grammar: no export, expansion or multiline values.
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        [[ $line == *=* ]] || return 2
        key=${line%%=*}; value=${line#*=}
        [[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 2
        quote=${value:0:1}
        if [[ $quote == '"' || $quote == "'" ]]; then
            [[ ${#value} -ge 2 && ${value: -1} == "$quote" ]] || return 2
            value=${value:1:${#value}-2}
        fi
        _ENV_NEXT[$key]="$value"
    done < "$file"
}
```

### Template rendering

```bash
render_template() {
    local template="$1" output="${2:-}" key
    # NUL transport to the renderer keeps secrets out of process argv and temp map files.
    for key in "${!ENV_VARS[@]}"; do printf '%s\0%s\0%s\0' "$key" "${ENV_VARS[$key]}" "${SECRET_KEYS[$key]:-0}"; done |
    python3 -c '
import os,re,sys,tempfile
from pathlib import Path
raw=sys.stdin.buffer.read().split(b"\0"); raw.pop()
if len(raw)%3: raise SystemExit("Invalid variable transport")
values={raw[i].decode():raw[i+1].decode() for i in range(0,len(raw),3)}
secrets={raw[i].decode() for i in range(0,len(raw),3) if raw[i+2]==b"1"}
text=Path(sys.argv[1]).read_text(); output=sys.argv[2]; allow=sys.argv[3]=="true"
pattern=re.compile(r"\$\$|\$\{([A-Za-z_][A-Za-z0-9_]*)\}|\$([A-Za-z_][A-Za-z0-9_]*)")
missing=set(); used_secrets=set()
def replace(match):
    if match[0]=="$$": return "$"
    key=match[1] or match[2]
    if key not in values: missing.add(key); return match[0]
    if key in secrets:
        used_secrets.add(key)
        if not allow: return "<redacted>"
    return values[key]
rendered=pattern.sub(replace,text)  # Single pass; values are never re-interpreted.
if missing: raise SystemExit("Unresolved variables: "+", ".join(sorted(missing)))
if output and used_secrets and not allow: raise SystemExit("Secret-bearing output requires an explicit plaintext-output policy")
if not output: print(rendered,end=""); raise SystemExit(0)
target=Path(output)
if target.is_symlink(): raise SystemExit("Refusing a symlink output")
fd,name=tempfile.mkstemp(prefix=target.name+".partial.",dir=target.parent)
try:
    with os.fdopen(fd,"w") as stream: stream.write(rendered); stream.flush(); os.fsync(stream.fileno())
    os.replace(name,target)
finally:
    if os.path.exists(name): os.unlink(name)
' "$template" "$output" "${ALLOW_SECRET_OUTPUT:-false}"
}
```

### Secrets encryption with OpenSSL

```bash
encrypt_value() {
    local value="$1"
    [[ "$value" != *$'\n'* && "$ENVMAN_PASSWORD" != *$'\n'* ]] || return 2
    printf '%s' "$value" | openssl enc -aes-256-cbc -pbkdf2 -base64 -A \
        -pass fd:3 3<<< "$ENVMAN_PASSWORD"
}

decrypt_value() {
    printf '%s' "$1" | openssl enc -aes-256-cbc -pbkdf2 -d -base64 -A \
        -pass fd:3 3<<< "$ENVMAN_PASSWORD"
}

save_secret() (
    umask 077
    local env="$1" key="$2" value="$3" encrypted stage
    [[ $env =~ ^[A-Za-z0-9_-]+$ && $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 2
    mkdir -p -- "$CONFIG_DIR/secrets" || return 1
    local secrets_file="$CONFIG_DIR/secrets/$env.enc"
    exec {lock_fd}>"$secrets_file.lock" || return 1
    flock -x "$lock_fd" || return 1
    encrypted=$(encrypt_value "$value") || return 1
    [[ $encrypted =~ ^[A-Za-z0-9+/=]+$ ]] || return 1
    stage=$(mktemp "$secrets_file.partial.XXXXXX") || return 1
    trap 'rm -f -- "$stage"' EXIT
    if [[ -f "$secrets_file" ]]; then
        awk -F= -v key="$key" '$1!=key' "$secrets_file" > "$stage" || return 1
    fi
    printf '%s=%s\n' "$key" "$encrypted" >> "$stage" || return 1
    mv -- "$stage" "$secrets_file"
)

load_secrets() {
    local env="$1" secrets_file="$CONFIG_DIR/secrets/$1.enc" line key encrypted value
    [[ -f "$secrets_file" ]] || return 0
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue
        [[ $line == *=* ]] || return 2
        # Split only the first separator; Base64 padding is part of the value.
        key=${line%%=*}; encrypted=${line#*=}
        [[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ && $encrypted =~ ^[A-Za-z0-9+/=]+$ ]] || return 2
        value=$(decrypt_value "$encrypted") || return 1
        _ENV_NEXT[$key]="$value"
        _SECRET_NEXT[$key]=1
    done < "$secrets_file"
}
```

This CBC example provides confidentiality, not authenticated tamper detection.
It accepts single-line text secrets; NUL/multiline values require a structured
binary-safe format. Use a protected prompt/descriptor for the password, do not
export it or enable shell tracing. The project must choose authenticated storage
if tamper detection is required. Rendering secrets into service configuration
creates plaintext output: the tension with “no plain text secrets storage” remains
an explicit author decision. Default previews redact; `ALLOW_SECRET_OUTPUT=true`
is an explicit caller choice, not a policy selected by the kit. Such output needs
permissions/lifecycle/backup rules before operational use.

### Diff between environments

```bash
diff_environments() {
    local env1="$1"
    local env2="$2"
    
    declare -A vars1 vars2 secret1 secret2
    
    # Load both
    load_environment "$env1" || return 1
    for k in "${!ENV_VARS[@]}"; do vars1[$k]="${ENV_VARS[$k]}"; done
    
    for k in "${!SECRET_KEYS[@]}"; do secret1[$k]=1; done
    
    load_environment "$env2" || return 1
    for k in "${!ENV_VARS[@]}"; do vars2[$k]="${ENV_VARS[$k]}"; done
    
    for k in "${!SECRET_KEYS[@]}"; do secret2[$k]=1; done
    # Compare
    echo "Different values:"
    for key in "${!vars1[@]}"; do
        if [[ -v vars2[$key] ]]; then
            if [[ "${vars1[$key]}" != "${vars2[$key]}" ]]; then
                if [[ ${secret1[$key]:-0} == 1 || ${secret2[$key]:-0} == 1 ]]; then
                    printf '  %s: <redacted> → <redacted> (different)\n' "$key"
                else
                    printf '  %s: %s → %s\n' "$key" "${vars1[$key]}" "${vars2[$key]}"
                fi
            fi
        fi
    done
    
    echo "Only in $env1:"
    for key in "${!vars1[@]}"; do
        [[ ! -v vars2[$key] ]] && echo "  $key"
    done
    
    echo "Only in $env2:"
    for key in "${!vars2[@]}"; do
        [[ ! -v vars1[$key] ]] && echo "  $key"
    done
    return 0
}
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Environment management | 20% | Multi-env, inheritance |
| Template rendering | 20% | Variables, validation |
| Secrets management | 20% | Encrypt/decrypt, secure |
| Apply/sync | 15% | Local apply, backup |
| Diff & validation | 10% | Compare, detect missing |
| Remote sync | 5% | SSH sync |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, template doc |

---

## Resources

- `man openssl enc` - Symmetric encryption
- `man gpg` - GPG encryption
- 12 Factor App - Config management
- Seminar 3-4 - Variables, text processing

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
