# E05: Config File Manager

> **Level:** EASY | **Estimated time:** 15-20 hours | **Components:** Bash only

---

## Description

Develop a tool for managing configuration files: backup, restore, diff, validation and simple versioning. Ideal for system configuration administration.

---

## Learning Objectives

- Configuration file management
- Diff and patch
- Simple versioning (snapshots)
- Configuration syntax validation

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Configuration backup** - save with timestamp in dedicated directory
2. **Restore** - revert to previous version
3. **Diff** - comparison between versions or with current file
4. **Version listing** - history for a file
5. **Grouping** - configuration profiles (dev, prod, etc.)

### Optional (for full marks)

6. **Validation** - syntax checking for known formats (ini, yaml, json)
7. **Templates** - generate configurations from template
8. **Sync** - synchronisation between machines
9. **Encryption** - encrypted backup for sensitive configurations

---

## Interface

```bash
./config_manager.sh <command> [options]

Commands:
  backup <file>           Save current version
  restore <file> [ver]    Restore version (default: latest)
  list <file>             List available versions
  diff <file> [ver1] [ver2]  Compare versions
  validate <file>         Check syntax
  profile save <n>     Save configuration set
  profile load <n>     Load profile

Global options:
  -h, --help              Display help
  -d, --dir DIR           Backup directory (default: ~/.config_backups)
  -v, --verbose           Detailed output

Examples:
  ./config_manager.sh backup /etc/nginx/nginx.conf
  ./config_manager.sh list /etc/nginx/nginx.conf
  ./config_manager.sh diff /etc/nginx/nginx.conf v2 v5
  ./config_manager.sh restore /etc/nginx/nginx.conf v3
  ./config_manager.sh profile save production
```

---

## Output Example

```
╔══════════════════════════════════════════════════════════════════╗
║              CONFIG FILE MANAGER                                 ║
╚══════════════════════════════════════════════════════════════════╝

$ ./config_manager.sh list /etc/nginx/nginx.conf

📁 Versions for: /etc/nginx/nginx.conf
──────────────────────────────────────────────────────────────────
Ver   Date                 Size      Hash (first 8)
───────────────────────────────────────────────────────────────────
v5    2025-01-20 14:30     2.3 KB    a1b2c3d4    [current]
v4    2025-01-18 10:15     2.1 KB    e5f6g7h8
v3    2025-01-15 09:00     2.0 KB    i9j0k1l2
v2    2025-01-10 16:45     1.9 KB    m3n4o5p6
v1    2025-01-05 11:20     1.8 KB    q7r8s9t0    [initial]

Total: 5 versions, 10.1 KB storage used

$ ./config_manager.sh diff /etc/nginx/nginx.conf v4 v5

📊 Diff: v4 → v5
──────────────────────────────────────────────────────────────────
--- v4 (2025-01-18 10:15)
+++ v5 (2025-01-20 14:30)
@@ -12,6 +12,8 @@
    server_name example.com;
+    # Added SSL configuration
+    ssl_certificate /etc/ssl/cert.pem;
+    ssl_certificate_key /etc/ssl/key.pem;
    location / {

Changes: +3 lines, -0 lines
```

---

## Recommended Structure

```
E05_Config_File_Manager/
├── src/
│   ├── config_manager.sh
│   └── lib/
│       ├── backup.sh
│       ├── restore.sh
│       ├── diff.sh
│       ├── validate.sh
│       └── profiles.sh
├── etc/
│   └── validators/         # validation scripts per format
│       ├── ini.sh
│       ├── yaml.sh
│       └── json.sh
└── tests/
```

---

## Implementation Hints

```bash
# Backup structure
BACKUP_DIR="$HOME/.config_backups"
# /etc/nginx/nginx.conf -> ~/.config_backups/etc/nginx/nginx.conf/
# v1_20250105_112000_a1b2c3d4.conf
# v2_20250110_164500_m3n4o5p6.conf

# Hash for quick identification
get_hash() {
    sha256sum "$1" | cut -c1-8
}

# JSON validation
validate_json() {
    python3 -m json.tool "$1" >/dev/null 2>&1
}
```

---

## Evaluation Criteria

| Criterion | Weight |
|-----------|--------|
| Functional backup | 15% |
| Restore | 15% |
| Correct diff | 15% |
| Version listing | 10% |
| Profiles | 10% |
| Validation (optional) | 5% |
| Code quality | 15% |
| Tests | 10% |
| Documentation | 5% |

---

*EASY Project | Operating Systems | ASE-CSIE*
