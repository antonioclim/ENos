# S06_07: Deployment Strategies in Detail

## Introduction

Deployment represents the critical moment when developed code crosses the boundary between the development environment and production, becoming accessible to end users. The choice of deployment strategy directly influences service availability, user experience during the update and recovery capability in case of problems.

This chapter comparatively analyses the main deployment strategies, highlighting trade-offs, optimal usage scenarios and implementation details in the context of CAPSTONE projects.

---

## Example and acceptance boundary

The comparison below describes illustrative architectures, not a universal ranking of deployment risk. Resource ratios, traffic thresholds, delays and metric limits are example inputs, not measured findings. Availability depends on spare capacity, health detection, routing acknowledgements, session draining and compatible data migrations. A filesystem rename is atomic only for the pathname replacement on one filesystem; it does not demonstrate uninterrupted request service.

The source-only algorithms are shared conceptually with P04's `strategy_reference.sh`. Extract the corresponding modules before running examples. Adapters must be configured for an explicitly selected topology; missing routing, metrics, health or lifecycle adapters fail rather than selecting infrastructure automatically. No code in this chapter is a command to operate the reader's live services. Tests may supply local recording adapters and owned fixture directories. Native Docker/systemd/SSH/Nginx/HAProxy/Kubernetes operation remains a separate acceptance exercise.

## Taxonomy of Deployment Strategies

### Classification by Impact and Risk

```
                        DEPLOYMENT RISK
                              │
         LOW ◄────────────────┼────────────────► HIGH
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │                         │                         │
    │   CANARY               │        ROLLING          │
    │   ────────              │        ──────────       │
    │   • Minimal risk       │        • Moderate risk  │
    │   • Rapid feedback     │        • Zero downtime  │
    │   • Instant rollback   │        • Gradual        │
    │                         │                         │
    │─────────────────────────┼─────────────────────────│
    │                         │                         │
    │   BLUE-GREEN           │       BIG BANG          │
    │   ────────────          │       ──────────        │
    │   • Controlled risk    │        • Maximum risk   │
    │   • Atomic switch      │        • Simple         │
    │   • Double resources   │        • Downtime       │
    │                         │                         │
    └─────────────────────────┴─────────────────────────┘
              LOW                        HIGH
                    INFRASTRUCTURE COMPLEXITY
```

---

## Rolling Deployment Strategy

### Concept

Rolling deployment updates application instances gradually, replacing the old version with the new one at a time (or batch at a time). During deployment, both versions coexist in production.

### Flow Diagram

```
Time ─────────────────────────────────────────────────────►

Instance 1: [████ V1 ████][░░ Update ░░][████ V2 ████████]
Instance 2: [████████ V1 ████████][░░ Update ░░][████ V2 ██]
Instance 3: [████████████ V1 ████████████][░░ Update ░░][V2]
Instance 4: [████████████████ V1 ████████████████][░░░░░░░░]

Load Balancer: ═══════════════════════════════════════════
              Directs traffic only to healthy instances
```

### Deployer Implementation

```bash
#!/usr/bin/env bash
# Source-only algorithm module. Adapters are supplied explicitly; no auto-detected
# /etc, service, SSH, cluster or load-balancer target is ever selected here.

require_adapter() { declare -F "$1" >/dev/null || { printf 'Missing adapter: %s\n' "$1" >&2; return 2; }; }
positive_integer() { [[ ${1:-} =~ ^[1-9][0-9]{0,5}$ ]]; }
nonnegative_integer() { [[ ${1:-} =~ ^[0-9]{1,5}$ ]]; }

deploy_rolling() {
    local release=$1; shift
    local -a instances=("$@")
    local total=${#instances[@]} batch=${BATCH_SIZE:-1} limit=${MAX_UNAVAILABLE:-1}
    local delay=${HEALTH_CHECK_INTERVAL:-10} i j end instance adapter
    positive_integer "$batch" && positive_integer "$limit" && nonnegative_integer "$delay" || return 2
    ((total > 0 && batch <= limit && limit <= total)) || return 2
    for adapter in drain_instance wait_for_drain stop_application sync_release start_application wait_for_healthy enable_instance restore_previous_version; do
        require_adapter "$adapter" || return 2
    done
    for ((i=0; i<total; i+=batch)); do
        end=$((i+batch)); ((end <= total)) || end=$total
        for ((j=i; j<end; j++)); do
            instance=${instances[j]}
            # A batch is a scheduling group; this reference updates instances sequentially.
            if drain_instance "$instance" && wait_for_drain "$instance" "${DRAIN_TIMEOUT:-30}" &&
               stop_application "$instance" && sync_release "$instance" "$release" &&
               start_application "$instance" && wait_for_healthy "$instance" "${HEALTH_CHECK_RETRIES:-3}" "$delay" &&
               enable_instance "$instance"; then :
            else
                # A successful recovery does not turn a failed deployment into success.
                if restore_previous_version "$instance" && start_application "$instance" &&
                   wait_for_healthy "$instance" "${HEALTH_CHECK_RETRIES:-3}" "$delay" && enable_instance "$instance"; then return 1
                else return 3; fi
            fi
        done
        if ((i+batch < total)); then sleep "$delay" || return 1; fi
    done
    return 0
}

wait_for_drain() {
    local instance=$1 duration=$2 deadline connections pause
    positive_integer "$duration" || return 2
    require_adapter get_active_connections || return 2
    deadline=$((SECONDS+duration))
    while ((SECONDS < deadline)); do
        connections=$(get_active_connections "$instance") || return 1
        nonnegative_integer "$connections" || return 1
        ((10#$connections != 0)) || return 0
        pause=$((deadline-SECONDS)); ((pause <= 2)) || pause=2
        ((pause > 0)) && sleep "$pause"
    done
    return 1  # A timed-out drain is not permission to stop active requests.
}


# Explicit application-control adapters. SERVICE_PROGRAM receives instance, action
# and service as separate arguments; it decides the approved local/remote transport.
run_on_instance() {
    local instance=$1; shift
    if [[ $instance == localhost || $instance == 127.0.0.1 ]]; then "$@"
    else "${REMOTE_EXEC_PROGRAM:?Configure the approved remote argv transport}" "$instance" "$@"; fi
}
stop_application() { "${SERVICE_PROGRAM:?}" "$1" stop "${APP_SERVICE:?}"; }
start_application() { "${SERVICE_PROGRAM:?}" "$1" start "${APP_SERVICE:?}"; }
force_stop_application() { "${SERVICE_PROGRAM:?}" "$1" kill "${APP_SERVICE:?}"; }
sync_release() { "${SYNC_RELEASE_PROGRAM:?Provide a transactional artefact-sync adapter}" "$1" "$2"; }
restore_previous_version() { "${RESTORE_RELEASE_PROGRAM:?}" "$1"; }
drain_instance() { "${ROUTING_PROGRAM:?}" drain "$1"; }
enable_instance() { "${ROUTING_PROGRAM:?}" enable "$1"; }
get_active_connections() { "${ROUTING_PROGRAM:?}" connections "$1"; }
wait_for_healthy() {
    local instance=$1 retries=$2 interval=$3 attempt
    positive_integer "$retries" && nonnegative_integer "$interval" || return 2
    for ((attempt=1; attempt<=retries; attempt++)); do
        if "${INSTANCE_HEALTH_PROGRAM:?}" "$instance"; then return 0; fi
        ((attempt == retries)) || sleep "$interval" || return 1
    done
    return 1
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Availability can be maintained with sufficient healthy capacity | Mixed versions in production |
| Partial rollback possible | Slower deployment |
| Efficient resources | Complexity in tracking |
| Progressive validation | Requires backward compatibility |

---

## Blue-Green Deployment Strategy

### Concept

Blue-Green maintains two identical production environments (Blue and Green). At any given moment, one serves live traffic (e.g., Blue) whilst the other (Green) is inactive or used for preparing the new version. Deployment consists of the atomic switch of traffic.

### Flow Diagram

```
                    BEFORE DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V1)      │         │
    │    │  [ACTIVE]   │         │  [STANDBY]  │         │
    │    └──────┬──────┘         └─────────────┘         │
    │           │                                         │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    PREPARING DEPLOYMENT
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [ACTIVE]   │    ◄──  │  [TESTING]  │         │
    │    └──────┬──────┘  smoke  └─────────────┘         │
    │           │         tests                          │
    │           │ 100% Traffic                           │
    │           ▼                                         │
    │    ┌─────────────┐                                 │
    │    │    USERS    │                                 │
    │    └─────────────┘                                 │
    └─────────────────────────────────────────────────────┘

                    AFTER SWITCH
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │    ┌─────────────┐         ┌─────────────┐         │
    │    │   BLUE      │         │   GREEN     │         │
    │    │   (V1)      │         │   (V2)      │         │
    │    │  [STANDBY]  │         │  [ACTIVE]   │         │
    │    └─────────────┘         └──────┬──────┘         │
    │                                    │               │
    │                        100% Traffic│               │
    │                                    ▼               │
    │                           ┌─────────────┐          │
    │                           │    USERS    │          │
    │                           └─────────────┘          │
    └─────────────────────────────────────────────────────┘
```

### Deployer Implementation

```bash
#!/usr/bin/env bash
# Requires P04's strategy_reference.sh and release_teaching.py.
# These are owned filesystem adapters; service/routing adapters are explicit programs.
get_env_path() {
    case $1 in blue|green) printf '%s/%s\n' "${DEPLOY_BASE_PATH:?}" "$1";; *) return 2;; esac
}
get_env_port() {
    case $1 in blue) printf '%s\n' "${BLUE_PORT:-8001}";; green) printf '%s\n' "${GREEN_PORT:-8002}";; *) return 2;; esac
}
get_active_env() {
    python3 - "${ACTIVE_ENV_FILE:?}" <<'PY'
import json,sys
try:
    value=json.load(open(sys.argv[1]))['active']
    if value not in ('blue','green'): raise ValueError()
    print(value)
except (OSError,ValueError,KeyError): raise SystemExit(1)
PY
}
set_active_env() {
    python3 - "${ACTIVE_ENV_FILE:?}" "$1" <<'PY'
import json,os,pathlib,sys,tempfile
path=pathlib.Path(sys.argv[1]); value=sys.argv[2]
if value not in ('blue','green'): raise SystemExit(2)
fd,temporary=tempfile.mkstemp(prefix='.active.',dir=path.parent)
try:
    with os.fdopen(fd,'w') as output: json.dump({'active':value},output)
    os.replace(temporary,path)
finally:
    if os.path.exists(temporary): os.unlink(temporary)
PY
}
prepare_environment() {
    local env=$1 path
    path=$(get_env_path "$env") || return 2
    [[ $env != "$(get_active_env)" ]] || return 1
    # current is reserved for a symlink, never mkdir'd as a directory.
    mkdir -p -- "$path/releases" "$path/shared" "$path/.deploy_state"
}
deploy_release() {
    local source=$1 env=$2 path release_id
    path=$(get_env_path "$env") || return 2
    release_id=$(python3 "${RELEASE_ENGINE_PATH:?}" prepare "$source" "$path") || return 1
    python3 "$RELEASE_ENGINE_PATH" activate "$path" "$release_id"
}
start_environment() { "${ENV_SERVICE_PROGRAM:?}" "$1" start; }
stop_environment() { "${ENV_SERVICE_PROGRAM:?}" "$1" stop; }
is_environment_healthy() {
    local port; port=$(get_env_port "$1") || return 2
    check_http "http://localhost:$port/health" 200 "${SMOKE_TEST_TIMEOUT:-10}"
}
run_smoke_tests() {
    local port response; port=$(get_env_port "$1") || return 2
    check_http "http://localhost:$port/health" 200 "${SMOKE_TEST_TIMEOUT:-10}" || return 1
    check_http "http://localhost:$port/api/status" 200 "${SMOKE_TEST_TIMEOUT:-10}" || return 1
    response=$(curl --fail --silent --show-error --connect-timeout 2 --max-time "${SMOKE_TEST_TIMEOUT:-10}" -- "http://localhost:$port/api/db/ping") || return 1
    python3 -c 'import json,sys; raise SystemExit(0 if json.loads(sys.argv[1]).get("status")=="ok" else 1)' "$response"
}
warmup_application() {
    local env=$1 requests=$2 port i
    nonnegative_integer "$requests" || return 2
    port=$(get_env_port "$env") || return 2
    for ((i=0; i<requests; i++)); do check_http "http://localhost:$port/" 200 5 || return 1; done
    return 0
}
switch_traffic() {
    local target=$1 percentage
    case $target in blue) percentage=0;; green) percentage=100;; *) return 2;; esac
    case ${TRAFFIC_BACKEND:?Choose a routing backend explicitly} in
        nginx)
            python3 "${ROUTING_REFERENCE_PATH:?}" "$percentage" --stable-port "$(get_env_port blue)" --canary-port "$(get_env_port green)" \
                --config "${NGINX_UPSTREAM_FILE:?}" --validator "${NGINX_VALIDATE_PROGRAM:?}" --reloader "${NGINX_RELOAD_PROGRAM:?}";;
        haproxy) "${HAPROXY_ROUTE_PROGRAM:?Acknowledged route transaction adapter}" "$target";;
        symlink)
            # Valid only for a server that resolves this pathname when serving new requests.
            python3 "${RELEASE_ENGINE_PATH:?}" switch "${DEPLOY_BASE_PATH:?}/live" "$(get_env_path "$target")/current";;
        *) return 2;;
    esac
}
deploy_blue_green() {
    local release=$1 active target adapter
    for adapter in get_active_env prepare_environment deploy_release start_environment run_smoke_tests warmup_application switch_traffic set_active_env is_environment_healthy; do
        require_adapter "$adapter" || return 2
    done
    active=$(get_active_env) || return 1
    case $active in blue) target=green;; green) target=blue;; *) return 2;; esac
    prepare_environment "$target" || return 1
    deploy_release "$release" "$target" || return 1
    start_environment "$target" || return 1
    run_smoke_tests "$target" || return 1
    warmup_application "$target" "${WARMUP_REQUESTS:-100}" || return 1
    # Keep both pools running until route/state acknowledgement is complete.
    switch_traffic "$target" || return 3
    if is_environment_healthy "$target" && set_active_env "$target"; then return 0; fi
    if start_environment "$active" && is_environment_healthy "$active" && switch_traffic "$active"; then return 1; fi
    return 3
}

rollback_blue_green() {
    local active previous
    active=$(get_active_env) || return 1
    case $active in blue) previous=green;; green) previous=blue;; *) return 2;; esac
    # A stopped standby must start before probing it.
    start_environment "$previous" || return 1
    is_environment_healthy "$previous" || return 1
    switch_traffic "$previous" || return 3
    set_active_env "$previous" || return 3
    return 0  # Stopping the failed pool is a separate, explicitly requested action.
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Rapid rollback when the previous pool is healthy | Resource doubling |
| Availability can be maintained | Infrastructure cost |
| Isolated testing | Complex data synchronisation |
| Atomic switch | Doesn't detect gradual problems |

---

## Canary Deployment Strategy

### Concept

Canary deployment exposes the new version to only a small subset of users initially (e.g., 5%), intensively monitoring for errors. If metrics are acceptable, the percentage increases gradually to 100%.

### Flow Diagram

```
    Phase 1: 5% traffic            Phase 2: 25% traffic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ████████████95% │      │ V1 ██████████ 75%  │
    │ V2 █           5%  │  ──► │ V2 ████      25%  │
    └────────────────────┘      └────────────────────┘
              │                           │
              ▼                           ▼
         Monitoring                  Monitoring
         • Error rate                • Error rate
         • Latency                   • Latency
         • Business metrics          • Business metrics
              │                           │
         OK? ─┴─ NO ──► Rollback         OK?
              │                           │
             YES                         YES
              │                           │
              ▼                           ▼
    
    Phase 3: 50% traffic           Phase 4: 100% traffic
    ┌────────────────────┐      ┌────────────────────┐
    │ V1 ██████    50%   │      │ V2 ████████████100%│
    │ V2 ██████    50%   │  ──► │                    │
    └────────────────────┘      └────────────────────┘
```

### Deployer Implementation

```bash
#!/usr/bin/env bash
# Explicit illustrative parameters; the operator supplies/approves the real values.
declare -a CANARY_STAGES=(5 25 50 75 100)
STAGE_DURATION=300
ERROR_THRESHOLD=1.0
LATENCY_THRESHOLD=500
CONSECUTIVE_FAILURE_LIMIT=3
AUTO_PROMOTE=false

canary_values_valid() {
    python3 - "$@" <<'PY'
import math,sys
try:
    error,latency,error_limit,latency_limit=map(float,sys.argv[1:])
    assert all(map(math.isfinite,(error,latency,error_limit,latency_limit)))
    assert 0<=error<=100 and 0<=error_limit<=100 and latency>=0 and latency_limit>=0
except (ValueError,AssertionError): raise SystemExit(2)
raise SystemExit(0 if error<=error_limit and latency<=latency_limit else 1)
PY
}

monitor_canary_stage() {
    local percentage=$1 duration=$2 interval=${METRICS_CHECK_INTERVAL:-10}
    local deadline error latency rc bad=0 pause
    positive_integer "$duration" && positive_integer "$interval" || return 2
    deadline=$((SECONDS+duration))
    while :; do
        error=$(get_canary_error_rate) || return 1
        latency=$(get_canary_latency) || return 1
        if canary_values_valid "$error" "$latency" "${ERROR_THRESHOLD:?Set an explicit error threshold}" "${LATENCY_THRESHOLD:?Set an explicit latency threshold}"; then
            bad=0
        else
            rc=$?; ((rc != 2)) || return 1  # No data/NaN is unavailable, not healthy.
            bad=$((bad+1))                # One bad observation, even if both metrics fail.
            ((bad < ${CONSECUTIVE_FAILURE_LIMIT:-3})) || return 1
        fi
        ((SECONDS < deadline)) || break
        pause=$((deadline-SECONDS)); ((pause <= interval)) || pause=$interval
        sleep "$pause" || return 1
    done
    # An unfinished bad streak at the end is not a stable stage ready for promotion.
    ((bad == 0))
}

deploy_canary() {
    local release=$1 percentage previous=0 adapter
    local -a stages=("${CANARY_STAGES[@]:-5 25 50 75 100}")
    # The array must be explicitly initialised by the caller; no word-splitting fallback.
    declare -p CANARY_STAGES &>/dev/null || return 2
    stages=("${CANARY_STAGES[@]}")
    ((${#stages[@]} > 0)) || return 2
    for percentage in "${stages[@]}"; do
        positive_integer "$percentage" || return 2
        ((percentage > previous && percentage <= 100)) || return 2
        previous=$percentage
    done
    ((previous == 100)) || return 2
    positive_integer "${STAGE_DURATION:-}" && positive_integer "${CONSECUTIVE_FAILURE_LIMIT:-3}" || return 2
    canary_values_valid 0 0 "${ERROR_THRESHOLD:-}" "${LATENCY_THRESHOLD:-}" || return 2
    for adapter in deploy_canary_instances set_canary_weight get_canary_error_rate get_canary_latency rollback_canary finalize_canary_deployment; do
        require_adapter "$adapter" || return 2
    done
    deploy_canary_instances "$release" || return 1
    for percentage in "${stages[@]}"; do
        if set_canary_weight "$percentage" && monitor_canary_stage "$percentage" "$STAGE_DURATION"; then :
        else rollback_canary || return 3; return 1; fi
        if ((percentage < 100)) && [[ ${AUTO_PROMOTE:-false} != true ]]; then
            require_adapter wait_for_promotion || { rollback_canary || return 3; return 2; }
            wait_for_promotion "$percentage" || { rollback_canary || return 3; return 1; }
        fi
    done
    # 100% receives the same observation window before promotion.
    finalize_canary_deployment || return 3
}


# Lifecycle adapters retain the old pool until rerouting is acknowledged.
deploy_canary_instances() { "${CANARY_LIFECYCLE_PROGRAM:?}" prepare "$1"; }
rollback_canary() {
    set_canary_weight 0 || return 3
    "${CANARY_LIFECYCLE_PROGRAM:?}" stop || return 1
    # No deletion follows an unacknowledged route change.
}
finalize_canary_deployment() {
    # prepare-stable must start and verify the new stable pool without stopping canary.
    "${CANARY_LIFECYCLE_PROGRAM:?}" prepare-stable || return 1
    "${CANARY_LIFECYCLE_PROGRAM:?}" verify-stable || return 1
    set_canary_weight 0 || return 3
    "${CANARY_LIFECYCLE_PROGRAM:?}" stop || return 1
}
wait_for_promotion() { "${PROMOTION_PROGRAM:?Explicit promotion adapter required}" "$1"; }
set_canary_weight() {
    local percentage=$1
    [[ $percentage =~ ^[0-9]{1,3}$ ]] && ((10#$percentage <= 100)) || return 2
    case ${TRAFFIC_BACKEND:?Choose the routing backend} in
        nginx)
            python3 "${ROUTING_REFERENCE_PATH:?}" "$percentage" --config "${NGINX_UPSTREAM_FILE:?}" \
                --validator "${NGINX_VALIDATE_PROGRAM:?}" --reloader "${NGINX_RELOAD_PROGRAM:?}";;
        istio)
            # The adapter must target an explicitly approved context/namespace and
            # confirm the route; installed kubectl alone is not configuration.
            "${ISTIO_ROUTE_PROGRAM:?}" "$percentage";;
        *) return 2;;
    esac
}
prometheus_value() {
    local query=$1 response
    response=$(curl --fail --silent --show-error --connect-timeout 2 --max-time 5 \
        --get --data-urlencode "query=$query" -- "${METRICS_ENDPOINT:?}/api/v1/query") || return 1
    python3 - "$response" <<'PY'
import json,math,sys
try:
    d=json.loads(sys.argv[1]); assert d['status']=='success' and d['data']['resultType']=='vector'
    rows=d['data']['result']; assert len(rows)==1
    value=float(rows[0]['value'][1]); assert math.isfinite(value) and value>=0
    print(value)
except (ValueError,KeyError,IndexError,TypeError,AssertionError): raise SystemExit(1)
PY
}
get_error_rate() {
    local version=$1
    [[ $version == stable || $version == canary ]] || return 2
    prometheus_value "sum(rate(http_requests_total{status=~\"5..\",version=\"$version\"}[5m])) / sum(rate(http_requests_total{version=\"$version\"}[5m])) * 100"
}
get_p99_latency() {
    local version=$1
    [[ $version == stable || $version == canary ]] || return 2
    prometheus_value "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{version=\"$version\"}[5m])) by (le)) * 1000"
}
get_canary_error_rate() { get_error_rate canary; }
get_canary_latency() { get_p99_latency canary; }
check_canary_health() {
    local error=$1 latency=$2 stable_error=$3 stable_latency=$4
    canary_values_valid "$error" "$latency" "$ERROR_THRESHOLD" "$LATENCY_THRESHOLD" || return 1
    canary_values_valid "$stable_error" "$stable_latency" 100 1000000000 || return 1
    python3 - "$error" "$stable_error" <<'PY'
import sys
error,stable=map(float,sys.argv[1:])
# This optional relative gate retains the lesson's illustrative 2x/.001 rule.
raise SystemExit(0 if error/(stable+.001)<=2 else 1)
PY
}
```

### Strengths and Weaknesses

| Strengths | Weaknesses |
|-----------|------------|
| Minimal risk | Setup complexity |
| Real user feedback | Requires advanced monitoring |
| Subtle problem detection | Slower deployment |
| Instant partial rollback | A/B testing side effects |

---

## Checked routing configuration

Save this module as `routing_reference.py`. Zero traffic uses a valid `weight=1 down` endpoint, not Nginx's invalid `weight=0`. Config replacement validates a staged file, retains the previous bytes and rolls the file back if reload fails. A failure to acknowledge restoration returns 3; do not stop or delete either application pool in that state. The configured validator must validate the fragment in its complete Nginx context. Weighted routing expresses a configuration target; finite observed traffic proportions can differ.

```python
#!/usr/bin/env python3
"""Nginx upstream fragment generation and checked local config replacement.

The caller supplies an owned config file and two executable adapters. The validator
must validate this fragment in its complete Nginx context; the reload adapter must
acknowledge the observed daemon outcome. Tests substitute local fixture programs.
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def render(percent,stable=8001,canary=8002):
    if type(percent)!=int or not 0<=percent<=100 or not 1<=stable<=65535 or not 1<=canary<=65535:
        raise ValueError('Invalid weight or port')
    def server(port,weight):
        return f'    server 127.0.0.1:{port} '+(f'weight={weight};' if weight else 'weight=1 down;')
    return 'upstream app_backend {\n'+server(stable,100-percent)+'\n'+server(canary,percent)+'\n}\n'


def apply(config,text,validator,reloader):
    if not config.is_absolute() or config.is_symlink() or not config.is_file():
        raise ValueError('Existing owned absolute configuration file required')
    with tempfile.TemporaryDirectory(prefix='.route.',dir=config.parent) as directory:
        directory=Path(directory); staged=directory/'candidate.conf'; backup=directory/'previous.conf'
        staged.write_text(text); shutil.copy2(config,backup)
        # Adapter validates the complete include context, not a bare upstream block as a main config.
        subprocess.run([validator,str(staged)],check=True)
        staged.chmod(config.stat().st_mode & 0o777)
        os.replace(staged,config)
        try: subprocess.run([reloader,str(config)],check=True)
        except subprocess.CalledProcessError:
            os.replace(backup,config)
            try: subprocess.run([reloader,str(config)],check=True)
            except subprocess.CalledProcessError: return 3  # Routing outcome is unknown: retain both pools.
            return 1
    return 0


def main():
    p=argparse.ArgumentParser(description=__doc__); p.add_argument('percent',type=int)
    p.add_argument('--stable-port',type=int,default=8001); p.add_argument('--canary-port',type=int,default=8002)
    p.add_argument('--config',type=Path); p.add_argument('--validator'); p.add_argument('--reloader')
    a=p.parse_args(); text=render(a.percent,a.stable_port,a.canary_port)
    if a.config:
        if not a.validator or not a.reloader: raise ValueError('Explicit validator/reloader adapters required')
        return apply(a.config,text,a.validator,a.reloader)
    print(text,end=''); return 0


if __name__=='__main__':
    try: raise SystemExit(main())
    except (OSError,ValueError,subprocess.CalledProcessError) as error:
        print(error,file=sys.stderr); raise SystemExit(1)
```

## Synthetic Comparison

### Comparative Table

| Criterion | Rolling | Blue-Green | Canary |
|-----------|---------|------------|--------|
| **Downtime** | Can be avoided with capacity/draining | Can be avoided with verified routing | Can be avoided with verified routing |
| **Additional resources** | Minimal | 2x | ~10-20% |
| **Complexity** | Medium | Medium | High |
| **Deployment time** | Medium | Fast | Long |
| **Rollback speed** | Medium | Instant | Gradual |
| **Risk** | Moderate | Low | Very low |
| **Simultaneous versions** | Yes | No (momentarily) | Yes |
| **Requires advanced LB** | No | No | Yes |
| **Pre-live testing** | Limited by the configured suite | Isolated candidate tests; coverage remains bounded | Limited before live traffic |

### Decision Tree

```
                    START
                      │
                      ▼
              ┌───────────────┐
              │ Do you have   │
              │   advanced    │
              │  monitoring?  │
              └───────┬───────┘
                      │
           NO ◄───────┴───────► YES
            │                    │
            ▼                    ▼
    ┌───────────────┐    ┌───────────────┐
    │ Can you double│    │ High traffic  │
    │  resources?   │    │   (>1M/day)?  │
    └───────┬───────┘    └───────┬───────┘
            │                    │
     YES ◄──┴──► NO      YES ◄──┴──► NO
      │          │         │          │
      ▼          ▼         ▼          ▼
  BLUE-GREEN  ROLLING   CANARY    ROLLING
```

---

## Practical Exercises

### Exercise 1: Feature Flags Implementation

Extend canary deployment with feature flags:

```bash
# Requirements:
# - Toggle features per user/segment
# - Integration with canary deployment
# - Dashboard for flag management
```

### Exercise 2: Multi-Region Deployment

Implement cross-region deployment:

```bash
# Requirements:
# - Deploy to multiple regions sequentially
# - Health checks per region
# - Selective rollback per region
```

### Exercise 3: GitOps Pipeline

Create a complete GitOps pipeline:

```bash
# Requirements:
# - Trigger deployment on push
# - Strategy selection based on branch
# - Automated integration tests
```

### Exercise 4: Chaos Engineering Integration

Integrate chaos testing into deployment:

```bash
# Requirements:
# - Failure injection in canary stage
# - Resilience verification
# - Auto-rollback on failure
```

### Exercise 5: Deployment Metrics Dashboard

Create a metrics visualisation system:

```bash
# Requirements:
# - Deployment metrics collection
# - Terminal visualisation
# - Export for Grafana/Prometheus
```

---

## Additional Resources

### Advanced Patterns

1. **Shadow Deployment**: Duplicated traffic to new version without serving responses
2. **A/B Testing**: Deployment based on experiments and business metrics
3. **Dark Launching**: Hidden features activated selectively
4. **Ramped Deployment**: Linear traffic increase (vs. discrete stages)

### Best Practices

1. **Explicit automation**: Automate the approved workflow and retain deliberate promotion or recovery decisions where required
2. **Monitoring before deploy**: Setup alerting before any change
3. **Tested rollback**: Verify that rollback works before deployment
4. **Communication**: Notify the team about planned deployments
5. **Post-mortems**: Analyse every failed deployment

### Technical reference for the corrected examples

The routing fragment uses documented [Nginx upstream server parameters](https://nginx.org/en/docs/http/ngx_http_upstream_module.html).
