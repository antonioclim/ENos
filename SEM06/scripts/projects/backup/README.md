# SysBackup — local backup and restore teaching application

SysBackup demonstrates multiple sources, compression, integrity checks, GNU tar incremental chains, graph-aware retention and explicit failure propagation. It is a bounded local tool. Consistent live-database snapshots, remote transport, automatic scheduling and crash-durable multi-file transactions require additional system design.

## Architecture and requirements

`backup.sh` orchestrates separate core/config/utils libraries. `lib/retention.py` validates parent relationships, `lib/validate_archive.py` checks extraction member paths/types and the shared `../config_data.py` parses literal configuration. `bin/sysbackup` invokes the complete project through Bash. Use Bash 4.4+, Python 3.10+, GNU tar, coreutils, awk, find, flock and the selected compressor/checksum tool. Alternative compressors must actually be available; no successful fallback is inferred.

## Complete owned example

From the repository root, run this as one script:

```bash
#!/usr/bin/env bash
set -euo pipefail
SEM06_DIR=$(realpath -- SEM06)
work=
trap '[[ -z ${work:-} ]] || rm -rf -- "$work"' EXIT
work=$(mktemp -d)
mkdir -- "$work/source" "$work/backups" "$work/restored"
printf 'version one\n' > "$work/source/document"
printf 'remove later\n' > "$work/source/obsolete"
printf 'rename later\n' > "$work/source/old-name"
BACKUP_PROGRAM="$SEM06_DIR/scripts/projects/backup/backup.sh"
source "$SEM06_DIR/scripts/examples/backup_examples.sh"
create_full_backup "$work/source" "$work/backups"
printf 'version two\n' > "$work/source/document"
printf 'created later\n' > "$work/source/new"
rm -- "$work/source/obsolete"
mv -- "$work/source/old-name" "$work/source/new-name"
create_incremental_backup "$work/source" "$work/backups"
latest=$(cat -- "$work/backups/.latest")
restore_incremental_chain "$work/backups/$latest" "$work/restored"
diff -r -- "$work/source" "$work/restored/${work#/}/source"
```

The helper uses `/dev/null` as an empty literal configuration, a destination-local lock and `/dev/null` logging unless an explicit BACKUP_CONFIG is supplied. It performs no email or remote transfer. Archives use canonical absolute source paths with the leading slash removed; this keeps multiple roots unambiguous. A destination inside a source and source `/` are refused.

## Supported command contract

Run `bash SEM06/scripts/projects/backup/backup.sh --help` for the current complete list. There is no `create`, `restore` or `rotate` subcommand: use options.

| Operation | Arguments |
|---|---|
| Sources/destination | `--source PATH` repeatable, `--dest PATH`, positional sources |
| Type | `--type auto|daily|weekly|monthly|full` |
| Compression | `--compression gz|gzip|bz2|bzip2|xz|zstd|none|tar` |
| Incremental chain | `--incremental`; explicit full/weekly/monthly start a new base; daily appends to matching current state |
| Retention | `--retention-daily N`, `--retention-weekly N`, `--retention-monthly N` |
| Exclusions/name | `--exclude PATTERN` repeatable; `--prefix NAME` |
| List | `--list --dest DIRECTORY`; emits only archive rows, with JSON-quoted names, byte size and UTC mtime |
| Restore | `--restore ARCHIVE --restore-dir EMPTY_DIRECTORY`; archive may be an exact name under --dest |
| Structural check | `--verify-archive FILE`; this checks tar readability, not a signature |
| Optional checks | `--no-verify`, `--no-checksum`; these weaken independent checks and do not claim equivalent assurance |
| Other | `--config FILE`, `--log-file FILE`, `--log-level LEVEL`, `--verbose`, `--dry-run`, `--email ADDRESS` |

The CLI does not expose JSON/CSV, daemon mode, `--files`, `--debug`, `-q`, `--rotate-by-age`, `--max-age`, `--exclude-file`, `--checksum-algo`, `--force-rotate` or `--verify`. These old README interfaces were not implemented. Scheduling belongs in cron/systemd; `rotate_by_age` remains a library function, not a CLI option.

## Incremental state, retention and recovery

GNU tar records directory changes, including deletion and rename effects. Each archive has a `.parent` link to the previous archive or an empty parent for a full base. Checksums are sidecars. An immutable `.snar` file holds that archive's GNU tar snapshot and `.state.json` atomically selects the next incremental base by archive, snapshot and source identity. Legacy `.snapshot`, `.latest` and `.sources` copies remain for display/compatibility; they are not the authoritative next-increment pointer. An old three-file state without `.state.json` starts a fresh full base.

The active chain and every ancestor of retained points are protected. Retention applies configured counts to complete chain roots matching the type; it does not promote a daily archive into a weekly/monthly archive merely by renaming it. Scheduled weekly/monthly runs create their own bases. `--type full` skips rotation. Missing parents/cycles cause retention to fail before deletion. Archive selection excludes checksum, parent and snapshot sidecars; associated sidecars are removed with a selected complete chain.

Restore validates the complete parent sequence and its checksums before extraction, and rejects a populated or symlink destination. Member validation rejects absolute/parent-traversing paths, escaping symlink targets and unsupported special types. Safe relative links and GNU incremental directory metadata are supported. Quiescent archive files and an owned empty restore directory are preconditions; the check is not protection against a concurrent hostile archive writer. Python tarfile must support the selected compression for member inspection; on older Python versions `.tar.zst` inspection may remain unavailable even if GNU tar can create it, and restore then fails explicitly.

A checksum detects byte disagreement with the sidecar; MD5/SHA1 are retained historical options, with SHA-256 the configured default. None authenticates a source or proves a consistent live-system snapshot. Atomic pointer publication protects normal state selection; fsync-based crash durability across all archive/sidecar/filesystem operations is not claimed.

## Literal configuration and hooks

The explicit `--config` file is loaded before CLI options; otherwise the project-relative `etc/backup.conf` is used. Shell-style quoted values and one-line arrays are literal data: `$()` and `$VAR` are never executed or expanded. CLI source options replace the file source array on first use. Exclude patterns use the GNU tar matching contract.

```ini
BACKUP_SOURCES=("/absolute/owned/source one" "/absolute/owned/source two")
BACKUP_DEST="/absolute/owned/backups"
BACKUP_PREFIX=backup
COMPRESSION=gz
INCREMENTAL=true
BACKUP_TYPE=daily
RETENTION_DAILY=7
RETENTION_WEEKLY=4
RETENTION_MONTHLY=12
VERIFY_BACKUP=true
SAVE_CHECKSUM=true
CHECKSUM_ALGORITHM=sha256
VERIFY_ARCHIVE_LISTING=true
PRE_BACKUP_SCRIPT=""
POST_BACKUP_SCRIPT=""
SCRIPT_TIMEOUT=300
LOG_FILE="/absolute/owned/backup.log"
LOG_DIR="/absolute/owned/log"
LOCK_FILE="/absolute/owned/backup.lock"
LOCK_TIMEOUT=60
NOTIFY_EMAIL=false
```

A configured pre/post hook must be executable. It is invoked as an executable path, with the archive path passed to the post hook. Timeout/failure propagates; an existing archive after a failed hook is not a completed workflow. Hooks and mail are never exercised against real external services by local tests.

Historical sample keys COMPRESSION_LEVEL, PRESERVE_PERMISSIONS, FOLLOW_SYMLINKS, MAX_FILE_SIZE, NICE_LEVEL, IONICE_CLASS, BACKUP_TIMEOUT, TIMESTAMP_FORMAT, WEEKLY_DAY and MONTHLY_DAY are retained in the distributed example for design history but do not change the current CLI implementation. The actual defaults use tar/compressor defaults, fixed Sunday/first-day classification and generated unique names. Do not present those inert settings as effective controls; extend the implementation and tests before relying on them. LOG_RETENTION_DAYS/USE_COLORS likewise do not establish automatic log retention. No MAX_PARALLEL_JOBS setting is accepted.

## Failure and diagnostic contract

Successful backup completion is printed only after creation, configured verification, retention and post hook succeed. Exit 1 covers configuration/environment/lock/pre-hook errors, 2 archive creation failure, 3 final verification failure; a post-hook's nonzero status is preserved. Missing sources fail the whole backup rather than quietly create a partial set. Missing/invalid archive selection and verification fail explicitly.

Notifications are optional. A failed mail transport is visible; transport acceptance does not prove delivery. Keep notification failures separate from archive integrity when reviewing the final report. Do not delete a flock file to bypass a live lock. Examine permissions on owned paths rather than immediately escalating to root. Insufficient-space recovery requires deliberate retention/recovery choices; no hidden force-rotation switch exists.

## Tests and automation

```bash
bash SEM06/scripts/projects/backup/tests/test_backup.sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest SEM06/tests/test_runtime_semantics.py SEM06/tests/test_teaching_examples.py -q
```

The Bash harness runs its complete suite; `--filter`, `--coverage` and printed historic 45/43/2 counts are not evidence from a current run. Current tests use isolated fixtures, including full+incremental restore. See [resource templates](../../../resources/README.md) for correctly spelled cron/systemd commands. Installation, timer activation, remote backup, database backup and notifications remain separately scoped operations.

## Licence

Educational project - Operating Systems, ASE Bucharest CSIE.
Free use for teaching and personal purposes.

## Author

Teaching material created for the Operating Systems course.
Seminar 6: CAPSTONE Bash Projects.
