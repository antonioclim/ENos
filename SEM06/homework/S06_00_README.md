# Assignments - Seminar 6 (CAPSTONE)

> **⚠️ SPECIAL STRUCTURE:** SEM06 is an integration **CAPSTONE** seminar.

---

## Folder Contents homework/

| File | Description | Audience |
|------|-------------|----------|
| `S06_00_README.md` | This explanatory document | Instructors |
| `S06_01_HOMEWORK_CAPSTONE.md` | Complete requirements for CAPSTONE projects | Students |
| `S06_02_RUBRICA_EVALUARE.md` | Detailed evaluation criteria | Instructors |
| `OLD_HW/` | Archived materials | - |

---

## About CAPSTONE Structure

### Differences from SEM01-05

| Aspect | Standard Seminars (SEM01-05) | SEM06 CAPSTONE |
|--------|------------------------------|----------------|
| Assignment type | Specific weekly exercises | Semester-long projects |
| File structure | `S0X_01_TEMA.md` + generation script | `S06_01_HOMEWORK_CAPSTONE.md` (single large file) |
| Evaluation | Per exercise | Portfolio + Integrated Project |
| Time allocation | 1-2 weeks | 4 weeks + exam session |

### CAPSTONE Components

Unlike seminars 01-05 which have specific assignments, **SEM06** proposes:

1. **Extensions to existing projects** (Monitor, Backup, Deployer)
2. **Integrated Project** - combining all components into a coherent system
3. **Portfolio-style evaluation** - all code developed during the semester

---

## CAPSTONE Assignment Structure

```
S06_01_HOMEWORK_CAPSTONE.md contains:
│
├── Assignment 1: Monitor Extensions (60p + 40p bonus)
│   ├── 1.1 Network Monitoring (20p)
│   ├── 1.2 Service Monitoring (20p)
│   ├── 1.3 Terminal Dashboard (20p)
│   ├── 1.4 Prometheus Export (+15p bonus)
│   ├── 1.5 Historical Data & Graphs (+15p bonus)
│   └── 1.6 Email/Slack Alerting (+10p bonus)
│
├── Assignment 2: Backup Extensions (60p + 40p bonus)
│   ├── 2.1 Encrypted Backup (20p)
│   ├── 2.2 Remote Backup SSH/SFTP (20p)
│   ├── 2.3 Advanced Rotation (20p)
│   ├── 2.4 Deduplication (+15p bonus)
│   ├── 2.5 Database Backup (+15p bonus)
│   └── 2.6 HTML Report (+10p bonus)
│
├── Assignment 3: Deployer Extensions (60p + 40p bonus)
│   ├── 3.1 Docker Deployment (20p)
│   ├── 3.2 Multi-Environment Pipeline (20p)
│   ├── 3.3 Monitoring Integration (20p)
│   ├── 3.4 GitOps Integration (+15p bonus)
│   ├── 3.5 Kubernetes Deployment (+15p bonus)
│   └── 3.6 Secrets Management (+10p bonus)
│
└── Assignment 4: Integrated Project (100p)
    ├── 4.1 Unified CLI (30p)
    ├── 4.2 Automated Workflows (30p)
    ├── 4.3 Web Dashboard (20p)
    └── 4.4 Documentation & Tests (20p)
```

---

## Submission Deadlines

| Assignment | Deadline | Points |
|------------|----------|--------|
| Assignment 1: Monitor Extensions | Week 12 | 60p + 40p bonus |
| Assignment 2: Backup Extensions | Week 13 | 60p + 40p bonus |
| Assignment 3: Deployer Extensions | Week 14 | 60p + 40p bonus |
| Assignment 4: Integrated Project | Exam Session | 100p |

---

## Submission Format

```
CAPSTONE_LastnameFirstname/
├── README.md               # Installation and usage instructions
├── monitor/                # Extended Monitor project
│   ├── monitor.sh
│   ├── tests/
│   └── docs/
├── backup/                 # Extended Backup project
│   ├── backup.sh
│   ├── tests/
│   └── docs/
├── deployer/               # Extended Deployer project
│   ├── deployer.sh
│   ├── tests/
│   └── docs/
├── integrated/             # Integrated Project
│   ├── capstone.sh         # Unified CLI
│   ├── workflows/          # Automated workflows
│   └── dashboard/          # Web dashboard (optional)
└── screenshots/            # Demonstrations
```

---

## Associated Files in Other Folders

- **Documentation**: `../docs/S06_*`
- **Base code**: `../scripts/projects/`
- **Testing framework**: `../scripts/test_helpers.sh`
- **Presentations**: `../prezentari/S06_*`

---

## Notes for Instructors

1. **Continuous evaluation**: Intermediate milestones are recommended
2. **Bonus flexibility**: Students can choose which bonus features to implement
3. **Live demonstrations**: Reserve time during exam session for presentations
4. **High complexity**: Estimate 40-60 hours of work per student

---

## Transition from Old Files

### Before (inconsistent structure):
- `README.md`
- `TEME_PRACTICE.md`
- `S06_02_RUBRICA_EVALUARE.md`

### After (standardised structure):
- `S06_00_README.md` (this file)
- `S06_01_HOMEWORK_CAPSTONE.md` (renamed from TEME_PRACTICE.md)
- `S06_02_RUBRICA_EVALUARE.md` (unchanged)

**Action**: Delete `README.md` and `TEME_PRACTICE.md` after applying the patch.

---

*Material for Operating Systems course | ASE Bucharest - CSIE*
