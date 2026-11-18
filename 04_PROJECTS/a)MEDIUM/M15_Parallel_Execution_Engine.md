# M15: Parallel Execution Engine

> **Level:** MEDIUM | **Estimated time:** 25-35 hours | **K8s Bonus:** +10%

---

## Description

Parallel execution engine for tasks: run commands on multiple files/hosts simultaneously, concurrency control, result aggregation and error handling. Similar to GNU Parallel but simplified and with additional features.

---

## Learning Objectives

- Parallel processing in Bash (jobs, background)
- Concurrency control and rate limiting
- Output aggregation and error handling
- IPC (pipes, named pipes, signals)
- Process management and cleanup

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Parallel execution**
   - Run command on list of inputs
   - Control number of workers (concurrency)
   - Timeout per task

2. **Input sources**
   - From file (one per line)
   - From pipe (stdin)
   - Glob patterns for files
   - Ranges (1-100)

3. **Output management**
   - Stdout/stderr aggregation
   - Ordered or real-time output
   - Per-job output separation

4. **Progress and status**
   - Progress bar
   - Calculated ETA
   - Final statistics

5. **Error handling**
   - Continue on error (configurable)
   - Retry failed jobs
   - Aggregated exit codes

### Optional (for full marks)

6. **Remote execution** - Parallel SSH on multiple hosts
7. **Job queues** - Persistent queue with resume
8. **Resource limits** - CPU/memory limits per job
9. **Dependency graphs** - Tasks with dependencies
10. **Web dashboard** - Status and control

---

## CLI Interface

```text
./pexec.sh [options] <command> [args...]

Input sources:
  -a, --arg LIST        List of arguments (comma-separated)
  -i, --input FILE      File with inputs (one per line)
  -I, --stdin           Read inputs from stdin
  -0                    NUL-delimited file/stdin inputs (adapter requirement)
  -g, --glob PATTERN    Expand glob pattern
  -r, --range START-END Numeric range

Execution options:
  -j, --jobs N          Number of parallel workers (default: CPU cores)
  -t, --timeout SEC     Timeout per job
  -k, --keep-going      Continue on errors
  --retry N             Retry failed jobs
  --delay SEC           Delay between launches

Output options:
  -o, --output DIR      Directory for per-job output
  -O, --ordered         Output in input order
  -q, --quiet           Errors only
  -v, --verbose         Detailed output
  --progress            Display progress bar
  --no-color            No colours

Placeholders in command:
  {}                    Replaced with current input
  {.}                   Input without extension
  {/}                   Basename
  {//}                  Directory
  {#}                   Job number (1, 2, 3...)

Examples:
  ./pexec.sh -j 4 -a "f1.txt,f2.txt,f3.txt" gzip {}
  cat urls.txt | ./pexec.sh -I -j 10 curl -O {}
  ./pexec.sh -g "*.log" -j 8 gzip {}
  ./pexec.sh -r 1-100 -j 20 ./process.sh {}
  ./pexec.sh -i hosts.txt -j 5 ssh {} "uptime"
```

---

## Output Examples

The following numbers and host names are synthetic illustrations, not benchmark measurements.

### Execution Progress

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PARALLEL EXECUTION ENGINE                                 ║
║                    Jobs: 100 | Workers: 8                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Command: gzip {}
Input: 100 files from *.log

PROGRESS
═══════════════════════════════════════════════════════════════════════════════
[████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░] 67% (67/100)

Running: 8 | Completed: 67 | Failed: 2 | Remaining: 25
ETA: 12 seconds | Elapsed: 24 seconds

ACTIVE WORKERS
───────────────────────────────────────────────────────────────────────────────
  [1] gzip app.log.15         (3.2s)
  [2] gzip app.log.16         (2.8s)
  [3] gzip app.log.17         (2.1s)
  [4] gzip app.log.18         (1.5s)
  [5] gzip app.log.19         (1.2s)
  [6] gzip app.log.20         (0.8s)
  [7] gzip app.log.21         (0.4s)
  [8] gzip app.log.22         (0.1s)

RECENT COMPLETIONS
───────────────────────────────────────────────────────────────────────────────
  ✓ app.log.14 (0.5s)
  ✓ app.log.13 (0.6s)
  ✗ app.log.12 - Permission denied (0.1s)
  ✓ app.log.11 (0.4s)
```

### Final Summary

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    EXECUTION COMPLETE                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

SUMMARY
═══════════════════════════════════════════════════════════════════════════════
  Total jobs:           100
  Successful:           98 (98%)
  Failed:               2 (2%)
  
  Total time:           36.2 seconds
  Wall time / jobs:     0.362 seconds (not mean job duration)
  Worker limit:         8 (speed-up requires a measured serial baseline)

FAILED JOBS
───────────────────────────────────────────────────────────────────────────────
  app.log.12     Exit 1: Permission denied
  app.log.45     Exit 1: No space left on device

TIMING STATISTICS
───────────────────────────────────────────────────────────────────────────────
  Fastest job:          0.1s (app.log.3)
  Slowest job:          2.8s (app.log.67)
  Mean job duration:    0.36s (illustrative independent measurement)
  Std deviation:        0.42s

OUTPUT
───────────────────────────────────────────────────────────────────────────────
  Combined stdout:      /tmp/pexec_20250120/stdout.log
  Combined stderr:      /tmp/pexec_20250120/stderr.log
  Per-job output:       /tmp/pexec_20250120/jobs/

Retry failed: ./pexec.sh --retry-failed /tmp/pexec_20250120
```

### SSH Parallel Execution

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    PARALLEL SSH EXECUTION                                    ║
║                    Hosts: 10 | Command: uptime                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

[████████████████████████████████████████████████████████████████████████] 100%

RESULTS
═══════════════════════════════════════════════════════════════════════════════

Host                Status    Result
─────────────────────────────────────────────────────────────────────────────
server01.local      ✓ OK      up 45 days, load: 0.12
server02.local      ✓ OK      up 45 days, load: 0.08
server03.local      ✓ OK      up 30 days, load: 0.45
server04.local      ✓ OK      up 30 days, load: 0.23
server05.local      ✓ OK      up 15 days, load: 1.23
server06.local      ✗ FAIL    Connection refused
server07.local      ✓ OK      up 60 days, load: 0.05
server08.local      ✓ OK      up 60 days, load: 0.18
server09.local      ✗ TIMEOUT ssh: connect timed out
server10.local      ✓ OK      up 20 days, load: 0.34

Summary: 8/10 successful (80%)
```

---

## Project Structure

```
M15_Parallel_Execution_Engine/
├── README.md
├── Makefile
├── src/
│   ├── pexec.sh                 # Main script
│   └── lib/
│       ├── worker.sh            # Worker process
│       ├── queue.sh             # Job queue management
│       ├── input.sh             # Input sources
│       ├── output.sh            # Output aggregation
│       ├── progress.sh          # Progress display
│       └── utils.sh             # Utility functions
├── etc/
│   └── pexec.conf
├── tests/
│   ├── test_parallel.sh
│   ├── test_input.sh
│   └── slow_command.sh
└── docs/
    ├── INSTALL.md
    └── EXAMPLES.md
```

---

## Implementation Hints

### Job queue with workers

```bash
# Caller supplies COMMAND_ARGV as an array and a fresh OUTPUT_DIR.
# This small scheduler waits for the oldest outstanding child; it is bounded,
# correct and less utilisation-efficient than a completion-driven event queue.
declare -a PIDS=()
declare -A JOB_STATUS=()
run_parallel() {
    local max_jobs="${JOBS:-$(nproc)}" input pid status job_num=0 completed=0 failed=0
    local total=$# launched=0
    [[ $max_jobs =~ ^[1-9][0-9]*$ && $total -gt 0 && ${#COMMAND_ARGV[@]} -gt 0 ]] || return 2
    [[ ! -e "$OUTPUT_DIR/jobs" ]] || { echo "A run requires a fresh jobs directory" >&2; return 2; }
    mkdir -p -- "$OUTPUT_DIR" && mkdir -- "$OUTPUT_DIR/jobs" || return 1
    PIDS=(); JOB_STATUS=(); START_TIME=$(date +%s)
    for input in "$@"; do
        if ((${#PIDS[@]} >= max_jobs)); then wait_for_slot; fi
        if ((failed > 0)) && [[ ${KEEP_GOING:-false} != true ]]; then break; fi
        job_num=$((job_num+1)); launched=$((launched+1))
        run_job "$input" "$job_num" 0 &
        PIDS+=("$!")
    done
    while ((${#PIDS[@]})); do wait_for_slot; done
    printf '\nRequested=%d Launched=%d Completed=%d Failed=%d Not_launched=%d\n' \
        "$total" "$launched" "$completed" "$failed" "$((total-launched))"
    (( failed == 0 && launched == total ))
}

wait_for_slot() {
    # Variables completed/failed/total are dynamically scoped to run_parallel.
    local pid="${PIDS[0]}" status
    if wait "$pid"; then status=0; else status=$?; fi
    JOB_STATUS[$pid]=$status
    PIDS=("${PIDS[@]:1}")
    completed=$((completed+1))
    if ((status != 0)); then failed=$((failed+1)); fi
    show_progress "$completed" "$total"
    return 0
}
```

### Worker process

```bash
run_job() (
    local input="$1" job_num="$2" attempt="${3:-0}" arg code start end
    local template expanded prefix directory
    [[ $job_num =~ ^[1-9][0-9]*$ && $attempt =~ ^[0-9]+$ ]] || return 2
    local output_dir="$OUTPUT_DIR/jobs/$job_num/attempt_$attempt"
    mkdir -p -- "$OUTPUT_DIR/jobs/$job_num" || return 1
    mkdir -- "$output_dir" || { echo "Attempt already exists: $output_dir" >&2; return 2; }
    local -a command=() timeout_args=()
    # Read each original template once. Replacement text is literal data and
    # must never be scanned again for another placeholder.
    IFS= read -r -d '' directory < <(dirname -z -- "$input") || return 1
    for arg in "${COMMAND_ARGV[@]}"; do
        template=$arg; expanded=''
        while [[ $template == *'{'* ]]; do
            prefix=${template%%\{*}; expanded+=$prefix; template=${template#"$prefix"}
            case "$template" in
                '{}'* ) expanded+=$input; template=${template:2} ;;
                '{.}'* ) expanded+=${input%.*}; template=${template:3} ;;
                '{/}'* ) expanded+=${input##*/}; template=${template:3} ;;
                '{//}'* ) expanded+=$directory; template=${template:4} ;;
                '{#}'* ) expanded+=$job_num; template=${template:3} ;;
                * ) expanded+='{'; template=${template:1} ;;
            esac
        done
        command+=("$expanded$template")
    done
    [[ ${#command[@]} -gt 0 ]] || return 2
    if [[ -n ${TIMEOUT:-} ]]; then
        [[ $TIMEOUT =~ ^[0-9]+([.][0-9]+)?[smhd]?$ ]] || return 2
        timeout_args=(timeout -- "$TIMEOUT")
    fi
    start=$(date +%s.%N)
    if "${timeout_args[@]}" "${command[@]}" >"$output_dir/stdout" 2>"$output_dir/stderr"; then code=0; else code=$?; fi
    end=$(date +%s.%N)
    # JSON is data. It is never sourced as Bash, including when retrying.
    python3 - "$output_dir/meta.json" "$input" "$job_num" "$attempt" "$code" "$start" "$end" "${TIMEOUT:-}" "${COMMAND_ARGV[@]}" <<'PYMETA'
import json,sys
from pathlib import Path
p,input_text,job,attempt,code,start,end,timeout,*argv=sys.argv[1:]
Path(p).write_text(json.dumps({'schema_version':1,'input':input_text,'job_num':int(job),'attempt':int(attempt),
 'exit_code':int(code),'start_time':float(start),'end_time':float(end),'duration':float(end)-float(start),
 'timeout':timeout,'command_argv':argv})+'\n')
PYMETA
    [[ $? -eq 0 ]] || return 1
    return "$code"
)
```

Commands are argument arrays, for example `COMMAND_ARGV=(gzip '{}')`.
A filename containing shell punctuation remains one argument. An explicit
`bash -c 'trusted code using "$1"' _ '{}'` opts into a caller-supplied shell
program; input data must remain positional parameters. No metadata is executable.
The supplied functions are also collected in [parallel_reference.sh](../reference/parallel_reference.sh).

### Input sources

```bash
parse_input_source() {
    local source_type="$1" source_value="${2:-}" start end item
    case "$source_type" in
        arg)  # Comma syntax cannot represent an input containing a comma or newline.
            local -a inputs=()
            IFS=',' read -r -a inputs <<< "$source_value"
            printf '%s\0' "${inputs[@]}" ;;
        file|stdin)  # One physical line is one input; -0 is needed for embedded newlines.
            if [[ $source_type == file ]]; then
                while IFS= read -r item || [[ -n $item ]]; do printf '%s\0' "$item"; done < "$source_value"
            else
                while IFS= read -r item || [[ -n $item ]]; do printf '%s\0' "$item"; done
            fi ;;
        file0) cat -- "$source_value" ;;
        stdin0) cat ;;
        glob) python3 -c 'import glob,os,sys; [sys.stdout.buffer.write(os.fsencode(p)+b"\0") for p in glob.glob(sys.argv[1])]' "$source_value" ;;
        range)
            [[ $source_value =~ ^([0-9]+)-([0-9]+)$ ]] || return 2
            start=${BASH_REMATCH[1]}; end=${BASH_REMATCH[2]}
            ((10#$start <= 10#$end && 10#$end-10#$start <= 1000000)) || return 2
            for ((item=10#$start; item<=10#$end; item++)); do printf '%s\0' "$item"; done ;;
        *) return 2 ;;
    esac
}
```

Input parsing emits NUL-delimited records. Capture it in an owned temporary file,
check its exit status, then use `mapfile -d '' -t inputs < "$file"`; a process
substitution alone would hide a parser failure. The CLI adapter must expose `-0`
for `file0`/`stdin0`. Shell arguments cannot contain NUL.

### Progress bar

```bash
show_progress() {
    local completed="$1" total="$2" width=50 percent filled empty elapsed eta_seconds
    [[ $total =~ ^[1-9][0-9]*$ && $completed =~ ^[0-9]+$ ]] && ((completed <= total)) || return 2
    percent=$((completed*100/total)); filled=$((width*completed/total)); empty=$((width-filled))
    elapsed=$(($(date +%s)-START_TIME))
    local eta='--:--' bar='' i
    if ((completed > 0)); then
        eta_seconds=$((elapsed*(total-completed)/completed))
        printf -v eta '%02d:%02d' "$((eta_seconds/60))" "$((eta_seconds%60))"
    fi
    for ((i=0;i<filled;i++)); do bar+='█'; done
    for ((i=0;i<empty;i++)); do bar+='░'; done
    printf '\r[%s] %3d%% (%d/%d) ETA: %s' "$bar" "$percent" "$completed" "$total" "$eta"
}
```

### xargs-style parallelism (alternative)

```bash
# For a fixed command whose last argument is each NUL-delimited input:
run_with_xargs() {
    [[ ${MAX_JOBS:-} =~ ^[1-9][0-9]*$ && ${#COMMAND_ARGV[@]} -gt 0 ]] || return 2
    xargs -0 -r -P "$MAX_JOBS" -n 1 -- "${COMMAND_ARGV[@]}"
}
# GNU Parallel has a separate command-template grammar. Do not concatenate
# untrusted input into a shell program; use its documented quoting contract.
# It is an alternative exercise, not an implicitly equivalent backend here.
```

### Retry failed jobs

```bash
retry_failed() (
    local run_dir="$1" max_retries="${2:-3}" job_dir meta plan input job attempt code any_failed=0
    [[ $max_retries =~ ^[1-9][0-9]*$ && -d "$run_dir/jobs" && ! -L "$run_dir" && ! -L "$run_dir/jobs" ]] || return 2
    OUTPUT_DIR="$run_dir"
    local -a fields=() COMMAND_ARGV=()
    shopt -s nullglob
    for job_dir in "$run_dir/jobs/"*; do
        [[ -d $job_dir && ! -L $job_dir && ${job_dir##*/} =~ ^[1-9][0-9]*$ ]] || { any_failed=1; continue; }
        plan=$(mktemp "$job_dir/retry-data.XXXXXX") || return 1
        if ! python3 - "$job_dir" > "$plan" <<'PYRETRY'
import json,re,sys
from pathlib import Path
def reject(message): raise ValueError(message)
def unique_pairs(pairs):
 result={}
 for key,value in pairs:
  if key in result: reject('duplicate metadata key')
  result[key]=value
 return result
try:
 root=Path(sys.argv[1]); job=int(root.name); records={}
 for folder in root.glob('attempt_*'):
  match=re.fullmatch(r'attempt_(0|[1-9][0-9]*)',folder.name)
  if not match or folder.is_symlink() or not folder.is_dir(): reject('invalid attempt directory')
  index=int(match[1]); path=folder/'meta.json'
  if path.is_symlink() or not path.is_file(): reject('missing or symlinked metadata')
  m=json.loads(path.read_text(),object_pairs_hook=unique_pairs)
  if not isinstance(m,dict): reject('metadata must be an object')
  a=m.get('command_argv'); n=m.get('job_num'); code=m.get('exit_code'); attempt=m.get('attempt')
  if type(m.get('schema_version')) is not int or m['schema_version']!=1 or type(n) is not int or n!=job:
   reject('invalid schema or job identity')
  if type(attempt) is not int or attempt!=index or type(code) is not int or not 0<=code<=255:
   reject('invalid attempt identity or exit status')
  if not isinstance(a,list) or not a or not all(isinstance(x,str) and '\0' not in x for x in a):
   reject('invalid command argv')
  if not isinstance(m.get('input'),str) or '\0' in m['input'] or not isinstance(m.get('timeout'),str):
   reject('invalid literal retry fields')
  if m['timeout'] and not re.fullmatch(r'[0-9]+(?:[.][0-9]+)?[smhd]?',m['timeout']): reject('invalid timeout')
  records[index]=m
 if not records or sorted(records)!=list(range(len(records))): reject('attempt history must start at zero without gaps')
 original=records[0]; latest=records[len(records)-1]
 contract=('command_argv','input','timeout','job_num')
 if any(any(record[k]!=original[k] for k in contract) for record in records.values()):
  reject('retry contract changed within one job')
 for value in [str(latest['exit_code']),original['input'],str(job),original['timeout'],str(len(records)),*original['command_argv']]:
  sys.stdout.buffer.write(value.encode()+b'\0')
except (ValueError,TypeError,KeyError,OSError) as error:
 print(f'Invalid retry metadata: {error}',file=sys.stderr); raise SystemExit(2)
PYRETRY
        then rm -f -- "$plan"; any_failed=1; continue; fi
        mapfile -d '' -t fields < "$plan"; rm -f -- "$plan"
        code=${fields[0]}; input=${fields[1]}; job=${fields[2]}; TIMEOUT=${fields[3]}; attempt=${fields[4]}; COMMAND_ARGV=("${fields[@]:5}")
        ((code != 0)) || continue
        # Resume from the latest validated outcome. A successful retry is final.
        # Run one retry controller at a time for this owned run directory.
        local remaining=$max_retries
        while ((remaining > 0)); do
            if run_job "$input" "$job" "$attempt"; then code=0; break; else code=$?; fi
            attempt=$((attempt+1)); remaining=$((remaining-1))
        done
        if ((code != 0)); then any_failed=1; fi
    done
    ((any_failed == 0))
)
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Parallel execution | 25% | Workers, concurrency control |
| Input sources | 15% | File, stdin, glob, range |
| Output management | 15% | Aggregate, per-job, ordered |
| Progress & stats | 15% | Progress bar, ETA, summary |
| Error handling | 15% | Continue, retry, exit codes |
| Remote execution | 5% | SSH parallel |
| Code quality + tests | 5% | ShellCheck, tests |
| Documentation | 5% | README, examples |

---

## Resources

- `man xargs` - Parallel execution basics
- `man parallel` - GNU Parallel reference
- `man wait` - Process waiting
- Seminar 2-3 - Background jobs, signals

---

*MEDIUM Project | Operating Systems | ASE-CSIE*
