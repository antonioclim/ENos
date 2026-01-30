# CAPSTONE: Integrated System Administration Projects

> Lab observation: don't wait for "the end" to deploy. An ugly but functional deployment in week 1–2 usually beats a perfect deployment attempted the last evening. Do it early and iterate.
## Operating Systems - Seminars 11-12

### Bucharest University of Economic Studies
### CSIE Faculty - Cybernetics, Statistics and Economic Informatics

---

## 1. Project Context and Motivation

The CAPSTONE project represents the culminating point of the Operating Systems course, 
synthesising competencies accumulated throughout the semester into an integrated practical 
experience. Unlike the isolated exercises from previous seminars, CAPSTONE requires 
students to build complete, functional software systems suitable for real production 
contexts.

### 1.1 The Fundamental Problem

System administrators and DevOps engineers face three essential categories of tasks 
daily which, although appearing distinct, share common foundations:

Resource monitoring - Understanding the current system state requires continuous 
interrogation of Linux kernel subsystems through /proc and /sys interfaces, aggregating 
data into a comprehensible form and detecting anomalies requiring intervention. An 
efficient monitoring system must operate with minimal overhead, persist historical 
data for analysis and trigger alerts when parameters exceed acceptable thresholds.

Backup and recovery - Protecting data against accidental loss or corruption represents 
a critical responsibility. A solid backup system must manage efficient compression, 
integrity verification through checksums, incremental backup for optimising space and 
time, plus reliable restoration procedures tested regularly.

Application deployment - Delivering software to production requires careful orchestration 
of multiple steps: stopping existing services, copying new files, configuring the 
environment, starting services and verifying functionality. Modern strategies such as 
blue-green and canary deployment minimise downtime risk and allow rapid rollback when 
problems occur.

### 1.2 Why Bash?

Choosing Bash as the primary language for CAPSTONE is deliberate and pedagogical:

Ubiquity - Bash exists on virtually any Unix-like system, from enterprise servers to 
embedded devices. The competencies gained transfer directly to any professional 
environment.

Direct system interaction - Unlike high-level languages that abstract the operating 
system, Bash directly exposes OS primitives: processes, file descriptors, signals, 
exit codes. This transparency consolidates deep understanding of underlying mechanisms.

Instructive constraints - Bash lacks sophisticated data structures, automatic memory 
management or extensive libraries. These "deficiencies" force explicit algorithmic 
thinking and appreciation for elegant solutions within constraints.

Professional realism - Bash scripts of similar complexity exist in production at 
companies of all sizes. The CAPSTONE experience prepares students for real code, 
not just academic exercises.

---

## 2. Learning Objectives

The CAPSTONE project targets competency development across multiple cognitive levels, 
following progression from factual knowledge to creative synthesis.

### 2.1 Knowledge and Understanding

Upon project completion, students will demonstrate knowledge of:

- Linux file system anatomy - hierarchical organisation, the role of standard 
  directories (/proc, /sys, /etc, /var), distinction between regular files, 
  devices and pseudo-files
  
- Inter-process communication mechanisms - pipes, FIFOs, POSIX signals, 
  environment variables, file descriptors
  
- Process lifecycle - fork/exec, zombies, orphans, process groups, 
  sessions, daemonisation
  
- Kernel monitoring subsystems - /proc/stat, /proc/meminfo, /proc/diskstats, 
  /sys/class, as well as associated userspace utilities

### 2.2 Application and Analysis

Students will demonstrate the ability to:

- Design modular architectures - decomposing complex problems into reusable 
  components with clearly defined interfaces
  
- Implement solid error handling - anticipating failure modes, propagating 
  errors through exit codes, structured logging, cleanup on termination
  
- Apply DRY (Don't Repeat Yourself) principles - abstracting common code 
  into shared functions and libraries
  
- Analyse trade-offs - evaluating compromises between performance, 
  complexity, maintainability and portability

### 2.3 Synthesis and Evaluation

The advanced level requires:

- Component integration - combining modules into a coherent system where 
  parts collaborate without friction
  
- Systematic testing - writing unit and integration tests, automating 
  validation, interpreting results
  
- Code quality evaluation - applying style standards, identifying code 
  smells, refactoring for clarity
  
- Professional documentation - writing technical documentation that serves 
  both users and future developers

---

## 3. General Architecture

The three CAPSTONE projects share a common architecture promoting consistency, 
code reuse and long-term maintainability.

### 3.1 Directory Structure

```
project/
├── project.sh              # Main script - entry point
├── bin/
│   └── sysproject          # Wrapper for system installation
├── etc/
│   ├── project.conf        # Main configuration
│   └── project.conf.example
├── lib/
│   ├── core/               # Central functionality
│   │   ├── config.sh       # Configuration loading and validation
│   │   ├── engine.sh       # Main business logic
│   │   └── parser.sh       # Command line argument parsing
│   └── utils/              # General utilities
│       ├── common.sh       # General helper functions
│       ├── logging.sh      # Logging system
│       └── validation.sh   # Input validation
├── var/
│   ├── log/                # Log files
│   ├── run/                # PID files, sockets
│   └── lib/                # Persistent data
└── tests/
    ├── unit/               # Unit tests per module
    ├── integration/        # Component integration tests
    └── fixtures/           # Test data
```

### 3.2 Architectural Principles

Separation of responsibilities - Each module has a single clearly defined 
responsibility. `logging.sh` manages logging exclusively, `config.sh` manages 
configuration exclusively. This separation enables isolated testing and 
independent modification.

Dependency inversion - High-level modules do not depend on concrete 
implementations but on abstractions. The main script calls functions with 
semantic names (`log_info`, `load_config`) without knowing implementation details.

Externalised configuration - Variable parameters are extracted into 
configuration files, not hardcoded in scripts. This allows adjusting behaviour 
without modifying source code.

Fail-fast with cleanup - Errors are detected as early as possible, and 
allocated resources are guaranteed to be released through EXIT traps.

### 3.3 Standard Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    INITIALISATION                           │
├─────────────────────────────────────────────────────────────┤
│  1. Determine script absolute path                          │
│  2. Source libraries from lib/                              │
│  3. Setup traps for cleanup                                 │
│  4. Parse command line arguments                            │
│  5. Load and validate configuration                         │
│  6. Initialise logging                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION                               │
├─────────────────────────────────────────────────────────────┤
│  1. Check dependencies (external commands)                  │
│  2. Check permissions (files, directories)                  │
│  3. Validate parameters                                     │
│  4. Check precursor conditions                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXECUTION                                │
├─────────────────────────────────────────────────────────────┤
│  1. Execute main operation                                  │
│  2. Log progress and results                                │
│  3. Handle intermediate errors                              │
│  4. Update persistent state                                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    FINALISATION                             │
├─────────────────────────────────────────────────────────────┤
│  1. Summarise results                                       │
│  2. Cleanup temporary resources                             │
│  3. Exit with appropriate code                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Project Presentation

### 4.1 System Monitor

Purpose: Collecting and reporting system performance metrics in real time, 
with support for alerting based on configurable thresholds.

Main functionalities:
- CPU monitoring (per-core utilisation, load average, processes)
- Memory monitoring (RAM, swap, cache, buffers)
- Disk monitoring (space, I/O, latencies)
- Network monitoring (throughput, connections, errors)
- Daemon mode with configurable interval
- Alerting through various channels (log, email, webhook)
- Data export in multiple formats (text, JSON, CSV)

Key concepts: parsing /proc, floating-point arithmetic in Bash, 
threshold detection, daemon mode, signal handling.

### 4.2 Backup System

Purpose: Automating backups with support for compression, integrity 
verification, incremental backup and selective restoration.

Main functionalities:
- Full and incremental backup
- Multiple compression (gzip, bzip2, xz, zstd)
- Integrity verification (MD5, SHA-1, SHA-256)
- Configurable pattern exclusion
- Automatic rotation (keep N backups)
- Complete or selective restoration
- Statistics reporting (size, duration, rates)

Key concepts: tar archives, compression algorithms, checksums, 
incremental backup via find, file pattern matching, rotation policies.

### 4.3 Application Deployer

Purpose: Orchestrating application deployment with support for advanced 
strategies and automatic rollback.

Main functionalities:
- Simple and scripted deployment
- Advanced strategies (blue-green, canary, rolling)
- Configurable health checks (HTTP, TCP, process, command)
- Automatic rollback on failure
- Hook system (pre/post deploy, on error)
- YAML manifest for declarative configuration
- Version and history management

Key concepts: deployment strategies, health checking, service 
management, process signals, atomic operations, state management.

---

## 5. Relationship Between Projects

The three projects are not isolated but form an integrated environment:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         INFRASTRUCTURE                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │   MONITOR   │    │   BACKUP    │    │  DEPLOYER   │             │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘             │
│         │                  │                  │                     │
│         └──────────────────┼──────────────────┘                     │
│                            │                                        │
│                   ┌────────┴────────┐                               │
│                   │    SHARED       │                               │
│                   │   LIBRARIES     │                               │
│                   │                 │                               │
│                   │  • logging.sh   │                               │
│                   │  • common.sh    │                               │
│                   │  • validation.sh│                               │
│                   └─────────────────┘                               │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    TESTING FRAMEWORK                         │   │
│  │         test_runner.sh  •  test_helpers.sh                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SYSTEM UTILITIES                          │   │
│  │  install.sh • uninstall.sh • check_dependencies.sh           │   │
│  │  generate_configs.sh                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

Integration scenarios:

1. Monitor + Deployer: The monitor verifies system health before and after 
   deployment, triggering rollback if metrics degrade.

2. Backup + Deployer: Automatic configuration backup before deploy, with 
   restoration on rollback.

3. Monitor + Backup: Alerting when backup space decreases, monitoring 
   backup duration and success.

---

## 6. Working Methodology

### 6.1 Incremental Approach

Projects are designed for incremental development:

Phase 1 - Functional prototype (week 11)
- Basic functionality implementation
- Directory and file structure
- Initial tests

Phase 2 - Consolidation (week 12)
- Complete error handling
- Logging and configuration
- Complete tests

Phase 3 - Refinement (individual)
- Performance optimisations
- Documentation
- Advanced functionalities

### 6.2 Continuous Testing

The integrated testing framework allows progress verification:

```bash
# Run all tests for a project
./test_runner.sh --project monitor

# Run only unit tests
./test_runner.sh --project backup --type unit

# Run with verbose output
./test_runner.sh --project deployer --verbose
```

### 6.3 Versioning and Collaboration

Although not mandatory for the seminar, Git usage is recommended:

```bash
# Initialise repository
cd SEM11-12_COMPLETE
git init
git add .
git commit -m "Initial CAPSTONE structure"

# After each completed functionality
git add -p  # review changes
git commit -m "feat(monitor): add CPU monitoring"
```

---

## 7. Evaluation

### 7.1 Evaluation Criteria

| Criterion                 | Weight  | Description                                  |
|---------------------------|---------|----------------------------------------------|
| Functionality             | 40%     | Correct implementation of requirements       |
| Code quality              | 25%     | Structure, readability, best practices       |
| Error handling            | 15%     | Solid error management                       |
| Testing                   | 10%     | Relevant and complete tests                  |
| Documentation             | 10%     | README, comments, help text                  |

### 7.2 Achievement Levels

Base Level (score 50-69%):

Three things matter here: main functionality implemented, script runs without critical errors and basic configuration functional.


Intermediate Level (score 70-84%):
- All functionalities implemented
- Error handling for common cases
- Functional logging
- Basic tests

Advanced Level (score 85-100%):
- Extra functionalities (optional)
- Complete error handling
- Extensive tests
- Complete documentation
- Optimised and elegant code

---

## 8. Resources and References

### 8.1 Official Documentation

- Bash Reference Manual: https://www.gnu.org/software/bash/manual/
- Linux man pages: `man bash`, `man test`, `man find`, `man tar`
- Filesystem Hierarchy Standard: https://refspecs.linuxfoundation.org/FHS_3.0/

### 8.2 Recommended Books

- Shotts, William E. "The Linux Command Line" (available free online)
- Robbins, Arnold & Beebe, Nelson. "Classic Shell Scripting", O'Reilly
- Cooper, Mendel. "Advanced Bash-Scripting Guide" (TLDP)

### 8.3 Articles and Tutorials

- Greg's Wiki (mywiki.wooledge.org) - Bash best practices
- ShellCheck (shellcheck.net) - static analysis for shell scripts
- Explain Shell (explainshell.com) - command explanations

---

## 9. Conclusion

The CAPSTONE project transforms theoretical knowledge into practical competencies 
immediately applicable in industry. By building these systems from scratch, 
students directly experience the challenges of real software development: 
complexity management, architectural compromises, systematic testing and 
clear documentation.

More than simple programming exercises, these projects cultivate the engineering 
mindset - the ability to analyse problems, decompose solutions, anticipate 
failure modes and build solid systems that function in real conditions, not 
just ideal laboratory scenarios.

Good luck with implementation!

---

*Document updated: January 2026*
*Version: 1.0*
*Author: Operating Systems Team, ASE-CSIE*
