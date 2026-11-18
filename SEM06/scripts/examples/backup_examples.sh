#!/usr/bin/env bash
# Source from a teaching fixture. BACKUP_PROGRAM must name scripts/projects/backup/backup.sh.
create_full_backup() {
    LOCK_FILE="$2/.backup.lock" bash "${BACKUP_PROGRAM:?Set the absolute path to backup.sh}" \
        --config "${BACKUP_CONFIG:-/dev/null}" --log-file /dev/null --source "$1" --dest "$2" --type full --incremental --compression "${3:-gz}"
}
create_incremental_backup() {
    LOCK_FILE="$2/.backup.lock" bash "${BACKUP_PROGRAM:?}" --config "${BACKUP_CONFIG:-/dev/null}" --log-file /dev/null --source "$1" --dest "$2" \
        --type daily --incremental --compression "${3:-gz}"
}
# GNU tar records deletions/renames. A full checkpoint starts the .parent chain;
# successful increments advance .snapshot, .latest and .sources only after verification.
restore_incremental_chain() {
    local target_archive=$1 destination=$2
    LOCK_FILE="$(dirname -- "$target_archive")/.backup.lock" bash "${BACKUP_PROGRAM:?}" --config "${BACKUP_CONFIG:-/dev/null}" --log-file /dev/null --dest "$(dirname -- "$target_archive")" \
        --restore "$target_archive" --restore-dir "$destination"
}
restore_backup() { restore_incremental_chain "$@"; }

checksum_tool() {
    case ${1:-sha256} in
        md5|sha1|sha256|sha512) printf '%ssum\n' "$1" ;;
        *) printf 'Unsupported checksum algorithm: %s\n' "$1" >&2; return 2 ;;
    esac
}
generate_checksum() (
    local file=$1 algorithm=${2:-sha256} tool directory base temporary
    tool=$(checksum_tool "$algorithm") || return 2
    directory=$(dirname -- "$file"); base=$(basename -- "$file")
    [[ -f $file && -r $file ]] || return 1
    temporary=$(mktemp "$directory/.checksum.XXXXXX") || return 1
    trap 'rm -f -- "$temporary"' EXIT
    (cd -- "$directory" && "$tool" -- "$base") > "$temporary" || return 1
    mv -- "$temporary" "$file.$algorithm"
)
verify_checksum() (
    local file=$1 algorithm=${2:-sha256} tool directory base
    tool=$(checksum_tool "$algorithm") || return 2
    directory=$(dirname -- "$file"); base=$(basename -- "$file")
    [[ -f $file && -r $file.$algorithm ]] || return 1
    # Recalculate the exact file; sidecars cannot redirect verification elsewhere.
    python3 - "$file" "$file.$algorithm" "$algorithm" <<'PY'
import hashlib, pathlib, re, sys
archive, sidecar, algorithm = sys.argv[1:]
try:
    expected = pathlib.Path(sidecar).read_text().split()[0].lstrip('\\')
    if not re.fullmatch('[0-9a-fA-F]+', expected): raise ValueError('invalid digest')
    with open(archive, 'rb') as stream:
        digest = hashlib.new(algorithm)
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
        actual = digest.hexdigest()
    raise SystemExit(0 if actual == expected.lower() else 1)
except (OSError, ValueError, IndexError) as error:
    print(error, file=sys.stderr); raise SystemExit(1)
PY
)
verify_archive() {
    local archive=$1 algorithm=${2:-sha256}
    [[ -f $archive && -r $archive ]] || return 1
    case $archive in
        *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tar.xz) tar -tf "$archive" >/dev/null || return 1 ;;
        *.tar.zst) tar --zstd -tf "$archive" >/dev/null || return 1 ;;
        *) return 2 ;;
    esac
    verify_checksum "$archive" "$algorithm" || return 1
    printf 'Archive structure and %s checksum verified: %s\n' "$algorithm" "$archive" >&2
}
compress_file() (
    local input=$1 algorithm=${2:-gzip} level=${3:-6} extension output stage before after ratio
    [[ -f $input && $level =~ ^[1-9]$|^1[0-9]$ ]] || return 2
    case $algorithm in
        gzip) extension=gz; ((level <= 9)) || return 2 ;;
        bzip2) extension=bz2; ((level <= 9)) || return 2 ;;
        xz) extension=xz; ((level <= 9)) || return 2 ;;
        zstd) extension=zst ;;
        *) return 2 ;;
    esac
    output=$input.$extension
    [[ ! -e $output && ! -L $output ]] || return 1
    stage=$(mktemp "$(dirname -- "$input")/.compress.XXXXXX") || return 1
    trap 'rm -f -- "$stage"' EXIT
    "$algorithm" -"$level" -c -- "$input" > "$stage" || return 1
    before=$(stat -c %s -- "$input") || return 1
    after=$(stat -c %s -- "$stage") || return 1
    if ((before == 0)); then ratio='undefined (empty input)'
    else ratio=$(awk -v a="$before" -v b="$after" 'BEGIN {printf "%.2f%%",100*(1-b/a)}'); fi
    mv -- "$stage" "$output" || return 1
    printf 'Bytes: %s -> %s; reduction: %s\n' "$before" "$after" "$ratio" >&2
    printf '%s\n' "$output"
)
