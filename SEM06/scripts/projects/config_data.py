#!/usr/bin/env python3
"""Read literal KEY=VALUE settings; shell expansion and execution are forbidden.

Values use shell-style quoting only. Array settings use (...) or whitespace-separated
quoted items. Output is a NUL-delimited assignment stream consumed by the Bash loader.
"""
import re
import shlex
import sys
from pathlib import Path


def main():
    source, *specs = sys.argv[1:]
    arrays = {x[:-2] for x in specs if x.endswith("[]")}
    allowed = {x[:-2] if x.endswith("[]") else x for x in specs}
    assignments = []
    for number, line in enumerate(Path(source).read_text(encoding="utf-8").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        match = re.fullmatch(r"([A-Za-z_][A-Za-z_0-9]*)\s*=\s*(.*)", line)
        if not match or match[1] not in allowed:
            raise ValueError(f"{source}:{number}: unsupported setting")
        key, raw = match.groups()
        if key in arrays and raw.startswith("("):
            if not raw.endswith(")"):
                raise ValueError(f"{source}:{number}: unterminated array")
            raw = raw[1:-1]
        values = shlex.split(raw, comments=True, posix=True)
        if key in arrays:
            assignments.append((key + "__RESET", ""))
            assignments.extend((key, value) for value in values)
        else:
            if len(values) > 1:
                raise ValueError(f"{source}:{number}: quote a value containing spaces")
            assignments.append((key, values[0] if values else ""))
    # Validate the whole file before emitting any assignments.
    for key, value in assignments:
        if "\0" in value:
            raise ValueError("NUL is not permitted in settings")
        sys.stdout.buffer.write(key.encode() + b"\0" + value.encode() + b"\0")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
