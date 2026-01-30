# Supplementary Resources

> **Operating Systems** | ASE Bucharest - CSIE
> Seminar 6: CAPSTONE Projects

---

## Contents

```
resources/
├── README.md           # This file
├── systemd/            # systemd service/timer files
│   ├── monitor.service
│   ├── backup.service
│   └── backup.timer
├── templates/          # Script templates
│   └── bash_script_template.sh
└── examples/           # Examples and references
    └── cron_examples.txt
```

---

## Systemd

### Installing Services

```bash
# Copy service files
sudo cp systemd/*.service /etc/systemd/system/
sudo cp systemd/*.timer /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start monitor
sudo systemctl enable monitor.service
sudo systemctl start monitor.service

# Enable and start backup timer
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

### Useful Commands

```bash
# Service status
sudo systemctl status monitor.service

# Logs
sudo journalctl -u monitor.service -f

# Restart
sudo systemctl restart monitor.service

# List timers
sudo systemctl list-timers

# Check timer
sudo systemctl status backup.timer
```

### Customisation

Edit `.service` files before installation for:
- Path adjustment (`WorkingDirectory`, `ExecStart`)
- Environment variable modification (`Environment`)
- User/group change (`User`, `Group`)
- Resource limit adjustment (`MemoryMax`, `CPUQuota`)

---

## Templates

### Bash Script Template

The `bash_script_template.sh` template includes:
- Strict mode (`set -euo pipefail`)
- Logging with colours and levels
- Argument parsing (short and long options)
- Help/usage generation
- Cleanup with trap
- Input validation
- Support for configuration from file

#### Usage

```bash
# Copy the template
cp templates/bash_script_template.sh ~/project/my_script.sh

# Edit and personalise
vim ~/project/my_script.sh

# Make executable
chmod +x ~/project/my_script.sh
```

---

## Examples

### Cron Jobs

The `examples/cron_examples.txt` file contains:
- Crontab format explanation
- Examples for Monitor, Backup, Deployer
- Solid patterns (with lock, timeout, logging)
- Debugging tips

---

## External References

### Official Documentation
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [Cron Manual](https://man7.org/linux/man-pages/man5/crontab.5.html)

### Guides and Tutorials
- [Bash Style Guide (Google)](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/) - Static analysis tool
- [Explain Shell](https://explainshell.com/) - Explains shell commands

### Useful Tools
- **ShellCheck**: `apt install shellcheck`
- **bat**: `apt install bat` - cat with syntax highlighting
- **fzf**: `apt install fzf` - fuzzy finder
- **jq**: `apt install jq` - JSON processor

---

## Usage in Projects

### Example: Monitor Setup with Systemd

```bash
# 1. Install project
cd /opt
sudo git clone <repo> capstone
cd capstone/monitor

# 2. Check dependencies
./check_dependencies.sh

# 3. Test manually
./monitor.sh --all

# 4. Copy and edit service file
sudo cp ../resources/systemd/monitor.service /etc/systemd/system/
sudo vim /etc/systemd/system/monitor.service
# Adjust WorkingDirectory and ExecStart

# 5. Enable
sudo systemctl daemon-reload
sudo systemctl enable monitor.service
sudo systemctl start monitor.service

# 6. Verify
sudo systemctl status monitor.service
sudo journalctl -u monitor.service -f
```

### Example: Backup Setup with Timer

```bash
# 1. Copy files
sudo cp ../resources/systemd/backup.service /etc/systemd/system/
sudo cp ../resources/systemd/backup.timer /etc/systemd/system/

# 2. Edit for your setup
sudo vim /etc/systemd/system/backup.service

# 3. Enable timer (not service directly)
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# 4. Check schedule
sudo systemctl list-timers | grep backup

# 5. Manual test (optional)
sudo systemctl start backup.service
sudo journalctl -u backup.service
```

---

*Resources for Operating Systems | ASE Bucharest - CSIE*
