# Deployer Project - Detailed Implementation

## Implementation boundary

The maintained CLI is `SEM06/scripts/projects/deployer/deployer.sh`; inspect `--help` before invocation. Its modules are `lib/core.sh`, `lib/utils.sh` and `lib/config.sh`. This chapter teaches a separate extracted filesystem release implementation plus deployment algorithms. Save named modules before combining the examples. They require Bash 4.4 or later, Python 3 and GNU utilities; YAML additionally requires PyYAML. `python3` alone is not evidence that PyYAML exists.

The filesystem routines operate on an explicitly owned application root. No example here establishes zero downtime: rename atomicity covers one namespace, whilst service health, requests in flight, routing and database compatibility require separate evidence. Service, routing, notification and remote execution adapters are supplied explicitly for the operator's chosen topology. A missing adapter fails before deployment instead of silently succeeding or probing `/etc` to choose infrastructure.

## Contents

1. [General Overview](#1-general-overview)
2. [System Architecture](#2-system-architecture)
3. [Deployment Strategies](#3-deployment-strategies)
4. [Core Module - deployer_core.sh](#4-core-module---deployer_coresh)
5. [Health Checks System](#5-health-checks-system)
6. [Hooks System](#6-hooks-system)
7. [Rollback and Recovery](#7-rollback-and-recovery)
8. [Manifest-based Deployment](#8-manifest-based-deployment)
9. [Implementation Exercises](#9-implementation-exercises)

---

## 1. General Overview

### 1.1 Project Purpose

The **Deployer** project implements an automated deployment system for applications, offering:

- **Multiple Strategies**: rolling, blue-green, canary deployment
- **Health Checks**: application state verification (HTTP, TCP, process, command)
- **Automatic Rollback**: revert to previous version in case of failure
- **Hooks System**: pre_deploy, post_deploy, on_rollback, on_failure
- **Manifest Deployment**: YAML file-based deployment
- **Service Management**: integration with systemd, Docker

### 1.2 File Structure

```
projects/deployer/
├── deployer.sh              # Main script (~1000 lines)
├── lib/
│   ├── deployer_core.sh     # Deployment functions (~800 lines)
│   ├── deployer_utils.sh    # Common utilities (~400 lines)
│   └── deployer_config.sh   # Configuration management (~300 lines)
└── config/
    └── deployer.conf        # Default configuration
```

### 1.3 Fundamental Concepts

**Deployment** = The process of installing and configuring a new application version

**Release** = A specific application version prepared for deployment

**Rollback** = Reverting to a previous functional version

**Health Check** = Verification that the application works correctly

---

## 2. System Architecture

### 2.1 Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        deployer.sh (Main)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_manifest()                                         │
│          └─ execute_deployment()                                        │
│                    │                                                     │
│         ┌─────────┴───────────┬────────────────┬──────────────┐        │
│         ▼                     ▼                ▼              ▼        │
│   deploy_rolling()    deploy_blue_green()  deploy_canary()  rollback() │
└─────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_core.sh                                  │
├──────────────────────────────────────────────────────────────────────────┤
│  prepare_release()      activate_release()      health_check()           │
│  upload_files()         switch_symlink()        check_http()             │
│  run_hooks()            restart_service()       check_tcp()              │
│  create_rollback_point()  cleanup_old_releases()  check_process()        │
└──────────────────────────────────────────────────────────────────────────┘
                │                    │              │
                ▼                    ▼              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         deployer_utils.sh                                 │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()          format_timestamp()       send_notification()     │
│  log_deployment()       generate_release_id()    parse_yaml()            │
│  create_lockfile()      archive_release()        validate_url()          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Deployment Directory Structure

```
/var/www/myapp/                     # Application root
├── releases/                       # All versions
│   ├── 20240115_143022/           # Release 1
│   │   ├── app/
│   │   ├── config/
│   │   └── .release_meta
│   ├── 20240116_093045/           # Release 2
│   └── 20240117_110530/           # Release 3 (current)
├── shared/                         # Files shared between releases
│   ├── config/                    # Permanent configurations
│   ├── uploads/                   # User uploaded files
│   └── logs/                      # Application logs
├── current -> releases/20240117_110530/  # Symlink to active version
└── .deploy_state/                  # Deployment state
    ├── last_deploy.json           # Last deployment info
    ├── rollback_point             # Version for rollback
    └── deploy.lock                # Lock for concurrency
```

### 2.3 Deployment Lifecycle

```
┌────────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT LIFECYCLE                                │
│                                                                        │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│   │ PREPARE │───▶│ UPLOAD  │───▶│  BUILD  │───▶│ VERIFY  │            │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘            │
│        │                                              │                │
│        │         ┌────────────────────────────────────┘                │
│        │         │                                                     │
│        │         ▼                                                     │
│        │    ┌─────────┐    ┌─────────┐    ┌─────────┐                 │
│        │    │ ACTIVATE│───▶│ HEALTH  │───▶│ CLEANUP │                 │
│        │    └─────────┘    │  CHECK  │    └─────────┘                 │
│        │         │         └─────────┘         │                       │
│        │         │              │              │                       │
│        │         │         FAIL │              │                       │
│        │         │              ▼              │                       │
│        │         │        ┌─────────┐          │                       │
│        │         │        │ROLLBACK │          │                       │
│        │         │        └─────────┘          │                       │
│        │         │              │              │                       │
│        └─────────┴──────────────┴──────────────┘                       │
│                           │                                            │
│                           ▼                                            │
│                     ┌─────────┐                                        │
│                     │ COMPLETE│                                        │
│                     └─────────┘                                        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Deployment Strategies

### 3.1 Rolling Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     ROLLING DEPLOYMENT                                   │
│                                                                          │
│   Initial State:                                                        │
│   [Instance 1: v1.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v1.0                                                             │
│                                                                          │
│   Step 1: Update Instance 1                                             │
│   [Instance 1: v2.0] [Instance 2: v1.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   33% v2.0, 67% v1.0                                                    │
│                                                                          │
│   Step 2: Update Instance 2                                             │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v1.0]             │
│   ─────────────────────────────────────────────────────────             │
│   67% v2.0, 33% v1.0                                                    │
│                                                                          │
│   Step 3: Update Instance 3                                             │
│   [Instance 1: v2.0] [Instance 2: v2.0] [Instance 3: v2.0]             │
│   ─────────────────────────────────────────────────────────             │
│   100% v2.0                                                             │
│                                                                          │
│   Advantages:              Disadvantages:                               │
│   + Availability target          - Mixed versions temporarily                 │
│   + Gradual rollback       - Higher complexity                          │
│   + Production testing     - Requires backward compatibility            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Blue-Green Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BLUE-GREEN DEPLOYMENT                                 │
│                                                                          │
│   Initial State:                                                        │
│                                                                          │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │   BLUE (v1.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                 ╳                                 │
│                                       ║                                 │
│   ┌─────────────────┐                 ║                                 │
│   │  GREEN (idle)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                                                   │
│                                                                          │
│   After Deploy:                                                         │
│                                                                          │
│   ┌─────────────────┐                 ╳                                 │
│   │   BLUE (v1.0)   │─ ─ ─ ─ ─ ─ ─ ─ ─                                  │
│   │    STANDBY      │                                                   │
│   └─────────────────┘                 ║                                 │
│                                       ║                                 │
│   ┌─────────────────┐         ┌─────────────────┐                       │
│   │  GREEN (v2.0)   │◀═══════▶│  Load Balancer  │◀═══▶ Users           │
│   │     ACTIVE      │         └─────────────────┘                       │
│   └─────────────────┘                                                   │
│                                                                          │
│   Advantages:              Disadvantages:                               │
│   + Rapid route rollback       - Resource duplication                       │
│   + Availability target          - Higher cost                                │
│   + Testing before         - Complex DB synchronisation                 │
│     switch                                                              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Canary Deployment

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      CANARY DEPLOYMENT                                   │
│                                                                          │
│   Initial State: 100% traffic → v1.0                                    │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Production (v1.0)                   │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
│   Step 1: Deploy canary (5% traffic)                                    │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │            Production (v1.0)                        │               │
│   │  ███████████████████████████████████████████████    │ 95%          │
│   └─────────────────────────────────────────────────────┘               │
│   ┌────┐                                                                │
│   │v2.0│ Canary                                           5%            │
│   └────┘                                                                │
│                                                                          │
│   Step 2: Monitor metrics (errors, latency, etc.)                       │
│   ┌──────────────────────────────────────────────────────────────┐      │
│   │  Errors: ✓ OK    Latency: ✓ OK    CPU: ✓ OK    Memory: ✓ OK  │      │
│   └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
│   Step 3: Gradual increase (25% → 50% → 100%)                           │
│                                                                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Production (v1.0)                │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│   ┌──────────────────────────────────────────┐                          │
│   │         Canary (v2.0)                    │ 50%                      │
│   └──────────────────────────────────────────┘                          │
│                                                                          │
│   Step 4: Finalisation (100% v2.0)                                      │
│                                                                          │
│   ┌─────────────────────────────────────────────────────┐               │
│   │                 Production (v2.0)                   │               │
│   │  █████████████████████████████████████████████████  │ 100%         │
│   └─────────────────────────────────────────────────────┘               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Core Module - deployer_core.sh

### 4.1 The prepare_release() Function

Save the following module as `lib/release_teaching.py`. It copies dotfiles, stages a unique immutable release, encodes metadata as JSON and refuses incomplete targets. Local source symlinks must stay within the source tree; archive imports in this teaching implementation accept regular files and directories only. Directory trees, tar archives and ZIP archives remain supported. The caller retains ownership; no implicit `chown` or permission policy is imposed.

```python
#!/usr/bin/env python3
"""Owned local release filesystem operations; no service/network actions.

Atomic replacement is limited to one filesystem namespace. It does not establish
zero downtime, database compatibility or a crash-durable deployment transaction.
"""
import argparse
import datetime
import fcntl
import getpass
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import socket
import stat
import subprocess
import sys
import tarfile
import tempfile
import uuid
import zipfile


def identifier(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*',value) or value in ('.','..'):
        raise ValueError('Invalid release identifier')
    return value


def relative(value):
    path=PurePosixPath(value)
    if path.is_absolute() or '..' in path.parts or not path.parts: raise ValueError('Unsafe member name')
    return str(path)


def write_json(path,data):
    fd,temporary=tempfile.mkstemp(prefix='.state.',dir=path.parent)
    try:
        with os.fdopen(fd,'w') as output: json.dump(data,output,ensure_ascii=False); output.write('\n'); output.flush(); os.fsync(output.fileno())
        os.replace(temporary,path)
    finally:
        if os.path.exists(temporary): os.unlink(temporary)


def copy_payload(source,destination):
    if source.is_dir():
        source=source.resolve()
        for path in source.rglob('*'):
            if path.is_symlink():
                target=path.resolve()
                if source!=target and source not in target.parents: raise ValueError('Source symlink escapes source tree')
            elif not (path.is_file() or path.is_dir()): raise ValueError('Unsupported source object')
        shutil.copytree(source,destination,dirs_exist_ok=True,symlinks=True)
    elif zipfile.is_zipfile(source):
        with zipfile.ZipFile(source) as archive:
            names=set(); total=0
            for item in archive.infolist():
                name=relative(item.filename); mode=item.external_attr>>16
                if name in names or stat.S_ISLNK(mode): raise ValueError('Duplicate or symlink ZIP member')
                names.add(name); total+=item.file_size
                if len(names)>100000 or total>2*1024**3: raise ValueError('Teaching archive limit exceeded')
            for item in archive.infolist():
                target=destination/relative(item.filename)
                if item.is_dir(): target.mkdir(parents=True,exist_ok=True)
                else:
                    target.parent.mkdir(parents=True,exist_ok=True)
                    with archive.open(item) as data,target.open('xb') as output: shutil.copyfileobj(data,output)
    else:
        with tarfile.open(source,'r:*') as archive:
            members=archive.getmembers(); names=set(); total=0
            for item in members:
                if item.name in ('.','./') and item.isdir(): continue
                name=relative(item.name)
                if name in names or not (item.isfile() or item.isdir()): raise ValueError('Unsupported/duplicate archive member')
                names.add(name); total+=item.size
                if len(names)>100000 or total>2*1024**3: raise ValueError('Teaching archive limit exceeded')
            for item in members:
                if item.name in ('.','./') and item.isdir(): continue
                target=destination/relative(item.name)
                if item.isdir(): target.mkdir(parents=True,exist_ok=True)
                else:
                    target.parent.mkdir(parents=True,exist_ok=True)
                    with archive.extractfile(item) as data,target.open('xb') as output: shutil.copyfileobj(data,output)
                    target.chmod(item.mode & 0o777)


def prepare(source,root,shared_dirs=(),shared_files=()):
    source=source.resolve(strict=True); root=root.resolve()
    if source==root or source in root.parents: raise ValueError('Release root must be outside source')
    (root/'releases').mkdir(parents=True,exist_ok=True); (root/'.deploy_state').mkdir(exist_ok=True)
    release_id=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%d_%H%M%S_')+uuid.uuid4().hex[:12]
    stage=Path(tempfile.mkdtemp(prefix='.prepare.',dir=root/'releases'))
    try:
        copy_payload(source,stage)
        for name in (*shared_dirs,*shared_files):
            name=relative(name); target=root/'shared'/name; link=stage/name
            if name in shared_dirs: target.mkdir(parents=True,exist_ok=True)
            elif not target.is_file(): raise ValueError('Shared file must already exist: '+name)
            if link.is_symlink() or link.is_file(): link.unlink()
            elif link.is_dir(): shutil.rmtree(link)
            link.parent.mkdir(parents=True,exist_ok=True); link.symlink_to(target)
        meta={'release_id':release_id,'timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'source':str(source),'deployed_by':getpass.getuser(),'hostname':socket.gethostname(),
              'git_commit':None,'git_branch':None}
        if source.is_dir() and (source/'.git').exists():
            for field,args in [('git_commit',['rev-parse','HEAD']),('git_branch',['rev-parse','--abbrev-ref','HEAD'])]:
                result=subprocess.run(['git','-C',str(source),*args],capture_output=True,text=True)
                if result.returncode==0: meta[field]=result.stdout.strip()
        write_json(stage/'.release_meta',meta)
        (stage/'.complete').touch()
        stage.rename(root/'releases'/release_id)
    finally:
        if stage.exists(): shutil.rmtree(stage)
    return release_id


def switch(link,target):
    if not target.is_dir(): raise ValueError('Target directory missing')
    if link.exists() and not link.is_symlink(): raise ValueError('Refuse replacing a non-symlink live path')
    temporary=Path(tempfile.mkdtemp(prefix='.switch.',dir=link.parent))
    try:
        (temporary/'link').symlink_to(target.resolve())
        os.replace(temporary/'link',link)
    finally: shutil.rmtree(temporary)


def activate(root,release_id):
    release=root/'releases'/identifier(release_id)
    if release.is_symlink() or not (release/'.complete').is_file(): raise ValueError('Incomplete/unsafe release')
    state=root/'.deploy_state'; state.mkdir(parents=True,exist_ok=True)
    with (state/'deploy.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        current=root/'current'; previous=current.resolve().name if current.is_symlink() else None
        write_json(state/'transition.json',{'previous':previous,'target':release_id})
        switch(current,release)
        write_json(state/'rollback_point.json',{'release_id':previous})


def prune(root,keep):
    if keep<1: raise ValueError('Keep at least one release')
    protected=set()
    if (root/'current').is_symlink(): protected.add((root/'current').resolve().name)
    point=root/'.deploy_state/rollback_point.json'
    if point.exists(): protected.add(json.loads(point.read_text()).get('release_id'))
    releases=sorted((p for p in (root/'releases').iterdir() if p.is_dir() and not p.is_symlink() and (p/'.complete').is_file()),
                    key=lambda p:json.loads((p/'.release_meta').read_text())['timestamp'],reverse=True)
    protected.update(p.name for p in releases[:keep])
    for path in releases:
        if path.name not in protected and not (path/'.protected').exists(): shutil.rmtree(path)


def main():
    parser=argparse.ArgumentParser(description=__doc__); sub=parser.add_subparsers(dest='action',required=True)
    p=sub.add_parser('prepare'); p.add_argument('source',type=Path); p.add_argument('root',type=Path)
    p.add_argument('--shared-dir',action='append',default=[]); p.add_argument('--shared-file',action='append',default=[])
    p=sub.add_parser('activate'); p.add_argument('root',type=Path); p.add_argument('release_id')
    p=sub.add_parser('switch'); p.add_argument('link',type=Path); p.add_argument('target',type=Path)
    p=sub.add_parser('prune'); p.add_argument('root',type=Path); p.add_argument('keep',type=int)
    args=parser.parse_args()
    if args.action=='prepare': print(prepare(args.source,args.root,args.shared_dir,args.shared_file))
    elif args.action=='activate': activate(args.root,args.release_id)
    elif args.action=='switch': switch(args.link,args.target)
    else: prune(args.root,args.keep)


if __name__=='__main__':
    try: main()
    except (OSError,ValueError,KeyError,tarfile.TarError,zipfile.BadZipFile) as error:
        print(error,file=sys.stderr); raise SystemExit(1)
```

The stdout contract of `prepare_release` is exactly one release identifier. Setup and metadata errors propagate; diagnostic messages belong on stderr.


```bash
release_engine() {
    python3 "${RELEASE_ENGINE_PATH:-${LIB_DIR:?Set LIB_DIR}/release_teaching.py}" "$@"
}
prepare_release() {
    local source_path=$1 app_root=$2 item
    local -a command=(prepare "$source_path" "$app_root") shared_dirs=() shared_files=()
    IFS=',' read -ra shared_dirs <<< "$(get_config shared_dirs '')"
    IFS=',' read -ra shared_files <<< "$(get_config shared_files '')"
    for item in "${shared_dirs[@]}"; do [[ -z $item ]] || command+=(--shared-dir "$item"); done
    for item in "${shared_files[@]}"; do [[ -z $item ]] || command+=(--shared-file "$item"); done
    release_engine "${command[@]}"
}
```

### 4.2 The activate_release() Function

```bash
activate_release() {
    local release_id=$1 app_root=$2 release_dir service
    release_dir=$app_root/releases/$release_id
    [[ -f $release_dir/.complete ]] || return 1
    run_hook pre_activate "$release_dir" || return 1
    release_engine activate "$app_root" "$release_id" || return 1
    run_hook post_activate "$release_dir" || return 1
    service=$(get_config restart_service '')
    if [[ -n $service ]]; then restart_application_service "$service" || return 1; fi
    update_deploy_state "$app_root" "$release_id" deployed || return 1
}
restart_application_service() {
    local service=$1 method script container
    method=$(get_config service_manager systemd)
    case $method in
        systemd) systemctl restart -- "$service";;
        docker) container=$(get_config docker_container "$service"); docker restart -- "$container";;
        supervisor) supervisorctl restart "$service";;
        script) script=$(get_config restart_script ''); [[ -n $script && -x $script ]] || return 2; "$script";;
        *) printf 'Unsupported service manager: %s\n' "$method" >&2; return 2;;
    esac
}
update_deploy_state() {
    python3 - "$1" "$2" "$3" <<'PY'
import datetime,json,os,pathlib,sys,tempfile
root,release,status=sys.argv[1:]; directory=pathlib.Path(root)/'.deploy_state'
directory.mkdir(parents=True,exist_ok=True)
fd,temporary=tempfile.mkstemp(prefix='.last.',dir=directory)
try:
    with os.fdopen(fd,'w') as output: json.dump({'release_id':release,'status':status,'timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat()},output)
    os.replace(temporary,directory/'last_deploy.json')
finally:
    if os.path.exists(temporary): os.unlink(temporary)
PY
}
```

### 4.3 Deployment Strategies Implementation

Save this source-only module as `strategy_reference.sh` together with the health-check functions in Section 5. Each strategy accepts a **prepared release path**; rolling additionally accepts explicit instance names. Chapter P07 supplies filesystem/routing examples and the adapter contract. Configurations such as `(5 25 50 75 100)` are illustrative stage choices, not a measured optimal policy. Initialise `CANARY_STAGES` as an array and provide thresholds explicitly. Status 1 means a failed deployment with recovery acknowledged; status 3 means recovery/routing outcome requires operator resolution, so both candidate pools must remain available.


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
```

---

## 5. Health Checks System

### 5.1 Health Checks Implementation

```bash
check_http() {
    local url=$1 expected=${2:-200} duration=${3:-5} response
    positive_integer "$duration" && [[ $expected =~ ^[1-5][0-9][0-9]$ ]] || return 2
    [[ $url == http://* || $url == https://* ]] || return 2
    response=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' \
        --connect-timeout "$duration" --max-time "$duration" -- "$url") || return 1
    [[ $response == "$expected" ]]
}
check_tcp() {
    local target=${1#tcp://} duration=${2:-5} host port
    positive_integer "$duration" || return 2
    # Explicit hostname/IPv4 subset; bracketed IPv6 requires a chosen nc adapter.
    [[ $target =~ ^([A-Za-z0-9._-]+):([0-9]{1,5})$ ]] || return 2
    host=${BASH_REMATCH[1]}; port=${BASH_REMATCH[2]}
    ((10#$port > 0 && 10#$port <= 65535)) || return 2
    timeout --kill-after=1 "$duration" bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$port"
}
check_process() {
    local target=${1#pid://}
    if [[ $target =~ ^[1-9][0-9]*$ ]]; then kill -0 "$target" 2>/dev/null
    elif [[ $target == name:* && -n ${target#name:} ]]; then pgrep -x -- "${target#name:}" >/dev/null
    else return 2; fi
}
check_command() {
    local duration=$1; shift
    positive_integer "$duration" && (($# > 0)) || return 2
    timeout --kill-after=1 "$duration" "$@" >/dev/null 2>&1  # argv, never bash -c from a manifest string.
}
health_check() {
    local target=$1 duration=${2:-30} method=${3:-auto} deadline remaining attempt pause
    positive_integer "$duration" || return 2
    if [[ $method == auto ]]; then
        case $target in http://*|https://*) method=http;; tcp://*) method=tcp;; pid://*) method=process;; *) return 2;; esac
    fi
    case $method in http|tcp|process) :;; *) return 2;; esac
    deadline=$((SECONDS+duration))
    while ((SECONDS < deadline)); do
        remaining=$((deadline-SECONDS)); attempt=$remaining; ((attempt <= 5)) || attempt=5
        case $method in
            http) if check_http "$target" 200 "$attempt"; then return 0; fi;;
            tcp) if check_tcp "$target" "$attempt"; then return 0; fi;;
            process) if check_process "$target"; then return 0; fi;;
        esac
        pause=$((deadline-SECONDS)); ((pause <= 2)) || pause=2
        ((pause > 0)) || break
        sleep "$pause" || return 1
    done
    return 1
}

advanced_health_check() {
    # One JSON object per argument: targets containing colons stay intact.
    local row temporary type target duration expected item rc=0
    temporary=$(mktemp) || return 1
    for row in "$@"; do
        if ! python3 - "$row" > "$temporary" <<'PY'
import json,sys
try:
    d=json.loads(sys.argv[1]); kind=d['type']; timeout=d.get('timeout',30)
    assert kind in ('http','tcp','process','command') and isinstance(timeout,int) and 1<=timeout<=9999
    target=d.get('target',''); expected=str(d.get('expected_code',200))
    argv=d.get('argv',[])
    assert isinstance(target,str) and isinstance(argv,list) and all(isinstance(x,str) and '\0' not in x for x in argv)
    assert '\0' not in target and (kind!='command' or argv)
    for x in (kind,target,str(timeout),expected,*argv): sys.stdout.buffer.write(x.encode()+b'\0')
except (ValueError,KeyError,AssertionError): raise SystemExit(2)
PY
        then rm -f -- "$temporary"; return 2; fi
        local -a fields=(); mapfile -d '' -t fields < "$temporary"
        type=${fields[0]}; target=${fields[1]}; duration=${fields[2]}; expected=${fields[3]}
        case $type in
            http) check_http "$target" "$expected" "$duration" || rc=1;;
            tcp) check_tcp "$target" "$duration" || rc=1;;
            process) check_process "$target" || rc=1;;
            command) check_command "$duration" "${fields[@]:4}" || rc=1;;
        esac
    done
    rm -f -- "$temporary"
    return "$rc"
}
```

---

## 6. Hooks System

### 6.1 Hooks Implementation

```bash
# Variable for tracking hooks
declare -A HOOK_RESULTS

run_hook() {
    local hook_name="$1"
    local release_dir="$2"
    shift 2
    local -a hook_args=("$@")
    
    log_debug "Searching hook: $hook_name"
    
    # Search for hook in multiple locations
    local -a hook_locations=(
        "${release_dir}/deploy/hooks/${hook_name}"
        "${release_dir}/deploy/hooks/${hook_name}.sh"
        "${release_dir}/.deploy/${hook_name}"
        "$(get_config "${hook_name}_hook" "")"
    )
    
    local hook_script=""
    for location in "${hook_locations[@]}"; do
        [[ -z "$location" ]] && continue
        
        if [[ -f "$location" && -x "$location" ]]; then
            hook_script="$location"
            break
        fi
    done
    
    if [[ -z "$hook_script" ]]; then
        log_debug "Hook '$hook_name' not found"
        return 0
    fi
    
    log_info "Executing hook: $hook_name"
    log_debug "  Script: $hook_script"
    
    # Prepare environment for hook
    export DEPLOY_HOOK_NAME="$hook_name"
    export DEPLOY_RELEASE_DIR="$release_dir"
    export DEPLOY_APP_ROOT="$(dirname "$(dirname "$release_dir")")"
    export DEPLOY_TIMESTAMP="$(date -Iseconds)"
    export DEPLOY_RELEASE_ID="$(basename "$release_dir")"
    
    # Execute hook with timeout
    local hook_timeout
    hook_timeout=$(get_config "hook_timeout" "300")
    
    local start_time exit_code output
    start_time=$(date +%s)
    
    if output=$(timeout --kill-after=1 "$hook_timeout" "$hook_script" "${hook_args[@]}" 2>&1); then exit_code=0
    else exit_code=$?; fi
    
    local duration=$(($(date +%s) - start_time))
    
    # Save result
    HOOK_RESULTS["$hook_name"]="$exit_code"
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Hook '$hook_name' completed in ${duration}s"
        log_debug "Output: $output"
        return 0
    elif [[ $exit_code -eq 124 ]]; then
        log_error "Hook '$hook_name' timeout after ${hook_timeout}s"
        return 1
    else
        log_error "Hook '$hook_name' failed (exit code: $exit_code)"
        log_error "Output: $output"
        return 1
    fi
}

# Standard hooks for deployment
run_deploy_hooks_sequence() {
    local release_dir="$1"
    local phase="${2:-full}"  # full, pre_only, post_only
    
    local hooks_failed=0
    
    # Pre-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "pre_only" ]]; then
        local -a pre_hooks=(
            "pre_deploy"
            "check_dependencies"
            "pre_build"
        )
        
        for hook in "${pre_hooks[@]}"; do
            if ! run_hook "$hook" "$release_dir"; then
                log_error "Pre-deployment hook failed: $hook"
                hooks_failed=$((hooks_failed + 1))
                
                # Abort if critical hook fails
                if [[ "$hook" == "pre_deploy" ]]; then
                    return 1
                fi
            fi
        done
    fi
    
    # Build hooks
    if [[ "$phase" == "full" ]]; then
        run_hook "build" "$release_dir" || {
            log_error "Build failed!"
            return 1
        }
    fi
    
    # Post-deployment hooks
    if [[ "$phase" == "full" || "$phase" == "post_only" ]]; then
        local -a post_hooks=(
            "post_deploy"
            "post_activate"
            "notify"
        )
        
        for hook in "${post_hooks[@]}"; do
            run_hook "$hook" "$release_dir" || {
                log_warning "Post-deployment hook failed: $hook"
                hooks_failed=$((hooks_failed + 1))
            }
        done
    fi
    
    [[ $hooks_failed -eq 0 ]]
}
```

### 6.2 Hook Script Examples

```bash
# hooks/pre_deploy.sh - Checks before deployment
#!/usr/bin/env bash
set -e

echo "=== Pre-Deploy Hook ==="
echo "Release: $DEPLOY_RELEASE_ID"
echo "Directory: $DEPLOY_RELEASE_DIR"

# Verify we have all required files
required_files=("index.php" "config/app.php" "composer.json")

for file in "${required_files[@]}"; do
    if [[ ! -f "${DEPLOY_RELEASE_DIR}/${file}" ]]; then
        echo "ERROR: Missing file: $file"
        exit 1
    fi
done

# Verify permissions
echo "Checking permissions..."
# Apply the explicitly supplied application permission adapter; no world-writable defaults.
: "${DEPLOY_PERMISSION_PROGRAM:?Provide the owned application permission adapter}"
"$DEPLOY_PERMISSION_PROGRAM" "$DEPLOY_RELEASE_DIR"

echo "Pre-deploy OK"
exit 0
```

```bash
# hooks/build.sh - Build and dependency installation
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Build Hook ==="

# Composer for PHP
if [[ -f "composer.json" ]]; then
    echo "Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader --no-interaction
fi

# NPM for JavaScript
if [[ -f "package.json" ]]; then
    echo "Installing NPM dependencies..."
    npm ci --production
    
    if [[ -f "webpack.config.js" ]]; then
        echo "Building assets..."
        npm run build
    fi
fi

# Python
if [[ -f "requirements.txt" ]]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt --quiet
fi

echo "Build completed"
exit 0
```

```bash
# hooks/post_deploy.sh - Actions after deployment
#!/usr/bin/env bash
set -e

cd "$DEPLOY_RELEASE_DIR"

echo "=== Post-Deploy Hook ==="

# Database migrations
if [[ -f "artisan" ]]; then
    echo "Running Laravel migrations..."
    php artisan migrate --force
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Clear cache
if [[ -d "cache" ]]; then
    echo "Clearing cache..."
    rm -rf cache/*
fi

# Notify external services
if [[ -n "${SLACK_WEBHOOK:-}" ]]; then
    payload=$(python3 -c 'import json,sys; print(json.dumps({"text":"Deployment complete: "+sys.argv[1]}))' "$DEPLOY_RELEASE_ID")
    curl --fail --silent --show-error --connect-timeout 5 --max-time 10 -X POST \
        -H 'Content-Type: application/json' --data "$payload" -- "$SLACK_WEBHOOK"
fi

echo "Post-deploy completed"
exit 0
```

---

## 7. Rollback and Recovery

### 7.1 Rollback Implementation

```bash
rollback() {
    local app_root=$1 target=${2:-} directory service
    if [[ -z $target ]]; then
        target=$(python3 - "$app_root/.deploy_state/rollback_point.json" <<'PY'
import json,sys
try:
    value=json.load(open(sys.argv[1]))['release_id']
    if not isinstance(value,str) or not value: raise ValueError()
    print(value)
except (OSError,ValueError,KeyError): raise SystemExit(1)
PY
        ) || return 1
    fi
    [[ $target =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ && $target != . && $target != .. ]] || return 2
    directory=$app_root/releases/$target
    [[ -f $directory/.complete ]] || return 1
    run_hook pre_rollback "$directory" || return 1
    release_engine activate "$app_root" "$target" || return 1
    service=$(get_config restart_service '')
    if [[ -n $service ]]; then restart_application_service "$service" || return 1; fi
    health_check "$(get_config app_url http://localhost)" 60 || return 1
    run_hook post_rollback "$directory" || return 1
    run_hook on_rollback "$directory" || return 1
    update_deploy_state "$app_root" "$target" rolled_back
}
auto_rollback_on_failure() {
    local app_root=$1 failed_release=$2
    [[ $(get_config auto_rollback false) == true ]] || return 1
    rollback "$app_root" || return 3
    # The deployment remains failed even after successful recovery.
    return 1
}
cleanup_failed_release() {
    local app_root=$1 release_id=$2 keep_for_debug=${3:-false}
    [[ $release_id =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ && $release_id != . && $release_id != .. ]] || return 2
    local directory=$app_root/releases/$release_id active=''
    [[ ! -L $app_root/current ]] || active=$(readlink -f -- "$app_root/current")
    [[ -f $directory/.complete && ! -L $directory && $active != "$(realpath -- "$directory")" ]] || return 1
    if [[ $keep_for_debug == true ]]; then touch -- "$directory/.protected"; else rm -rf -- "$directory"; fi
}
```

### 7.2 Cleanup and Maintenance

```bash
cleanup_old_releases() { release_engine prune "$1" "${2:-5}"; }
verify_deployment_state() {
    local root=$1 issues=0
    [[ -d $root/releases ]] || issues=$((issues+1))
    [[ -L $root/current && -f $root/current/.complete ]] || issues=$((issues+1))
    printf '%s\n' "$issues"
    ((issues == 0))
}
```

---

## 8. Manifest-based Deployment

### 8.1 YAML Manifest Structure

```yaml
# deploy.yml — data, not shell source. Values below are illustrative topology inputs.
name: my-application
version: "1.2.3"
source:
  type: local
  url: /owned/artifacts/my-application
  # Alternatives: type: git with url/branch, or type: archive with an approved URL.
deployment:
  strategy: rolling
  app_root: /owned/apps/my-application
  keep_releases: 5
  instances: [instance-1, instance-2]
  rolling:
    batch_size: 1
    batch_delay: 10
    max_unavailable: 1
  canary:
    stages: [5, 25, 50, 75, 100]
    stage_duration: 60
    error_threshold: 1.0
    latency_threshold: 500
    auto_promote: false
health_checks:
  - type: http
    target: http://localhost:8080/health
    expected_code: 200
    timeout: 10
  - type: tcp
    target: tcp://localhost:8080
    timeout: 5
  - type: command
    argv: ["./bin/health-check", "--local"]
    timeout: 10
hooks:
  pre_deploy: [["./bin/check-dependencies"]]
  build: [["npm", "ci"], ["npm", "run", "build"]]
  post_deploy: [["./bin/check-release"]]
service:
  manager: systemd
  name: myapp
  reload_argv: ["systemctl", "reload", "nginx"]
notifications:
  slack:
    webhook_env: SLACK_WEBHOOK
    channel: "#deployments"
  email:
    recipients: ["devops@example.com"]
environment:
  APP_ENV: production
  LOG_LEVEL: warning
```

### 8.2 Manifest Parser and Executor

Save the validator below as `lib/manifest_reference.py`. It validates mappings and nested fields, rejects unknown keys, preserves quotes and apostrophes as data and emits JSON without shell assignments. Hook and command-check arguments are arrays: no `eval`, interpolation or implicit shell is used. Environment values are literal. Notification credentials refer to an explicit environment-variable name; choosing recipients, enabling notifications or selecting remote authentication remains an operator action.

```python
#!/usr/bin/env python3
"""Validate the chapter manifest as data. PyYAML is an explicit dependency."""
import json
import os
from pathlib import Path
import subprocess
import sys


def keys(value,allowed,required=()):
    if not isinstance(value,dict) or set(value)-set(allowed) or not set(required)<=set(value):
        raise ValueError('Unknown, missing or invalid mapping fields')


def string(value):
    if not isinstance(value,str) or '\0' in value: raise ValueError('Expected NUL-free string')
    return value


def integer(value,low,high):
    if type(value)!=int or not low<=value<=high: raise ValueError('Integer outside schema bounds')


def validate(data):
    keys(data,('name','version','source','deployment','health_checks','hooks','service','notifications','environment'),('name','version','source','deployment'))
    for key in ('name','version'): string(data[key])
    keys(data['source'],('type','url','branch'),('type','url'))
    if data['source']['type'] not in ('local','archive','git'): raise ValueError('Unknown source type')
    string(data['source']['url']); string(data['source'].get('branch','main'))
    deployment=data['deployment']
    keys(deployment,('strategy','app_root','keep_releases','instances','rolling','canary'),('strategy','app_root'))
    if deployment['strategy'] not in ('rolling','blue-green','canary'): raise ValueError('Unknown strategy')
    root=Path(string(deployment['app_root']))
    if not root.is_absolute() or root==Path('/'): raise ValueError('Explicit absolute app_root required')
    integer(deployment.get('keep_releases',5),1,10000)
    instances=deployment.get('instances',[])
    if not isinstance(instances,list) or not all(isinstance(v,str) and v and '\0' not in v for v in instances): raise ValueError('Invalid instances')
    if deployment['strategy']=='rolling' and not instances: raise ValueError('Rolling needs explicit instances')
    rolling=deployment.get('rolling',{})
    keys(rolling,('batch_size','batch_delay','max_unavailable'))
    for k,default,low in [('batch_size',1,1),('batch_delay',10,0),('max_unavailable',1,1)]: integer(rolling.get(k,default),low,10000)
    canary=deployment.get('canary',{})
    keys(canary,('stages','stage_duration','error_threshold','latency_threshold','auto_promote'))
    if deployment['strategy']=='canary':
        stages=canary.get('stages')
        if not isinstance(stages,list) or not stages: raise ValueError('Explicit canary stages required')
        previous=0
        for item in stages: integer(item,previous+1,100); previous=item
        if previous!=100: raise ValueError('Final canary stage must be 100')
        integer(canary.get('stage_duration'),1,86400)
        import math
        for key,maximum in [('error_threshold',100),('latency_threshold',1e9)]:
            value=canary.get(key)
            if type(value) not in (int,float) or not math.isfinite(value) or not 0<=value<=maximum: raise ValueError('Explicit valid metric threshold required')
        if type(canary.get('auto_promote',False)) is not bool: raise ValueError('auto_promote is boolean')
    checks=data.get('health_checks',[])
    if not isinstance(checks,list): raise ValueError('health_checks is a list')
    for check in checks:
        keys(check,('type','target','timeout','expected_code','argv'),('type',))
        if check['type'] not in ('http','tcp','process','command'): raise ValueError('Unknown health check')
        integer(check.get('timeout',30),1,9999)
        if check['type']=='command':
            argv=check.get('argv')
            if not isinstance(argv,list) or not argv: raise ValueError('Command health check requires argv')
            for item in argv: string(item)
        else: string(check.get('target'))
        if 'expected_code' in check: integer(check['expected_code'],100,599)
    hooks=data.get('hooks',{})
    keys(hooks,('pre_deploy','build','post_deploy','on_failure','on_rollback'))
    for commands in hooks.values():
        if not isinstance(commands,list): raise ValueError('Hook phase is a list of argv arrays')
        for argv in commands:
            if not isinstance(argv,list) or not argv: raise ValueError('Hook command requires an argv array')
            for item in argv: string(item)
    service=data.get('service',{})
    keys(service,('manager','name','reload_argv'))
    if service:
        if service.get('manager') not in ('systemd','docker','supervisor','script'): raise ValueError('Unsupported service adapter')
        string(service.get('name'))
        if 'reload_argv' in service:
            if not isinstance(service['reload_argv'],list) or not service['reload_argv']: raise ValueError('reload_argv required')
            for item in service['reload_argv']: string(item)
    environment=data.get('environment',{})
    if not isinstance(environment,dict): raise ValueError('Environment mapping required')
    import re
    for name,value in environment.items():
        if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*',name): raise ValueError('Invalid environment name')
        string(value)
    notifications=data.get('notifications',{})
    keys(notifications,('slack','email'))
    if 'slack' in notifications:
        keys(notifications['slack'],('webhook_env','channel'),('webhook_env',))
        string(notifications['slack']['webhook_env'])
        if 'channel' in notifications['slack']: string(notifications['slack']['channel'])
    if 'email' in notifications:
        keys(notifications['email'],('recipients',),('recipients',))
        recipients=notifications['email']['recipients']
        if not isinstance(recipients,list) or not recipients: raise ValueError('Recipients list required')
        for recipient in recipients: string(recipient)
    return data


def main():
    action=sys.argv[1]
    if action=='validate':
        try: import yaml
        except ImportError: raise ValueError('PyYAML must be installed explicitly; python3 alone is not a YAML parser')
        source=Path(sys.argv[2])
        if source.stat().st_size>1024*1024: raise ValueError('Manifest exceeds the teaching limit')
        print(json.dumps(validate(yaml.safe_load(source.read_text())),ensure_ascii=False))
    elif action=='get':
        value=json.loads(sys.argv[2])
        for key in sys.argv[3].split('.'):
            if not isinstance(value,dict) or key not in value: print(sys.argv[4]); return
            value=value[key]
        if isinstance(value,(dict,list)): print(json.dumps(value))
        elif isinstance(value,bool): print(str(value).lower())
        else: print(value)
    elif action=='hooks':
        data=validate(json.loads(sys.argv[2])); phase=sys.argv[3]; directory=sys.argv[4]
        env=os.environ.copy(); env.update(data.get('environment',{})); env['DEPLOY_RELEASE_DIR']=directory
        for argv in data.get('hooks',{}).get(phase,[]): subprocess.run(argv,cwd=directory,env=env,check=True,timeout=300,stdout=sys.stderr)
    else: raise ValueError('Unknown manifest operation')


if __name__=='__main__':
    try: main()
    except (OSError,ValueError,TypeError,subprocess.SubprocessError) as error:
        print(error,file=sys.stderr); raise SystemExit(2)
```

The executor consumes the complete validated plan. Before fetching any source, `configure_manifest_adapters` must acknowledge every configured service, route, health and notification capability or return nonzero; no accepted field may be silently ignored. It is an explicit topology adapter from `DEPLOY_ADAPTERS_FILE`, not a hidden default. Tests supply harmless adapters. That boundary is necessary because a repository cannot infer service names, remote authentication, database rollback or notification authorisation from an example manifest.


```bash
manifest_engine() { python3 "${MANIFEST_ENGINE_PATH:-${LIB_DIR:?}/manifest_reference.py}" "$@"; }
declare -g MANIFEST_JSON='' OWNED_SOURCE_DIR=''
parse_manifest() { MANIFEST_JSON=$(manifest_engine validate "$1"); }
manifest_get() { manifest_engine get "$MANIFEST_JSON" "$1" "${2:-}"; }
fetch_source() {
    local -n result=$1
    local kind url branch target
    kind=$(manifest_get source.type); url=$(manifest_get source.url); branch=$(manifest_get source.branch main)
    OWNED_SOURCE_DIR=$(mktemp -d) || return 1
    case $kind in
        local)
            [[ -d $url ]] || return 1
            cp -a -- "$url/." "$OWNED_SOURCE_DIR/" || return 1
            result=$OWNED_SOURCE_DIR;;
        git)
            git clone --depth 1 --branch "$branch" -- "$url" "$OWNED_SOURCE_DIR" >&2 || return 1
            result=$OWNED_SOURCE_DIR;;
        archive)
            target=$OWNED_SOURCE_DIR/artifact.tar.gz
            curl --fail --location --silent --show-error --connect-timeout 10 --max-time 300 --output "$target" -- "$url" || return 1
            result=$target;;
        *) return 2;;
    esac
}
execute_manifest_deployment() (
    local manifest=$1 source_path release_id release_dir root strategy rc=0 rows
    parse_manifest "$manifest" || return 2
    : "${DEPLOY_ADAPTERS_FILE:?Provide the explicitly approved topology adapter module}"
    source "$DEPLOY_ADAPTERS_FILE" || return 2
    require_adapter configure_manifest_adapters || return 2
    configure_manifest_adapters "$MANIFEST_JSON" || return 2
    trap '[[ -z $OWNED_SOURCE_DIR ]] || rm -rf -- "$OWNED_SOURCE_DIR"' EXIT
    fetch_source source_path || return 1
    root=$(manifest_get deployment.app_root)
    strategy=$(manifest_get deployment.strategy)
    release_id=$(prepare_release "$source_path" "$root") || return 1
    release_dir=$root/releases/$release_id
    manifest_engine hooks "$MANIFEST_JSON" pre_deploy "$release_dir" || return 1
    manifest_engine hooks "$MANIFEST_JSON" build "$release_dir" || return 1
    BATCH_SIZE=$(manifest_get deployment.rolling.batch_size 1)
    MAX_UNAVAILABLE=$(manifest_get deployment.rolling.max_unavailable 1)
    HEALTH_CHECK_INTERVAL=$(manifest_get deployment.rolling.batch_delay 10)
    STAGE_DURATION=$(manifest_get deployment.canary.stage_duration 60)
    ERROR_THRESHOLD=$(manifest_get deployment.canary.error_threshold '')
    LATENCY_THRESHOLD=$(manifest_get deployment.canary.latency_threshold '')
    AUTO_PROMOTE=$(manifest_get deployment.canary.auto_promote false)
    local -a instances=() stages=() checks=()
    rows=$OWNED_SOURCE_DIR/plan.fields
    python3 - "$MANIFEST_JSON" > "$rows" <<'PY'
import json,sys
d=json.loads(sys.argv[1]); groups=[d['deployment'].get('instances',[]),d['deployment'].get('canary',{}).get('stages',[]),d.get('health_checks',[])]
for group in groups:
    print(json.dumps(group))
PY
    local instances_json stages_json checks_json
    { IFS= read -r instances_json; IFS= read -r stages_json; IFS= read -r checks_json; } < "$rows"
    mapfile -d '' -t instances < <(python3 -c 'import json,sys; [sys.stdout.buffer.write(str(x).encode()+b"\0") for x in json.loads(sys.argv[1])]' "$instances_json")
    mapfile -d '' -t CANARY_STAGES < <(python3 -c 'import json,sys; [sys.stdout.buffer.write(str(x).encode()+b"\0") for x in json.loads(sys.argv[1])]' "$stages_json")
    mapfile -t checks < <(python3 -c 'import json,sys; [print(json.dumps(x)) for x in json.loads(sys.argv[1])]' "$checks_json")
    case $strategy in
        rolling) if deploy_rolling "$release_dir" "${instances[@]}"; then :; else rc=$?; fi;;
        blue-green) if deploy_blue_green "$release_dir"; then :; else rc=$?; fi;;
        canary) if deploy_canary "$release_dir"; then :; else rc=$?; fi;;
    esac
    if ((rc != 0)); then manifest_engine hooks "$MANIFEST_JSON" on_failure "$release_dir" || :; return "$rc"; fi
    (cd -- "$release_dir" && advanced_health_check "${checks[@]}") || return 1
    manifest_engine hooks "$MANIFEST_JSON" post_deploy "$release_dir" || return 1
    cleanup_old_releases "$root" "$(manifest_get deployment.keep_releases 5)" || return 1
    # Adapter receives validated service/notification/environment fields, never executable assignments.
    require_adapter finish_manifest_adapters || return 2
    finish_manifest_adapters "$MANIFEST_JSON" "$release_dir"
)
```

---

## 9. Implementation Exercises

### Exercise 1: Docker Deployment

```bash
# Implement deployment for Docker containers
deploy_docker_container() {
    local image="$1"
    local container_name="$2"
    local port_mapping="$3"
    
    # TODO: Implement:
    # 1. Pull new image
    # 2. Stop old container
    # 3. Rename for rollback
    # 4. Start new container
    # 5. Health check
    # 6. Cleanup old container if OK
    :
}
```

### Exercise 2: Multi-Environment

```bash
# Implement support for multiple environments
deploy_to_environment() {
    local env="$1"  # dev, staging, production
    local source="$2"
    
    # TODO: Implement:
    # 1. Load environment-specific config
    # 2. Validate source compatibility
    # 3. Deployment with specific settings
    # 4. Differentiated notifications
    :
}
```

### Exercise 3: A/B Testing Deployment

```bash
# Implement deployment for A/B testing
deploy_ab_test() {
    local variant_a="$1"
    local variant_b="$2"
    local traffic_split="$3"  # e.g.: "50:50"
    
    # TODO: Implement:
    # 1. Deploy both variants
    # 2. Configure load balancer for split
    # 3. Monitor metrics per variant
    # 4. Dashboard for comparison
    :
}
```

### Exercise 4: GitOps Integration

```bash
# Implement deployment trigger from Git webhook
handle_git_webhook() {
    local payload="$1"
    
    # TODO: Implement:
    # 1. Parse payload (GitHub/GitLab)
    # 2. Verify branch/tag
    # 3. Trigger automatic deployment
    # 4. Update status in Git
    :
}
```

### Exercise 5: Deployment Metrics

```bash
# Implement metrics collection and reporting
collect_deployment_metrics() {
    local release_id="$1"
    
    # TODO: Implement:
    # 1. Deployment duration
    # 2. Number of errors in first 5 minutes
    # 3. Average latency post-deploy
    # 4. Export to Prometheus/Grafana
    :
}
```

---

## Conclusions

The Deployer project demonstrates the implementation of explicit deployment algorithms and local release transactions. Key points:

1. **Multiple Strategies** - support for different deployment scenarios
2. **Safety** - health checks and automatic rollback
3. **Flexibility** - hooks for customisation
4. **Automation** - manifest-based deployment
5. **Observability** - logging and metrics

The system can be extended for:
- Kubernetes integration
- Complete CI/CD pipelines
- Multi-cloud deployment
- Advanced canary analysis with ML
- GitOps and Infrastructure as Code
