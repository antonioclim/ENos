# SysDeployer - Advanced Deployment System

CAPSTONE Project - Seminar 6 Operating Systems

SysDeployer is a complete deployment system for applications and services, implemented in Bash. It supports multiple deployment strategies, systemd service management, Docker containers, advanced health checks and automatic rollback.

## Contents

- [Features](#-features)
- [System Requirements](#-system-requirements)
- [Installation](#-installation)
- [Quick Usage](#-quick-usage)
- [Available Actions](#-available-actions)
- [Configuration](#-configuration)
- [Deployment Strategies](#-deployment-strategies)
- [Health Checks](#-health-checks)
- [Hooks System](#-hooks-system)
- [Manifest-Based Deployment](#-manifest-based-deployment)
- [Rollback](#-rollback)
- [Advanced Examples](#-advanced-examples)
- [Architecture](#-architecture)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

## Features

### Core Features
- Multiple Deployment Strategies: Rolling, Blue-Green, Canary
- Service Management: Native systemd support (start, stop, restart, enable)
- Container Support: Docker containers with build, pull, run, stop
- Health Checks: HTTP, TCP, Process, Custom Command
- Automatic Rollback: Automatic revert to previous version on failure
- Version Management: Tracking and management of deployment versions

### Advanced Features
- Hooks System: Pre/post hooks for each deployment phase
- Manifest Deployment: Declarative deployment from YAML files
- Parallel Execution: Support for parallel deployment (configurable)
- Notifications: Email and Slack for deployment status
- Complete Logging: Multi-level with automatic rotation
- Lock Management: Prevention of concurrent deployments on same service

## System Requirements

### Required
- **Bash** >= 4.0
- **coreutils**: date, mkdir, cp, mv, rm, cat, etc.
- **systemd** (for service management) or alternative
- **curl** (for HTTP health checks and notifications)

### Optional
- Docker >= 20.0 (for containers)
- **jq** (for JSON processing)
- **yq** or **python3-yaml** (for YAML manifest)
- nc/netcat (for TCP health checks)
- mail/sendmail (for email notifications)

### Requirements Check
```bash
# Complete check
./deployer.sh --check-deps

# Specific check
command -v systemctl && echo "systemd: OK"
command -v docker && echo "docker: OK"
command -v curl && echo "curl: OK"
```

## Installation

### Local Installation (Development)
```bash
# Clone or copy
cd deployer/

# Create necessary directories
mkdir -p var/{log,run,backups,deployments}
chmod +x deployer.sh bin/sysdeploy

# Test
./deployer.sh --help
```

### System Installation
```bash
# Copy to /opt
sudo mkdir -p /opt/deployer
sudo cp -r . /opt/deployer/
sudo chmod +x /opt/deployer/deployer.sh

# Create symlink
sudo ln -sf /opt/deployer/bin/sysdeploy /usr/local/bin/sysdeploy

# Create runtime directories
sudo mkdir -p /var/log/deployer /var/run/deployer
sudo chown $USER:$USER /var/log/deployer /var/run/deployer
```

### Initial Configuration
```bash
# Copy configuration
sudo cp etc/deployer.conf /etc/deployer/deployer.conf

# Edit configuration
sudo nano /etc/deployer/deployer.conf
```

## Quick Usage

### Deploy Service
```bash
# Deploy simple web application
./deployer.sh deploy --service myapp \
    --source /path/to/myapp \
    --target /opt/myapp \
    --health-check http://localhost:8080/health

# Deploy with rolling strategy
./deployer.sh deploy --service api \
    --source ./api-v2.0 \
    --strategy rolling \
    --instances 3
```

### Deploy Container
```bash
# Deploy container from image
./deployer.sh deploy --container webapp \
    --image nginx:latest \
    --port 8080:80 \
    --health-check http://localhost:8080/

# Deploy container with local build
./deployer.sh deploy --container myapi \
    --build ./Dockerfile \
    --port 3000:3000 \
    --env NODE_ENV=production
```

### Status and Monitoring
```bash
# Specific service status
./deployer.sh status myapp

# List all deployments
./deployer.sh list

# Global health check
./deployer.sh health
```

### Rollback
```bash
# Rollback to previous version
./deployer.sh rollback myapp

# Rollback to specific version
./deployer.sh rollback myapp --version 1.2.0
```

## Available Actions

| Action | Description | Example |
|--------|-------------|---------|
| `deploy` | Deploy new service/container | `deploy --service myapp --source ./app` |
| `rollback` | Revert to previous version | `rollback myapp` |
| `status` | Specific service status | `status myapp` |
| `list` | List all deployments | `list [--format json]` |
| `health` | Health check all services | `health [--service myapp]` |
| `stop` | Stop service | `stop myapp` |
| `start` | Start service | `start myapp` |
| `restart` | Restart service | `restart myapp` |
| `logs` | Display deployment logs | `logs myapp [--lines 100]` |
| `cleanup` | Clean up old deployments | `cleanup [--keep 5]` |

## Configuration

### Main Configuration File
```bash
# /etc/deployer/deployer.conf

#---------------------------------------
# Directories
#---------------------------------------
DEPLOY_BASE_DIR="/opt/deployments"
BACKUP_DIR="/var/backups/deployer"
LOG_DIR="/var/log/deployer"
RUN_DIR="/var/run/deployer"

#---------------------------------------
# Deployment Settings
#---------------------------------------
DEFAULT_STRATEGY="rolling"          # rolling, blue-green, canary
KEEP_VERSIONS=5                     # Versions kept for rollback
DEPLOYMENT_TIMEOUT=300              # Deployment timeout (seconds)
PARALLEL_DEPLOYMENTS=false          # Enable parallel deployment
MAX_PARALLEL=3                      # Max simultaneous deployments

#---------------------------------------
# Health Checks
#---------------------------------------
HEALTH_CHECK_ENABLED=true
HEALTH_CHECK_RETRIES=3
HEALTH_CHECK_INTERVAL=10            # Seconds between attempts
HEALTH_CHECK_TIMEOUT=30             # Timeout per check
AUTO_ROLLBACK_ON_FAILURE=true

#---------------------------------------
# Docker Settings
#---------------------------------------
DOCKER_REGISTRY=""                  # Private registry (optional)
DOCKER_NETWORK="bridge"
DOCKER_RESTART_POLICY="unless-stopped"
DOCKER_PULL_ALWAYS=false

#---------------------------------------
# Notifications
#---------------------------------------
NOTIFY_EMAIL=""                     # admin@example.com
NOTIFY_SLACK_WEBHOOK=""             # https://hooks.slack.com/...
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true

#---------------------------------------
# Logging
#---------------------------------------
LOG_LEVEL="INFO"                    # DEBUG, INFO, WARN, ERROR
LOG_MAX_SIZE=10485760               # 10MB
LOG_RETENTION_DAYS=30
```

### Environment Variables
```bash
# Override configuration via environment
export DEPLOYER_CONFIG="/custom/path/deployer.conf"
export DEPLOYER_LOG_LEVEL="DEBUG"
export DEPLOYER_DRY_RUN="true"

./deployer.sh deploy --service myapp --source ./app
```

## Deployment Strategies

### Rolling Deployment
Gradual deployment, replacing instances one by one.

```bash
./deployer.sh deploy --service api \
    --strategy rolling \
    --instances 4 \
    --batch-size 1 \
    --batch-delay 30
```

Flow:
1. Stop instance 1 → Deploy v2 → Health check → OK
2. Stop instance 2 → Deploy v2 → Health check → OK
3. ... continues until all instances are updated

### Blue-Green Deployment
Two identical environments, instant switch between them.

```bash
./deployer.sh deploy --service webapp \
    --strategy blue-green \
    --port 8080
```

Flow:
1. Deploy v2 in "green" environment (inactive)
2. Health checks on green
3. Switch traffic from "blue" to "green"
4. Blue becomes backup for rollback

### Canary Deployment
Gradual deployment to a subset of users.

```bash
./deployer.sh deploy --service api \
    --strategy canary \
    --canary-percent 10 \
    --canary-duration 300
```

Flow:
1. Deploy v2 on 10% of instances
2. Monitor for 5 minutes
3. If OK → complete deployment
4. If errors → automatic rollback

## Health Checks

### HTTP Health Check
```bash
# Simple GET request
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/health

# With custom parameters
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/api/status \
    --health-expected-code 200 \
    --health-expected-body '"status":"ok"'
```

### TCP Health Check
```bash
# Check port is open
./deployer.sh deploy --service db \
    --health-check tcp://localhost:5432 \
    --health-timeout 10
```

### Process Health Check
```bash
# Check process is running
./deployer.sh deploy --service worker \
    --health-check process://worker.py \
    --health-check-user www-data
```

### Custom Command Health Check
```bash
# Custom command
./deployer.sh deploy --service cache \
    --health-check 'command://redis-cli ping | grep PONG'
```

### Advanced Health Check Configuration
```bash
# Multiple health checks
./deployer.sh deploy --service api \
    --health-check http://localhost:8080/health \
    --health-check tcp://localhost:8080 \
    --health-retries 5 \
    --health-interval 15 \
    --health-timeout 60
```

## Hooks System

Hooks allow execution of custom scripts at different phases of deployment.

### Available Hooks
| Hook | Execution Moment |
|------|------------------|
| `pre-deploy` | Before deployment starts |
| `post-deploy` | After successful deployment |
| `pre-start` | Before service starts |
| `post-start` | After service starts |
| `pre-stop` | Before service stops |
| `post-stop` | After service stops |
| `pre-rollback` | Before rollback |
| `post-rollback` | After rollback |
| `on-failure` | On any error |

### Creating a Hook
```bash
# hooks/pre-deploy.sh
#!/bin/bash
SERVICE_NAME="$1"
VERSION="$2"
SOURCE_DIR="$3"

echo "Preparing deployment for $SERVICE_NAME v$VERSION"

# Pre-deployment validation
if [[ ! -f "$SOURCE_DIR/package.json" ]]; then
    echo "ERROR: package.json missing!"
    exit 1
fi

# Notify team
curl -X POST "$SLACK_WEBHOOK" \
    -d "{\"text\": \"🚀 Starting deployment: $SERVICE_NAME v$VERSION\"}"

exit 0
```

### Enabling Hooks
```bash
# Hooks from standard directory
./deployer.sh deploy --service api \
    --hooks-dir ./hooks

# Individual hook
./deployer.sh deploy --service api \
    --pre-deploy "./scripts/validate.sh" \
    --post-deploy "./scripts/notify.sh"
```

## Manifest-Based Deployment

Complex deployment using YAML manifest file.

### Manifest Example
```yaml
# deploy-manifest.yaml
name: production-stack
version: "2.0.0"

services:
  api:
    type: service
    source: ./api
    target: /opt/api
    strategy: rolling
    instances: 3
    health_check:
      type: http
      url: http://localhost:3000/health
      interval: 10
      retries: 3
    hooks:
      pre_deploy: ./hooks/api-pre.sh
      post_deploy: ./hooks/api-post.sh
    env:
      NODE_ENV: production
      DB_HOST: localhost

  frontend:
    type: container
    image: myregistry/frontend:2.0.0
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /data/static:/usr/share/nginx/html
    health_check:
      type: http
      url: http://localhost:80/
    depends_on:
      - api

  worker:
    type: container
    build: ./worker/Dockerfile
    environment:
      - QUEUE_URL=redis://localhost:6379
    restart: always

settings:
  parallel: true
  max_parallel: 2
  notify:
    slack: https://hooks.slack.com/...
    on_success: true
    on_failure: true
```

### Using Manifest
```bash
# Deploy from manifest
./deployer.sh deploy --manifest deploy-manifest.yaml

# Dry-run for validation
./deployer.sh deploy --manifest deploy-manifest.yaml --dry-run

# Deploy specific service from manifest
./deployer.sh deploy --manifest deploy-manifest.yaml --only api
```

## ↩ Rollback

### Automatic Rollback
Enabled by default when health check fails.

```bash
# Configuration
AUTO_ROLLBACK_ON_FAILURE=true

# During deployment, if health check fails:
# 1. Failure is detected
# 2. Previous version is restored
# 3. Service is restarted
# 4. Health is verified
# 5. Notification is sent (if configured)
```

### Manual Rollback
```bash
# Rollback to immediately previous version
./deployer.sh rollback myapp

# Rollback to specific version
./deployer.sh rollback myapp --version 1.5.2

# List versions available for rollback
./deployer.sh list --service myapp --versions

# Forced rollback (without confirmation)
./deployer.sh rollback myapp --force
```

### Rollback Protection
```bash
# Set version as "protected" (cannot be deleted)
./deployer.sh protect myapp --version 1.0.0

# Disable protection
./deployer.sh unprotect myapp --version 1.0.0
```

## Advanced Examples

### Complete Web Stack Deploy
```bash
#!/bin/bash
# deploy-stack.sh

# 1. Deploy database (without initial health check)
./deployer.sh deploy --service postgres \
    --container \
    --image postgres:15 \
    --port 5432:5432 \
    --env POSTGRES_PASSWORD=secret \
    --volume /data/postgres:/var/lib/postgresql/data \
    --health-check tcp://localhost:5432

# 2. Deploy Redis cache
./deployer.sh deploy --service redis \
    --container \
    --image redis:7-alpine \
    --port 6379:6379 \
    --health-check 'command://docker exec redis redis-cli ping'

# 3. Deploy API (depends on DB and Redis)
./deployer.sh deploy --service api \
    --source ./api \
    --target /opt/api \
    --strategy rolling \
    --pre-deploy "./scripts/wait-for-deps.sh" \
    --health-check http://localhost:3000/health \
    --env DB_HOST=localhost \
    --env REDIS_URL=redis://localhost:6379

# 4. Deploy Frontend
./deployer.sh deploy --service frontend \
    --container \
    --build ./frontend/Dockerfile \
    --port 80:80 \
    --port 443:443 \
    --health-check http://localhost:80/
```

### CI/CD Integration
```bash
# .gitlab-ci.yml or GitHub Actions
deploy_production:
  script:
    - |
      ./deployer.sh deploy \
        --service $SERVICE_NAME \
        --source ./dist \
        --strategy canary \
        --canary-percent 5 \
        --canary-duration 600 \
        --health-check $HEALTH_URL \
        --notify-slack $SLACK_WEBHOOK \
        --tag "build-$CI_PIPELINE_ID"
```

### Blue-Green with Load Balancer
```bash
#!/bin/bash
# blue-green-deploy.sh

SERVICE="webapp"
NEW_VERSION="2.0.0"

# Deploy to green
./deployer.sh deploy --service ${SERVICE}-green \
    --source ./app-${NEW_VERSION} \
    --health-check http://localhost:8081/health

# Additional verification
sleep 30
curl -f http://localhost:8081/health || exit 1

# Switch in load balancer (nginx)
sudo sed -i 's/upstream_blue/upstream_green/' /etc/nginx/sites-enabled/webapp
sudo nginx -t && sudo nginx -s reload

# Mark blue as backup
./deployer.sh tag ${SERVICE}-blue --role backup
./deployer.sh tag ${SERVICE}-green --role active

echo "Deployment complete. Green is active."
```

## Architecture

### Directory Structure
```
deployer/
├── deployer.sh           # Main script (entry point)
├── bin/
│   └── sysdeploy         # Wrapper for system installation
├── lib/
│   ├── core.sh           # Core functions (logging, errors, locks)
│   ├── utils.sh          # Utilities (services, containers, health)
│   └── config.sh         # Configuration and CLI parsing
├── etc/
│   └── deployer.conf     # Default configuration
├── hooks/                # Hook scripts (optional)
│   ├── pre-deploy.sh
│   └── post-deploy.sh
├── tests/
│   └── test_deployer.sh  # Test suite
└── var/
    ├── log/              # Deployment logs
    ├── run/              # PID files, locks
    ├── backups/          # Backups for rollback
    └── deployments/      # Deployment metadata
```

### Deployment Flow
```
┌─────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT FLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [Start] ──► [Validate Config] ──► [Acquire Lock]           │
│                                          │                   │
│                                          ▼                   │
│  [Pre-Deploy Hook] ◄──────────── [Create Backup]            │
│         │                                                    │
│         ▼                                                    │
│  [Deploy Files/Container] ──► [Configure Service]           │
│                                          │                   │
│                                          ▼                   │
│  [Post-Deploy Hook] ◄──────────── [Start Service]           │
│         │                                                    │
│         ▼                                                    │
│  [Health Check] ──► [Success?] ──► YES ──► [Notify] ──► [End]│
│                          │                                   │
│                          NO                                  │
│                          │                                   │
│                          ▼                                   │
│  [Rollback] ◄───── [On-Failure Hook]                        │
│         │                                                    │
│         ▼                                                    │
│  [Restore Backup] ──► [Restart Service] ──► [Notify Failure]│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Exit Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Configuration/parameter error |
| 2 | Partial deployment (some services failed) |
| 3 | Fatal error (deployment completely failed) |
| 4 | Health check failed |
| 5 | Lock exists (deployment in progress) |
| 6 | Rollback failed |
| 10 | Timeout exceeded |

## Testing

### Run Complete Tests
```bash
cd deployer/
./tests/test_deployer.sh
```

### Specific Tests
```bash
# Core tests only
./tests/test_deployer.sh --filter core

# Integration tests only
./tests/test_deployer.sh --filter integration

# Verbose mode
./tests/test_deployer.sh --verbose
```

### Coverage
```bash
# Generate coverage report
./tests/test_deployer.sh --coverage

# Output:
# Core Functions: 45/45 (100%)
# Utils Functions: 38/40 (95%)
# Config Functions: 22/22 (100%)
# Integration Tests: 15/15 (100%)
```

## Troubleshooting

### Common Problems

Deployment blocked
```bash
# Check lock
ls -la var/run/*.lock

# Manual lock release (only if certain nothing is running)
./deployer.sh --force-unlock myapp

# Or direct deletion
rm var/run/myapp.lock
```

Health check timeout
```bash
# Increase timeout
./deployer.sh deploy --service api \
    --health-timeout 120 \
    --health-retries 10

# Debug health check
curl -v http://localhost:8080/health
```

Permission denied
```bash
# Check permissions
ls -la /opt/deployments/
ls -la /var/log/deployer/

# Fix
sudo chown -R $USER:$USER /opt/deployments
```

Container won't start
```bash
# Container logs
docker logs myapp 2>&1 | tail -50

# Check image
docker images | grep myapp

# Forced rebuild
./deployer.sh deploy --container myapp \
    --build ./Dockerfile \
    --no-cache
```

### Debug Mode
```bash
# Enable complete debug
./deployer.sh --debug deploy --service api --source ./app

# Or via environment
DEPLOYER_LOG_LEVEL=DEBUG ./deployer.sh deploy ...
```

### Logs
```bash
# Current deployment logs
tail -f var/log/deployer.log

# Specific service logs
./deployer.sh logs myapp --lines 200

# Logs with filter
grep "ERROR\|WARN" var/log/deployer.log
```

## Licence

Copyright (c) 2024 - Educational Project  
Seminar 6 Operating Systems  
Faculty of Cybernetics, Statistics and Economic Informatics  
Bucharest University of Economic Studies

This project is intended exclusively for educational purposes.

---

Version: 1.0.0  
Author: CSIE Student  
Lecturer: Ing. Dr. Antonio Clim
