#!/usr/bin/env bash
# Strategy orchestration examples. Adapters are explicit dependencies and must
# return nonzero on failure. Tests supply harmless local adapters; sourcing this
# file performs no deployment, service access or notification.
deploy_rolling() {
    local app=$1 version=$2; shift 2
    local -a instances=("$@") batch=()
    local batch_size=${ROLLING_BATCH_SIZE:-1} delay=${ROLLING_DELAY:-0}
    local total=${#instances[@]} i instance deployed=0
    [[ $batch_size =~ ^[1-9][0-9]{0,5}$ && $delay =~ ^[0-9]{1,4}$ ]] || return 2
    ((total > 0)) || return 2
    for ((i=0; i<total; i+=batch_size)); do
        batch=("${instances[@]:i:batch_size}")
        for instance in "${batch[@]}"; do
            if drain_instance "$instance" && deploy_to_instance "$instance" "$app" "$version" &&
               wait_for_health "$instance" "${HEALTH_TIMEOUT:-30}" && enable_instance "$instance"; then
                deployed=$((deployed + 1))
            else
                if ! rollback_instance "$instance" "$app"; then return 3; fi
                return 1  # Stop even when rollback succeeds.
            fi
        done
        if ((i + batch_size < total)); then sleep "$delay" || return 1; fi
    done
    printf 'Rolling complete: %s/%s\n' "$deployed" "$total"
}
deploy_blue_green() {
    local app=$1 version=$2 active target
    active=$(get_active_environment "$app") || return 1
    case $active in blue) target=green;; green) target=blue;; *) return 2;; esac
    deploy_to_environment "$target" "$app" "$version" || return 1
    check_environment_health "$target" "$app" || return 1
    run_smoke_tests "$target" "$app" || return 1
    switch_traffic "$app" "$target" || return 1
    if check_environment_health "$target" "$app" && update_active_environment "$app" "$target"; then
        printf 'Active environment: %s\n' "$target"
    else
        switch_traffic "$app" "$active" || return 3
        return 1
    fi
}
canary_values_healthy() {
    python3 - "$@" <<'PY'
import math,sys
try:
    error,latency,error_limit,latency_limit=map(float,sys.argv[1:])
    ok=all(map(math.isfinite,(error,latency,error_limit,latency_limit)))
    ok=ok and 0<=error<=100 and 0<=error_limit<=100 and latency>=0 and latency_limit>=0
    raise SystemExit(0 if ok and error<=error_limit and latency<=latency_limit else 1)
except (ValueError,TypeError): raise SystemExit(1)
PY
}
deploy_canary() {
    local app=$1 version=$2 percentage error latency
    local observe=${CANARY_OBSERVE_SECONDS:-60}
    [[ $observe =~ ^[0-9]{1,4}$ && -n ${CANARY_ERROR_THRESHOLD:-} && -n ${CANARY_LATENCY_THRESHOLD:-} ]] || return 2
    canary_values_healthy 0 0 "$CANARY_ERROR_THRESHOLD" "$CANARY_LATENCY_THRESHOLD" || return 2
    deploy_to_canary_pool "$app" "$version" || return 1
    for percentage in 5 25 50 75 100; do
        if set_canary_weight "$app" "$percentage" && monitor_canary_metrics "$app" "$observe" &&
           error=$(get_canary_error_rate "$app") && latency=$(get_canary_latency "$app" p99) &&
           canary_values_healthy "$error" "$latency" "$CANARY_ERROR_THRESHOLD" "$CANARY_LATENCY_THRESHOLD"; then :
        else
            rollback_canary "$app" || return 3
            return 1
        fi
    done
    promote_canary "$app" "$version"
}
check_health() {
    local instance=$1 type=$2 endpoint=$3 duration=${4:-10} status host port
    [[ $duration =~ ^[1-9][0-9]{0,3}$ ]] || return 2
    case $type in
        http)
            status=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' \
                --connect-timeout "$duration" --max-time "$duration" -- "http://${instance}${endpoint}") || return 1
            [[ $status == 200 ]] ;;
        tcp)
            IFS=: read -r host port <<< "$instance"
            [[ $host =~ ^[A-Za-z0-9._-]+$ && $port =~ ^[1-9][0-9]{0,4}$ ]] || return 2
            ((port <= 65535)) || return 2
            timeout "$duration" bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port" ;;
        process) process_probe "$instance" "$endpoint" "$duration" ;;
        command) command_probe "$instance" "$endpoint" "$duration" ;;
        *) return 2 ;;
    esac
}
wait_for_health() {
    local instance=$1 duration=${2:-60} interval=${3:-5} deadline remaining attempt
    [[ $duration =~ ^[1-9][0-9]{0,3}$ && $interval =~ ^[1-9][0-9]{0,3}$ ]] || return 2
    deadline=$((SECONDS + duration))
    while ((SECONDS < deadline)); do
        remaining=$((deadline - SECONDS)); attempt=$remaining
        ((attempt <= 10)) || attempt=10
        if check_health "$instance" http /health "$attempt"; then return 0; fi
        remaining=$((deadline - SECONDS))
        ((remaining > 0)) || break
        ((remaining >= interval)) && remaining=$interval
        sleep "$remaining" || return 1
    done
    return 1
}
deploy_with_feature_flag() {
    local app=$1 version=$2 feature=$3 pct delay=${FEATURE_OBSERVE_SECONDS:-300}
    [[ $delay =~ ^[0-9]{1,4}$ ]] || return 2
    set_feature_flag "$feature" 0 "$app" || return 1
    deploy_rolling "$app" "$version" "${INSTANCES[@]}" || return 1
    for pct in 5 25 50 100; do
        if set_feature_flag "$feature" "$pct" "$app" && sleep "$delay" && check_metrics "$app" "$feature"; then :
        else
            rollback_feature_flag "$feature" "$app" || return 3
            return 1
        fi
    done
}
