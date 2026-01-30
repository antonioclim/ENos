# 📁 Project Evaluation — Automated Testing

> **Location:** `SEM07/project_evaluation/`  
> **Purpose:** Automated project testing in isolated Docker containers  
> **Audience:** Instructors and evaluation system

## Contents

| File | Purpose |
|------|---------|
| `run_auto_eval_EN.sh` | Main evaluation orchestration script |
| `Docker/Dockerfile` | Isolated test environment |
| `manual_eval_checklist_EN.md` | Manual evaluation criteria |
| `oral_defence_questions_EN.md` | Interview question bank |

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ Student Project │     │  Docker Build    │     │  Run Tests      │
│   (tarball)     │ ──► │  + Copy files    │ ──► │  + Collect      │
│                 │     │  + Install deps  │     │    results      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
                                                  ┌─────────────────┐
                                                  │ Grade Report    │
                                                  │ + Feedback      │
                                                  └─────────────────┘
```

---

## run_auto_eval_EN.sh

### Usage

```bash
./run_auto_eval_EN.sh <project> [options]

Arguments:
  project           Project tarball or directory

Options:
  --timeout SEC     Total evaluation timeout (default: 300)
  --memory MB       Memory limit for container (default: 512)
  --parallel N      Evaluate N projects simultaneously
  --output DIR      Output directory for results
  --keep-container  Don't remove container after eval (debugging)
  --no-network      Disable network in container (default)
  --verbose         Show detailed execution log
```

### Examples

```bash
# Evaluate single project
./run_auto_eval_EN.sh student123_project.tar.gz

# Batch evaluation
./run_auto_eval_EN.sh projects/ --parallel 4 --output results/

# Debugging mode
./run_auto_eval_EN.sh project.tar.gz --keep-container --verbose
```

---

## Docker Environment

### Dockerfile

Built from `Docker/Dockerfile`:

```dockerfile
FROM ubuntu:24.04

# Install course dependencies
RUN apt-get update && apt-get install -y \
    bash \
    python3 \
    shellcheck \
    make \
    ...

# Security: non-root user
RUN useradd -m -s /bin/bash evaluator
USER evaluator

# No network access during evaluation
# (handled by run_auto_eval_EN.sh)
```

### Build Docker Image

```bash
cd Docker/
docker build -t enos-eval:latest .

# Verify
docker run --rm enos-eval:latest bash --version
```

### Manual Testing

```bash
# Interactive debugging
docker run -it --rm -v $(pwd)/project:/project enos-eval:latest /bin/bash

# Run make test manually
docker run --rm -v $(pwd)/project:/project enos-eval:latest make -C /project test
```

---

## Evaluation Process

### Step 1: Validation

```bash
# Automatic checks before evaluation
- Archive integrity
- Required files (README, Makefile, src/)
- No forbidden files
- Size limits
```

### Step 2: Build

```bash
# Inside container
cd /project
make all
```

### Step 3: Test

```bash
# Run project test suite
make test

# Run evaluation test suite
/eval/run_tests.sh
```

### Step 4: Collect Results

```bash
# Parse test output
# Calculate scores
# Generate feedback
```

---

## Output Format

### Evaluation Report

```
═══════════════════════════════════════════════════════════════
 PROJECT EVALUATION REPORT
═══════════════════════════════════════════════════════════════

Student: student123
Project: M02_Process_Lifecycle_Monitor
Date: 2026-01-30 14:32:15

BUILD: ✅ PASSED
  make all completed in 2.3s

TESTS: 8/10 PASSED (80%)
  ✅ test_basic_functionality
  ✅ test_process_detection
  ✅ test_output_format
  ⚠️ test_edge_cases (partial: 5/10)
  ❌ test_performance (timeout)
  ...

STYLE: 85%
  shellcheck: 2 warnings
  Documentation: Complete

TOTAL: 78/100

═══════════════════════════════════════════════════════════════
```

---

## Security Considerations

| Measure | Implementation |
|---------|----------------|
| Isolation | Docker container |
| No network | `--network none` flag |
| Resource limits | CPU, memory, disk quotas |
| Timeout | Hard kill after timeout |
| Non-root | `evaluator` user in container |
| Read-only | Source mounted read-only |

---

## Manual Evaluation

After automated evaluation, use:

- `manual_eval_checklist_EN.md` — Checklist for manual review
- `oral_defence_questions_EN.md` — Questions for project interview

```bash
# Example checklist items
□ Code is readable and well-organised
□ Solution demonstrates understanding
□ Error handling is appropriate
□ Documentation is complete
```

---

*See also: [`Docker/`](Docker/) for container configuration*  
*See also: [`../grade_aggregation/`](../grade_aggregation/) for final grades*

*Last updated: January 2026*
