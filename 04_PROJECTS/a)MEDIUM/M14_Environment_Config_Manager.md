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

```bash
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
load_environment() {
    local env_name="$1"
    local config_dir="$CONFIG_DIR"
    
    declare -gA ENV_VARS
    
    # Load default
    load_env_file "$config_dir/default.env"
    
    # Load environment-specific (override)
    local env_file="$config_dir/${env_name}.env"
    if [[ -f "$env_file" ]]; then
        load_env_file "$env_file"
    fi
    
    # Load decrypted secrets
    load_secrets "$env_name"
}

load_env_file() {
    local file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes if present
        value="${value%\"}"
        value="${value#\"}"
        value="${value%\'}"
        value="${value#\'}"
        
        ENV_VARS[$key]="$value"
    done < "$file"
}
```

### Template rendering

```bash
render_template() {
    local template="$1"
    local output="$2"
    
    local content
    content=$(<"$template")
    
    # Replace all variables ${VAR} and $VAR
    for key in "${!ENV_VARS[@]}"; do
        local value="${ENV_VARS[$key]}"
        # Escape for sed
        value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')
        
        content=$(echo "$content" | sed "s/\${$key}/$value/g")
        content=$(echo "$content" | sed "s/\$$key/$value/g")
    done
    
    # Check for unresolved variables
    local missing
    missing=$(echo "$content" | grep -oE '\$\{?[A-Z_][A-Z0-9_]*\}?' | sort -u)
    
    if [[ -n "$missing" ]]; then
        echo "Warning: Unresolved variables:"
        echo "$missing"
    fi
    
    if [[ -n "$output" ]]; then
        echo "$content" > "$output"
    else
        echo "$content"
    fi
}
```

### Secrets encryption with OpenSSL

```bash
encrypt_value() {
    local value="$1"
    local password="$ENVMAN_PASSWORD"
    
    echo "$value" | openssl enc -aes-256-cbc -pbkdf2 -base64 -pass pass:"$password"
}

decrypt_value() {
    local encrypted="$1"
    local password="$ENVMAN_PASSWORD"
    
    echo "$encrypted" | openssl enc -aes-256-cbc -pbkdf2 -d -base64 -pass pass:"$password"
}

# Save encrypted secrets
save_secret() {
    local env="$1"
    local key="$2"
    local value="$3"
    
    local secrets_file="$CONFIG_DIR/secrets/${env}.enc"
    local encrypted
    encrypted=$(encrypt_value "$value")
    
    # Add or update
    if grep -q "^${key}=" "$secrets_file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${encrypted}|" "$secrets_file"
    else
        echo "${key}=${encrypted}" >> "$secrets_file"
    fi
}

load_secrets() {
    local env="$1"
    local secrets_file="$CONFIG_DIR/secrets/${env}.enc"
    
    [[ -f "$secrets_file" ]] || return 0
    
    while IFS='=' read -r key encrypted; do
        [[ -z "$key" ]] && continue
        local value
        value=$(decrypt_value "$encrypted")
        ENV_VARS[$key]="$value"
    done < "$secrets_file"
}
```

### Diff between environments

```bash
diff_environments() {
    local env1="$1"
    local env2="$2"
    
    declare -A vars1 vars2
    
    # Load both
    load_environment "$env1"
    for k in "${!ENV_VARS[@]}"; do vars1[$k]="${ENV_VARS[$k]}"; done
    
    unset ENV_VARS
    declare -gA ENV_VARS
    
    load_environment "$env2"
    for k in "${!ENV_VARS[@]}"; do vars2[$k]="${ENV_VARS[$k]}"; done
    
    # Compare
    echo "Different values:"
    for key in "${!vars1[@]}"; do
        if [[ -v vars2[$key] ]]; then
            if [[ "${vars1[$key]}" != "${vars2[$key]}" ]]; then
                echo "  $key: '${vars1[$key]}' → '${vars2[$key]}'"
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
