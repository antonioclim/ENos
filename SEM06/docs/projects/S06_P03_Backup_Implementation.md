# Backup Project - Detailed Implementation

## Executable contracts and recovery limits

The repository programme is `SEM06/scripts/projects/backup/backup.sh`, with `lib/core.sh`, `lib/utils.sh` and `lib/config.sh`. Its CLI is available through `--help`; for example, from `SEM06`, `bash scripts/projects/backup/backup.sh --source /owned/source --dest /owned/backups --type full --incremental`, followed by `--type daily --incremental`. Restore uses `--restore ARCHIVE --restore-dir EMPTY_DIRECTORY`. The subcommand API taught below belongs to a separately extracted reference implementation; it is not an alternative spelling of the repository CLI.

Use owned, quiescent source trees and a destination outside every source. GNU tar incremental metadata records directory deletions and renames; restoration must apply the complete parent chain with `--listed-incremental=/dev/null`. A saved checksum establishes byte equality against that record, not publisher authenticity. The examples assume trusted locally produced archives; importing arbitrary archives requires a separate path/link and resource-limit validation policy. No example authorises writing to live directories.

Retention values below are illustrative parameters. The caller chooses them explicitly for the dataset; the lesson does not adopt an institutional retention policy. A complete chain, including its full base and checksum/metadata sidecars, is the unit of retention.

## Contents

1. [General Overview](#1-general-overview)
2. [System Architecture](#2-system-architecture)
3. [Core Module - backup_core.sh](#3-core-module---backup_coresh)
4. [Utilities Module - backup_utils.sh](#4-utilities-module---backup_utilssh)
5. [Configuration Module - backup_config.sh](#5-configuration-module---backup_configsh)
6. [Main Script - backup.sh](#6-main-script---backupsh)
7. [Backup Strategies](#7-backup-strategies)
8. [Verification and Restoration](#8-verification-and-restoration)
9. [Implementation Exercises](#9-implementation-exercises)

---

## 1. General Overview

### 1.1 Project Purpose

The **Backup** project implements a complete backup and restoration system, offering:

- **Full Backup**: Complete archiving of specified sources
- **Incremental Backup**: Only files modified since the last backup
- **Multiple Compression**: Support for gzip, bzip2, xz, zstd
- **Integrity Verification**: Checksums MD5, SHA1, SHA256
- **Automatic Rotation**: Retention policies (daily, weekly, monthly)
- **Selective Restoration**: Complete or partial extraction
- **Pattern Exclusions**: Glob and regex support for exclusions

### 1.2 File Structure

```
projects/backup/
├── backup.sh               # Main script (~900 lines)
├── lib/
│   ├── backup_core.sh      # Backup/restore functions (~700 lines)
│   ├── backup_utils.sh     # Common utilities (~500 lines)
│   └── backup_config.sh    # Configuration management (~400 lines)
└── config/
    └── backup.conf         # Default configuration
```

### 1.3 Data Flow

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           BACKUP WORKFLOW                                 │
│                                                                          │
│  ┌─────────┐     ┌─────────────┐     ┌────────────┐     ┌─────────────┐  │
│  │ Sources │────▶│ Exclusions  │────▶│ Archiving  │────▶│ Compression │  │
│  │ /home   │     │  *.log      │     │ tar -cvf   │     │ gzip/xz     │  │
│  │ /etc    │     │  node_mod*  │     │            │     │             │  │
│  └─────────┘     └─────────────┘     └────────────┘     └─────────────┘  │
│                                                                │         │
│                                                                ▼         │
│  ┌─────────────┐     ┌─────────────┐     ┌────────────┐  ┌──────────┐   │
│  │ Metadata    │◀────│ Checksum    │◀────│ Manifest   │◀─│ Archive  │   │
│  │ .meta file  │     │ SHA256      │     │ file list  │  │ .tar.gz  │   │
│  └─────────────┘     └─────────────┘     └────────────┘  └──────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 2. System Architecture

### 2.1 Component Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           backup.sh (Main)                               │
├─────────────────────────────────────────────────────────────────────────┤
│  main() ─┬─ parse_arguments()                                           │
│          ├─ load_config()                                               │
│          ├─ validate_sources()                                          │
│          └─ execute_action()                                            │
│                  │                                                       │
│         ┌───────┴────────┬─────────────────┬──────────────────┐         │
│         ▼                ▼                 ▼                  ▼         │
│    do_backup()     do_restore()     do_verify()        do_list()       │
└─────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_core.sh                                    │
├──────────────────────────────────────────────────────────────────────────┤
│  create_archive()          extract_archive()         verify_archive()    │
│  create_incremental()      extract_selective()       verify_checksum()   │
│  compress_archive()        list_archive()            generate_checksum() │
│  apply_rotation()          find_latest_backup()      compare_checksums() │
└──────────────────────────────────────────────────────────────────────────┘
              │                │                │
              ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         backup_utils.sh                                   │
├──────────────────────────────────────────────────────────────────────────┤
│  log_message()       format_bytes()         get_timestamp()              │
│  log_progress()      format_duration()      is_incremental_mode()        │
│  create_lockfile()   human_readable_size()  get_compression_ext()        │
│  remove_lockfile()   calculate_size()       estimate_compression()       │
└──────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Archive Naming Conventions

The system uses a consistent convention for archive names:

```
<prefix>_<type>_<timestamp>.<ext>

Examples:
  backup_full_20240115_143022.tar.gz      # Full backup
  backup_incr_20240115_143022.tar.gz      # Incremental backup
  backup_full_20240115_143022.tar.gz.sha256   # Checksum
  backup_full_20240115_143022.meta        # Metadata
  backup_full_20240115_143022.manifest    # File list
```

### 2.3 Backup Directory Structure

```
/var/backups/mybackup/
├── daily/                    # Daily backups
│   ├── backup_full_20240115_020000.tar.gz
│   ├── backup_incr_20240116_020000.tar.gz
│   └── ...
├── weekly/                   # Weekly backups
│   ├── backup_full_20240108_030000.tar.gz
│   └── ...
├── monthly/                  # Monthly backups
│   ├── backup_full_20240101_040000.tar.gz
│   └── ...
├── latest -> daily/backup_full_20240115_020000.tar.gz  # Symlink
└── .state/                   # State for incremental
    ├── snapshot.snar         # GNU tar snapshot
    └── last_backup.timestamp # Last backup timestamp
```

---

## 3. Core Module - backup_core.sh

### 3.1 The create_archive() Function

Save this complete local engine as `lib/backup_reference.py`. Bash retains configuration, orchestration, hooks and reporting; Python performs exact pathname handling, standard JSON serialisation and atomic state-file replacement while invoking GNU tar with an argument vector. Each build uses a fresh staging directory and a separate snapshot. `.chain.json` advances only after archive verification/publication. This covers ordinary command failure, not crash durability of a multi-file transaction. A failed publication can leave an unreferenced generation for inspection, while the previous state pointer remains authoritative.

```python
#!/usr/bin/env python3
"""Local teaching backup engine: GNU tar, explicit chains and owned destinations.

Sources must be quiescent for a consistent backup. Publication is failure-checked,
not a multi-file crash-durable transaction. Test fixtures never contain live data.
"""
import argparse
import csv
import datetime as dt
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import uuid

EXTENSIONS = { 'none': '.tar', 'gzip': '.tar.gz', 'bzip2': '.tar.bz2', 'xz': '.tar.xz', 'zstd': '.tar.zst' }
SIDECARS = ('.sha256', '.sha512', '.sha1', '.md5', '.meta.json', '.parent', '.manifest')


def atomic_text(path, text):
    fd, temporary = tempfile.mkstemp(prefix='.state.', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as output: output.write(text); output.flush(); os.fsync(output.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary): os.unlink(temporary)


def digest(path, algorithm='sha256'):
    if algorithm not in ('sha256', 'sha512', 'sha1', 'md5'): raise ValueError('Unsupported checksum')
    result = hashlib.new(algorithm)
    with path.open('rb') as source:
        for chunk in iter(lambda: source.read(1024*1024), b''): result.update(chunk)
    return result.hexdigest()


def write_checksum(path, algorithm='sha256'):
    # JSON sidecars name the basename; moving the archive/sidecar pair preserves identity.
    atomic_text(Path(str(path)+'.'+algorithm), json.dumps({'file': path.name, 'digest': digest(path, algorithm)})+'\n')


def verify_checksum(path, algorithm='sha256'):
    sidecar = Path(str(path)+'.'+algorithm)
    if not sidecar.is_file(): raise ValueError('UNVERIFIED: checksum is missing')
    data = json.loads(sidecar.read_text())
    if data.get('file') != path.name or data.get('digest') != digest(path, algorithm): raise ValueError('Checksum mismatch')


def tar_list(path):
    subprocess.run(['tar', '--list', '--file='+str(path)], check=True, stdout=subprocess.DEVNULL)


def archives(root):
    return sorted(p for p in root.rglob('*') if p.is_file() and not p.is_symlink()
                  and any(p.name.endswith(ext) for ext in EXTENSIONS.values()))


def metadata(path):
    data = json.loads(Path(str(path)+'.meta.json').read_text())
    dt.datetime.fromisoformat(data['timestamp'])
    if not isinstance(data['sources'], list) or not data['sources']: raise ValueError('Missing source metadata')
    return data


def chain(target, catalogue):
    by_name = {}
    for archive in catalogue:
        if archive.name in by_name: raise ValueError('Duplicate archive basename')
        by_name[archive.name] = archive
    result, seen, current = [], set(), target
    while True:
        if current.name in seen: raise ValueError('Cycle in backup chain')
        seen.add(current.name); result.append(current)
        parent_path = Path(str(current)+'.parent')
        if not parent_path.is_file(): raise ValueError('Incomplete chain metadata')
        parent = parent_path.read_text().strip()
        if not parent: break
        if Path(parent).name != parent or parent not in by_name: raise ValueError('Missing/invalid chain parent')
        current = by_name[parent]
    result.reverse()
    if metadata(result[0])['type'] != 'full': raise ValueError('Chain has no full base')
    return result


def create(root, kind, sources, compression='gzip', prefix='backup', excludes=(), algorithm='sha256', checksum=True, verify=True):
    if kind not in ('full', 'incremental') or compression not in EXTENSIONS: raise ValueError('Invalid type/compression')
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]*', prefix): raise ValueError('Invalid archive prefix')
    sources = [Path(p).resolve(strict=True) for p in sources]
    if not sources: raise ValueError('No sources')
    root = root.resolve()
    if root == Path('/') or any(root == p or p in root.parents for p in sources):
        raise ValueError('Use a destination outside every source')
    root.mkdir(parents=True, exist_ok=True)
    with (root/'.backup.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        identity = hashlib.sha256(json.dumps([list(map(str,sources)),list(excludes)],sort_keys=True).encode()).hexdigest()
        state_path = root/'.chain.json'
        previous = json.loads(state_path.read_text()) if state_path.exists() else None
        incremental = kind == 'incremental' and previous is not None and previous.get('identity') == identity
        parent = previous['latest'] if incremental else ''
        if incremental:
            catalogue = archives(root)
            candidates = [p for p in catalogue if p.name == parent]
            if len(candidates) != 1: raise ValueError('Latest parent is missing or ambiguous')
            for item in chain(candidates[0], catalogue): verify_checksum(item, metadata(item)['algorithm'])
        # Every chain requires a checksum, including when --no-checksum was requested.
        if not checksum and (kind == 'incremental' or incremental): raise ValueError('Incremental chains require checksums')
        stamp = dt.datetime.now(dt.timezone.utc)
        effective = 'incremental' if incremental else 'full'
        name = f'{prefix}_{effective}_{stamp:%Y%m%d_%H%M%S}_{uuid.uuid4().hex[:10]}{EXTENSIONS[compression]}'
        target = root/name
        with tempfile.TemporaryDirectory(prefix='.build.', dir=root) as temporary:
            stage = Path(temporary); archive = stage/name; snapshot = stage/'snapshot.snar'
            if incremental:
                source_snapshot = root/previous['snapshot']
                if source_snapshot.parent != root or not source_snapshot.is_file(): raise ValueError('Snapshot unavailable')
                shutil.copyfile(source_snapshot, snapshot)
            command = ['tar', '--create', '--file='+str(archive), '--listed-incremental='+str(snapshot)]
            if compression != 'none': command += ['--'+compression]
            command += ['--exclude='+pattern for pattern in excludes]
            command += ['--directory=/', '--']+[str(p).lstrip('/') for p in sources]
            subprocess.run(command, check=True, stdout=sys.stderr)
            tar_list(archive)  # Publication always requires a readable archive structure.
            meta = {'timestamp':stamp.isoformat(), 'type':effective, 'sources':list(map(str,sources)),
                    'algorithm':algorithm, 'checksum':checksum, 'parent':parent}
            (stage/(name+'.meta.json')).write_text(json.dumps(meta)+'\n')
            (stage/(name+'.parent')).write_text(parent+'\n')
            if checksum: write_checksum(archive, algorithm)
            if verify and checksum: verify_checksum(archive, algorithm)
            # Commit complete generation files, then one state pointer.
            snapshot_name = '.snapshot.'+uuid.uuid4().hex
            os.replace(snapshot, root/snapshot_name)
            for member in sorted(stage.iterdir()): os.replace(member, root/member.name)
            atomic_text(state_path, json.dumps({'identity':identity,'latest':name,'snapshot':snapshot_name})+'\n')
            temporary_link = root/('.latest.'+uuid.uuid4().hex)
            try: temporary_link.symlink_to(name); os.replace(temporary_link, root/'latest')
            finally:
                if temporary_link.is_symlink(): temporary_link.unlink()
        # The old snapshot is no longer referenced by committed state.
        if previous and previous.get('snapshot') != snapshot_name:
            old = root/previous.get('snapshot','')
            if old.parent == root and old.name.startswith('.snapshot.') and old.is_file(): old.unlink()
    return target


def restore(root, target, destination, files=()):
    catalogue = archives(root)
    sequence = chain(target, catalogue)
    if destination.exists() and (not destination.is_dir() or any(destination.iterdir())):
        raise ValueError('Restore requires an empty destination')
    for path in sequence:
        data = metadata(path)
        if not data.get('checksum'): raise ValueError('UNVERIFIED: restore needs an explicit verified archive')
        verify_checksum(path, data['algorithm']); tar_list(path)
    # GNU incremental extraction includes deletion records; apply full + every parent in order.
    destination.mkdir(parents=True, exist_ok=True)
    for path in sequence:
        subprocess.run(['tar','--extract','--listed-incremental=/dev/null','--no-same-owner',
                        '--file='+str(path),'--directory='+str(destination)],check=True)
    if files:
        raise ValueError('Selective chain restore: restore to a disposable staging tree, then copy explicitly selected paths')


def select_at(root, instant):
    target = dt.datetime.strptime(instant, '%Y%m%d_%H%M%S').replace(tzinfo=dt.timezone.utc)
    candidates = [(dt.datetime.fromisoformat(metadata(p)['timestamp']), p) for p in archives(root)]
    candidates = [(stamp,p) for stamp,p in candidates if stamp <= target]
    if not candidates: raise ValueError('No recovery point at or before requested time')
    selected = max(candidates)[1]
    chain(selected, archives(root))  # Refuse a missing base before extraction.
    return selected


def rotate(root, daily, weekly, monthly, apply=False):
    if any(n < 0 or n > 10000 for n in (daily,weekly,monthly)): raise ValueError('Invalid retention count')
    catalogue = archives(root)
    groups = {}
    for path in catalogue:
        sequence = chain(path,catalogue); base = sequence[0].name
        groups.setdefault(base,[]).append(path)
    heads = []
    for base, members in groups.items():
        last = max(members,key=lambda p:metadata(p)['timestamp'])
        heads.append((dt.datetime.fromisoformat(metadata(last)['timestamp']),base,members))
    heads.sort(reverse=True,key=lambda row:row[0])
    keep = {}; now = dt.datetime.now(dt.timezone.utc)
    # One newest recovery chain per calendar bucket, with all ancestors retained.
    for tier,count,key in [('daily',daily,lambda t:t.date()),
                            ('weekly',weekly,lambda t:t.isocalendar()[:2]),
                            ('monthly',monthly,lambda t:(t.year,t.month))]:
        selected = set()
        for stamp,base,members in heads:
            if stamp > now: raise ValueError('Future timestamp requires review')
            bucket=key(stamp)
            if bucket not in selected and len(selected)<count:
                selected.add(bucket); keep.setdefault(base,tier)
    state = json.loads((root/'.chain.json').read_text()) if (root/'.chain.json').exists() else None
    if state:
        latest=[p for p in catalogue if p.name==state.get('latest')]
        if len(latest)!=1: raise ValueError('Active chain pointer unavailable')
        keep.setdefault(chain(latest[0],catalogue)[0].name,'daily')
    plans=[]
    for stamp,base,members in heads:
        for path in members:
            tier=keep.get(base); destination=root/tier/path.name if tier else None
            if destination==path: continue
            plans.append({'source':str(path),'destination':str(destination) if destination else None})
            if apply:
                if destination: destination.parent.mkdir(exist_ok=True)
                for suffix in ('',)+SIDECARS:
                    source=Path(str(path)+suffix)
                    if not source.exists(): continue
                    if destination:
                        target=Path(str(destination)+suffix)
                        if target.exists(): raise ValueError('Rotation collision')
                        os.replace(source,target)
                    else: source.unlink()
    if apply and state:
        matches=[p for p in archives(root) if p.name==state['latest']]
        link=root/('.latest.'+uuid.uuid4().hex)
        try: link.symlink_to(matches[0].relative_to(root)); os.replace(link,root/'latest')
        finally:
            if link.is_symlink(): link.unlink()
    return plans


def main():
    parser=argparse.ArgumentParser(description=__doc__); sub=parser.add_subparsers(dest='action',required=True)
    p=sub.add_parser('create'); p.add_argument('root',type=Path); p.add_argument('kind',choices=('full','incremental')); p.add_argument('sources',nargs='+')
    p.add_argument('--compression',default='gzip',choices=EXTENSIONS); p.add_argument('--prefix',default='backup'); p.add_argument('--exclude',action='append',default=[])
    p.add_argument('--algorithm',default='sha256'); p.add_argument('--no-checksum',action='store_true'); p.add_argument('--no-verify',action='store_true')
    p=sub.add_parser('restore'); p.add_argument('root',type=Path); p.add_argument('target',type=Path); p.add_argument('destination',type=Path)
    p=sub.add_parser('at'); p.add_argument('root',type=Path); p.add_argument('instant')
    p=sub.add_parser('rotate'); p.add_argument('root',type=Path); p.add_argument('daily',type=int); p.add_argument('weekly',type=int); p.add_argument('monthly',type=int); p.add_argument('--apply',action='store_true')
    p=sub.add_parser('list'); p.add_argument('root',type=Path); p.add_argument('--format',choices=('human','json','csv'),default='human'); p.add_argument('--latest',action='store_true')
    p=sub.add_parser('verify'); p.add_argument('archive',type=Path)
    args=parser.parse_args()
    if args.action=='create': print(create(args.root,args.kind,args.sources,args.compression,args.prefix,args.exclude,args.algorithm,not args.no_checksum,not args.no_verify))
    elif args.action=='restore': restore(args.root,args.target,args.destination)
    elif args.action=='at': print(select_at(args.root,args.instant))
    elif args.action=='rotate': print(json.dumps(rotate(args.root,args.daily,args.weekly,args.monthly,args.apply),indent=2))
    elif args.action=='verify': verify_checksum(args.archive,metadata(args.archive)['algorithm']); tar_list(args.archive)
    elif args.action=='list':
        rows=[dict(path=str(p),size=p.stat().st_size,**metadata(p)) for p in archives(args.root)]
        rows.sort(key=lambda r:r['timestamp'],reverse=True)
        if args.latest: rows=rows[:1]
        if args.format=='json': print(json.dumps({'backups':rows},ensure_ascii=False))
        elif args.format=='csv':
            writer=csv.writer(sys.stdout); writer.writerow(('path','type','timestamp','size'))
            for row in rows: writer.writerow([row[k] for k in ('path','type','timestamp','size')])
        else:
            for row in rows: print(f"{row['timestamp']} {row['type']} {row['size']} {row['path']}")


if __name__=='__main__':
    try: main()
    except (OSError,ValueError,KeyError,subprocess.CalledProcessError) as error:
        print(error,file=sys.stderr); raise SystemExit(1)
```

The Bash wrapper below preserves the chapter API and prints only the completed archive pathname to stdout. Diagnostics go to stderr. Each explicit full backup starts a new chain; an incremental request without a compatible base creates a full checkpoint.


This is the main function for creating backups:

```bash
backup_engine() {
    python3 "${BACKUP_ENGINE_PATH:-${LIB_DIR:?Set LIB_DIR}/backup_reference.py}" "$@"
}
create_archive() {
    local kind=${1:-full} destination=${2:-} source exclusions pattern external
    shift 2
    (($# > 0)) || return 2
    destination=${destination:-$(get_config backup_destination '')}
    [[ -n $destination ]] || return 2
    local -a command=(create "$destination" "$kind" "$@"
        --compression "$(get_config compression gzip)" --prefix "$(get_config backup_prefix backup)"
        --algorithm "$(get_config checksum_algorithm sha256)")
    exclusions=$(get_config exclude_patterns '')
    local -a patterns=()
    IFS=',' read -ra patterns <<< "$exclusions"
    for pattern in "${patterns[@]}"; do [[ -z $pattern ]] || command+=(--exclude "$pattern"); done
    external=$(get_config exclude_file '')
    if [[ -n $external ]]; then
        [[ -r $external ]] || return 2
        while IFS= read -r pattern || [[ -n $pattern ]]; do
            [[ -z $pattern || $pattern == \#* ]] || command+=(--exclude "$pattern")
        done < "$external"
    fi
    [[ $(get_config generate_checksum true) == true ]] || command+=(--no-checksum)
    [[ $(get_config verify_after_backup true) == true ]] || command+=(--no-verify)
    backup_engine "${command[@]}"
}
```

### 3.2 The create_exclude_file() Function

Generates a temporary file with exclusion patterns:

```bash
# For a caller that needs a GNU tar --exclude-from file. The caller owns/removes it.
create_exclude_file() (
    local output patterns pattern external
    output=$(mktemp) || return 1
    trap 'rm -f -- "$output"' EXIT
    patterns=$(get_config exclude_patterns '')
    local -a items=()
    IFS=',' read -ra items <<< "$patterns"
    for pattern in "${items[@]}"; do
        [[ -z $pattern ]] || printf '%s\n' "$pattern" >> "$output" || return 1
    done
    external=$(get_config exclude_file '')
    if [[ -n $external ]]; then cat -- "$external" >> "$output" || return 1; fi
    printf '%s\n' "$output"
    trap - EXIT  # Ownership transfers to the successful caller only.
)
```

### 3.3 The apply_rotation() Function

Implements the grandfather-father-son rotation policy:

```bash
# Calendar-bucket GFS: newest complete chain in each of N daily/weekly/monthly buckets.
# All tiers are scanned on every run; dependencies and the current chain are protected.
apply_rotation() {
    local root=$1
    local -a command=(rotate "$root" "$(get_config rotation_daily 7)"
        "$(get_config rotation_weekly 4)" "$(get_config rotation_monthly 12)")
    [[ $(get_config dry_run false) == true ]] || command+=(--apply)
    backup_engine "${command[@]}"
}
```

### 3.4 The extract_archive() Function

Restores a backup completely or selectively:

```bash
extract_archive() (
    local archive=$1 destination=$2 root stage selected relative
    shift 2
    root=${BACKUP_CATALOGUE_ROOT:-$(dirname -- "$archive")}
    if (($# == 0)); then backup_engine restore "$root" "$archive" "$destination"; return $?; fi
    # Selective restore uses a disposable complete chain first, including deletion records.
    [[ ! -e $destination || -d $destination ]] || return 2
    [[ ! -d $destination || -z $(find "$destination" -mindepth 1 -print -quit) ]] || return 2
    stage=$(mktemp -d) || return 1
    trap 'rm -rf -- "$stage"' EXIT
    backup_engine restore "$root" "$archive" "$stage" || return 1
    for selected in "$@"; do
        [[ $selected != /* && $selected != '..' && $selected != ../* && $selected != */../* && $selected != */.. ]] || return 2
        [[ -e $stage/$selected || -L $stage/$selected ]] || return 2
    done
    mkdir -p -- "$destination" || return 1
    for selected in "$@"; do
        (cd -- "$stage" && cp -a --parents -- "$selected" "$destination") || return 1
    done
)
restore_incremental() {
    local root=$1 destination=$2 target_date=${3:-} archive
    if [[ -n $target_date ]]; then archive=$(backup_engine at "$root" "$target_date") || return 1
    else archive=$(readlink -f -- "$root/latest") || return 1; fi
    BACKUP_CATALOGUE_ROOT=$root extract_archive "$archive" "$destination"
}
```

### 3.5 Verification Functions

```bash
# The reference engine's sidecars are JSON, distinct from coreutils text sidecars.
generate_checksum() {
    python3 - "${BACKUP_ENGINE_PATH:-${LIB_DIR:?}/backup_reference.py}" "$1" "${2:-sha256}" <<'PY'
import importlib.util,pathlib,sys
spec=importlib.util.spec_from_file_location('backup_reference',sys.argv[1]); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
module.write_checksum(pathlib.Path(sys.argv[2]),sys.argv[3])
PY
}
verify_checksum() {
    local archive=$1 algorithm=${2:-} candidate
    if [[ -z $algorithm ]]; then
        for candidate in sha256 sha512 sha1 md5; do
            if [[ -f $archive.$candidate ]]; then algorithm=$candidate; break; fi
        done
    fi
    [[ -n $algorithm ]] || { printf 'UNVERIFIED: no checksum for %s\n' "$archive" >&2; return 2; }
    python3 - "${BACKUP_ENGINE_PATH:-${LIB_DIR:?}/backup_reference.py}" "$archive" "$algorithm" <<'PY'
import importlib.util,pathlib,sys
spec=importlib.util.spec_from_file_location('backup_reference',sys.argv[1]); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
try: module.verify_checksum(pathlib.Path(sys.argv[2]),sys.argv[3])
except (OSError,ValueError) as error: print(error,file=sys.stderr); raise SystemExit(1)
PY
}
verify_archive() {
    local archive=$1
    verify_structure "$archive" || return 1
    verify_checksum "$archive" || return 1
}
generate_manifest() (
    local archive=$1 temporary
    temporary=$(mktemp "$(dirname -- "$archive")/.manifest.XXXXXX") || return 1
    trap 'rm -f -- "$temporary"' EXIT
    tar --list --verbose --file="$archive" > "$temporary" || return 1
    mv -- "$temporary" "$archive.manifest"
)
```

---

## 4. Utilities Module - backup_utils.sh

### 4.1 Progress and Logging Functions

```bash
# Variables for progress tracking
declare -g PROGRESS_PID=""
declare -g PROGRESS_ACTIVE=false

# Display progress spinner
show_progress() {
    local message="${1:-Working...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    PROGRESS_ACTIVE=true
    
    while $PROGRESS_ACTIVE; do
        printf "\r  %s %s" "${spin:i++%${#spin}:1}" "$message"
        sleep 0.1
    done
    
    printf "\r%*s\r" $((${#message} + 4)) ""
}

# Start progress in background
start_progress() {
    local message="$1"
    
    show_progress "$message" &
    PROGRESS_PID=$!
}

# Stop progress
stop_progress() {
    if [[ -n "$PROGRESS_PID" ]]; then
        PROGRESS_ACTIVE=false
        kill "$PROGRESS_PID" 2>/dev/null
        wait "$PROGRESS_PID" 2>/dev/null
        PROGRESS_PID=""
        printf "\r%*s\r" 60 ""
    fi
}

# Progress bar for known operations
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local prefix="${4:-Progress}"
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=""
    bar+=$(printf '%*s' "$filled" '' | tr ' ' '#')
    bar+=$(printf '%*s' "$empty" '' | tr ' ' '-')
    
    printf "\r%s: [%s] %3d%% (%d/%d)" \
        "$prefix" "$bar" "$percent" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Log with timestamp and level
log_message() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local color=""
    case "$level" in
        DEBUG)    color="\e[36m" ;;
        INFO)     color="\e[32m" ;;
        WARNING)  color="\e[33m" ;;
        ERROR)    color="\e[31m" ;;
        CRITICAL) color="\e[1;31m" ;;
    esac
    
    local log_line="[$timestamp] [$level] $message"
    
    # Write to log file
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "$log_line" >> "$LOG_FILE"
    fi
    
    # Display to terminal
    if [[ -t 2 ]]; then
        printf "%b%s\e[0m\n" "$color" "$log_line" >&2
    else
        echo "$log_line" >&2
    fi
}
```

### 4.2 Formatting and Calculation Functions

```bash
# Format bytes to human readable
format_bytes() {
    python3 - "${1:-0}" "${2:-2}" <<'PY'
import sys
from decimal import Decimal
try:
    raw,precision=sys.argv[1:]; precision=int(precision)
    if not raw.isdigit() or not 0<=precision<=8: raise ValueError()
    value=Decimal(raw); units=('B','KiB','MiB','GiB','TiB','PiB'); unit=0
    while value>=1024 and unit<len(units)-1: value/=1024; unit+=1
    print(f'{value:.{precision}f} {units[unit]}',end='')
except ValueError: raise SystemExit(2)
PY
}

# Format duration
format_duration() {
    local seconds="${1:-0}"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm %ds" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
    fi
}

# Calculate total source size
calculate_source_size() {
    local -a sources=("$@")
    local total_size=0
    
    for src in "${sources[@]}"; do
        if [[ -e "$src" ]]; then
            local size
            size=$(du -sb -- "$src" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
        fi
    done
    
    echo "$total_size"
}

# Estimate compression ratio
estimate_compression_ratio() {
    local compression="${1:-gzip}"
    
    # Illustrative planning inputs only, not measured or generally typical ratios.
    # Real ratios depend on the source corpus and must be measured before sizing storage.
    case "$compression" in
        none)  echo "1.0" ;;
        gzip)  echo "0.4" ;;  # ~60% reduction
        bzip2) echo "0.35" ;; # ~65% reduction
        xz)    echo "0.30" ;; # ~70% reduction
        zstd)  echo "0.35" ;; # ~65% reduction
    esac
}

# Get extension based on compression
get_compression_extension() {
    local compression="${1:-gzip}"
    
    case "$compression" in
        none)  echo "" ;;
        gzip)  echo ".gz" ;;
        bzip2) echo ".bz2" ;;
        xz)    echo ".xz" ;;
        zstd)  echo ".zst" ;;
        *)     echo ".gz" ;;
    esac
}
```

### 4.3 Lock and Concurrency Functions

```bash
declare -g LOCK_FILE='' LOCK_FD='' TEMP_DIR=''
create_lockfile() {
    local name=${1:-backup}
    [[ $name =~ ^[A-Za-z0-9_-]+$ ]] || return 2
    : "${BACKUP_LOCK_DIR:?Set an existing owned lock directory}"
    [[ -d $BACKUP_LOCK_DIR ]] || return 2
    LOCK_FILE=$BACKUP_LOCK_DIR/$name.lock
    exec {LOCK_FD}>>"$LOCK_FILE" || return 1
    if flock -n "$LOCK_FD"; then return 0; fi
    exec {LOCK_FD}>&-; LOCK_FD=''; return 1
}
remove_lockfile() {
    if [[ -n $LOCK_FD ]]; then exec {LOCK_FD}>&-; LOCK_FD=''; fi
    # Persistent pathname: never unlink a lock used by other contenders.
    return 0
}
setup_cleanup_handler() {
    trap cleanup_on_exit EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
}
cleanup_on_exit() {
    local rc=$?
    stop_progress || :
    remove_lockfile || :
    if [[ -n $TEMP_DIR ]]; then rm -rf -- "$TEMP_DIR"; fi
    return "$rc"
}
```

---

## 5. Configuration Module - backup_config.sh

### 5.1 Configuration Structure

```bash
# Global variables for configuration
declare -A CONFIG
declare -g CONFIG_FILE=""

# Default values
set_defaults() {
    # Destination and prefix
    CONFIG[backup_destination]="/var/backups"
    CONFIG[backup_prefix]="backup"
    
    # Compression
    CONFIG[compression]="gzip"
    CONFIG[compression_level]="6"
    
    # Rotation
    CONFIG[rotation_enabled]="true"
    CONFIG[rotation_daily]="7"
    CONFIG[rotation_weekly]="4"
    CONFIG[rotation_monthly]="12"
    
    # Verification
    CONFIG[checksum_algorithm]="sha256"
    CONFIG[verify_after_backup]="true"
    
    # Exclusions
    CONFIG[exclude_patterns]="*.tmp,*.log,*.cache,node_modules,__pycache__"
    
    # Logging
    CONFIG[log_level]="INFO"
    CONFIG[log_file]="/var/log/backup.log"
    
    # Options
    CONFIG[verbose]="false"
    CONFIG[dry_run]="false"
    CONFIG[force]="false"
    CONFIG[generate_checksum]="true"
    CONFIG[exclude_file]=""
    CONFIG[backup_sources]=""
    CONFIG[output_format]="human"
    CONFIG[show_latest_only]="false"
    
    # Hooks
    CONFIG[pre_backup_hook]=""
    CONFIG[post_backup_hook]=""
    CONFIG[on_error_hook]=""
}
```

### 5.2 Loading and Parsing

```bash
load_config() {
    local config_file="${1:-}"
    
    # Set default values first
    set_defaults
    CONFIG_FILE=""
    [[ -z $config_file || -r $config_file ]] || return 2
    # Search for configuration file
    local search_paths=(
        "$config_file"
        "${HOME}/.config/backup/backup.conf"
        "${HOME}/.backup.conf"
        "/etc/backup/backup.conf"
        "${SCRIPT_DIR}/config/backup.conf"
    )
    
    for path in "${search_paths[@]}"; do
        [[ -z "$path" ]] && continue
        
        if [[ -f "$path" && -r "$path" ]]; then
            CONFIG_FILE="$path"
            log_info "Loading configuration: $CONFIG_FILE"
            break
        fi
    done
    
    # Parse file if it exists
    if [[ -n "$CONFIG_FILE" ]]; then
        parse_config_file "$CONFIG_FILE" || return 2
    else
        log_warning "No configuration file found, using default values"
    fi
    
    # Validate configuration
    validate_config
}

parse_config_file() {
    local file="$1"
    local line_num=0
    local current_section=""
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))
        
        # Remove whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        
        # Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^[#\;] ]] && continue
        
        # Detect sections [section]
        if [[ "$line" =~ ^\[([^\]]+)\]$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            continue
        fi
        
        # Parse key=value
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Add section prefix if exists
            if [[ -n "$current_section" ]]; then
                key="${current_section}_${key}"
            fi
            
            # Literal data with optional matching outer quotes; never evaluate values.
            if [[ $value == \"* || $value == \'* ]]; then
                local quote=${value:0:1}
                [[ ${#value} -ge 2 && ${value: -1} == "$quote" ]] || return 2
                value=${value:1:${#value}-2}
            fi
            [[ -v CONFIG[$key] ]] || { log_error "Unknown configuration key: $key"; return 2; }

            CONFIG["$key"]="$value"
            log_debug "Config: $key = $value"
        else
            log_error "Invalid configuration line $line_num"
            return 2
        fi
    done < "$file"
}

validate_config() {
    local errors=0
    
    # Validate compression
    local compression="${CONFIG[compression]}"
    case "$compression" in
        none|gzip|bzip2|xz|zstd) ;;
        *)
            log_error "Invalid compression: $compression"
            errors=$((errors + 1))
            ;;
    esac
    
    # Validate compression level
    local level="${CONFIG[compression_level]}"
    if ! [[ "$level" =~ ^[0-9]$ ]]; then
        log_error "Invalid compression level: $level (must be 0-9)"
        errors=$((errors + 1))
    fi
    
    # Validate checksum algorithm
    local algorithm="${CONFIG[checksum_algorithm]}"
    case "$algorithm" in
        md5|sha1|sha256|sha512) ;;
        *)
            log_error "Invalid checksum algorithm: $algorithm"
            errors=$((errors + 1))
            ;;
    esac
    
    # Validate rotation
    for key in rotation_daily rotation_weekly rotation_monthly; do
        local val="${CONFIG[$key]}"
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            log_error "Invalid $key: $val"
            errors=$((errors + 1))
        fi
    done
    
    return $((errors > 0 ? 1 : 0))
}

# Configuration access
get_config() {
    local key="$1"
    local default="${2:-}"
    
    if [[ -n "${CONFIG[$key]+isset}" ]]; then
        echo "${CONFIG[$key]}"
    else
        echo "$default"
    fi
}

set_config() {
    local key="$1"
    local value="$2"
    CONFIG["$key"]="$value"
}
```

---

## 6. Main Script - backup.sh

### 6.1 General Structure

```bash
#!/usr/bin/env bash
#
# backup.sh - Enterprise Backup Solution
# CAPSTONE Project - Operating Systems
#

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.0.0"

readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"

# Load modules
source "${LIB_DIR}/backup_utils.sh"
source "${LIB_DIR}/backup_config.sh"
source "${LIB_DIR}/backup_core.sh"

# Setup cleanup
setup_cleanup_handler
```

### 6.2 Argument Parsing

```bash
# Variables for arguments
declare -g ACTION=""
declare -a SOURCES=()
declare -g DESTINATION=""
declare -g BACKUP_TYPE="full"
declare -g ARCHIVE_PATH=""
declare -g RESTORE_PATH=""
declare -a RESTORE_FILES=()

show_help() {
    cat <<EOF
Usage: $SCRIPT_NAME <action> [options] [sources...]

Actions:
  backup       Create a new backup
  restore      Restore from a backup
  verify       Verify backup integrity
  list         List existing backups
  rotate       Manually apply rotation policy

General options:
  -h, --help                Display this message
  -V, --version             Display version
  -c, --config FILE         Use specific configuration file
  -v, --verbose             Verbose mode
  -n, --dry-run             Simulation without changes
  -f, --force               Force operation

Backup options:
  -d, --destination DIR     Destination directory for backup
  -t, --type TYPE           Backup type: full, incremental (default: full)
  -z, --compression ALG     Compression: none, gzip, bzip2, xz, zstd
  -e, --exclude PATTERN     Exclusion pattern (can be repeated)
  --no-checksum             Don't generate checksum
  --no-verify               Don't verify after backup

Restore options:
  -a, --archive FILE        Archive to restore
  -o, --output DIR          Restoration directory (default: .)
  --files FILE [FILE...]    Specific files to restore

List options:
  --format FORMAT           Format: human, json, csv (default: human)
  --latest                  Show only the most recent backup

Examples:
  $SCRIPT_NAME backup -d /backups /home /etc
  $SCRIPT_NAME backup -t incremental -d /backups /home
  $SCRIPT_NAME restore -a /backups/backup_full_20240115.tar.gz -o /tmp/restore
  $SCRIPT_NAME restore -a backup.tar.gz --files home/user/docs
  $SCRIPT_NAME verify -a /backups/backup_full_20240115.tar.gz
  $SCRIPT_NAME list -d /backups --format json

EOF
}

parse_arguments() {
    [[ $# -eq 0 ]] && { show_help; exit 0; }
    
    # First argument is the action
    ACTION="$1"
    shift
    
    case "$ACTION" in
        backup|restore|verify|list|rotate|help)
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -V|--version)
            echo "$SCRIPT_NAME version $VERSION"
            exit 0
            ;;
        *)
            log_error "Unknown action: $ACTION"
            show_help
            exit 1
            ;;
    esac
    
    # Parse remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config|-d|--destination|-t|--type|-z|--compression|-e|--exclude|-a|--archive|-o|--output|--format)
                [[ $# -ge 2 && -n $2 ]] || { log_error "Missing value for $1"; return 2; };;
        esac
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--destination)
                DESTINATION="$2"
                shift 2
                ;;
            -t|--type)
                BACKUP_TYPE="$2"
                shift 2
                ;;
            -z|--compression)
                set_config "compression" "$2"
                shift 2
                ;;
            -e|--exclude)
                local current
                current=$(get_config "exclude_patterns" "")
                set_config "exclude_patterns" "${current:+$current,}$2"
                shift 2
                ;;
            -a|--archive)
                ARCHIVE_PATH="$2"
                shift 2
                ;;
            -o|--output)
                RESTORE_PATH="$2"
                shift 2
                ;;
            -v|--verbose)
                set_config "verbose" "true"
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -n|--dry-run)
                set_config "dry_run" "true"
                shift
                ;;
            -f|--force)
                set_config "force" "true"
                shift
                ;;
            --no-checksum)
                set_config "generate_checksum" "false"
                shift
                ;;
            --no-verify)
                set_config "verify_after_backup" "false"
                shift
                ;;
            --files)
                shift
                while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                    RESTORE_FILES+=("$1")
                    shift
                done
                ;;
            --format)
                set_config "output_format" "$2"
                shift 2
                ;;
            --latest)
                set_config "show_latest_only" "true"
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                # Positional arguments are sources for backup
                SOURCES+=("$1")
                shift
                ;;
        esac
    done
}
```

### 6.3 Action Execution

```bash
execute_action() {
    if [[ $(get_config dry_run false) == true ]]; then
        printf '[DRY RUN] action=%q destination=%q archive=%q restore=%q\n' "$ACTION" "$DESTINATION" "$ARCHIVE_PATH" "$RESTORE_PATH"
        printf '[DRY RUN] source=%q\n' "${SOURCES[@]}"
        return 0  # Before locks, hooks, mkdir, logging destinations, restore or rotation.
    fi
    case "$ACTION" in
        backup)
            do_backup
            ;;
        restore)
            do_restore
            ;;
        verify)
            do_verify
            ;;
        list)
            do_list
            ;;
        rotate)
            do_rotate
            ;;
        help)
            show_help
            ;;
    esac
}

do_backup() {
    # Validations
    if [[ ${#SOURCES[@]} -eq 0 ]]; then
        # Try to get sources from configuration
        local config_sources
        config_sources=$(get_config "backup_sources" "")
        
        if [[ -n "$config_sources" ]]; then
            IFS=',' read -ra SOURCES <<< "$config_sources"
        else
            log_error "No sources specified for backup!"
            exit 1
        fi
    fi
    
    # Verify sources exist
    for src in "${SOURCES[@]}"; do
        if [[ ! -e "$src" ]]; then
            log_error "Source does not exist: $src"
            exit 1
        fi
    done
    
    # Destination
    if [[ -z "$DESTINATION" ]]; then
        DESTINATION=$(get_config "backup_destination" "/var/backups")
    fi
    
    # Obtain lock
    create_lockfile "backup" || exit 1
    
    # Execute pre-hook
    local pre_hook
    pre_hook=$(get_config "pre_backup_hook" "")
    if [[ -n "$pre_hook" && -x "$pre_hook" ]]; then
        log_info "Executing pre-backup hook: $pre_hook"
        "$pre_hook" || {
            log_error "Pre-backup hook failed!"
            exit 1
        }
    fi
    
    # Dry run?
    if [[ "$(get_config 'dry_run' 'false')" == "true" ]]; then
        log_info "[DRY RUN] Would create backup:"
        log_info "  Type: $BACKUP_TYPE"
        log_info "  Sources: ${SOURCES[*]}"
        log_info "  Destination: $DESTINATION"
        log_info "  Compression: $(get_config 'compression' 'gzip')"
        exit 0
    fi
    
    # Create the backup
    local result
    local exit_code=0
    if result=$(create_archive "$BACKUP_TYPE" "$DESTINATION" "${SOURCES[@]}"); then :; else exit_code=$?; fi
    
    if [[ $exit_code -eq 0 ]]; then
        # Execute post-hook
        local post_hook
        post_hook=$(get_config "post_backup_hook" "")
        if [[ -n "$post_hook" && -x "$post_hook" ]]; then
            export BACKUP_FILE="$result"
            log_info "Executing post-backup hook: $post_hook"
            "$post_hook" || log_warning "Post-backup hook failed"
        fi
        
        if [[ $(get_config rotation_enabled false) == true ]]; then apply_rotation "$DESTINATION" || return 1; fi
        log_info "Backup created successfully: $result"
    else
        # Execute error hook
        local error_hook
        error_hook=$(get_config "on_error_hook" "")
        if [[ -n "$error_hook" && -x "$error_hook" ]]; then
            log_info "Executing error hook: $error_hook"
            "$error_hook" || true
        fi
        
        log_error "Backup failed!"
        exit 1
    fi
}

do_restore() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Archive must be specified with -a/--archive"
        exit 1
    fi
    
    if [[ ! -f "$ARCHIVE_PATH" ]]; then
        log_error "Archive does not exist: $ARCHIVE_PATH"
        exit 1
    fi
    
    [[ -z "$RESTORE_PATH" ]] && RESTORE_PATH="."
    
    log_info "Restoring from: $ARCHIVE_PATH"
    log_info "To: $RESTORE_PATH"
    
    if [[ ${#RESTORE_FILES[@]} -gt 0 ]]; then
        log_info "Selected files: ${RESTORE_FILES[*]}"
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH" "${RESTORE_FILES[@]}"
    else
        extract_archive "$ARCHIVE_PATH" "$RESTORE_PATH"
    fi
}

do_verify() {
    if [[ -z "$ARCHIVE_PATH" ]]; then
        log_error "Archive must be specified with -a/--archive"
        exit 1
    fi
    
    verify_archive "$ARCHIVE_PATH"
}

do_list() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Directory does not exist: $backup_dir"
        exit 1
    fi
    
    local format
    format=$(get_config "output_format" "human")
    
    list_backups "$backup_dir" "$format"
}

list_backups() {
    local -a command=(list "$1" --format "${2:-human}")
    [[ $(get_config show_latest_only false) == true ]] && command+=(--latest)
    backup_engine "${command[@]}"
}

do_rotate() {
    local backup_dir
    backup_dir="${DESTINATION:-$(get_config 'backup_destination' '/var/backups')}"
    
    log_info "Applying manual rotation in: $backup_dir"
    apply_rotation "$backup_dir"
}
```

### 6.4 The Main Function

```bash
main() {
    local -a args=("$@")
    local i config=''
    for ((i=0; i<${#args[@]}; i++)); do
        if [[ ${args[i]} == -c || ${args[i]} == --config ]]; then
            ((i+1 < ${#args[@]})) || return 2
            config=${args[i+1]}
        fi
    done
    load_config "$config" || return 2
    parse_arguments "${args[@]}" || return 2
    validate_config || return 2
    if [[ $(get_config dry_run false) == true ]]; then execute_action; return $?; fi
    LOG_FILE=$(get_config log_file '')
    setup_cleanup_handler
    execute_action
}
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi
```

---

## 7. Backup Strategies

### 7.1 Full vs Incremental Backup

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     FULL BACKUP                                          │
│                                                                          │
│   [Complete Sources] ────────────────────────────▶ [Complete Archive]   │
│                                                                          │
│   Advantages:                    Disadvantages:                          │
│   + Simple restoration           - Long time                             │
│   + Single file                  - Large space                           │
│   + Independent                  - High bandwidth                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                   INCREMENTAL BACKUP                                     │
│                                                                          │
│   Monday:    [FULL] ─────────────────────────────▶ [Full Backup]        │
│   Tuesday:   [Changes Mon→Tue] ──────────────────▶ [Incr1]             │
│   Wednesday: [Changes Tue→Wed] ──────────────────▶ [Incr2]             │
│   ...                                                                    │
│                                                                          │
│   Restore: [Full] + [Incr1] + [Incr2] + ... = [Current State]          │
│                                                                          │
│   Advantages:                    Disadvantages:                          │
│   + Fast                         - Complex restoration                   │
│   + Reduced space                - Depends on chain                      │
│   + Bandwidth efficient          - Corruption risk                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.2 The 3-2-1 Strategy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      THE 3-2-1 RULE                                      │
│                                                                          │
│   3 ─ Three copies of data                                              │
│       ┌──────────┐  ┌──────────┐  ┌──────────┐                          │
│       │ Original │  │ Backup 1 │  │ Backup 2 │                          │
│       └──────────┘  └──────────┘  └──────────┘                          │
│                                                                          │
│   2 ─ On two different types of media                                   │
│       ┌──────────┐  ┌──────────┐                                        │
│       │   SSD    │  │   HDD    │  or NAS, Cloud, Tape                   │
│       └──────────┘  └──────────┘                                        │
│                                                                          │
│   1 ─ One in an off-site location                                       │
│       ┌──────────────────────────────────────┐                          │
│       │  Cloud Storage / Remote Server       │                          │
│       └──────────────────────────────────────┘                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Compression Algorithm Comparison

| Algorithm | Compression Speed | Compression Ratio | CPU Usage | Decompression |
|-----------|-------------------|-------------------|-----------|---------------|
| none      | N/A               | 1:1               | 0%        | N/A           |
| gzip      | Fast              | ~60%              | Medium    | Fast          |
| bzip2     | Medium            | ~65%              | High      | Medium        |
| xz        | Slow              | ~70%              | V. High   | Fast          |
| zstd      | V. Fast           | ~65%              | Medium    | V. Fast       |

---

## 8. Verification and Restoration

### 8.1 Multi-Level Verification

```bash
verify_structure() { tar --list --file="$1" >/dev/null; }
verify_integrity() { verify_checksum "$1"; }
verify_content() (
    local archive=$1 original=$2 temporary rc=0 root_member
    original=$(realpath -- "$original") || return 2
    temporary=$(mktemp -d) || return 1
    trap 'rm -rf -- "$temporary"' EXIT
    extract_archive "$archive" "$temporary" || return 1
    # This engine archives absolute source names relative to /. Compare the matching root.
    root_member=${original#/}
    [[ -e $temporary/$root_member ]] || return 1
    if diff -rq -- "$original" "$temporary/$root_member"; then :; else rc=$?; fi
    return "$rc"
)
```

### 8.2 Point-in-Time Restoration

```bash
restore_to_point_in_time() {
    local root=$1 destination=$2 target_datetime=$3 target
    target=$(backup_engine at "$root" "$target_datetime") || return 1
    BACKUP_CATALOGUE_ROOT=$root extract_archive "$target" "$destination"
}
```

---

## 9. Implementation Exercises

### Exercise 1: Encrypted Backup

```bash
# Implement backup with GPG/OpenSSL encryption
create_encrypted_backup() {
    local archive="$1"
    local passphrase="${2:-}"
    
    # TODO: Implement:
    # 1. Create normal backup
    # 2. Encrypt with openssl or gpg
    # 3. Generate checksum for encrypted file
    # 4. Implement restoration with decryption
    :
}
```

### Exercise 2: Remote Backup

```bash
# Implement backup to remote server via SSH/rsync
remote_backup() {
    local sources=("$@")
    local remote_host="backup-server.example.com"
    local remote_path="/backups"
    
    # TODO: Implement:
    # 1. Create local archive
    # 2. Transfer with rsync --progress
    # 3. Verify transfer (remote checksum)
    # 4. Cleanup local archive (optional)
    :
}
```

### Exercise 3: Notifications

```bash
# Implement notification system
send_notification() {
    local type="$1"      # success, warning, error
    local message="$2"
    local method="$3"    # email, slack, telegram
    
    # TODO: Implement:
    # 1. Format message based on type
    # 2. Send via specified method
    # 3. Log notification
    :
}
```

### Exercise 4: Backup Scheduling

```bash
# Generate crontab configuration
generate_cron_config() {
    local backup_script="$1"
    local schedule_type="${2:-daily}"  # daily, weekly, monthly
    
    # TODO: Implement:
    # 1. Generate correct crontab line
    # 2. Set environment variables
    # 3. Redirect output to log
    # 4. Support for each schedule type
    :
}
```

### Exercise 5: Dashboard and Reporting

```bash
# Generate HTML report for backups
generate_report() {
    local backup_dir="$1"
    local output_file="$2"
    
    # TODO: Implement:
    # 1. Collect statistics (backup count, sizes, successes/failures)
    # 2. Generate graphs (using ASCII or SVG)
    # 3. Export HTML with inline CSS
    # 4. Timeline of recent backups
    :
}
```

---

## Conclusions

The Backup project demonstrates the implementation of an enterprise-grade backup system using Bash. Key points:

1. **Flexibility** - support for multiple backup types and compression
2. **Integrity** - multi-level verification with checksums
3. **Automation** - automatic rotation and hooks for integration
4. **Stability** - error handling and reliable restoration
5. **Extensibility** - modular architecture for future extensions

The system can be extended for:
- Cloud backup (S3, Azure Blob, GCS) — and related to that, block-level deduplication
- End-to-end encryption
- Web interface for management
- Integration with alerting systems

### Technical reference for the corrected examples

For the snapshot and deletion-record contract, see the [GNU tar incremental-dump manual](https://www.gnu.org/software/tar/manual/html_section/Incremental-Dumps.html).
