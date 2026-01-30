# E03: Bulk File Organizer

> **Level:** EASY | **Estimated time:** 15-20 hours | **Components:** Bash only

---

## Description

Develop a tool for automatic file organisation into structured directories. Supports organisation by type, date, size or custom patterns.

---

## Learning Objectives

- File and directory manipulation
- Pattern matching and globbing
- Safe batch operations
- Undo/rollback operations

---

## Functional Requirements

### Mandatory (for passing grade)

1. **Organisation by type (extension)**
   - Grouping: Images/, Documents/, Videos/, Audio/, Archives/, Other/
   - Configurable extension mapping

2. **Organisation by date**
   - Structure: YYYY/MM/DD or YYYY-MM
   - Use modification or creation date

3. **Organisation by size**
   - Categories: tiny (<1KB), small (<1MB), medium (<100MB), large (>100MB)

4. **Dry-run mode**
   - Preview actions without execution
   - Detailed report of proposed changes

5. **Rollback**
   - Operation journal for undo
   - Restore previous state

### Optional (for full marks)

6. **Organisation by custom pattern** (regex)
7. **Deduplication** - identify and manage duplicates
8. **Batch renaming** - rename by template
9. **Watch mode** - automatic organisation for new files

---

## Interface

```bash
./file_organizer.sh [OPTIONS] <source_dir> [dest_dir]

Options:
  -h, --help              Display help
  -m, --mode MODE         Organisation mode: type|date|size|custom
  -p, --pattern REGEX     Pattern for custom mode
  -d, --dry-run           Simulation without changes
  -r, --recursive         Include subdirectories
  -u, --undo              Undo last operation
  --date-format FORMAT    Date format: YYYY/MM|YYYY-MM-DD
  --keep-original         Copy instead of move
  -v, --verbose           Detailed output

Examples:
  ./file_organizer.sh -m type ~/Downloads ~/Organised
  ./file_organizer.sh -m date --date-format YYYY/MM ~/Photos
  ./file_organizer.sh -d -m type ~/Messy  # dry-run
  ./file_organizer.sh --undo              # rollback
```

---

## Output Example

```
╔══════════════════════════════════════════════════════════════════╗
║              BULK FILE ORGANIZER - DRY RUN                       ║
║  Source: /home/user/Downloads (234 files)                        ║
║  Mode: type                                                      ║
╚══════════════════════════════════════════════════════════════════╝

📊 SUMMARY OF CHANGES
──────────────────────────────────────────────────────────────────
Category        Files    Size      Destination
─────────────────────────────────────────────────────────────────
Images/         45       234 MB    → ./Organised/Images/
Documents/      67       45 MB     → ./Organised/Documents/
Videos/         12       1.2 GB    → ./Organised/Videos/
Archives/       23       890 MB    → ./Organised/Archives/
Other/          87       123 MB    → ./Organised/Other/

📝 DETAILED ACTIONS (first 10):
──────────────────────────────────────────────────────────────────
[MOVE] photo_2025.jpg → Images/photo_2025.jpg
[MOVE] report.pdf → Documents/report.pdf
[MOVE] video.mp4 → Videos/video.mp4
...

⚠️  CONFLICTS DETECTED:
──────────────────────────────────────────────────────────────────
[!] Images/photo.jpg already exists - will rename to photo_1.jpg

════════════════════════════════════════════════════════════════════
Run without --dry-run to execute these changes
Journal will be saved to: ~/.file_organizer/journal_20250120_143000.log
════════════════════════════════════════════════════════════════════
```

---

## Recommended Structure

```
E03_Bulk_File_Organizer/
├── README.md
├── Makefile
├── src/
│   ├── file_organizer.sh
│   └── lib/
│       ├── organizers/
│       │   ├── by_type.sh
│       │   ├── by_date.sh
│       │   └── by_size.sh
│       ├── journal.sh        # Logging for undo
│       ├── conflicts.sh      # Conflict resolution
│       └── utils.sh
├── etc/
│   └── type_mappings.conf    # extension -> category
├── tests/
└── docs/
```

---

## Implementation Hints

```bash
# Categorisation by extension
get_category() {
    local ext="${1##*.}"
    case "${ext,,}" in
        jpg|jpeg|png|gif|bmp) echo "Images" ;;
        pdf|doc|docx|txt|odt) echo "Documents" ;;
        mp4|avi|mkv|mov) echo "Videos" ;;
        mp3|wav|flac|ogg) echo "Audio" ;;
        zip|tar|gz|rar|7z) echo "Archives" ;;
        *) echo "Other" ;;
    esac
}

# Journal for undo
log_operation() {
    echo "$(date +%s)|$1|$2|$3" >> "$JOURNAL_FILE"
    # Format: timestamp|operation|source|destination
}
```

---

## Evaluation Criteria

| Criterion | Weight |
|-----------|--------|
| Type organisation | 15% |
| Date organisation | 10% |
| Size organisation | 10% |
| Functional dry-run | 10% |
| Undo/rollback | 15% |
| Conflict handling | 10% |
| Code quality | 15% |
| Tests | 10% |
| Documentation | 5% |

---

*EASY Project | Operating Systems | ASE-CSIE*
