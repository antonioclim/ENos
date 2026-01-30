# Resources - Seminar 1: Bash Shell

## Useful Links

### Official Documentation
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Linux man pages online](https://man7.org/linux/man-pages/)
- [Filesystem Hierarchy Standard (FHS)](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)

### Interactive Tools
- [ExplainShell](https://explainshell.com/) - Explains shell commands visually
- [ShellCheck](https://www.shellcheck.net/) - Online script checker
- [TLDR pages](https://tldr.sh/) - Quick examples for commands
- [Bash Academy](https://guide.bash.academy/) - Interactive tutorial

### Cheat Sheets
- [Devhints Bash Cheatsheet](https://devhints.io/bash)
- [LeCoupa Bash Cheatsheet](https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh)

### Online Practice
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Game for learning Linux
- [Linux Journey](https://linuxjourney.com/) - Step by step tutorial
- [Terminus](https://web.mit.edu/mprat/Public/web/Terminus/Web/main.html) - Terminal game in browser

---

## Bibliography

### Recommended Books
1. **"The Linux Command Line"** - William Shotts
   - Available for free: https://linuxcommand.org/tlcl.php
   - Chapters 1-12 for this seminar

2. **"Learning the bash Shell"** - Cameron Newham (O'Reilly)
   - Classic Bash reference

3. **"Bash Pocket Reference"** - Arnold Robbins (O'Reilly)
   - Quick reference, very useful

4. **"UNIX and Linux System Administration Handbook"** - Evi Nemeth et al.
   - The shell scripting chapter

### Articles and Tutorials
- Bash Guide for Beginners: https://tldp.org/LDP/Bash-Beginners-Guide/html/
- Advanced Bash-Scripting Guide: https://tldp.org/LDP/abs/html/

---

## Required Software

### Mandatory
- **Linux Terminal** (WSL2, VM, or native installation)
- **Bash shell** (version 4.0+)
- **Text editor** (nano, vim, or VS Code)

### Recommended for Demos
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y figlet lolcat cmatrix cowsay tree ncdu pv dialog

# Verify installation
which figlet lolcat cmatrix cowsay tree ncdu pv dialog
```

### Optional for Productivity
- **tmux** - Terminal multiplexer
- **fzf** - Fuzzy finder
- **bat** - Cat with syntax highlighting
- **exa/eza** - Modern ls

---

## Useful man Commands

To learn more about any command:

```bash
# Complete manual
man bash
man ls
man cd

# Specific section from manual
man 1 intro      # Introduction to commands
man 7 hier       # File system hierarchy

# Search in manuals
apropos "search term"
man -k "keyword"

# Quick help
help cd          # For built-in commands
ls --help        # For external commands
```

---

## Learning Objectives

After completing this seminar, students will be able to:

### Fundamental Level (Remember/Understand)
- [ ] Explain the role of the shell in the operating system
- [ ] Identify and describe the main directories in FHS
- [ ] Distinguish between local and environment variables

### Intermediate Level (Apply/Analyse)
- [ ] Navigate efficiently in the file system
- [ ] Create and manipulate files and directories
- [ ] Configure the working environment through .bashrc
- [ ] Use wildcards for file selection

### Advanced Level (Evaluate/Create)
- [ ] Write functional bash scripts
- [ ] Debug common problems with variables and quoting
- [ ] Automate repetitive tasks through aliases and functions

---

## Common Mistakes to Avoid

1. **Spaces in assignments**: `VAR = "val"` ❌ → `VAR="val"` ✅
2. **$ in assignment**: `$VAR="val"` ❌ → `VAR="val"` ✅
3. **Missing quotes**: `echo $VAR` for files with spaces ❌
4. **rm -rf without care**: ALWAYS check the path!
5. **Confusion ~ vs /**: ~ = $HOME, NOT root
6. **Single vs double quotes**: Choose correctly for context
7. **Forgetting `source`**: After modifying .bashrc

---

## Contact and Support

- **Course platform**: [Link to ASE platform]
- **Discussion forum**: [Forum link]
- **Consultation hours**: [Schedule]

---

*Last updated: January 2025*
