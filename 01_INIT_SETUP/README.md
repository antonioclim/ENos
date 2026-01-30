# 01_INIT_SETUP — Environment Installation

> **Operating Systems** | ASE Bucharest - CSIE | Academic Year 2024-2025  
> **Version:** 2.1 | **Last updated:** January 2025  
> **Author:** ing. dr. Antonio Clim

---

## Purpose

This section contains pre-course setup guides distributed via email **before SEM01**. Students must complete **ONE** installation path before the first seminar — no exceptions.

Every year, students who skip this step spend the first seminar troubleshooting instead of learning. Do yourself a favour: complete this guide at home, where you have time and internet.

---

## Contents

| File | Description | Recommended for |
|------|-------------|-----------------|
| `GUIDE_WSL2_Ubuntu2404_EN.md` | WSL2 installation guide | Windows 10/11 users |
| `GUIDE_WSL2_Ubuntu2404_INTERACTIVE.html` | Interactive HTML version with progress tracking | Visual learners |
| `GUIDE_VirtualBox_Ubuntu2404_EN.md` | VirtualBox + Ubuntu Server guide | macOS, Linux, older Windows |
| `GUIDE_VirtualBox_Ubuntu2404_INTERACTIVE.html` | Interactive HTML version | Visual learners |
| `verify_installation.sh` | Verification script | Everyone (run after setup) |
| `QUICK_START_EN.md` | 5-minute verification checklist | Quick reference |

---

## Which Path Should I Choose?

```
┌─────────────────────────────────────────────────────────────┐
│                    DECISION FLOWCHART                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  What operating system do you have?                         │
│                                                             │
│  ├── Windows 11 (any version)                               │
│  │   └── RAM ≥ 8GB?                                         │
│  │       ├── YES → Use WSL2 guide (recommended)             │
│  │       └── NO  → Use VirtualBox guide                     │
│  │                                                          │
│  ├── Windows 10                                             │
│  │   └── Version 2004+ (Build 19041+)?                      │
│  │       ├── YES → Use WSL2 guide                           │
│  │       └── NO  → Use VirtualBox guide                     │
│  │                                                          │
│  ├── macOS (Intel or Apple Silicon)                         │
│  │   └── Use VirtualBox guide                               │
│  │                                                          │
│  └── Linux                                                  │
│      └── Use VirtualBox guide                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Still unsure?** WSL2 is simpler if your system supports it. VirtualBox works everywhere but requires more disk space.

---

## Time Estimates

| Path | Total time | Internet required |
|------|------------|-------------------|
| WSL2 | 45-70 minutes | ~2.5 GB download |
| VirtualBox | 60-90 minutes | ~3.5 GB download |

Slower internet or older hardware? Add 30 minutes to these estimates.

---

## After Completion

Once you pass the verification script, you are ready for SEM01.

**Next steps:**
1. Download homework recording tools → see `02_INIT_HOMEWORKS/`
2. Browse the Bash reference → see `03_GUIDES/01_Bash_Scripting_Guide.md`
3. Attend SEM01 with your environment ready

---

## Troubleshooting

Each guide has a "Common Problems and Solutions" section. Check there first.

If the guides do not solve your problem:
1. Read the debugging guide → `03_GUIDES/03_Observability_and_Debugging_Guide.md`
2. Ask an AI assistant (Claude or ChatGPT) — see Section 14 in either guide
3. Post in the course forum with your error message
4. As a last resort, email the instructor

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1 | January 2025 | Added verification script, time checkpoints, common mistakes |
| 2.0 | October 2024 | Updated for Ubuntu 24.04 LTS |
| 1.0 | September 2023 | Initial release |

---

*For the Operating Systems course at ASE Bucharest - CSIE*
