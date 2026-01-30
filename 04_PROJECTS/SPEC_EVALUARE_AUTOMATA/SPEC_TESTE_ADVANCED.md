# Detailed Test Specifications - ADVANCED Projects (A01-A03)

## General Note

ADVANCED projects require:
- **C Compilation**: GCC, Make, development libraries
- **Memory tests**: Valgrind for leak detection
- **Concurrency tests**: Race condition verification
- **Shared memory**: Access to /dev/shm
- **Debugging tools**: GDB, strace

---

## A01: Mini Job Scheduler

```yaml
a01_mini_job_scheduler:
  metadata:
    project_id: A01
    name: "Mini Job Scheduler"
    difficulty: ADVANCED
    total_points: 100
    auto_evaluable_percent: 85
    estimated_test_time: 15m
    required_tools: [gcc, make, valgrind, gdb]

  # === BUILD PHASE ===
  build_tests:
    - id: build_01
      name: "Compile C library"
      command: "make -C src/c 2>&1"
      expect:
        exit_code: 0
        file_exists: "build/libjobqueue.so"
      points: 10
      category: build
      
    - id: build_02
      name: "Compile CLI tool"
      command: "make"
      expect:
        exit_code: 0
        file_exists: "bin/jobctl"
        file_executable: "bin/jobctl"
      points: 5
      category: build
      
    - id: build_03
      name: "Compile without warnings"
      command: "make clean && make 2>&1 | grep -c 'warning:'"
      expect:
        output_matches_regex: "^0$"
      points: 5
      category: build

  # === C FUNCTIONALITY ===
  c_functionality:
    - id: c_func_01
      name: "Initialise shared memory"
      command: "./bin/jobctl init"
      expect:
        exit_code: 0
        shm_exists: "/dev/shm/jobscheduler"
      points: 5
      
    - id: c_func_02
      name: "Submit simple job"
      command: "./bin/jobctl submit 'echo test'"
      expect:
        exit_code: 0
        output_matches_regex: "Job.*#[0-9]+"
      points: 5
      
    - id: c_func_03
      name: "List jobs"
      setup: |
        ./bin/jobctl init
        ./bin/jobctl submit 'sleep 10'
        ./bin/jobctl submit 'echo hello'
      command: "./bin/jobctl list"
      expect:
        exit_code: 0
        output_contains: ["sleep", "echo"]
        line_count_min: 2
      points: 5
      
    - id: c_func_04
      name: "Cancel job"
      setup: "./bin/jobctl submit 'sleep 100'"
      command: "./bin/jobctl cancel 1"
      expect:
        exit_code: 0
      points: 5
      
    - id: c_func_05
      name: "Job status"
      setup: "./bin/jobctl submit 'sleep 5'"
      command: "./bin/jobctl status 1"
      expect:
        output_contains_one_of: ["pending", "running", "PENDING", "RUNNING"]
      points: 5

  # === PRIORITY QUEUE (Heap) ===
  priority_queue:
    - id: pq_01
      name: "Priority ordering - high first"
      setup: |
        ./bin/jobctl init
        ./bin/jobctl submit -p 10 'echo low'
        ./bin/jobctl submit -p 1 'echo high'
        ./bin/jobctl submit -p 5 'echo medium'
      command: "./bin/jobctl list --by-priority"
      expect:
        # First job must be the one with priority 1 (highest)
        first_line_contains: "high"
      points: 10
      
    - id: pq_02
      name: "Heap property maintained after multiple ops"
      setup: |
        ./bin/jobctl init
        for i in $(seq 1 20); do
          ./bin/jobctl submit -p $((RANDOM % 100)) "job_$i"
        done
      command: "./bin/jobctl list --by-priority | head -5"
      expect:
        output_is_sorted_by_priority: true
      points: 10

  # === SHARED MEMORY & SEMAPHORES ===
  ipc_tests:
    - id: ipc_01
      name: "Shared memory created correctly"
      command: "ls -la /dev/shm/ | grep jobscheduler"
      expect:
        output_contains: "jobscheduler"
      points: 5
      
    - id: ipc_02
      name: "Concurrent access - no corruption"
      command: |
        ./bin/jobctl init
        # 10 simultaneous submit processes
        for i in $(seq 1 10); do
          ./bin/jobctl submit "concurrent_$i" &
        done
        wait
        ./bin/jobctl list | wc -l
      expect:
        # All 10 jobs must be present
        output_matches_regex: "^1[0-9]$"
      points: 15
      timeout: 30
      
    - id: ipc_03
      name: "Semaphore prevents race condition"
      command: |
        ./bin/jobctl init
        # Stress test
        for i in $(seq 1 100); do
          (./bin/jobctl submit "stress_$i" && ./bin/jobctl list > /dev/null) &
        done
        wait
        ./bin/jobctl stats
      expect:
        exit_code: 0
        output_contains: "submitted"
        # Must not crash or corrupt
      points: 10
      timeout: 60

  # === MEMORY SAFETY ===
  memory_tests:
    - id: mem_01
      name: "Valgrind - no memory leaks in jobctl"
      command: "valgrind --leak-check=full --error-exitcode=1 ./bin/jobctl submit 'test' 2>&1"
      expect:
        exit_code: 0
        output_contains: "no leaks are possible"
      points: 10
      timeout: 30
      
    - id: mem_02
      name: "Valgrind - no invalid reads/writes"
      command: "valgrind --track-origins=yes --error-exitcode=1 ./bin/jobctl list 2>&1"
      expect:
        output_not_contains: ["Invalid read", "Invalid write"]
      points: 5

  # === BASH-C INTEGRATION ===
  integration:
    - id: int_01
      name: "Bash wrapper works"
      command: "./scheduler.sh submit 'echo from bash'"
      expect:
        exit_code: 0
        output_matches_regex: "Job.*[0-9]+"
      points: 5
      
    - id: int_02
      name: "Library path correct"
      command: "ldd ./bin/jobctl | grep libjobqueue"
      expect:
        output_contains: "libjobqueue"
      points: 5

  # === ERROR HANDLING ===
  errors:
    - id: err_01
      name: "Duplicate init - handle gracefully"
      setup: "./bin/jobctl init"
      command: "./bin/jobctl init 2>&1"
      expect:
        exit_code: 0
        output_contains_one_of: ["already", "exists", "reusing"]
      points: 3
      
    - id: err_02
      name: "Cancel non-existent job"
      command: "./bin/jobctl cancel 99999 2>&1"
      expect:
        exit_code: "!= 0"
        output_contains_one_of: ["not found", "invalid", "error"]
      points: 3
      
    - id: err_03
      name: "Submit with empty command"
      command: "./bin/jobctl submit '' 2>&1"
      expect:
        exit_code: "!= 0"
      points: 2

  cleanup:
    - "./bin/jobctl destroy 2>/dev/null"
    - "rm -f /dev/shm/jobscheduler*"

  manual_evaluation_required:
    - criterion: "Correctness of scheduling algorithm"
      reason: "Fair-share and priority require analysis of execution times"
      impact: "10%"
      
    - criterion: "C code quality"
      reason: "Style, organisation, comments - subjective"
      impact: "5%"
      
    - criterion: "Robustness to crashes"
      reason: "Difficult to test recovery after kill -9"
      impact: "5%"
```

---

## A02: Interactive Shell Extension

```yaml
a02_interactive_shell_extension:
  metadata:
    project_id: A02
    name: "Interactive Shell Extension"
    difficulty: ADVANCED
    total_points: 100
    auto_evaluable_percent: 75
    estimated_test_time: 12m
    required_tools: [gcc, make, readline-dev]

  build_tests:
    - id: build_01
      name: "Compile libshellext"
      command: "make -C src/c"
      expect:
        file_exists: "build/libshellext.so"
      points: 10
      
    - id: build_02
      name: "Link with readline"
      command: "ldd build/libshellext.so | grep readline"
      expect:
        output_contains: "readline"
      points: 5

  # === SYNTAX HIGHLIGHTING ===
  syntax_highlighting:
    - id: hl_01
      name: "Highlight keywords (if, then, fi)"
      command: "echo 'if [ -f test ]; then echo found; fi' | ./highlight"
      expect:
        output_contains_ansi: true
        # Verify that 'if', 'then', 'fi' have different colour
        ansi_color_for: ["if", "then", "fi"]
      points: 10
      
    - id: hl_02
      name: "Highlight builtins (echo, cd)"
      command: "echo 'echo hello; cd /tmp' | ./highlight"
      expect:
        ansi_color_for: ["echo", "cd"]
      points: 5
      
    - id: hl_03
      name: "Highlight variables"
      command: "echo 'echo $HOME ${PATH}' | ./highlight"
      expect:
        ansi_color_for: ["$HOME", "${PATH}"]
      points: 5
      
    - id: hl_04
      name: "Highlight strings"
      command: "echo 'echo \"hello world\"' | ./highlight"
      expect:
        string_has_consistent_color: true
      points: 5
      
    - id: hl_05
      name: "Highlight comments"
      command: "echo 'echo test # comment' | ./highlight"
      expect:
        comment_has_different_color: true
      points: 5

  # === LEXER/TOKENIZER ===
  lexer:
    - id: lex_01
      name: "Tokenize simple command"
      command: "./tokenize 'ls -la /tmp'"
      expect:
        tokens_include: ["COMMAND:ls", "OPTION:-la", "PATH:/tmp"]
      points: 10
      
    - id: lex_02
      name: "Tokenize pipeline"
      command: "./tokenize 'cat file | grep pattern | wc -l'"
      expect:
        tokens_include: ["PIPE:|"]
        token_count: {PIPE: 2}
      points: 5
      
    - id: lex_03
      name: "Tokenize redirection"
      command: "./tokenize 'echo test > output.txt 2>&1'"
      expect:
        tokens_include: ["REDIRECT:>", "REDIRECT:2>&1"]
      points: 5

  # === TRIE COMPLETION ===
  completion:
    - id: comp_01
      name: "Complete 'gre' -> 'grep'"
      setup: "./load_commands"
      command: "./complete 'gre'"
      expect:
        output_contains: "grep"
      points: 10
      
    - id: comp_02
      name: "Multiple completions for 'ca'"
      command: "./complete 'ca'"
      expect:
        output_contains: ["cat", "cal"]
        line_count_min: 2
      points: 5
      
    - id: comp_03
      name: "No completion for non-existent prefix"
      command: "./complete 'xyznonexistent'"
      expect:
        output_empty: true
      points: 5
      
    - id: comp_04
      name: "Trie handles many commands"
      setup: |
        # Load all commands from PATH
        ./load_commands --all
      command: "./complete 's' | wc -l"
      expect:
        output_matches_regex: "[1-9][0-9]+"
      points: 5

  # === INTEGRATION ===
  integration:
    - id: int_01
      name: "Shell extension loads"
      command: "bash --rcfile ./shellext.sh -c 'type _shellext_complete'"
      expect:
        output_contains: "function"
      points: 5
      
    - id: int_02
      name: "Highlighting in interactive mode"
      # This test is difficult - we simulate with script
      command: "./test_interactive.sh"
      expect:
        exit_code: 0
      points: 5
      may_require_pty: true

  memory_tests:
    - id: mem_01
      name: "Trie - no memory leaks"
      command: "valgrind --leak-check=full ./complete 'test' 2>&1"
      expect:
        output_contains: "no leaks"
      points: 10

  manual_evaluation_required:
    - criterion: "User experience (UX)"
      reason: "Requires manual testing in real terminal"
      impact: "15%"
      
    - criterion: "Colour/theme quality"
      reason: "Subjective aesthetics"
      impact: "5%"
      
    - criterion: "Performance in real terminal"
      reason: "Perceptible lag is subjective"
      impact: "5%"
```

---

## A03: Distributed File Sync

```yaml
a03_distributed_file_sync:
  metadata:
    project_id: A03
    name: "Distributed File Sync"
    difficulty: ADVANCED
    total_points: 100
    auto_evaluable_percent: 85
    estimated_test_time: 15m
    required_tools: [gcc, make, openssl, inotify-tools]

  setup:
    commands:
      - |
        # Create test files
        mkdir -p /tmp/a03_test/{source,dest}
        dd if=/dev/urandom of=/tmp/a03_test/source/file1.bin bs=1M count=10 2>/dev/null
        dd if=/dev/urandom of=/tmp/a03_test/source/file2.bin bs=1K count=500 2>/dev/null
        echo "small text file" > /tmp/a03_test/source/text.txt

  build_tests:
    - id: build_01
      name: "Compile libsyncutil"
      command: "make -C src/c"
      expect:
        file_exists: "build/libsyncutil.so"
      points: 10
      
    - id: build_02
      name: "Link with OpenSSL"
      command: "ldd build/libsyncutil.so | grep -E 'ssl|crypto'"
      expect:
        output_contains_one_of: ["libssl", "libcrypto"]
      points: 5

  # === HASHING ===
  hashing:
    - id: hash_01
      name: "Hash file - correct output"
      command: "./bin/synctool hash /tmp/a03_test/source/text.txt"
      expect:
        output_matches_regex: "[a-f0-9]{64}"  # SHA256
      points: 5
      
    - id: hash_02
      name: "Hash consistent"
      command: |
        h1=$(./bin/synctool hash /tmp/a03_test/source/text.txt)
        h2=$(./bin/synctool hash /tmp/a03_test/source/text.txt)
        [ "$h1" = "$h2" ] && echo "consistent"
      expect:
        output_contains: "consistent"
      points: 5
      
    - id: hash_03
      name: "Hash different for different files"
      command: |
        h1=$(./bin/synctool hash /tmp/a03_test/source/file1.bin)
        h2=$(./bin/synctool hash /tmp/a03_test/source/file2.bin)
        [ "$h1" != "$h2" ] && echo "different"
      expect:
        output_contains: "different"
      points: 5

  # === SIGNATURE GENERATION ===
  signatures:
    - id: sig_01
      name: "Generate signature"
      command: "./bin/synctool signature /tmp/a03_test/source/file1.bin"
      expect:
        exit_code: 0
        file_exists: "/tmp/a03_test/source/file1.bin.sig"
      points: 10
      
    - id: sig_02
      name: "Signature contains block hashes"
      command: "cat /tmp/a03_test/source/file1.bin.sig | wc -l"
      expect:
        # 10MB / block_size = multiple lines
        output_matches_regex: "[1-9][0-9]+"
      points: 5

  # === ROLLING HASH & DELTA ===
  delta_sync:
    - id: delta_01
      name: "Delta for slightly modified file"
      setup: |
        cp /tmp/a03_test/source/file1.bin /tmp/a03_test/modified.bin
        echo "small change" >> /tmp/a03_test/modified.bin
      command: "./bin/synctool delta /tmp/a03_test/source/file1.bin /tmp/a03_test/modified.bin"
      expect:
        exit_code: 0
        file_exists: "/tmp/a03_test/modified.bin.delta"
        # Delta must be much smaller than original file
        delta_size_percent_max: 10
      points: 15
      
    - id: delta_02
      name: "Delta for completely different file"
      command: "./bin/synctool delta /tmp/a03_test/source/file1.bin /tmp/a03_test/source/file2.bin"
      expect:
        # For totally different files, delta ~ new file size
        delta_size_percent_min: 80
      points: 5
      
    - id: delta_03
      name: "Apply delta reconstructs file"
      setup: |
        ./bin/synctool signature /tmp/a03_test/source/file1.bin
        ./bin/synctool delta /tmp/a03_test/source/file1.bin /tmp/a03_test/modified.bin
      command: |
        ./bin/synctool apply /tmp/a03_test/source/file1.bin /tmp/a03_test/modified.bin.delta -o /tmp/a03_test/result.bin
        diff /tmp/a03_test/modified.bin /tmp/a03_test/result.bin && echo "identical"
      expect:
        output_contains: "identical"
      points: 15

  # === COMPLETE SYNC ===
  full_sync:
    - id: sync_01
      name: "Sync directory"
      command: "./sync.sh /tmp/a03_test/source /tmp/a03_test/dest"
      expect:
        exit_code: 0
        files_match: ["/tmp/a03_test/source/text.txt", "/tmp/a03_test/dest/text.txt"]
      points: 10
      
    - id: sync_02
      name: "Incremental sync - transfers only diff"
      setup: |
        ./sync.sh /tmp/a03_test/source /tmp/a03_test/dest
        echo "new content" >> /tmp/a03_test/source/text.txt
      command: "./sync.sh /tmp/a03_test/source /tmp/a03_test/dest --verbose 2>&1"
      expect:
        output_contains: ["delta", "text.txt"]
        output_not_contains: "full transfer"
      points: 10

  # === CONFLICT DETECTION ===
  conflicts:
    - id: conf_01
      name: "Detect conflict"
      setup: |
        echo "source version" > /tmp/a03_test/source/conflict.txt
        echo "dest version" > /tmp/a03_test/dest/conflict.txt
      command: "./sync.sh /tmp/a03_test/source /tmp/a03_test/dest 2>&1"
      expect:
        output_contains: ["conflict", "CONFLICT"]
      points: 10

  memory_tests:
    - id: mem_01
      name: "No memory leaks in delta generation"
      command: "valgrind --leak-check=full ./bin/synctool delta /tmp/a03_test/source/file1.bin /tmp/a03_test/modified.bin 2>&1"
      expect:
        output_contains: "no leaks"
      points: 10

  manual_evaluation_required:
    - criterion: "Efficiency of rsync algorithm"
      reason: "Depends on block size and rolling hash strategy"
      impact: "10%"
      
    - criterion: "Communication protocol"
      reason: "Requires testing with real network"
      impact: "5%"
      
    - criterion: "Conflict resolution"
      reason: "Multiple valid strategies (last-write-wins, merge, prompt)"
      impact: "5%"
```

---

## Summary A01-A03: What CANNOT Be Evaluated Automatically

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
      - SYS_PTRACE  # for valgrind/gdb
    shm_size: "256m"
    
  timeout_per_test: 120s
  total_timeout: 30m
```
