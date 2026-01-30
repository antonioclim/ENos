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

```bash
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
deploy_symlink() {
    local package="$1"
    local env="$2"
    local version="$3"
    
    local releases_dir="/opt/${PROJECT}/releases"
    local current_link="/opt/${PROJECT}/current"
    local target_dir="${releases_dir}/${version}"
    
    # Extract to releases/
    mkdir -p "$target_dir"
    tar -xzf "$package" -C "$target_dir"
    
    # Atomic symlink swap
    ln -sfn "$target_dir" "${current_link}.new"
    mv -Tf "${current_link}.new" "$current_link"
    
    echo "Deployed $version"
}

rollback_symlink() {
    local env="$1"
    local version="$2"
    
    local releases_dir="/opt/${PROJECT}/releases"
    local current_link="/opt/${PROJECT}/current"
    
    if [[ -z "$version" ]]; then
        # Find previous version
        version=$(ls -t "$releases_dir" | sed -n '2p')
    fi
    
    [[ -d "${releases_dir}/${version}" ]] || die "Version $version not found"
    
    ln -sfn "${releases_dir}/${version}" "${current_link}.new"
    mv -Tf "${current_link}.new" "$current_link"
    
    echo "Rolled back to $version"
}
```

### Health check with retry

```bash
health_check() {
    local url="$1"
    local timeout="${2:-30}"
    local retries="${3:-3}"
    local delay="${4:-5}"
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_info "Health check attempt $attempt/$retries..."
        
        local status
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
        
        if [[ "$status" == "200" ]]; then
            log_info "Health check passed (HTTP $status)"
            return 0
        fi
        
        log_warn "Health check failed (HTTP $status)"
        
        ((attempt++))
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
            current=$(cat VERSION 2>/dev/null || echo "0.0.0")
            
            IFS='.' read -r major minor patch <<< "$current"
            
            case "$increment" in
                major) echo "$((major + 1)).0.0" ;;
                minor) echo "${major}.$((minor + 1)).0" ;;
                patch) echo "${major}.${minor}.$((patch + 1))" ;;
            esac
            ;;
        timestamp)
            date +"%Y%m%d.%H%M%S"
            ;;
        git-sha)
            git rev-parse --short HEAD
            ;;
    esac
}
```

### Old releases cleanup

```bash
cleanup_old_releases() {
    local releases_dir="$1"
    local keep="$2"
    local current
    
    current=$(readlink /opt/${PROJECT}/current | xargs basename)
    
    ls -t "$releases_dir" | tail -n +$((keep + 1)) | while read -r release; do
        [[ "$release" == "$current" ]] && continue
        
        log_info "Removing old release: $release"
        rm -rf "${releases_dir}/${release}"
    done
}
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
