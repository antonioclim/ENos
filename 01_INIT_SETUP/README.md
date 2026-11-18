# 01_INIT_SETUP — Environment Installation

> **Phase 5 source correction:** Keep the academic identifier (for example `AP_1001_A`) in your student records. The machine hostname is a separate DNS-compatible label: map that example to `ap-1001-a` by lowercasing and replacing underscores with hyphens. This is a technical mapping, not an authentication or grading rule. Usernames must also satisfy the installer: start with a lower-case letter, use a suitable unique local username and keep the full student identity separately.

Use a unique local password that you can retain securely. Never configure the shared historical example password `stud` on a network-accessible guest. Bridged mode exposes the guest to the surrounding network: use only an authorised lab network and scope SSH access to the intended host. A first SSH connection requires checking the guest fingerprint through the VM console.

> **Operating Systems** | ASE Bucharest - CSIE | Course schedule: use the current institutional announcement  
> **Version:** ENos 6.0.0 | **Release metadata updated:** 18 November 2026\
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

| Host | Route | Architecture and resource condition |
|---|---|---|
| Supported Windows 11 or Windows 10 version/build | WSL2 where the required Windows features are available | Select x64 or ARM64 for the actual Windows host; consult the current Microsoft requirements in the guide. |
| Supported Windows, macOS or Linux host | VirtualBox | Match the host-supported guest architecture. Apple Silicon uses an ARM guest; an amd64 ISO is not an ARM image. |
| A host with constrained memory or an unsupported configuration | Discuss a suitable lab/host arrangement | Low RAM does not automatically make VirtualBox the suitable alternative to WSL2. Check available resources for the selected guest. |


**Still unsure?** WSL2 is simpler if your system supports it. VirtualBox requires a supported host/guest combination; choose the correct architecture and check host resource availability.

---

## Time Estimates

| Path | Total time | Internet required |
|------|------------|-------------------|
| WSL2 | 45-70 minutes | ~2.5 GB download |
| VirtualBox | 60-90 minutes | ~3.5 GB download |

Slower internet or older hardware? Add 30 minutes to these estimates.

---

## After Completion

A successful verification script reports its bounded local checks. Complete the practical commands in the selected guide and retain their output; it is not a certificate for every later seminar dependency.

**Next steps:**
1. Read the [homework recording tools](../02_INIT_HOMEWORKS/README_EN.md); use offline practice until submission settings are confirmed.
2. Browse the Bash reference → see [SEM01 shell fundamentals](../SEM01/README.md)
3. Attend SEM01 with your environment ready

---

## Troubleshooting

Each guide has a "Common Problems and Solutions" section. Check there first.

If the guides do not solve your problem:
1. Read the debugging guide → [SEM05 scripting and debugging](../SEM05/README.md)
2. Ask an AI assistant (Claude or ChatGPT) — see Section 14 in either guide
3. Post in the course forum with your error message
4. As a last resort, email the instructor

---

## Virtualisation PDF source and build

[TC0_Lab0C_Virtualisation_ENv2.md](TC0_Lab0C_Virtualisation_ENv2.md) is the editable source for [TC0_Lab0C_Virtualisation_ENv2.pdf](TC0_Lab0C_Virtualisation_ENv2.pdf). The historical filename and v2.1 source edition are retained for continuity. Its candidate label records preparation during the v6 correction work; current release identity is recorded in the repository metadata. Rebuild from the repository root:

```bash
# In a Python virtual environment with reportlab, pypdf and markdown-it-py installed:
python3 01_INIT_SETUP/build_lab0c_pdf.py
```

The builder accepts `--help` for output/font options. It uses DejaVu fonts, creates document language, structural tags and bookmarks, and produces deterministic output for the recorded dependencies/fonts. The eight pages were rendered and visually inspected in Phase 5. Tagging is not a PDF/UA certification or a screen-reader acceptance test. Host installation, bridge networking and static-address ownership still require the named target environment and authorised network configuration.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1 | January 2025 | Added verification script, time checkpoints, common mistakes |
| 2.0 | October 2024 | Updated for Ubuntu 24.04 LTS |
| 1.0 | September 2023 | Initial release |

---

*For the Operating Systems course at ASE Bucharest - CSIE*
