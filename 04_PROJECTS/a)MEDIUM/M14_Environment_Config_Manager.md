# M14: Environment Config Manager

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Develop a configuration and environment-variable manager using synthetic local environments (dev/staging/prod). The supplied reference supports redacted previews and a disposable local configuration exercise. Real credentials, receiving services, remote synchronisation and an authenticated secret store are deferred extensions.

---

## Adopted local teaching profile (D7)

Use fictitious values only. Mark synthetic secret values with `DEMO_ONLY_`; this
is an exercise convention, not a detector proving that arbitrary input is safe.
Previews always redact values marked as secrets, even if
`ALLOW_SECRET_OUTPUT=true` is inherited. Non-secret values must not contain
credentials. Real deployment, authenticated storage and Windows ACL acceptance
are outside this adopted profile.

A plaintext exercise output requires an explicit `--workspace`, new
`--output-dir` name and `--synthetic-demo` request. On POSIX, the workspace must
already be owned by the exercising user with mode `0700`; the reference creates
a fresh child directory `0700` and `service.conf` with mode `0600`. A local dummy
receiver checks the exact bytes, after which the file and child directory are
removed. Existing targets, links, unexpected ownership and non-private workspaces
are refused. A handled error triggers cleanup; failure to confirm cleanup is
reported as residual output for inspection, never as success.

Keep the workspace outside version control and synchronised folders. The helper
rejects version-control markers and common synchronisation locations; it cannot
discover every background synchronisation configuration. The user must select
local scratch storage. No secret value is passed in a child process argument or
printed by output-mode reporting. The reference makes no secure-erasure, crash
recovery or general absence-of-plaintext-from-memory guarantee. An unhandled
process termination can leave output: inspect the named workspace before reuse.

The [renderer reference](../reference/m14/render_local.py) implements this bounded
exercise, not the complete student CLI or configuration manager. The grading
percentages later in this document remain planning material under the
[assessment contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md).

## Learning Objectives

- Environment variables and dotfiles management
- Template rendering in Bash
- Secrets management (encryption/decryption)
- Configuration versioning and diff
- Configuration deployment design and trust boundaries (deferred operational extension)

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
   - A clearly labelled CBC round-trip using synthetic values only
   - Redacted previews; explicit disposable plaintext for the local dummy receiver
   - Fresh private output, exact-byte verification and cleanup
   - Authenticated storage and real-service decryption remain deferred

4. **Apply/Sync**
   - Apply only to the local dummy receiver in private scratch storage
   - Refuse an existing output target; do not modify system configuration
   - Clean up created output on success and handled failure

5. **Diff and validation**
   - Comparison between environments
   - Complete configuration validation
   - Missing variable detection

### Optional (for full marks)

6. **Remote sync** - Deferred design extension requiring separately approved endpoints and trust
7. **Version control** - Non-secret templates and source history only; exclude rendered outputs and secret stores
8. **Hooks** - Pre/post apply hooks
9. **Schema validation** - Type and value validation
10. **UI** - Dashboard for configuration visualisation

---

## CLI Interface

This is the student CLI contract. The supplied renderer is invoked separately as
shown below; it does not implement all these commands. Secret input must use a
protected prompt or descriptor, never a command-line value.

```text
./envman.sh <command> [options]

Commands:
  init                  Initialise project structure
  env list              List available environments
  env create <n>     Create new environment
  env show <n>       Display environment variables
  set <key> <value>     Set a non-secret variable
  get <key>             Display variable value
  render <template>     Render template
  apply [env]           Exercise the local dummy receiver only
  diff <env1> <env2>    Compare two environments
  export <env>          Export as .env file
  secret encrypt <key>  Encrypt value
  secret decrypt <key>  Decrypt value
  sync <target>         Deferred real-service extension

Options:
  -e, --env ENV         Target environment (default: development)
  -f, --file FILE       Configuration file
  --workspace DIR      Existing private local scratch directory (mode 0700)
  --output-dir NAME    New disposable child directory for the dummy receiver
  --synthetic-demo     Explicit acknowledgement of fictitious values only
  -d, --dry-run         Simulation without modifications
  -v, --verbose         Detailed output
  --no-backup           Don't create backup
  --force               Never bypass secret-output or existing-target checks

Examples:
  ./envman.sh env create production
  ./envman.sh set -e production DATABASE_HOST "db.example.invalid"
  ./envman.sh secret encrypt -e production API_KEY
  ./envman.sh render nginx.conf.tmpl                 # Redacted preview
  ./envman.sh render app.env.tmpl --workspace "$M14_WORKSPACE" --output-dir run1 --synthetic-demo
  ./envman.sh apply production                     # Local dummy receiver only
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
  templates/nginx.conf.tmpl      → private scratch / run1 / service.conf
  templates/app.env.tmpl         → private scratch / run2 / service.conf
  templates/systemd.service.tmpl → private scratch / run3 / service.conf
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

For a template containing `app=${APP}` and `secret=${TOKEN}`, the default preview
with `APP=demo` and a marked synthetic token is:

```text
app=demo
secret=<redacted>
```

An explicit local output request creates `service.conf` in a fresh private
exercise directory. The dummy receiver compares its exact bytes and the helper
then removes that file and directory. The JSON report contains
`status: VERIFIED_LOCAL_SYNTHETIC`, the byte count and `output_removed: true`.
It never prints the unredacted configuration. No `/etc` or service path is a
valid deployment target under this profile.

---

## Configuration File Structure

The following is a logical layout for fictitious exercise data. Keep runtime
`CONFIG_DIR` and rendered outputs in private local scratch storage, outside the
source repository and synchronised folders. Environment names such as
`production` are labels in this exercise, not connections to real services.

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

Set `M14_RENDERER` to the supplied `04_PROJECTS/reference/m14/render_local.py`.
The NUL-delimited input protocol carries keys, values and secret markers through
standard input. Only single-line UTF-8 values are supported; duplicate keys and
malformed input are rejected. Substitution is one pass: substituted values are
not evaluated as shell code or expanded again.

```bash
render_template() {
    local template="$1" key
    shift
    [[ -n ${M14_RENDERER:-} && -f $M14_RENDERER && ! -L $M14_RENDERER ]] || {
        printf 'Set M14_RENDERER to the supplied renderer reference\n' >&2
        return 2
    }
    for key in "${!ENV_VARS[@]}"; do
        printf '%s\0%s\0%s\0' "$key" "${ENV_VARS[$key]}" "${SECRET_KEYS[$key]:-0}"
    done | python3 "$M14_RENDERER" "$template" "$@"
}
```

From the repository root, a local exercise uses:

```bash
M14_RENDERER="$PWD/04_PROJECTS/reference/m14/render_local.py"
M14_WORKSPACE=$(mktemp -d "${TMPDIR:-/tmp}/enos-m14.XXXXXXXX") || exit 1
chmod 700 "$M14_WORKSPACE" || exit 1
# Load only the fictitious exercise variables into ENV_VARS and SECRET_KEYS.
render_template app.env.tmpl                              # Always redacted
render_template app.env.tmpl --workspace "$M14_WORKSPACE" \
    --output-dir run1 --synthetic-demo
# A successful report confirms dummy-receiver bytes and output removal.
# Stop and inspect any failure; do not recursively delete unexpected contents.
rmdir -- "$M14_WORKSPACE"
```

`ALLOW_SECRET_OUTPUT` has no effect on this reference. An output request cannot
turn a later preview into an unredacted view. Reports contain status and byte
count, not the secret values. Output mode is refused on systems without the
required POSIX directory operations; Windows ACL behaviour is not inferred.

### Secrets encryption with OpenSSL

```bash
encrypt_value() {
    local value="$1"
    [[ ${ENVMAN_SYNTHETIC_DEMO:-false} == true && $value == DEMO_ONLY_* ]] || return 2
    [[ "$value" != *$'\n'* && "$ENVMAN_PASSWORD" != *$'\n'* ]] || return 2
    printf '%s' "$value" | openssl enc -aes-256-cbc -pbkdf2 -base64 -A \
        -pass fd:3 3<<< "$ENVMAN_PASSWORD"
}

decrypt_value() {
    [[ ${ENVMAN_SYNTHETIC_DEMO:-false} == true ]] || return 2
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

This explicitly non-authenticated CBC example is limited to synthetic values.
Set `ENVMAN_SYNTHETIC_DEMO=true` only for this exercise and obtain a fictitious
password through a protected prompt or descriptor. Do not export the password,
pass it in process arguments or enable shell tracing. The example accepts
single-line values; NUL/multiline support requires a separately specified format.
Place `CONFIG_DIR` and any encrypted exercise store in private, local scratch
storage outside version control and synchronised folders. These storage snippets
are teaching fragments, not an accepted authenticated storage backend.

CBC does not authenticate changes to stored data. `openssl enc` does not support
GCM/CCM modes; an authenticated backend cannot be obtained merely by replacing
its CBC option. Real credentials, authenticated envelopes, key custody and
service reload/retention require a separate design, implementation and tests.
The local renderer's disposable plaintext lifecycle above is the adopted D7
exercise; the former blanket promise of no plaintext storage is replaced by
that concrete, testable contract.

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
| Secrets management | 20% | Synthetic round-trip, redacted previews and the adopted local output lifecycle |
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

### Primary sources for the adopted boundary

- OpenSSL Project. (n.d.). *openssl-enc*. https://docs.openssl.org/master/man1/openssl-enc/
- Dworkin, M. (2007). *Recommendation for block cipher modes of operation: Galois/Counter Mode (GCM) and GMAC* (NIST SP 800-38D). National Institute of Standards and Technology. https://doi.org/10.6028/NIST.SP.800-38D

These sources distinguish confidentiality from authenticated encryption. They do
not certify this exercise or prescribe an institutional deployment policy.
