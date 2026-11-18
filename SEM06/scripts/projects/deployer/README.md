# SysDeployer — deployment teaching application

CAPSTONE Project — Seminar 6, Operating Systems.

SysDeployer demonstrates explicit status handling, local file deployment, systemd/container adapters, bounded health checks and rollback bookkeeping. The routing and metrics adapters for blue-green/canary need a concrete integration; missing adapters fail. It is not a complete production platform or a measured zero-downtime guarantee.

## Contents

- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Quick Usage](#quick-usage)
- [Available Actions](#available-actions)
- [Configuration](#configuration)
- [Deployment Strategies](#deployment-strategies)
- [Health Checks](#health-checks)
- [Hooks System](#hooks-system)
- [Manifest-Based Deployment](#manifest-based-deployment)
- [Rollback](#rollback)
- [Advanced Examples](#advanced-examples)
- [Architecture](#architecture)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Features

| Mechanism | Current scope and limitation |
|---|---|
| Local files | Copy into an owned staging sibling, back up existing destination, replace with checked renames; not a one-operation directory exchange |
| systemd | Check/restart an explicitly selected service; optional service-file input comes from a flat manifest |
| Docker | Pull/run/stop a selected image/container with explicit status checks; not Compose/Kubernetes or a complete container-definition restore |
| Rolling | Sequential checked targets/batches; first failed target stops later targets |
| Blue-green | Inactive service suffix, required smoke-test and traffic-switch hooks; availability depends on actual integration/capacity |
| Canary | Strict increasing stages ending at 100, checked weights and available numeric metrics; no fabricated healthy rate |
| Manifests | Restricted flat `key: scalar` grammar; no nested service graph or general YAML |
| Rollback | In-process service-file/previous-image bookkeeping; no claim that a later independent CLI invocation reconstructs an unsaved history |
| Notifications | Optional explicit mail/Slack transport, encoded payload and bounded timeout; no external calls in local fixture tests |

The historical README also described parallel deployment, protected versions, image builds, arbitrary environment/volume flags, live traffic routers and a nested YAML stack. These are extension designs, not current supported CLI features.

## System Requirements

Bash 4.4+, Python 3.10+, coreutils, flock and the relevant local tool. Real service actions require systemd; container actions require a working Docker daemon. Curl is needed for HTTP/Slack, mail/sendmail only for configured email. Python handles literal config and JSON encoding; no yq/jq-based nested-manifest capability is implied.

```bash
bash SEM06/scripts/projects/deployer/deployer.sh --help
command -v bash python3 tar flock curl
```

`--check-deps` is not an option. Checking that a command exists is not acceptance of its daemon, permissions or endpoint.

## Installation

Keep the whole `deployer/` project and its shared sibling config_data.py when copying this kit. The tracked wrapper invokes Bash and resolves its main source. Local inspection needs no global symlink, root account, service restart or upload. System installation under `/opt` and runtime directory ownership are separate authorised host choices; do not blindly recursively change ownership of existing deployment trees.

## Quick Usage

From the repository root, a complete local files-only fixture:

```bash
#!/usr/bin/env bash
set -euo pipefail
program=$(realpath -- SEM06/scripts/projects/deployer/deployer.sh)
work=
trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
work=$(mktemp -d)
mkdir -- "$work/source"
printf 'local version one\n' > "$work/source/index.html"
cat > "$work/app.yaml" <<EOF
name: teaching-app
version: v1
type: files
source: $work/source
destination: $work/live
EOF
cat > "$work/deployer.conf" <<EOF
DEPLOY_ROOT="$work/deployments"
BACKUP_DIR="$work/backups"
LOG_DIR="$work/logs"
RUN_DIR="$work/run"
HOOKS_DIR="$work/hooks"
NOTIFY_EMAIL=""
SLACK_WEBHOOK=""
EOF
bash "$program" --config "$work/deployer.conf" --manifest "$work/app.yaml" --dry-run deploy
[[ ! -e $work/live ]]
bash "$program" --config "$work/deployer.conf" --manifest "$work/app.yaml" --no-notify --force deploy
cmp -- "$work/source/index.html" "$work/live/index.html"
```

`--force` only bypasses this program's interactive confirmation; it does not confer authority for an external service or endpoint. Dry-run validates configuration and manifests before returning without directories, hooks, locks, mail or service changes.

## Available Actions

| Action | Actual interface |
|---|---|
| deploy | `deploy --service NAME`, `--container IMAGE[:TAG]` or `--manifest FILE` |
| rollback | `rollback --service NAME` or `--container NAME`; current unsaved history limits described below |
| status | `status --service NAME` / `--container NAME` |
| list | `list`; host-dependent service/container and manifest listing |
| health | `health --service NAME` / `--container NAME` |

Options include `--config FILE`, `--env NAME`, `--deploy-root DIR`, `--backup-dir DIR`, `--strategy rolling|blue-green|canary|in-place`, `--dry-run`, `--force`, `--no-backup`, `--no-rollback`, `--skip-health-check`, `--health-retries N`, `--health-interval N`, `--health-timeout N`, `--registry URL`, `--pull`, `--no-pull`, `--notify-email ADDRESS`, `--slack-webhook URL`, `--notify-success`, `--no-notify`, `--output text|json` and `--log-file FILE`. Read `--help` for short forms. JSON is the final deployment/rollback report, not an advertised JSON schema for every status/list output.

There are no standalone start/stop/restart/logs/cleanup/protect/unprotect/tag actions, no --source/--target/--instances/--image/--port/--build/--volume/--only/--versions/--force-unlock switches and no `--version VALUE` rollback selection. These are not accepted merely because older text showed them.

## Configuration

Literal KEY=VALUE settings are loaded from the explicit file or the documented search locations; CLI values override the file. Unknown keys fail instead of silently pretending to be effective. Supported keys are DEPLOY_ROOT, BACKUP_DIR, LOG_DIR, RUN_DIR, ENVIRONMENT, STRATEGY, ROLLBACK_ON_FAILURE, HEALTH_CHECK_ENABLED, HEALTH_CHECK_RETRIES, HEALTH_CHECK_INTERVAL, HEALTH_CHECK_TIMEOUT, SERVICE_RESTART_DELAY, SERVICE_STOP_TIMEOUT, SERVICE_START_TIMEOUT, DOCKER_REGISTRY, DOCKER_PULL_TIMEOUT, CONTAINER_STOP_TIMEOUT, NOTIFY_ON_SUCCESS, NOTIFY_ON_FAILURE, NOTIFY_EMAIL, SLACK_WEBHOOK, LOG_LEVEL, LOG_FILE, HOOKS_DIR, DRY_RUN, VERBOSE, PARALLEL and comma-separated SERVICES, CONTAINERS, MANIFESTS. PARALLEL is a historical accepted setting; current target execution is sequential.

Do not use old DEPLOYER_CONFIG/DEPLOYER_LOG_LEVEL prefixes, DEPLOY_BASE_DIR, DEFAULT_STRATEGY or AUTO_ROLLBACK_ON_FAILURE names. Quotes are literal-value syntax; this is not a shell program. Main config and container settings are not sourced as code. The optional `DEPLOY_ROOT/containers/NAME.conf` supports only CONTAINER_PORTS, CONTAINER_VOLUMES and CONTAINER_RESTART as literal single values; multiple mappings need a deliberate tested extension, not arbitrary injected shell text.

## Deployment Strategies

Rolling checks each selected target before advancing. Batch/delay values are bounded and failure prevents later service, container or manifest actions. Rollback failure remains failure; it cannot establish a successful restoration.

Blue-green requires prepared `service-blue`/`service-green` units, an executable `smoke-test` and `switch-traffic` hook under HOOKS_DIR. Service status, routing, draining, shared database compatibility and capacity are separate conditions. The old environment is retained as a recovery target; a two-environment diagram does not prove zero downtime or a universal 2× resource cost.

Canary requires executable `set-canary-weight` and a concrete get_canary_error_rate implementation returning a finite 0–100 rate. The provided default explicitly fails as unconfigured. Stages must increase to 100; unavailable/invalid metrics trigger failure/rollback before promotion. Traffic percentage is not the fraction of server capacity. The separate `scripts/examples/deploy_strategies.sh` supports isolated algorithm fixtures; it does not activate a real router.

## Health Checks

Library functions provide checked HTTP status, TCP connection and process/custom-command checks. The entry-point service adapter checks systemd active state; the container adapter checks running state and a published port when present. No undocumented --health-check URL or --health-expected-body option is parsed by the CLI. Tests inject explicit local fixtures. A running PID/open port/HTTP 200 alone does not establish application correctness.

Use finite retry counts and per-attempt timeouts. Custom commands are trusted executable argv, not a user-supplied shell program. Real endpoints must be selected by the operator; localhost is not automatically disposable infrastructure.

## Hooks System

Hook filenames have no implicit `.sh` suffix: pre-deploy, post-deploy, pre-service, post-service, pre-rollback and post-rollback. Strategy adapters additionally require smoke-test, switch-traffic or set-canary-weight. Optional missing hooks are skipped; a present non-executable hook fails. A required integration hook must exist and be executable.

Hooks receive the arguments used by their call site. In particular pre-service gets target and `deploy`; post-service gets target and success/failed; routing hooks receive the target environment or percentage. Deployment counters/state are exported. Version and source directory are not invented positional arguments. A failing post-service hook prevents that target's success record. Hooks can perform consequential operations, so create only a bounded local fixture during teaching verification.

## Manifest-Based Deployment

```yaml
name: teaching-app
version: v1
type: files
source: ./source
destination: ./live
```

Required keys: name, version, type. Types: `files` requires source/destination; `container` requires image; `service` optionally supplies service_file (default NAME.service beside the manifest). Optional description is literal text. Keys are flat, unknown/duplicate keys fail and state is cleared before each parse. Relative sources resolve beside the manifest; relative destinations resolve under DEPLOY_ROOT/ENVIRONMENT. This restricted format is not a general YAML parser: nested `services`, sequences, dependencies, environment maps and inline YAML semantics are rejected.

## Rollback

The current runtime registers rollback values in an associative array for the active process. Automatic rollback can restore a saved service file or selected previous image while that state exists. A new CLI process does not possess that history and fails if no record is available. It does not guess by version sorting or directory mtime.

Container image restoration does not reconstruct every old Docker flag, environment, secret, volume, network or data state. File-backup paths are retained for deliberate restore but are not a complete persistent cross-process rollback journal. Do not call this full transactional application recovery. For local immutable release/history teaching, use `scripts/examples/release_reference.py` and its owned release demo; its transition journal is separate from this entry point.

## Advanced Examples

A stack pipeline must stop when a dependency fails, before deploying dependants. Keep build, database migration, service deployment, health, approval and routing adapters explicit; use local mocks to test failed staging, rejected approval, unavailable metrics and failed rollback. Never put secrets in a command line or claim an unavailable feature succeeded. Production CI activation, Git writes, Docker operations and router changes are separate operations, not a consequence of running documentation checks.

## Architecture

The entry point loads core/utils/config; validates inputs; performs a no-write dry-run branch when selected; creates owned temporary state and acquires a stable lock; then executes the chosen action and serialises its final report. Errors stop the relevant workflow. Temporary path registration survives command substitution by using an owned parent workspace. Lock paths are not removed while another process could rely on their inode.

Exit 0 is successful completion of the selected operation, 1 configuration/operation error, 2 failed deployment, 3 fatal library/setup error, 4 failed health action and 5 lock acquisition failure. Review the report's actual state and error detail; a rollback helper may return 1 and notification failure is separate from whether files were changed.

## Testing

```bash
bash SEM06/scripts/projects/deployer/tests/test_deployer.sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest SEM06/tests/test_runtime_semantics.py SEM06/tests/test_teaching_examples.py -q
```

The Bash harness has no implemented --filter/--coverage contract. Old “45/45, 38/40, 22/22, 15/15” figures were illustrative and are not current coverage measurements. Native Docker/systemd/HTTP-router acceptance is not established by unit mocks, fixture copying or Bash parsing. Tests assert stop-on-failure, source/destination non-nesting, config isolation, literal values and missing-adapter failure.

## Troubleshooting

A lock file's presence does not indicate a stale active lock; flock applies to an open inode. Do not unlink it or use an imaginary force-unlock switch. Inspect the owner/operation and retry deliberately.

For permission errors, review the intended owned directories and configured account. For health failures, preserve the failed status and inspect the actual adapter; increasing timeout is not evidence of health. --debug raises diagnostic detail without enabling shell xtrace that could reveal secrets. Status/list results depend on the host; failure or unavailable tools must remain distinguishable from an empty healthy inventory.

## Licence

Copyright (c) 2024 - Educational Project  
Seminar 6 Operating Systems  
Faculty of Cybernetics, Statistics and Economic Informatics  
Bucharest University of Economic Studies

This project is a teaching example. Eligible original ENos code is MIT and original documentation is CC BY 4.0 under [the component policy](../../../../LICENCE.md). The attribution above and the author line below are retained. Student, institutional or other third-party contributions whose rights are not confirmed remain outside the new grant. The educational context is not an additional restriction on eligible original code licensed under MIT.

---

Version: 1.0.0  
Author: CSIE Student  
Lecturer: Ing. Dr. Antonio Clim
