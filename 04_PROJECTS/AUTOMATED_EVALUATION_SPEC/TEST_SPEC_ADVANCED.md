# Detailed Test Specifications - ADVANCED Projects (A01-A03)

## Status and executable boundary (Phase 5 correction)

These are **author proposals**, not an adopted grading system or a measured
automation result. Original points, percentages, time estimates and competing
grade/penalty proposals are retained as planning history. `total_points` now
equals the sum of the displayed case points; it is not an automatic rescaling to
100. No final grade, bonus, deduction, disclosure or publication policy is selected.

The implemented [local reference](../helpers/evaluation_reference.py) validates
the finite structured predicates printed below and emits JSON once. Unknown
operators, malformed values and duplicate JSON/YAML keys are errors. `all`, `any`
and `not` are explicit; string lists do not have an implicit OR meaning. A `pending`
predicate is a concrete unresolved adapter/author requirement: it reports NOT_RUN,
never PASS, and prevents a purported complete percentage. Existing project CLI
alternatives remain proposed unless a specific technical contract is explicitly
adopted below. Adoption does not supply an omitted implementation.

Each explicitly authorised trusted local case uses a fresh owned project copy and
`FIXTURE_ROOT`; inherited setup runs again before every case. Setup and cleanup
share one shell; only explicitly exported variables reach the command child.
Background fixtures must retain their parent, export their PID and be killed and
waited for. The runner also terminates its own process group on timeout. Permission
oracles require a non-root fixture user. No shared `/tmp` paths, host crontab,
services, HOME directory or unrelated IPC objects are part of the local contract.

This helper is **not a sandbox for untrusted submissions**. It supplies a wall-time
and output bound for trusted fixtures, not CPU/RAM/PID/disk/network containment.
`requires_platform` cases are reported NOT_RUN. A production isolation backend,
archive intake, student execution, notifications and institutional acceptance are
not implemented or executed by this repair. Use the regression tests for the
implemented boundary, not the proposal's planning percentages as evidence.

```bash
# Validation does not execute setup or project commands; YAML requires PyYAML.
python3 04_PROJECTS/helpers/evaluation_reference.py validate owned-suite.yaml
# This opt-in is only for a trusted, owned fixture, never an untrusted submission.
python3 04_PROJECTS/helpers/evaluation_reference.py run owned-suite.yaml --run-owned --project owned-fixture
python3 -m unittest discover -s 04_PROJECTS/tests -p test_evaluation_spec.py -v
```

The local reference uses all-or-nothing points per asserted case only to demonstrate
arithmetic. Partial credit and institutional consequences remain explicit author
choices. See [the assessment/evidence contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md).


## General Note

**Draft acceptance contracts — author approval required.** The snippets below
are specification candidates, not an executable grading engine. D6 adopts the
A03 digest/CLI contract stated below; weights and automatic/manual proportions
remain unadopted planning material. A01's
queue lifecycle now distinguishes explicit creation and attachment; repeated
`init` must not erase work. A02's live Bash/readline bridge is student-supplied and
cannot be proved by a non-interactive `--rcfile` invocation. A03's adopted D6 contract uses SHA-256 (32 bytes), 64 lower-case hexadecimal
characters plus one newline for the student hash CLI, and version 2 / sha256
digest records. The local hashing reference is updated; the omitted student CLI
and record/transport adapters remain **PENDING_CLI_ADAPTER** /
**PENDING_TRANSPORT_ADAPTER** until supplied and validated. The following
`pending` predicates therefore remain NOT_RUN rather than awarding points. See the
project documents and [the assessment/evidence contract](../ASSESSMENT_AND_EVIDENCE_CONTRACT.md) for alternatives and consequences.
All temporary paths in runnable harnesses must be created with `mktemp -d`; no
shared `/tmp/a03_test` or broad shared-memory deletion is authorised by this draft.


ADVANCED projects require:
- **C Compilation**: GCC, Make, development libraries
- **Memory tests**: Valgrind for leak detection
- **Concurrency tests**: Race condition verification
- **Shared memory**: Access to /dev/shm
- **Debugging tools**: GDB, strace

---

## A01: Mini Job Scheduler

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# === BUILD PHASE ===
# === C FUNCTIONALITY ===
# === PRIORITY QUEUE (Heap) ===
# First job must be the one with priority 1 (highest)
# === SHARED MEMORY & SEMAPHORES ===
# 10 simultaneous submit processes
# All 10 jobs must be present
# Stress test
# Must not crash or corrupt
# === MEMORY SAFETY ===
# === BASH-C INTEGRATION ===
# === ERROR HANDLING ===
# Never remove shared-memory wildcard paths; destroy only the owned test instance.
a01_mini_job_scheduler:
  metadata:
    project_id: A01
    name: Mini Job Scheduler
    difficulty: ADVANCED
    total_points: 128
    auto_evaluable_percent: 85
    estimated_test_time: 15m
    required_tools:
    - gcc
    - make
    - valgrind
    - gdb
    historical_declared_total_points: 100
    test_count: 20
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  build_tests:
  - id: build_01
    name: Compile C library
    command: make -C src/c 2>&1
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - path:
          kind: file
          path: build/libjobqueue.so
    points: 10
    category: build_tests
    historical_category: build
  - id: build_02
    name: Compile CLI tool
    command: make
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - path:
          kind: file
          path: bin/jobctl
      - path:
          kind: executable
          path: bin/jobctl
    points: 5
    category: build_tests
    historical_category: build
  - id: build_03
    name: Compile without warnings
    command: make clean && make > build-diagnostics.log 2>&1 && cat build-diagnostics.log
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - not:
          text:
            stream: stdout
            op: contains
            value: 'warning:'
    points: 5
    category: build_tests
    historical_category: build
  c_functionality:
  - id: c_func_01
    name: Initialise shared memory
    command: ./bin/jobctl init
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - pending: 'Exact project/platform contract required for shm_exists: "/dev/shm/jobscheduler"'
    points: 5
    category: c_functionality
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
    cleanup: ./bin/jobctl destroy
  - id: c_func_02
    name: Submit simple job
    command: ./bin/jobctl submit 'echo test'
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - text:
          stream: stdout
          op: regex
          value: Job.*#[0-9]+
    points: 5
    category: c_functionality
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - id: c_func_03
    name: List jobs
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      ./bin/jobctl submit 'sleep 10'
      ./bin/jobctl submit 'echo hello'
    command: ./bin/jobctl list
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - all:
        - text:
            stream: stdout
            op: contains
            value: sleep
        - text:
            stream: stdout
            op: contains
            value: echo
      - lines:
          stream: stdout
          op: ge
          value: 2
    points: 5
    category: c_functionality
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  - id: c_func_04
    name: Cancel job
    setup: |-
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      ./bin/jobctl submit 'sleep 100'
    command: ./bin/jobctl cancel 1
    expect:
      exit_code:
        op: eq
        value: 0
    points: 5
    category: c_functionality
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  - id: c_func_05
    name: Job status
    setup: |-
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      ./bin/jobctl submit 'sleep 5'
    command: ./bin/jobctl status 1
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: pending
      - text:
          stream: stdout
          op: contains
          value: running
      - text:
          stream: stdout
          op: contains
          value: PENDING
      - text:
          stream: stdout
          op: contains
          value: RUNNING
    points: 5
    category: c_functionality
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  priority_queue:
  - id: pq_01
    name: Priority ordering - high first
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      ./bin/jobctl submit -p 10 'echo low'
      ./bin/jobctl submit -p 1 'echo high'
      ./bin/jobctl submit -p 5 'echo medium'
    command: ./bin/jobctl list --by-priority
    expect:
      text:
        stream: stdout
        op: first_line_contains
        value: high
    points: 10
    category: priority_queue
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  - id: pq_02
    name: Heap property maintained after multiple ops
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
      for i in $(seq 1 20); do
        ./bin/jobctl submit -p $((RANDOM % 100)) "job_$i"
      done
    command: ./bin/jobctl list --by-priority | head -5
    expect:
      pending: 'Exact project/platform contract required for output_is_sorted_by_priority: true'
    points: 10
    category: priority_queue
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  ipc_tests:
  - id: ipc_01
    name: Shared memory created correctly
    command: ./bin/jobctl stats
    expect:
      pending: Verify only the unique JOBQUEUE_INSTANCE object through the completed adapter; a global /dev/shm listing is not an ownership oracle.
    points: 5
    category: ipc_tests
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - id: ipc_02
    name: Concurrent access - no corruption
    command: |-
      pids=()
      for i in $(seq 1 10); do ./bin/jobctl submit "concurrent_$i" > "submit_$i.log" 2>&1 & pids+=("$!"); done
      failed=0
      for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
      (( failed == 0 )) || exit 1
      ./bin/jobctl list
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - unique_matches:
          pattern: concurrent_[0-9]+\b
          values:
          - concurrent_1
          - concurrent_2
          - concurrent_3
          - concurrent_4
          - concurrent_5
          - concurrent_6
          - concurrent_7
          - concurrent_8
          - concurrent_9
          - concurrent_10
    points: 15
    timeout: 30
    category: ipc_tests
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - id: ipc_03
    name: Semaphore prevents race condition
    command: |
      ./bin/jobctl init
      # Stress test
      for i in $(seq 1 100); do
        (./bin/jobctl submit "stress_$i" && ./bin/jobctl list > /dev/null) &
      done
      wait
      ./bin/jobctl stats
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - text:
          stream: stdout
          op: contains
          value: submitted
    points: 10
    timeout: 60
    category: ipc_tests
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
    cleanup: ./bin/jobctl destroy
  memory_tests:
  - id: mem_01
    name: Valgrind - no memory leaks in jobctl
    command: valgrind --leak-check=full --error-exitcode=1 ./bin/jobctl submit 'test' 2>&1
    expect:
      exit_code:
        op: eq
        value: 0
    points: 10
    timeout: 30
    category: memory_tests
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
    notes: A clean bounded Valgrind run is evidence for this execution only; missing tools, ptrace restrictions or lifecycle failures are unavailable, not a pass.
  - id: mem_02
    name: Valgrind - no invalid reads/writes
    command: valgrind --track-origins=yes --error-exitcode=1 ./bin/jobctl list 2>&1
    expect:
      exit_code:
        op: eq
        value: 0
    points: 5
    category: memory_tests
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
    notes: A clean bounded Valgrind run is evidence for this execution only; missing tools, ptrace restrictions or lifecycle failures are unavailable, not a pass.
  integration:
  - id: int_01
    name: Bash wrapper works
    command: ./scheduler.sh submit 'echo from bash'
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - text:
          stream: stdout
          op: regex
          value: Job.*[0-9]+
    points: 5
    category: integration
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - id: int_02
    name: Library path correct
    command: ldd ./bin/jobctl
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - linked_library: libjobqueue
    points: 5
    category: integration
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  errors:
  - id: err_01
    name: Duplicate init - handle gracefully
    setup: |-
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    command: ./bin/jobctl init 2>&1
    expect:
      all:
      - exit_code:
          op: ne
          value: 0
      - any:
        - text:
            stream: combined
            op: contains
            value: already
        - text:
            stream: combined
            op: contains
            value: exists
        - text:
            stream: combined
            op: contains
            value: Exists
    points: 3
    category: errors
    notes: Explicit init refuses an existing instance; attach is distinct and must preserve pending jobs.
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    cleanup: ./bin/jobctl destroy
  - id: err_02
    name: Cancel non-existent job
    command: ./bin/jobctl cancel 99999 2>&1
    expect:
      all:
      - exit_code:
          op: ne
          value: 0
      - any:
        - text:
            stream: stdout
            op: contains
            value: not found
        - text:
            stream: stdout
            op: contains
            value: invalid
        - text:
            stream: stdout
            op: contains
            value: error
    points: 3
    category: errors
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  - id: err_03
    name: Submit with empty command
    command: ./bin/jobctl submit '' 2>&1
    expect:
      exit_code:
        op: ne
        value: 0
    points: 2
    category: errors
    requires_platform: owned named POSIX IPC instance and completed versioned A01 CLI; never shared global /dev/shm paths
    setup: |
      export JOBQUEUE_INSTANCE=${FIXTURE_ROOT##*/}
      ./bin/jobctl init
    cleanup: ./bin/jobctl destroy
  manual_evaluation_required:
  - criterion: Correctness of scheduling algorithm
    reason: Fair-share and priority require analysis of execution times
    impact: 10%
  - criterion: C code quality
    reason: Style, organisation, comments - subjective
    impact: 5%
  - criterion: Robustness to crashes
    reason: Difficult to test recovery after kill -9
    impact: 5%
```

---

## A02: Interactive Shell Extension

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# === SYNTAX HIGHLIGHTING ===
# Verify that 'if', 'then', 'fi' have different colour
# === LEXER/TOKENIZER ===
# === TRIE COMPLETION ===
# Load all commands from PATH
# === INTEGRATION ===
# This test is difficult - we simulate with script
a02_interactive_shell_extension:
  metadata:
    project_id: A02
    name: Interactive Shell Extension
    difficulty: ADVANCED
    total_points: 110
    auto_evaluable_percent: 75
    estimated_test_time: 12m
    required_tools:
    - gcc
    - make
    - readline-dev
    historical_declared_total_points: 100
    test_count: 17
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  build_tests:
  - id: build_01
    name: Compile libshellext
    command: make -C src/c
    expect:
      path:
        kind: file
        path: build/libshellext.so
    points: 10
    category: build_tests
  - id: build_02
    name: Link with readline
    command: ldd build/libshellext.so
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - linked_library: libreadline
    points: 5
    category: build_tests
  syntax_highlighting:
  - id: hl_01
    name: Highlight keywords (if, then, fi)
    command: echo 'if [ -f test ]; then echo found; fi' | ./highlight
    expect:
      all:
      - ansi: true
      - ansi:
        - if
        - then
        - fi
    points: 10
    category: syntax_highlighting
  - id: hl_02
    name: Highlight builtins (echo, cd)
    command: echo 'echo hello; cd /tmp' | ./highlight
    expect:
      ansi:
      - echo
      - cd
    points: 5
    category: syntax_highlighting
  - id: hl_03
    name: Highlight variables
    command: echo 'echo $HOME ${PATH}' | ./highlight
    expect:
      ansi:
      - $HOME
      - ${PATH}
    points: 5
    category: syntax_highlighting
  - id: hl_04
    name: Highlight strings
    command: echo 'echo "hello world"' | ./highlight
    expect:
      pending: 'Exact project/platform contract required for string_has_consistent_color: true'
    points: 5
    category: syntax_highlighting
  - id: hl_05
    name: Highlight comments
    command: 'echo ''echo test # comment'' | ./highlight'
    expect:
      pending: 'Exact project/platform contract required for comment_has_different_color: true'
    points: 5
    category: syntax_highlighting
  lexer:
  - id: lex_01
    name: Tokenize simple command
    command: ./tokenize 'ls -la /tmp'
    expect:
      pending: 'Exact project/platform contract required for tokens_include: ["COMMAND:ls", "OPTION:-la", "PATH:/tmp"]'
    points: 10
    category: lexer
  - id: lex_02
    name: Tokenize pipeline
    command: ./tokenize 'cat file | grep pattern | wc -l'
    expect:
      all:
      - pending: 'Exact project/platform contract required for tokens_include: ["PIPE:|"]'
      - pending: 'Exact project/platform contract required for token_count: {"PIPE": 2}'
    points: 5
    category: lexer
  - id: lex_03
    name: Tokenize redirection
    command: ./tokenize 'echo test > output.txt 2>&1'
    expect:
      pending: 'Exact project/platform contract required for tokens_include: ["REDIRECT:>", "REDIRECT:2>&1"]'
    points: 5
    category: lexer
  completion:
  - id: comp_01
    name: Complete 'gre' -> 'grep'
    setup: ./load_commands
    command: ./complete 'gre'
    expect:
      text:
        stream: stdout
        op: contains
        value: grep
    points: 10
    category: completion
  - id: comp_02
    name: Multiple completions for 'ca'
    command: ./complete 'ca'
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: cat
        - text:
            stream: stdout
            op: contains
            value: cal
      - lines:
          stream: stdout
          op: ge
          value: 2
    points: 5
    category: completion
  - id: comp_03
    name: No completion for non-existent prefix
    command: ./complete 'xyznonexistent'
    expect:
      text:
        stream: stdout
        op: equals
        value: ''
    points: 5
    category: completion
  - id: comp_04
    name: Trie handles many commands
    setup: |
      # Load all commands from PATH
      ./load_commands --all
    command: ./complete 's' | wc -l
    expect:
      output_number:
        op: ge
        value: 10
    points: 5
    category: completion
  integration:
  - id: int_01
    name: Loader function is defined in the explicitly sourced child shell
    command: bash --noprofile --norc -c 'source ./shellext.sh; declare -F _shellext_complete'
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - text:
          stream: stdout
          op: contains
          value: _shellext_complete
    points: 5
    category: integration
    notes: This does not prove live readline highlighting or current-shell library loading.
  - id: int_02
    name: Highlighting in interactive mode
    command: ./test_interactive.sh
    expect:
      exit_code:
        op: eq
        value: 0
    points: 5
    may_require_pty: true
    category: integration
    requires_platform: an owned PTY and the completed live readline bridge
  memory_tests:
  - id: mem_01
    name: Trie - no memory leaks
    command: valgrind --error-exitcode=97 --leak-check=full ./complete 'test' 2>&1
    expect:
      exit_code:
        op: eq
        value: 0
    points: 10
    category: memory_tests
    notes: A clean bounded Valgrind run is evidence for this execution only; missing tools, ptrace restrictions or lifecycle failures are unavailable, not a pass.
    requires_platform: compatible local Valgrind runtime and completed project command
  manual_evaluation_required:
  - criterion: User experience (UX)
    reason: Requires manual testing in real terminal
    impact: 15%
  - criterion: Colour/theme quality
    reason: Subjective aesthetics
    impact: 5%
  - criterion: Performance in real terminal
    reason: Perceptible lag is subjective
    impact: 5%
```

---

## A03: Distributed File Sync

```yaml
# Retained historical inline notes; the Phase 5 status above governs evidence/policy.
# Create test files
# === HASHING ===
# === SIGNATURE GENERATION ===
# 10MB / block_size = multiple lines
# === ROLLING HASH & DELTA ===
# Delta must be much smaller than original file
# For totally different files, delta ~ new file size
# === COMPLETE SYNC ===
# === CONFLICT DETECTION ===
a03_distributed_file_sync:
  metadata:
    project_id: A03
    name: Distributed File Sync
    difficulty: ADVANCED
    total_points: 120
    auto_evaluable_percent: 85
    estimated_test_time: 15m
    required_tools:
    - gcc
    - make
    - openssl
    - inotify-tools
    historical_declared_total_points: 100
    test_count: 14
    policy_status: proposal_not_adopted
    evidence_status: unmeasured_planning_estimate
    fixture_lifecycle: fresh project copy and inherited setup per case; unconditional owned cleanup
  setup:
    commands:
    - |
      # Create test files
      mkdir -p "${FIXTURE_ROOT}"/a03_test/{source,dest}
      dd if=/dev/urandom of="${FIXTURE_ROOT}"/a03_test/source/file1.bin bs=1M count=10 2>/dev/null
      dd if=/dev/urandom of="${FIXTURE_ROOT}"/a03_test/source/file2.bin bs=1K count=500 2>/dev/null
      echo "small text file" > "${FIXTURE_ROOT}"/a03_test/source/text.txt
  build_tests:
  - id: build_01
    name: Compile libsyncutil
    command: make -C src/c
    expect:
      path:
        kind: file
        path: build/libsyncutil.so
    points: 10
    category: build_tests
  - id: build_02
    name: Link with OpenSSL
    command: ldd build/libsyncutil.so
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - linked_library: libcrypto
    points: 5
    category: build_tests
  hashing:
  - id: hash_01
    name: 'PENDING_CLI_ADAPTER: adopted SHA-256 file format'
    command: ./bin/synctool hash "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    expect:
      pending: D6 fixes SHA-256 and stdout as the exact 64-character lower-case digest plus one newline. Validate the student CLI adapter and owned fixtures before replacing this pending predicate; no complete CLI is supplied by the local reference.
    points: 5
    category: hashing
    setup: printf abc > "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    historical_command: ./bin/synctool hash /tmp/a03_test/source/text.txt
    notes: 'Adopted abc stdout is ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad followed by exactly one newline; status 0, no diagnostics. Error paths require non-zero status and no success digest. The local C tests do not validate the omitted CLI.'
  - id: hash_02
    name: Hash consistent
    command: ./bin/synctool hash "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    expect:
      pending: D6 fixes SHA-256 and stdout as the exact 64-character lower-case digest plus one newline. Validate the student CLI adapter and owned fixtures before replacing this pending predicate; no complete CLI is supplied by the local reference.
    points: 5
    category: hashing
    setup: printf abc > "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    historical_command: |
      h1=$(./bin/synctool hash /tmp/a03_test/source/text.txt)
      h2=$(./bin/synctool hash /tmp/a03_test/source/text.txt)
      [ "$h1" = "$h2" ] && echo "consistent"
    notes: 'Adopted abc stdout is ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad followed by exactly one newline; status 0, no diagnostics. Error paths require non-zero status and no success digest. The local C tests do not validate the omitted CLI.'
  - id: hash_03
    name: Hash different for different files
    command: ./bin/synctool hash "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    expect:
      pending: D6 fixes SHA-256 and stdout as the exact 64-character lower-case digest plus one newline. Validate the student CLI adapter and owned fixtures before replacing this pending predicate; no complete CLI is supplied by the local reference.
    points: 5
    category: hashing
    setup: printf abc > "${FIXTURE_ROOT}"/a03_test/source/known-vector.txt
    historical_command: |
      h1=$(./bin/synctool hash /tmp/a03_test/source/file1.bin)
      h2=$(./bin/synctool hash /tmp/a03_test/source/file2.bin)
      [ "$h1" != "$h2" ] && echo "different"
    notes: 'Adopted abc stdout is ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad followed by exactly one newline; status 0, no diagnostics. Error paths require non-zero status and no success digest. The local C tests do not validate the omitted CLI.'
  signatures:
  - id: sig_01
    name: Generate signature
    command: ./bin/synctool signature "${FIXTURE_ROOT}"/a03_test/source/file1.bin
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/a03_test/source/file1.bin.sig
    points: 10
    category: signatures
  - id: sig_02
    name: Signature contains block hashes
    command: cat "${FIXTURE_ROOT}"/a03_test/source/file1.bin.sig | wc -l
    expect:
      pending: Signature serialization is not defined by a line count; validate the versioned binary/text schema and exact block signatures after the author selects the protocol.
    points: 5
    category: signatures
  delta_sync:
  - id: delta_01
    name: Delta for slightly modified file
    setup: |
      cp "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin
      echo "small change" >> "${FIXTURE_ROOT}"/a03_test/modified.bin
    command: ./bin/synctool delta "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - path:
          kind: file
          path: ${FIXTURE_ROOT}/a03_test/modified.bin.delta
      - pending: 'Exact project/platform contract required for delta_size_percent_max: 10'
    points: 15
    category: delta_sync
  - id: delta_02
    name: Delta for completely different file
    command: ./bin/synctool delta "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/source/file2.bin
    expect:
      pending: 'Exact project/platform contract required for delta_size_percent_min: 80'
    points: 5
    category: delta_sync
  - id: delta_03
    name: Apply delta reconstructs file
    setup: |-
      cp "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin
      printf "small change\n" >> "${FIXTURE_ROOT}"/a03_test/modified.bin
      ./bin/synctool signature "${FIXTURE_ROOT}"/a03_test/source/file1.bin
      ./bin/synctool delta "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin
    command: |
      ./bin/synctool apply "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin.delta -o "${FIXTURE_ROOT}"/a03_test/result.bin
      diff "${FIXTURE_ROOT}"/a03_test/modified.bin "${FIXTURE_ROOT}"/a03_test/result.bin && echo "identical"
    expect:
      text:
        stream: stdout
        op: contains
        value: identical
    points: 15
    category: delta_sync
  full_sync:
  - id: sync_01
    name: Sync directory
    command: ./sync.sh "${FIXTURE_ROOT}"/a03_test/source "${FIXTURE_ROOT}"/a03_test/dest
    expect:
      all:
      - exit_code:
          op: eq
          value: 0
      - files_equal:
        - ${FIXTURE_ROOT}/a03_test/source/text.txt
        - ${FIXTURE_ROOT}/a03_test/dest/text.txt
    points: 10
    category: full_sync
    requires_platform: completed A03 transport/conflict adapter in an isolated owned endpoint fixture
  - id: sync_02
    name: Incremental sync - transfers only diff
    setup: |
      ./sync.sh "${FIXTURE_ROOT}"/a03_test/source "${FIXTURE_ROOT}"/a03_test/dest
      echo "new content" >> "${FIXTURE_ROOT}"/a03_test/source/text.txt
    command: ./sync.sh "${FIXTURE_ROOT}"/a03_test/source "${FIXTURE_ROOT}"/a03_test/dest --verbose 2>&1
    expect:
      all:
      - all:
        - text:
            stream: stdout
            op: contains
            value: delta
        - text:
            stream: stdout
            op: contains
            value: text.txt
      - not:
          text:
            stream: stdout
            op: contains
            value: full transfer
    points: 10
    category: full_sync
    requires_platform: completed A03 transport/conflict adapter in an isolated owned endpoint fixture
  conflicts:
  - id: conf_01
    name: Detect conflict
    setup: |
      echo "source version" > "${FIXTURE_ROOT}"/a03_test/source/conflict.txt
      echo "dest version" > "${FIXTURE_ROOT}"/a03_test/dest/conflict.txt
    command: ./sync.sh "${FIXTURE_ROOT}"/a03_test/source "${FIXTURE_ROOT}"/a03_test/dest 2>&1
    expect:
      any:
      - text:
          stream: stdout
          op: contains
          value: conflict
      - text:
          stream: stdout
          op: contains
          value: CONFLICT
    points: 10
    category: conflicts
    requires_platform: completed A03 transport/conflict adapter in an isolated owned endpoint fixture
  memory_tests:
  - id: mem_01
    name: No memory leaks in delta generation
    command: valgrind --error-exitcode=97 --leak-check=full ./bin/synctool delta "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin 2>&1
    expect:
      exit_code:
        op: eq
        value: 0
    points: 10
    category: memory_tests
    setup: |-
      cp "${FIXTURE_ROOT}"/a03_test/source/file1.bin "${FIXTURE_ROOT}"/a03_test/modified.bin
      printf "small change\n" >> "${FIXTURE_ROOT}"/a03_test/modified.bin
    notes: A clean bounded Valgrind run is evidence for this execution only; missing tools, ptrace restrictions or lifecycle failures are unavailable, not a pass.
    requires_platform: compatible local Valgrind runtime and completed project command
  manual_evaluation_required:
  - criterion: Efficiency of rsync algorithm
    reason: Depends on block size and rolling hash strategy
    impact: 10%
  - criterion: Communication protocol
    reason: Requires testing with real network
    impact: 5%
  - criterion: Conflict resolution
    reason: Multiple valid strategies (last-write-wins, merge, prompt)
    impact: 5%
```

---

## Summary A01-A03: What Requires Additional or Human Evidence

| Project | Criterion | Impact | Technical Reason |
|---------|-----------|--------|------------------|
| **A01** | Scheduling correctness | 10% | Requires temporal analysis |
| **A01** | C code quality | 5% | Subjective style |
| **A01** | Crash robustness | 5% | Difficult to simulate |
| **A02** | Real terminal UX | 15% | Requires manual testing |
| **A02** | Colour aesthetics | 5% | Personal preferences |
| **A02** | Perceptible performance | 5% | Subjective |
| **A03** | rsync efficiency | 10% | Depends on parameters |
| **A03** | Network protocol | 5% | Requires infrastructure |
| **A03** | Conflict strategy | 5% | Multiple valid approaches |

**Total not automatically evaluable for ADVANCED: ~15-25% per project**

---

## Special Tools Required for ADVANCED

```yaml
advanced_sandbox_requirements:
  compilers:
  - gcc >= 9.0
  - make
  libraries:
  - libc-dev
  - libreadline-dev
  - libssl-dev
  - libpthread (standard)
  debugging:
  - valgrind
  - gdb
  - strace
  runtime:
  - /dev/shm access (shared memory)
  - inotify-tools
  - openssl CLI
  docker_config:
    privileged: false
    capabilities:
    - SYS_PTRACE
    shm_size: 256m
  timeout_per_test: 120s
  total_timeout: 30m
```
