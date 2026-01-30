# Python Scripting Guide (for the Operating Systems course)

In this kit, Python is used as a "magnifying glass": to measure, instrument and process system data (processes, files, memory, logs) with more structure than in Bash.

## 1. Basic conventions

- Python 3.12+ (for pattern matching, modern type hints)
- `pathlib.Path` instead of `os.path.join()` or concatenations
- `argparse` for predictable CLI
- Type hints on public functions (aids documentation and IDE)

## 2. System interaction: `subprocess`

```python
import subprocess
from typing import Optional

def run_cmd(args: list[str], timeout: int = 30) -> Optional[str]:
    """Execute command, return stdout or None on error."""
    try:
        result = subprocess.run(
            args, text=True, check=True,
            capture_output=True, timeout=timeout
        )
        return result.stdout
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        print(f"Error: {e}", file=__import__('sys').stderr)
        return None

# Usage
if output := run_cmd(["ps", "-eo", "pid,comm,%cpu", "--sort=-%cpu"]):
    print(output)
```

Rules:
- `check=True` — exception on returncode ≠ 0
- `capture_output=True` — only when you actually process the output
- **Never** `shell=True` — command injection risk

## 3. Reading from `/proc` (without subprocess)

```python
from pathlib import Path

def get_process_info(pid: int | str = "self") -> dict[str, str]:
    """Extract information from /proc/<pid>/status."""
    status_path = Path(f"/proc/{pid}/status")
    if not status_path.exists():
        return {}
    
    keys = ("Name", "State", "Pid", "PPid", "VmRSS", "Threads")
    info = {}
    for line in status_path.read_text(encoding="utf-8").splitlines():
        key, _, value = line.partition(":")
        if key in keys:
            info[key] = value.strip()
    return info

# Usage
print(get_process_info())        # current process
print(get_process_info(1))       # init/systemd
```

Other useful sources: `/proc/meminfo`, `/proc/cpuinfo`, `/proc/loadavg`.

## 4. Log aggregation (Counter pattern)

```python
from collections import Counter
import subprocess
import re

def analyze_ssh_logs(since: str = "today") -> Counter[str]:
    """Count IPs with failed authentication."""
    output = subprocess.run(
        ["journalctl", "-u", "ssh", "--since", since, "--no-pager"],
        text=True, capture_output=True
    ).stdout
    
    ip_pattern = re.compile(r"Failed password.*from (\d+\.\d+\.\d+\.\d+)")
    return Counter(ip_pattern.findall(output))

# Usage
for ip, count in analyze_ssh_logs().most_common(5):
    print(f"{ip}: {count} attempts")
```

## 5. Execution time measurement

```python
import time
from contextlib import contextmanager
from typing import Generator

@contextmanager
def measure_time(label: str = "Operation") -> Generator[None, None, None]:
    """Context manager for time measurement."""
    start = time.perf_counter()
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        print(f"{label}: {elapsed:.3f}s")

# Usage
with measure_time("Reading /proc"):
    info = get_process_info()
```

For CPU time (not wall-clock): `resource.getrusage(resource.RUSAGE_SELF)`.

## 6. Pattern: temporary files with cleanup

```python
import tempfile
from pathlib import Path
from contextlib import contextmanager
from typing import Generator

@contextmanager
def temp_workspace() -> Generator[Path, None, None]:
    """Create temporary directory, automatically deleted on exit."""
    tmp = tempfile.mkdtemp(prefix="so_lab_")
    try:
        yield Path(tmp)
    finally:
        import shutil
        shutil.rmtree(tmp, ignore_errors=True)

# Usage
with temp_workspace() as ws:
    (ws / "test.txt").write_text("temporary data")
    # on exiting the with block, the directory disappears
```

## 7. Quality checklist

- [ ] `if __name__ == "__main__":` for executable scripts
- [ ] `argparse` with functional `-h`
- [ ] Type hints on functions (verifiable with `mypy --strict`)
- [ ] Docstrings on public functions
- [ ] Separation of I/O from logic (testability)

Edition date: **27 January 2026**
