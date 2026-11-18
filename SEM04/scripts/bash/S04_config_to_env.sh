#!/usr/bin/env bash
# Teaching serializer: flat key=value records -> Bash words, never eval/source.
# Sections are labels only; keys remain global. Not a universal dotenv/INI parser.
set -o pipefail
export LC_ALL=C
usage() {
    printf '%s\n' 'Usage: S04_config_to_env.sh [--exports|--assignments] FILE' \
        'Read a flat configuration and emit Bash-safe assignments only after validation.' \
        'Default: --exports. --assignments omits export; output still requires Bash syntax.'
}
mode=exports
case ${1-} in
    -h|--help) usage; exit 0 ;;
    --exports) shift ;;
    --assignments) mode=assignments; shift ;;
esac
[[ $# == 1 && -f $1 && -r $1 ]] || { usage >&2; exit 2; }
input=$1
# Bash cannot represent NUL. Reject it explicitly instead of silently dropping it.
if IFS= read -r -d '' _nul_prefix < "$input"; then
    printf 'Invalid configuration: NUL byte is unsupported\n' >&2; exit 2
fi
exec 3< "$input" || exit 1
declare -A seen=()
declare -a output=()
line_no=0
while IFS= read -r line <&3 || [[ -n $line ]]; do
    line_no=$((line_no + 1))
    line=${line%$'\r'}
    [[ $line =~ ^[[:space:]]*$ || $line =~ ^[[:space:]]*[#\;] ]] && continue
    [[ $line =~ ^[[:space:]]*\[[A-Za-z0-9_.\ -]+\][[:space:]]*$ ]] && continue
    [[ $line == *=* ]] || { printf 'Line %d: expected key=value\n' "$line_no" >&2; exit 2; }
    key=${line%%=*}; value=${line#*=}
    key=${key#"${key%%[![:space:]]*}"}
    key=${key%"${key##*[![:space:]]}"}
    [[ $key =~ ^[A-Za-z_][A-Za-z0-9_.]*$ ]] || {
        printf 'Line %d: invalid key\n' "$line_no" >&2; exit 2;
    }
    key=${key//./_}; key=${key^^}
    [[ ! -v seen[$key] ]] || {
        printf 'Line %d: duplicate or normalisation collision for %s\n' "$line_no" "$key" >&2; exit 2;
    }
    seen[$key]=1
    printf -v word '%q' "$value"
    if [[ $mode == exports ]]; then output+=("export $key=$word"); else output+=("$key=$word"); fi
done
exec 3<&-
((${#output[@]} == 0)) || printf '%s\n' "${output[@]}"
