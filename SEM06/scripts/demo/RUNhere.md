# 📁 Live Demos — SEM06

> **Location:** `SEM06/scripts/demo/`  
> **Purpose:** Interactive demonstrations for seminar teaching  
> **Audience:** Instructors and students following along

## Contents

| Demo | Topic | Duration |
|------|-------|----------|
| `S06_01_hook_demo.sh` | Attention grabber | ~3-5 min |

## How to Present

### Preparation

1. Open terminal in fullscreen mode
2. Increase font size: `Ctrl++` or Terminal → Preferences
3. Consider using a dark background for visibility
4. Read through demo script source before class

### Running Demos

```bash
# Make all executable (once)
chmod +x *.sh

# Run specific demo
./S06_0X_demo_topic.sh

# Run with explanation pauses
bash -v ./S06_0X_demo_topic.sh
```

## Demo Descriptions

### S06_01_hook_demo.sh

**Purpose:** Attention-grabbing opener for seminar start  
**Duration:** ~3 minutes  
**Visual effects:** ASCII art, colours, optional animations

```bash
# With full effects (requires figlet, lolcat)
./S06_01_hook_demo.sh

# Install optional visual tools (Ubuntu)
sudo apt install figlet lolcat cowsay
```



## Teaching Tips

### For Instructors

- **Read the source code first** — Comments contain teaching notes
- **Pause at key points** — Scripts have built-in `read` pauses
- **Encourage prediction** — Ask students what will happen before running
- **Show failures too** — Error cases are educational

### For Self-Study

```bash
# Step through manually
bash -x ./demo_script.sh

# Read with line numbers
cat -n ./demo_script.sh | less
```

## Script Features

All demo scripts include:

- `set -euo pipefail` for safe error handling
- Coloured output for visibility
- `# TEACHING NOTE:` comments for instructors
- Built-in pauses at demonstration points
- Cleanup of any temporary files

## Customisation

### Adjusting Speed

Edit the `PAUSE_DURATION` variable at script top:
```bash
PAUSE_DURATION=2  # seconds between steps
```

### Disabling Colours

```bash
NO_COLOR=1 ./S06_02_demo_topic.sh
```

---

## Related Resources

- [`../bash/`](../bash/) — Utility scripts for students
- [`../../docs/`](../../docs/) — Full documentation
- [`../../presentations/`](../../presentations/) — Slide materials

---

*Pro tip: Practice demos before class to ensure smooth delivery*

*Last updated: January 2026*
