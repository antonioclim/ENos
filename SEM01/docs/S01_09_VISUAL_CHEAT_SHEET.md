# Visual Cheat Sheet - Seminar 1-2
## One-Pager for Students | Print and Keep!

*(Bash has ugly syntax, I admit. But it runs everywhere and that matters enormously in practice.)*

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                     🐧 BASH CHEAT SHEET - SEMINAR 1-2                         ║




╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        📂 NAVIGATION                                    │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  pwd              Where am I? (Print Working Directory)                 │  ║
║  │  cd /path         Go to absolute path                                   │  ║
║  │  cd folder        Go to folder (relative path)                          │  ║
║  │  cd ~  or  cd     Go to HOME                                            │  ║
║  │  cd ..            Go to parent directory                                │  ║
║  │  cd -             Toggle between last 2 directories                     │  ║
║  │  ls               List contents                                         │  ║
║  │  ls -la           List EVERYTHING with details                          │  ║
║  │  ls -lh           Human-readable sizes (KB, MB)                         │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        📁 FILES & DIRECTORIES                           │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  touch file       Create if absent; else update times                                     │  ║
║  │  mkdir dir        Create directory                                      │  ║
║  │  mkdir -p a/b/c   Create directory hierarchy                            │  ║
║  │  cp src dst       Copy file                                             │  ║
║  │  cp -r src/ dst/  Copy directory (recursive)                            │  ║
║  │  mv old new       Move/Rename                                           │  ║
║  │  rm file          Delete file (⚠️ PERMANENT!)                           │  ║
║  │  rm -r dir        Delete directory with contents                        │  ║
║  │  rmdir dir        Delete EMPTY directory                                │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        👁️ VIEWING CONTENT                               │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  cat file         Display all content                                   │  ║
║  │  head -n 10 file  First 10 lines                                        │  ║
║  │  tail -n 10 file  Last 10 lines                                         │  ║
║  │  tail -f file     LIVE monitoring (logs)                                │  ║
║  │  less file        Paginated view (q = exit)                             │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        🔤 VARIABLES                                     │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  VAR="value"            Set shell variable (no spaces!)                 │  ║
║  │  export VAR="val"       Set environment variable                        │  ║
║  │  echo $VAR              Display value                                   │  ║
║  │  unset VAR              Delete variable                                 │  ║
║  │                                                                         │  ║
║  │  SPECIAL VARIABLES:                                                     │  ║
║  │  $HOME    → /home/user         $USER   → username                       │  ║
║  │  $PATH    → executable paths   $SHELL  → login-shell value                      │  ║
║  │  $PWD     → current directory  $?      → exit code (0=success)          │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        🔠 QUOTING - SUPER IMPORTANT!                    │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │                                                                         │  ║
║  │   'single quotes'  →  EVERYTHING is LITERAL (doesn't expand $VAR)       │  ║
║  │   "double quotes"  →  Expands $VAR, `cmd`, $()                          │  ║
║  │   \                →  Escape a single character                         │  ║
║  │                                                                         │  ║
║  │   EXAMPLE with NAME="Ana":                                              │  ║
║  │   echo '$NAME'    →  $NAME (literal)                                    │  ║
║  │   echo "$NAME"    →  Ana (expanded)                                     │  ║
║  │   echo \$NAME     →  $NAME (escaped)                                    │  ║
║  │                                                                         │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        🃏 WILDCARDS (GLOBBING)                          │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  *              Zero or more characters            ls *.txt             │  ║
║  │  ?              Exactly ONE character              ls file?.txt         │  ║
║  │  [abc]          One character from set             ls file[123].txt     │  ║
║  │  [a-z]          One character from range           ls file[a-z].txt     │  ║
║  │  [!abc]         ONE character NOT in set           ls file[!0-9].txt    │  ║
║  │  {a,b,c}        Explicit expansion                 mkdir dir{1,2,3}     │  ║
║  │  {1..10}        Sequence                           touch file{1..10}    │  ║
║  │                                                                         │  ║
║  │  ⚠️ Trap: * does NOT include hidden files (.hidden) !                   │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        ⚙️ SHELL CONFIGURATION                           │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  ~/.bashrc           Configuration file (edit with nano)                │  ║
║  │  source ~/.bashrc    Apply changes NOW                                  │  ║
║  │  . ~/.bashrc         Equivalent to source                               │  ║
║  │                                                                         │  ║
║  │  ALIASES in .bashrc:                                                    │  ║
║  │  alias ll='ls -la'                                                      │  ║
║  │  alias cls='clear'                                                      │  ║
║  │  alias ..='cd ..'                                                       │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  ┌─────────────────────────────────────────────────────────────────────────┐  ║
║  │                        🆘 HELP                                          │  ║
║  ├─────────────────────────────────────────────────────────────────────────┤  ║
║  │  man command      Complete manual (q = exit)                            │  ║
║  │  command --help   Quick help                                            │  ║
║  │  type command     What type? (builtin, alias, external)                 │  ║
║  │  which command    Where is the executable?                              │  ║
║  │  apropos keyword  Search in manuals                                     │  ║
║  └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  📁 FILE SYSTEM HIERARCHY (FHS)                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  /                    Root                                                    ║
║  ├── bin/             Essential commands (ls, cp, cat)                        ║
║  ├── etc/             System configurations (passwd, hosts)                   ║
║  ├── home/            User directories                                        ║
║  │   └── student/     YOUR home                                               ║
║  ├── tmp/             Temporary files (cleanup is local policy)                     ║
║  ├── var/             Variable data                                           ║
║  │   └── log/         System logs (syslog, auth.log)                          ║
║  └── usr/             User programs                                           ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  ⚠️ COMMON MISTAKES TO AVOID                                                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  ❌ VAR = "val"     →  ✅ VAR="val"       (no spaces around =)               ║
║  ❌ rm -rf /        →  ✅ NEVER!         (GNU rm protects / by default)             ║
║  ❌ '$VAR'          →  ✅ "$VAR"          (if you want expansion)            ║
║  ❌ cd /home/~      →  ✅ cd ~ or cd      (~ is already /home/user)          ║
║  ❌ alias ll=ls -la →  ✅ alias ll='ls -la' (with quotes)                    ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

                    📚 ASE-CSIE | Operating Systems | Seminar 1
```

*Personal note: Many prefer `zsh`, but I stick with Bash because it's the standard on servers. Consistency beats comfort.*


---

## QUICK REFERENCE - COMMANDS BY CATEGORY

### Top 10 most used commands:

| # | Command | What it does | Example |
|---|---------|--------------|---------|
| 1 | `cd` | Change directory | `cd ~/Documents` |
| 2 | `ls` | List | `ls -la` |
| 3 | `pwd` | Current directory | `pwd` |
| 4 | `cat` | Display file | `cat file.txt` |
| 5 | `mkdir` | Create directory | `mkdir -p a/b/c` |
| 6 | `touch` | Create file | `touch new.txt` |
| 7 | `cp` | Copy | `cp -r src/ dst/` |
| 8 | `mv` | Move/Rename | `mv old.txt new.txt` |
| 9 | `rm` | Delete | `rm -r folder/` |
| 10 | `echo` | Display text | `echo "$HOME"` |

### Terminal shortcuts:

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Interrupt current command |
| `Ctrl+D` | Logout / End of input |
| `Ctrl+L` | Clear screen (or `clear`) |
| `Ctrl+A` | Go to beginning of line |
| `Ctrl+E` | Go to end of line |
| `Ctrl+R` | Search in history |
| `Tab` | Auto-completion |
| `Tab Tab` | Show all options |
| `↑ / ↓` | Navigate history |

---

## QUICK SELF-TEST

Can you answer these questions?

1. ❓ What does `cd -` do?
2. ❓ What's the difference between `'$VAR'` and `"$VAR"`?
3. ❓ How do you create a directory with subdirectories in one command?
4. ❓ What does `ls file?.txt` do differently from `ls file*.txt`?
5. ❓ How do you apply changes from .bashrc without closing the terminal?

<details>
<summary>🔑 Answers</summary>

1. Toggle between the last 2 visited directories
2. Single quotes = literal, double quotes = expands the variable
3. `mkdir -p dir/subdir/subsubdir`
4. `?` = exactly 1 character, `*` = any number of characters
5. `source ~/.bashrc` or `. ~/.bashrc`

</details>

---

*Cheat Sheet | OS Seminar 1-2 | ASE-CSIE*
