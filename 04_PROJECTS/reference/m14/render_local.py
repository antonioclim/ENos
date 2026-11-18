"""Local M14 rendering exercise: redacted previews and disposable synthetic output.

This module does not implement a secret store, a deployment client or the full
student CLI. Output mode is restricted to a private POSIX scratch workspace.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import stat
import sys
from pathlib import Path

MAX_INPUT = 1024 * 1024
KEY = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
RUN_NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,63}\Z")
TOKEN = re.compile(r"\$\$|\$\{([A-Za-z_][A-Za-z0-9_]*)\}|\$([A-Za-z_][A-Za-z0-9_]*)")
SYNTHETIC_PREFIX = "DEMO_ONLY_"
DIR_FD_SUPPORTED = {os.open, os.mkdir, os.stat, os.unlink, os.rmdir}.issubset(os.supports_dir_fd)


class LifecycleError(ValueError):
    """A safe diagnostic which never includes a variable value."""


def read_variables(raw: bytes) -> tuple[dict[str, str], set[str]]:
    if len(raw) > MAX_INPUT or (raw and not raw.endswith(b"\0")):
        raise LifecycleError("Invalid variable transport")
    parts = raw[:-1].split(b"\0") if raw else []
    if len(parts) % 3:
        raise LifecycleError("Invalid variable transport")
    values: dict[str, str] = {}
    secrets: set[str] = set()
    for i in range(0, len(parts), 3):
        try:
            key, value, marker = (x.decode("utf-8") for x in parts[i:i + 3])
        except UnicodeError as error:
            raise LifecycleError("Variables must be UTF-8 text") from error
        if not KEY.fullmatch(key) or key in values or marker not in {"0", "1"}:
            raise LifecycleError("Invalid or duplicate variable definition")
        if "\n" in value or "\r" in value:
            raise LifecycleError("Only single-line variable values are supported")
        values[key] = value
        if marker == "1":
            secrets.add(key)
    return values, secrets


def render(text: str, values: dict[str, str], secrets: set[str], *, preview: bool) -> str:
    missing: set[str] = set()

    def substitute(match: re.Match[str]) -> str:
        if match[0] == "$$":
            return "$"
        key = match[1] or match[2]
        if key not in values:
            missing.add(key)
            return match[0]
        return "<redacted>" if preview and key in secrets else values[key]

    result = TOKEN.sub(substitute, text)  # One pass: substituted values are literal.
    if missing:
        raise LifecycleError("Unresolved template variables")
    return result


def private_workspace(path: Path) -> int:
    if os.name != "posix" or not all(hasattr(os, flag) for flag in ("O_NOFOLLOW", "O_DIRECTORY")) or not DIR_FD_SUPPORTED:
        raise LifecycleError("Output requires verified POSIX directory semantics")
    absolute = path.absolute()
    try:
        if absolute != absolute.resolve(strict=True):
            raise LifecycleError("Workspace links or traversal are not allowed")
        for parent in (absolute, *absolute.parents):
            if parent.is_symlink():
                raise LifecycleError("Workspace links are not allowed")
            if any((parent / marker).exists() for marker in (".git", ".hg", ".svn", ".dropbox", ".stfolder")):
                raise LifecycleError("Use a scratch workspace outside version control and synchronisation")
            part = parent.name.casefold()
            if part in {"dropbox", "googledrive", "google drive", "icloud drive", "nextcloud"} or part.startswith("onedrive"):
                raise LifecycleError("Use a local unsynchronised scratch workspace")
        fd = os.open(absolute, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    except OSError as error:
        raise LifecycleError("Workspace is unavailable or not a plain directory") from error
    info = os.fstat(fd)
    if info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o700:
        os.close(fd)
        raise LifecycleError("Workspace must be owned by this user with mode 0700")
    return fd


def local_dummy_receiver(fd: int, expected: bytes) -> int:
    chunks = []
    while True:
        chunk = os.read(fd, 65536)
        if not chunk:
            break
        chunks.append(chunk)
        if sum(map(len, chunks)) > len(expected):
            raise LifecycleError("Dummy receiver found an unexpected output length")
    if b"".join(chunks) != expected:
        raise LifecycleError("Dummy receiver byte verification failed")
    return len(expected)


def run_local_demo(workspace: Path, run_name: str, payload: bytes,
                   receiver=local_dummy_receiver) -> dict[str, object]:
    if not RUN_NAME.fullmatch(run_name) or run_name in {".", ".."}:
        raise LifecycleError("Output directory must be one new simple name")
    workspace_fd = private_workspace(workspace)
    run_fd = None
    directory_identity = None
    file_identity = None
    old_umask = os.umask(0o077)
    cleanup_error = None
    try:
        os.mkdir(run_name, 0o700, dir_fd=workspace_fd)  # Existing names are refused.
        directory_identity = os.stat(run_name, dir_fd=workspace_fd, follow_symlinks=False)
        run_fd = os.open(run_name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=workspace_fd)
        opened = os.fstat(run_fd)
        if (opened.st_dev, opened.st_ino) != (directory_identity.st_dev, directory_identity.st_ino) or opened.st_uid != os.getuid() or stat.S_IMODE(opened.st_mode) != 0o700:
            raise LifecycleError("Unexpected exercise-directory identity or permissions")
        fd = os.open("service.conf", os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=run_fd)
        file_identity = os.fstat(fd)
        try:
            if file_identity.st_uid != os.getuid() or stat.S_IMODE(file_identity.st_mode) != 0o600:
                raise LifecycleError("Unexpected output ownership or permissions")
            position = 0
            while position < len(payload):
                written = os.write(fd, payload[position:])
                if written <= 0:
                    raise LifecycleError("Output write did not complete")
                position += written
            os.fsync(fd)
        finally:
            os.close(fd)
        fd = os.open("service.conf", os.O_RDONLY | os.O_NOFOLLOW, dir_fd=run_fd)
        try:
            info = os.fstat(fd)
            if (info.st_dev, info.st_ino) != (file_identity.st_dev, file_identity.st_ino):
                raise LifecycleError("Output identity changed before dummy verification")
            if receiver(fd, payload) != len(payload):
                raise LifecycleError("Dummy receiver did not verify all bytes")
        finally:
            os.close(fd)
    finally:
        try:
            if run_fd is not None and file_identity is not None:
                current = os.stat("service.conf", dir_fd=run_fd, follow_symlinks=False)
                if (current.st_dev, current.st_ino) != (file_identity.st_dev, file_identity.st_ino):
                    raise LifecycleError("Residual output: unexpected file identity; inspect workspace")
                os.unlink("service.conf", dir_fd=run_fd)
            if directory_identity is not None:
                current = os.stat(run_name, dir_fd=workspace_fd, follow_symlinks=False)
                if (current.st_dev, current.st_ino) != (directory_identity.st_dev, directory_identity.st_ino):
                    raise LifecycleError("Residual output: unexpected directory identity; inspect workspace")
                os.rmdir(run_name, dir_fd=workspace_fd)
        except (OSError, LifecycleError) as error:
            cleanup_error = LifecycleError("Residual exercise output requires inspection; cleanup was not confirmed")
        finally:
            if run_fd is not None:
                os.close(run_fd)
            os.close(workspace_fd)
            os.umask(old_umask)
        if cleanup_error is not None:
            raise cleanup_error
    return {"status": "VERIFIED_LOCAL_SYNTHETIC", "bytes": len(payload), "output_removed": True}


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("template", type=Path)
    parser.add_argument("--workspace", type=Path)
    parser.add_argument("--output-dir")
    parser.add_argument("--synthetic-demo", action="store_true")
    args = parser.parse_args(argv)
    try:
        values, secrets = read_variables(sys.stdin.buffer.read(MAX_INPUT + 1))
        if args.template.is_symlink() or not args.template.is_file():
            raise LifecycleError("Template must be a regular file, not a link")
        text = args.template.read_text(encoding="utf-8")
        if not args.output_dir:
            if args.workspace:
                raise LifecycleError("Workspace requires an explicit output directory")
            sys.stdout.write(render(text, values, secrets, preview=True))
            return 0  # ALLOW_SECRET_OUTPUT is intentionally never consulted.
        if not args.workspace or not args.synthetic_demo:
            raise LifecycleError("Output requires a private workspace and explicit synthetic-demo mode")
        if any(not values[key].startswith(SYNTHETIC_PREFIX) for key in secrets):
            raise LifecycleError("Output accepts only marked DEMO_ONLY_ exercise values")
        payload = render(text, values, secrets, preview=False).encode("utf-8")
        report = run_local_demo(args.workspace, args.output_dir, payload)
        print(json.dumps(report, sort_keys=True))
        return 0
    except LifecycleError as error:
        print(str(error), file=sys.stderr)
        return 2
    except (OSError, UnicodeError):
        print("Local rendering failed; inspect the private workspace before reuse", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
