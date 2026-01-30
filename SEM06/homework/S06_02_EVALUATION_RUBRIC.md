# Evaluation Rubric - CAPSTONE Projects

> **Instructor document** | Seminar 6 + Final Presentation (SEM07)

---

## Scoring System Legend

| Symbol | Meaning | Example |
|--------|---------|---------|
| **%** | Percentage of final project grade (100%) | Mandatory Requirements: 60% |
| **Pts (in tables)** | Relative points within section | 5 pts out of section's 20% |
| **Bonus +X%** | Additional percentage above 100% base | Bonus: +40% |
| **Adjustment ±X%** | Percentage modification applied to final grade | Code quality: ±10% |

> **Important note**: Points in table columns (Pts) are **relative points** that add up to form the respective section percentage. Bonuses are added above base grade and can exceed 100%.

---

## CAPSTONE Structure

Seminar 06 is an **integrating seminar** where students work on one of the 3 CAPSTONE projects and present it in the final seminar (SEM07).

### Project Options

| Project | Focus | Difficulty |
|---------|-------|------------|
| **Monitor** | System monitoring and dashboard | ⭐⭐⭐ |
| **Backup** | Incremental backup and restore | ⭐⭐⭐ |
| **Deployer** | Simplified CI/CD pipeline | ⭐⭐⭐⭐ |
| **Integrated** | Combination of all 3 | ⭐⭐⭐⭐⭐ |

---

## ASSIGNMENT 1: Monitor - Feature Extension

### Mandatory Requirements (60%)

#### 1.1 Network Monitoring (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Reading /proc/net/dev | 5 | Correct parsing all fields | Main fields | Parsing errors |
| Rate calculation (Mbps) | 5 | Difference between readings, correct conversion | Works | Wrong calculation |
| Multi-interface | 5 | All interfaces detected | eth0 hardcoded | Errors |
| Structured output | 5 | Consistent key:value format | Functional | Unformatted |

#### 1.2 Service Monitoring (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| systemctl status | 5 | is-active + show correct | Only is-active | Errors |
| Memory/CPU per service | 5 | Reading from cgroups/systemctl | Approximation | Missing |
| Service list | 5 | Correct array processing | Works | Hardcoded |
| Error handling | 5 | Non-existent service handled | Generic message | Crash |

#### 1.3 Terminal Dashboard (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| ANSI escape codes | 5 | Colours, positioning, clear | Partial | Text only |
| Progress bars | 5 | `[████████░░]` with percentage | Functional | Missing |
| Live refresh | 5 | Loop with configurable interval | Works | Manual |
| Organised layout | 5 | Clear sections, aligned | Functional | Disorganised |

### Bonus Requirements (40%)

| Requirement | Pts | Description |
|-------------|-----|-------------|
| Process tree | +10 | Hierarchical process display |
| Email alert | +10 | Notification at threshold |
| Historical data | +10 | Saving and historical graphs |
| Config file | +10 | External YAML/JSON settings |

---

## ASSIGNMENT 2: Backup - Complete System

### Mandatory Requirements (60%)

#### 2.1 Incremental Backup (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Modification detection | 7 | find -newer or rsync | Partial | Full backup |
| Snapshot management | 7 | Version tracking | Works | Manual |
| Compression | 6 | tar.gz with configurable level | Fixed tar.gz | Uncompressed |

#### 2.2 Restore (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| List versions | 5 | Display all snapshots | Works | Missing |
| Specific restore | 7 | Version + file selection | All or nothing | Errors |
| Dry-run | 5 | Preview without modifications | Mentioned | Missing |
| Integrity verification | 3 | Checksum or tar -t | Partial | Missing |

#### 2.3 Rotation and Cleanup (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Retention policy | 7 | Daily/weekly/monthly | Fixed number | No rotation |
| Disk space check | 7 | Verification before backup | Message | Missing |
| Logging | 6 | Timestamp, status, errors | Partial | Missing |

### Bonus Requirements (40%)

| Requirement | Pts | Description |
|-------------|-----|-------------|
| Deduplication | +10 | Hash-based for identical files |
| Remote backup | +10 | SCP/rsync to remote server |
| Encryption | +10 | GPG for archives |
| Schedule wizard | +10 | Interactive crontab generator |

---

## ASSIGNMENT 3: Deployer - CI/CD Pipeline

### Mandatory Requirements (60%)

#### 3.1 Git Integration (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Clone/pull | 5 | Automatic detection | Manual | Errors |
| Branch selection | 5 | Parameter or config | Hardcoded main | Missing |
| Commit tracking | 5 | Save current hash | Works | Missing |
| Submodules | 5 | --recursive handling | Ignored | Errors |

#### 3.2 Build & Deploy (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Pre/post hooks | 7 | Custom script execution | One of two | Missing |
| Environment config | 7 | .env or export | Partial | Hardcoded |
| Atomic deploy | 6 | Symlink switch | Works | In-place |

#### 3.3 Rollback (20%)

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Version history | 7 | N versions kept | Works | Current only |
| Quick rollback | 7 | Single command | Works | Manual |
| Post-rollback validation | 6 | Health check | Message | Missing |

### Bonus Requirements (40%)

| Requirement | Pts | Description |
|-------------|-----|-------------|
| Zero-downtime | +10 | Blue-green deployment |
| Container support | +10 | Docker build/deploy |
| Slack notifications | +10 | Webhook on deploy |
| Multi-environment | +10 | Dev/staging/prod |

---

## ASSIGNMENT 4: Integrated Project (MAJOR BONUS)

| Criterion | Pts | Description |
|-----------|-----|-------------|
| Monitor + Dashboard | 20 | Metrics visualisation |
| Backup automation | 20 | Backup with monitoring |
| Deploy pipeline | 20 | Complete CI/CD |
| Orchestration | 20 | All components communicate |
| Documentation | 20 | Complete README, diagrams |

**Total possible Integrated Project: +100% bonus** (added above base grade from chosen main project)

---

## FINAL PRESENTATION (SEM07) - 40% of final grade

### Presentation Criteria

| Criterion | Pts | Excellent | Satisfactory | Insufficient |
|-----------|-----|-----------|--------------|--------------|
| Live demo | 15 | Works perfectly | Works with minor issues | Crash |
| Code explanation | 10 | Clear architecture | Functionally explained | Confusing |
| Question responses | 10 | Clear answers | Partial | Doesn't know |
| Time (10-15 min) | 5 | Within interval | ±3 minutes | Way over/under |

### Recommended Presentation Structure

1. **Introduction** (2 min)
   - What project you chose and why
   - Proposed objectives

2. **Architecture** (3 min)
   - File structure
   - Data flow
   - Dependencies

3. **Live Demo** (5 min)
   - Main features
   - Edge cases handled

4. **Interesting Code** (3 min)
   - Relevant snippets
   - Challenges solved

5. **Conclusions** (2 min)
   - What you learned
   - Possible improvements

---

## Transversal Criteria

### Code Quality (adjustment: -10% to +10% of final grade)

| Aspect | Bonus | Penalty |
|--------|-------|---------|
| ShellCheck clean | +3 | -3 |
| Function modularisation | +2 | -2 |
| Complete error handling | +2 | -2 |
| Inline documentation | +2 | -2 |
| Tests included | +3 | 0 |

---

## Penalties

| Situation | Penalty |
|-----------|---------|
| Plagiarism | **-100%** |
| No presentation in SEM07 | **-40%** |
| Demo doesn't work | -20% |
| No documentation | -10% |
| Unorganised code | -5% |

---

## Final Checklist

```
□ Complete and functional project
□ README.md with instructions
□ All scripts executable
□ ShellCheck without errors
□ Tests (at least smoke tests)
□ Presentation prepared (slides optional)
□ Demo tested on clean machine
```

---

*Internal document | CAPSTONE Projects - Seminar 6 + SEM07 Presentations*
