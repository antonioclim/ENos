# M05: Deployment Pipeline

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Complete deployment pipeline for applications: build, test, package, deploy with support for multiple environments (dev/staging/prod), automatic rollback and notifications. Simulates a mini CI/CD without external dependencies.

---

## Learning Objectives

- CI/CD concepts and deployment automation
- Environment management (dev/staging/prod)
- Versioning and release management
- Rollback and disaster recovery
- Integration with Git hooks

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Build stage**
   - Automatic project type detection (Node, Python, Go, static)
   - Dependency installation
   - Compilation/bundling where applicable
   - Build artifact generation

2. **Test stage**
   - Run automated tests
   - Generate coverage report (if available)
   - Fail pipeline if tests fail

3. **Package stage**
   - Create deployment archive (tar.gz)
   - Automatic versioning (semver or timestamp)
   - Generate manifest with metadata

4. **Deploy stage**
   - Support multiple environments (dev, staging, prod)
   - Backup before deploy
   - Atomic deploy (symlink swap)
   - Post-deploy health check

5. **Rollback**
   - Rollback to previous version
   - Deployment history
   - Automatic rollback on health check failure

### Optional (for full marks)

6. **Notifications** - Slack/email on success/failure
7. **Git integration** - Deploy on specific tag or branch
8. **Blue-green deployment** - Zero downtime
9. **Canary releases** - Gradual deploy with monitoring
10. **Secrets management** - Encrypted environment variables

---

## CLI Interface

```text
./deploy.sh <command> [options]

Commands:
  init                  Initialise pipeline configuration
  build                 Run build stage
  test                  Run tests
  package               Create deployment package
  deploy <env>          Deploy to environment (dev|staging|prod)
  rollback <env> [ver]  Rollback to previous version
  status <env>          Current deployment status
  history <env>         Deployment history
  promote <from> <to>   Promote version between environments
  cleanup <env>         Delete old deployments

Options:
  -c, --config FILE     Configuration file (default: deploy.yaml)
  -v, --version VER     Specific version for deploy
  -f, --force           Force deploy (skip confirmations)
  -n, --dry-run         Simulation without changes
  --no-backup           Skip backup before deploy
  --no-tests            Skip tests (ONLY for dev)
  --tag TAG             Deploy specific git tag
  --branch BRANCH       Deploy specific branch

Examples:
  ./deploy.sh init
  ./deploy.sh build && ./deploy.sh test && ./deploy.sh package
  ./deploy.sh deploy staging
  ./deploy.sh deploy prod -v 1.2.3
  ./deploy.sh rollback prod
  ./deploy.sh promote staging prod
```

---

## Output Examples

### Build Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT PIPELINE - BUILD STAGE                         ║
║                    Project: myapp | Type: nodejs                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

[14:30:01] ▶ Starting build...
[14:30:01] ├─ Detecting project type... nodejs (package.json found)
[14:30:01] ├─ Node version: 20.10.0 ✓
[14:30:01] ├─ NPM version: 10.2.3 ✓
[14:30:02] ├─ Installing dependencies...
[14:30:15] │  └─ 847 packages installed
[14:30:15] ├─ Running build script (npm run build)...
[14:30:28] │  └─ Build output: dist/ (2.3 MB)
[14:30:28] ├─ Generating source maps... ✓
[14:30:29] └─ Build completed successfully

┌─────────────────────────────────────────────────────────────────────────────┐
│ BUILD SUMMARY                                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│ Duration:        28 seconds                                                 │
│ Output size:     2.3 MB (dist/)                                            │
│ Git commit:      a1b2c3d "feat: add user dashboard"                        │
│ Git branch:      main                                                       │
│ Build number:    #142                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

✓ BUILD PASSED - Ready for test stage
```

### Deploy Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT PIPELINE - DEPLOY STAGE                        ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

[15:00:01] ▶ Starting deployment to PRODUCTION
[15:00:01] │
[15:00:01] ├─ Pre-flight checks
[15:00:01] │  ├─ Package exists: myapp-1.2.3.tar.gz ✓
[15:00:01] │  ├─ Target accessible: prod-server.local ✓
[15:00:02] │  ├─ Disk space: 45 GB available ✓
[15:00:02] │  └─ Tests passed: build #142 ✓
[15:00:02] │
[15:00:02] ├─ Creating backup
[15:00:02] │  ├─ Current version: 1.2.2
[15:00:05] │  └─ Backup created: /var/backups/myapp/1.2.2_20250120.tar.gz
[15:00:05] │
[15:00:05] ├─ Deploying version 1.2.3
[15:00:05] │  ├─ Uploading package... 2.3 MB
[15:00:08] │  ├─ Extracting to /opt/myapp/releases/1.2.3/
[15:00:10] │  ├─ Installing dependencies...
[15:00:25] │  ├─ Running migrations... (2 pending)
[15:00:28] │  ├─ Updating symlink: /opt/myapp/current → releases/1.2.3
[15:00:28] │  └─ Restarting service...
[15:00:30] │
[15:00:30] ├─ Health checks
[15:00:30] │  ├─ Service status: active ✓
[15:00:31] │  ├─ HTTP health: 200 OK (45ms) ✓
[15:00:32] │  ├─ Database connection: OK ✓
[15:00:32] │  └─ All checks passed ✓
[15:00:32] │
[15:00:32] └─ Deployment completed successfully!

┌─────────────────────────────────────────────────────────────────────────────┐
│ DEPLOYMENT SUMMARY                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ Environment:     production                                                 │
│ Version:         1.2.2 → 1.2.3                                             │
│ Duration:        31 seconds                                                 │
│ Deployed by:     antonio                                                    │
│ Rollback:        ./deploy.sh rollback prod 1.2.2                           │
└─────────────────────────────────────────────────────────────────────────────┘

📧 Notification sent to #deployments channel
```

### Rollback Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ⚠️  ROLLBACK INITIATED                                    ║
║                    Environment: production                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Rolling back: 1.2.3 → 1.2.2

[15:05:01] ├─ Stopping current service...
[15:05:03] ├─ Updating symlink: current → releases/1.2.2
[15:05:03] ├─ Starting service...
[15:05:05] ├─ Health check... ✓
[15:05:05] └─ Rollback completed

⚠️  Version 1.2.3 marked as failed
    Review logs: /var/log/myapp/deploy_1.2.3.log
```

---

## Configuration File

```yaml
# deploy.yaml
project:
  name: myapp
  type: nodejs           # nodejs|python|go|static
  build_cmd: "npm run build"
  test_cmd: "npm test"
  
versioning:
  strategy: semver       # semver|timestamp|git-sha
  auto_increment: patch  # major|minor|patch

environments:
  dev:
    host: localhost
    path: /opt/myapp
    user: deploy
    branch: develop
    auto_deploy: true
    
  staging:
    host: staging.local
    path: /opt/myapp
    user: deploy
    branch: main
    requires_tests: true
    
  prod:
    host: prod.local
    path: /opt/myapp
    user: deploy
    branch: main
    requires_tests: true
    requires_approval: true
    backup_retention: 10

deploy:
  strategy: symlink      # symlink|rsync|docker
  health_check:
    enabled: true
    url: "http://localhost:3000/health"
    timeout: 30
    retries: 3
  rollback_on_failure: true
  
notifications:
  slack:
    webhook: "${SLACK_WEBHOOK}"
    channel: "#deployments"
  email:
    to: "team@example.com"
    on: [failure, prod_deploy]

cleanup:
  keep_releases: 5
  keep_backups: 10
```

---

## Project Structure

```
M05_Deployment_Pipeline/
├── README.md
├── Makefile
├── src/
│   ├── deploy.sh                # Main script
│   └── lib/
│       ├── build.sh             # Build stage
│       ├── test.sh              # Test stage
│       ├── package.sh           # Package stage
│       ├── deploy_stage.sh      # Deploy logic
│       ├── rollback.sh          # Rollback logic
│       ├── health.sh            # Health checks
│       ├── notify.sh            # Notifications
│       ├── config.sh            # Configuration parser
│       └── git.sh               # Git operations
├── etc/
│   ├── deploy.yaml.example
│   └── hooks/
│       ├── pre-deploy.sh.example
│       └── post-deploy.sh.example
├── templates/
│   ├── manifest.json.tmpl
│   └── notification.tmpl
├── tests/
│   ├── test_build.sh
│   ├── test_deploy.sh
│   └── mock_project/            # Test project
├── docs/
│   ├── INSTALL.md
│   ├── CONFIGURATION.md
│   └── STRATEGIES.md
└── examples/
    ├── nodejs/
    ├── python/
    └── static/
```

---

## Implementation Hints

### Project type detection

```bash
detect_project_type() {
    local project_dir="$1"
    
    if [[ -f "$project_dir/package.json" ]]; then
        echo "nodejs"
    elif [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "$project_dir/go.mod" ]]; then
        echo "go"
    elif [[ -f "$project_dir/Makefile" ]]; then
        echo "make"
    else
        echo "static"
    fi
}
```

### Atomic deploy with symlink

```bash
# Populate these maps from a validated configuration parser, never eval its data.
declare -A ENV_PATHS=() ENV_HOSTS=() ENV_USERS=()
resolve_environment() {
    local env="$1"
    [[ $env =~ ^[A-Za-z0-9_-]+$ && -n ${ENV_PATHS[$env]:-} ]] || return 2
    [[ ${ENV_HOSTS[$env]:-localhost} == localhost ]] || { echo "Remote transport must be implemented explicitly" >&2; return 2; }
    [[ ${ENV_USERS[$env]:-$(id -un)} == "$(id -un)" ]] || return 2
    [[ ${ENV_PATHS[$env]} == /* && ${ENV_PATHS[$env]} != / && ! -L ${ENV_PATHS[$env]} ]] || return 2
    printf '%s\n' "${ENV_PATHS[$env]}"
}

valid_release() { [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ && $1 != . && $1 != .. ]]; }

validate_package() {
    # Caller supplies an independently retained expected content digest.
    python3 - "$1" "${PACKAGE_SHA256:-}" <<'PACKAGE'
import hashlib,re,sys,tarfile
from pathlib import Path,PurePosixPath
path=Path(sys.argv[1]); expected=sys.argv[2]
if not re.fullmatch(r'[0-9a-f]{64}',expected): raise SystemExit('Expected SHA-256 required')
if hashlib.sha256(path.read_bytes()).hexdigest()!=expected: raise SystemExit('Package digest mismatch')
with tarfile.open(path,'r:gz') as archive:
    seen=set()
    for item in archive:
        name=PurePosixPath(item.name)
        if name.is_absolute() or '..' in name.parts or item.name in seen: raise SystemExit('Unsafe/duplicate member')
        if not (item.isfile() or item.isdir()): raise SystemExit('This teaching package accepts only regular files/directories')
        seen.add(item.name)
    if not seen: raise SystemExit('Empty package')
PACKAGE
}

deploy_symlink() (
    local package="$1" env="$2" version="$3" root stage switch previous=''
    valid_release "$version" || return 2
    root=$(resolve_environment "$env") || return 2
    [[ -r "$package" ]] || return 1
    mkdir -p -- "$root/releases" || return 1
    exec {lock_fd}>"$root/deploy.lock" || return 1
    flock -n "$lock_fd" || return 1  # Keep this inode; do not unlink on unlock.
    [[ ! -e "$root/releases/$version" ]] || return 1
    [[ ! -e "$root/current" || -L "$root/current" ]] || return 1
    if [[ -L "$root/current" ]]; then
        previous=$(readlink -- "$root/current") || return 1
        [[ $previous == releases/* && $previous != */../* ]] || return 1
    fi
    stage=$(mktemp -d "$root/releases/.stage.XXXXXX") || return 1
    switch=$(mktemp -d "$root/.switch.XXXXXX") || { rm -rf -- "$stage"; return 1; }
    trap 'rm -rf -- "$stage" "$switch"' EXIT
    # Validate and extract one owned snapshot, not a mutable external pathname.
    cp -- "$package" "$switch/package.tar.gz" || return 1
    validate_package "$switch/package.tar.gz" || return 1
    tar --extract --gzip --file="$switch/package.tar.gz" --directory="$stage" --no-same-owner || return 1
    touch "$stage/.complete" || return 1
    mv -- "$stage" "$root/releases/$version" || return 1
    ln -s "releases/$version" "$switch/current" || return 1
    # Record planned transition before promotion; recovery compares it with current.
    printf '%s\n%s\n' "$previous" "releases/$version" > "$switch/transition" || return 1
    mv -- "$switch/transition" "$root/transition" || return 1
    mv -Tf -- "$switch/current" "$root/current" || return 1
    printf 'Deployed %s to %s\n' "$version" "$env"
)

rollback_symlink() (
    local env="$1" version="${2:-}" root previous active
    root=$(resolve_environment "$env") || return 2
    exec {lock_fd}>"$root/deploy.lock" || return 1
    flock -n "$lock_fd" || return 1
    if [[ -z "$version" ]]; then
        [[ -r "$root/transition" ]] || return 1
        { IFS= read -r previous; IFS= read -r active; } < "$root/transition" || return 1
        [[ $(readlink -- "$root/current") == "$active" && $previous == releases/* ]] || return 1
        version=${previous#releases/}
    fi
    valid_release "$version" || { echo "No valid predecessor" >&2; return 1; }
    [[ -d "$root/releases/$version" && ! -L "$root/releases/$version" && -f "$root/releases/$version/.complete" ]] || return 1
    local switch
    switch=$(mktemp -d "$root/.rollback.XXXXXX") || return 1
    trap 'rm -rf -- "$switch"' EXIT
    ln -s "releases/$version" "$switch/current" || return 1
    mv -Tf -- "$switch/current" "$root/current" || return 1
    printf 'Rolled back %s to %s\n' "$env" "$version"
)
```

The atomic boundary above is replacement of one symlink on the same filesystem.
It does not reverse database migrations, restart a service or prove zero downtime.
`validate_package` checks the supplied SHA-256 and permitted tar member types/paths on an owned copy. It rejects links/special files in this bounded teaching format. The digest establishes consistency with an expected value, not package authorship or build/test acceptance; those gates need their own evidence contract.
The `transition` record supplies a predecessor, not a directory-mtime guess. After
an interrupted transition, compare the record and actual link before choosing any
recovery action. Remote transport and application health gates remain student work.

### Health check with retry

```bash
health_check() {
    local url="$1"
    local timeout="${2:-30}"
    local retries="${3:-3}"
    local delay="${4:-5}"
    
    [[ $timeout =~ ^[1-9][0-9]*$ && $retries =~ ^[1-9][0-9]*$ && $delay =~ ^[0-9]+$ ]] || return 2
    # timeout is per attempt; worst case includes retries and inter-attempt delays.
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_info "Health check attempt $attempt/$retries..."
        
        local status
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" -- "$url") || status=TRANSPORT_ERROR
        
        if [[ "$status" == "200" ]]; then
            log_info "Health check passed (HTTP $status)"
            return 0
        fi
        
        log_warn "Health check failed (HTTP $status)"
        
        attempt=$((attempt + 1))
        [[ $attempt -le $retries ]] && sleep "$delay"
    done
    
    return 1
}
```

### Version generation

```bash
get_next_version() {
    local strategy="$1"  # semver|timestamp|git-sha
    local increment="${2:-patch}"
    
    case "$strategy" in
        semver)
            local current
            if [[ -e VERSION ]]; then current=$(cat VERSION) || return 1; else current=0.0.0; fi
            [[ $current =~ ^([0-9]{1,8})[.]([0-9]{1,8})[.]([0-9]{1,8})$ ]] || return 2
            local major=$((10#${BASH_REMATCH[1]})) minor=$((10#${BASH_REMATCH[2]})) patch=$((10#${BASH_REMATCH[3]}))
            
            case "$increment" in
                major) echo "$((major + 1)).0.0" ;;
                minor) echo "${major}.$((minor + 1)).0" ;;
                patch) echo "${major}.${minor}.$((patch + 1))" ;;
                *) return 2 ;;
            esac
            ;;
        timestamp)
            date +"%Y%m%d.%H%M%S"
            ;;
        git-sha)
            git rev-parse --short HEAD
            ;;
        *) return 2 ;;
    esac
}
```

### Old releases cleanup

```bash
cleanup_old_releases() (
    local env="$1" keep="$2" root current previous='' target=''
    [[ $keep =~ ^[0-9]+$ ]] || return 2
    root=$(resolve_environment "$env") || return 2
    exec {lock_fd}>"$root/deploy.lock" || return 1
    flock -n "$lock_fd" || return 1
    current=$(readlink -- "$root/current") || return 1
    if [[ -r "$root/transition" ]]; then
        { IFS= read -r previous; IFS= read -r target; } < "$root/transition" || return 1
    fi
    local -a releases=()
    local path release kept=0
    while IFS= read -r -d '' path; do
        release=${path##*/}
        valid_release "$release" || continue
        [[ -f "$path/.complete" && ! -L "$path" ]] || continue
        releases+=("$release")
    done < <(find "$root/releases" -mindepth 1 -maxdepth 1 -type d -print0 | sort -zr)
    # Lexical release order is explicit here; replace with a validated version ledger
    # if IDs are not lexically chronological. Current and predecessor are protected.
    for release in "${releases[@]}"; do
        [[ "releases/$release" == "$current" || "releases/$release" == "$previous" ]] && continue
        if ((kept < keep)); then kept=$((kept + 1)); continue; fi
        rm -rf -- "$root/releases/$release" || return 1
    done
)
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Build stage | 15% | Project detection, correct build |
| Test stage | 10% | Test integration, fail on error |
| Package stage | 10% | Archiving, versioning, manifest |
| Deploy stage | 20% | Multi-env, atomic, backup |
| Rollback | 15% | Correct rollback, automatic on fail |
| Health checks | 10% | Post-deploy verification |
| Extra features | 10% | Notifications, blue-green |
| Code quality + tests | 5% | ShellCheck, modular |
| Documentation | 5% | README, configuration |

---

## Resources

- [12 Factor App](https://12factor.net/) - Deployment best practices
- Seminar 3-5 - Advanced scripting, processes
- Git hooks documentation

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
