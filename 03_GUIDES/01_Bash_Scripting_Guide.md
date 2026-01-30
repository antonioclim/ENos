# Bash Scripting Guide (for the Operating Systems course)

This guide establishes a set of recommended practices for Bash scripts used in the laboratory: **stability**, **predictability** and **safety**. In the OS context, Bash is particularly useful for *orchestration* (command chains, automation, utility integration), while Python is often more suitable for complex logic and parsing.

## 1. Shebang, strict mode, conventions

### Shebang
Use Bash explicitly (for portability across distributions):
```bash
#!/usr/bin/env bash
```

### Strict mode (recommended)
```bash
set -euo pipefail
IFS=$'\n\t'
```

- `-e` stops the script at the first failing command (be careful with controlled exceptions);
- `-u` treats undefined variables as errors;
- `pipefail` propagates errors from pipelines.

### Messages and logging
- "normal" output → `stdout`
- debugging / error messages → `stderr`

Example:
```bash
log() { printf '%s\n' "$*" >&2; }
die() { log "Error: $*"; exit 1; }
```

## 2. Quoting: the golden rule

In Bash, most bugs start from missing quotes.

Wrong:
```bash
for f in *.txt; do
  echo $f
done
```

Correct:
```bash
shopt -s nullglob  # avoid errors when no files exist
for f in ./*.txt; do
  [[ -f "$f" ]] || continue
  printf '%s\n' "$f"
done
```

Key points:
- `"$var"` almost always, not `$var`
- `"$@"` to preserve arguments as a list

## 3. Arguments and options

### Positional parameters
- `$0` script name
- `$1`, `$2`, ... arguments
- `$#` number of arguments
- `"$@"` the list of arguments

### `getopts` (short options)
Recommended pattern:
```bash
readonly SCRIPT_NAME="${0##*/}"
usage() { cat <<EOF >&2
Usage: $SCRIPT_NAME [-n] [-o OUTPUT] ARG1
EOF
  exit 2
}

OUTPUT=""
DRY_RUN=0

while getopts ":no:" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    o) OUTPUT="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))
[[ $# -ge 1 ]] || usage  # validate mandatory argument
```

## 4. Functions and control structures

Prefer small, easily testable functions:
```bash
ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}
```

Common structures:
- `if [[ ... ]]`
- `case "$var" in ... esac`
- `for`, `while read -r ...`

## 5. Temporary files and cleanup

In OS, scripts frequently create temporary files. Use `mktemp` + `trap`:

```bash
readonly TMP_DIR="$(mktemp -d)" || exit 1
cleanup() { [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM
```

## 6. Error handling and exit codes

Practical convention:
- `0` = success
- `1` = generic error
- `2` = incorrect usage (CLI)
- `3+` = application-specific codes

## 7. Quality: ShellCheck and style

Run:
```bash
shellcheck -x path/to/script.sh
```

Suggestions:
- document options in `usage()`;
- avoid "magic values";
- prefer `printf` instead of `echo` for predictable output.

## 8. Typical examples (related to OS)

### 8.1. Process audit
```bash
ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 15
```

### 8.2. Quick system inventory
```bash
uname -a
lsb_release -a 2>/dev/null || cat /etc/os-release
free -h
df -h
```

### 8.3. Pipeline for logs
```bash
journalctl -u ssh --since "today" | grep -E "Failed password|Accepted" | tail -n 50
```

Edition date: **27 January 2026**
