# Resources and References - Seminar 3-4
## Operating Systems | ASE Bucharest - CSIE

> Version: 1.0 | Updated: January 2025  
> Purpose: Curated collection of resources for deepening concepts from Seminar 2

---

## Table of Contents

1. [Official Documentation](#-official-documentation)
2. [Interactive Tutorials](#-interactive-tutorials)
3. [Books and Manuals](#-books-and-manuals)
4. [Cheat Sheets and Quick References](#-cheat-sheets-and-quick-references)
5. [Videos and Online Courses](#-videos-and-online-courses)
6. [Practice and Exercises](#-practice-and-exercises)
7. [Tools and Utilities](#-tools-and-utilities)
8. [Communities and Forums](#-communities-and-forums)
9. [Articles and Blog Posts](#-articles-and-blog-posts)
10. [Resources in Romanian](#-resources-in-romanian)

---

## Official Documentation

### GNU Bash Manual
- Link: https://www.gnu.org/software/bash/manual/bash.html
- Content: Complete official documentation for Bash
- Sections relevant to seminar:
  - 3.2.4 Lists of Commands (operators `;`, `&&`, `||`)
  - 3.6 Redirections (all redirection forms)
  - 3.2.6 GNU Parallel
  - 3.5.1 Brace Expansion
  - 4.1 Bourne Shell Builtins (`break`, `continue`)
- Use `man` or `--help` when in doubt

### Coreutils Manual
- Link: https://www.gnu.org/software/coreutils/manual/coreutils.html
- Relevant sections:
  - sort: Text sorting
  - uniq: Reporting/omitting repeated lines
  - cut: Extracting sections from lines
  - paste: Merging lines from files
  - tr: Translating or deleting characters
  - wc: Counting lines, words, bytes
  - head/tail: Extracting portions from files
  - tee: Duplicating data streams

### POSIX Shell Command Language
- Link: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
- Utility: POSIX standard for maximum portability

### Man Pages Online
- Link: https://man7.org/linux/man-pages/
- Relevant commands: `man bash`, `man sort`, `man uniq`, `man cut`, `man tr`

---

## Interactive Tutorials

### Exercism - Bash Track
- Link: https://exercism.org/tracks/bash
- Description: Practical exercises with free mentorship
- Level: Beginner → Advanced
- Recommended for: Progressive practice with feedback

### Learn Shell - Interactive Tutorial
- Link: https://www.learnshell.org/
- Description: Interactive browser tutorial
- Relevant sections:
  - Pipes and Filters
  - Process Substitution
  - Loops

### ShellCheck
- Link: https://www.shellcheck.net/
- Description: Online linter for shell scripts
- Utility: Identifies errors and bad practices in code
- Read error messages carefully — they contain valuable hints

### Explain Shell
- Link: https://explainshell.com/
- Description: Explains complex shell commands
- Example: Try `cat file | sort | uniq -c | sort -rn | head -10`

### RegexOne - Regex Tutorial
- Link: https://regexone.com/
- Utility: Useful for understanding patterns used with `grep`, `sed`

---

## Books and Manuals

### Free (Online)

#### The Linux Command Line (William Shotts)
- Link: https://linuxcommand.org/tlcl.php
- Format: Free PDF, 500+ pages
- Relevant chapters:
  - Part 1: Learning the Shell
  - Chapter 6: Redirection
  - Chapter 7: Seeing the World as the Shell Sees It
  - Part 4: Shell Scripting
- ⭐ Recommended as first reading

#### Advanced Bash-Scripting Guide
- Link: https://tldp.org/LDP/abs/html/
- Description: Complete guide for advanced Bash
- Relevant chapters:
  - Chapter 16: I/O Redirection
  - Chapter 11: Loops and Branches
  - Chapter 7: Tests

#### Bash Guide for Beginners
- Link: https://tldp.org/ldp/bash-beginners-guide/html/
- Level: Beginner
- Style: Accessible, with many examples

### Paid (but excellent)

#### "Learning the Bash Shell" - O'Reilly
- Authors: Cameron Newham
- ISBN: 978-0596009656
- Notes: Classic, 3rd edition
- Verify the result before continuing

#### "Bash Cookbook" - O'Reilly
- Authors: Carl Albing, JP Vossen
- ISBN: 978-1491975336
- Notes: Practical solutions for real problems

#### "Classic Shell Scripting" - O'Reilly
- Authors: Arnold Robbins, Nelson H.F. Beebe
- ISBN: 978-0596005955
- Notes: Unix philosophy, pipes and filters
- Read error messages carefully — they contain valuable hints

---

## Cheat Sheets and Quick References

### Official Cheat Sheets

#### Devhints - Bash Cheat Sheet
- Link: https://devhints.io/bash
- Format: Web, organised by sections
- Strengths: Concise, updated

#### SS64 - Bash Reference
- Link: https://ss64.com/bash/
- Format: Command dictionary
- Utility: Quick reference per command

### PDF Cheat Sheets

#### Bash Reference Card
- Link: https://mywiki.wooledge.org/BashSheet
- Format: One-page reference
- Content: Condensed syntax
- Verify the result before continuing

#### Linux Command Line Cheat Sheet
- Link: https://cheatography.com/davechild/cheat-sheets/linux-command-line/
- Format: Printable PDF

### Quick Reference Cards

#### Unix/Linux Command Reference (FOSSWire)
- Link: https://files.fosswire.com/2007/08/fwunixref.pdf
- Format: A4 PDF front and back
- Style: Very condensed

---

## Videos and Online Courses

### Free

#### DistroTube - Bash Scripting
- Link: https://www.youtube.com/c/DistroTube
- Playlist: "Learning Bash Scripting"
- Style: Practical, straight to the point

#### The Linux Foundation - Introduction to Linux
- Link: https://www.edx.org/course/introduction-to-linux
- Platform: edX
- Certificate: Available (optional, paid)

#### freeCodeCamp - Bash Scripting Tutorial
- Link: https://www.youtube.com/watch?v=tK9Oc6AEnR4
- Duration: ~5 hours
- Level: Beginner → Intermediate

#### Ryan's Tutorials - Bash Scripting
- Link: https://ryanstutorials.net/bash-scripting-tutorial/
- Format: Text + examples
- Style: Very accessible

### Paid (high quality)

#### Linux Academy / A Cloud Guru
- Course: "Linux Shell Scripting"
- Platform: https://acloudguru.com/
- Level: Intermediate
- Use `man` or `--help` when in doubt

#### Udemy - "Bash Shell Scripting"
- Instructor: Jason Cannon
- Notes: Wait for sales (frequently at $10-15)

---

## Practice and Exercises

### Practice Platforms

#### HackerRank - Linux Shell
- Link: https://www.hackerrank.com/domains/shell
- Exercises: 60+ problems
- Categories: Bash, Text Processing
- Level: Easy → Hard

#### LeetCode - Shell
- Link: https://leetcode.com/problemset/shell/
- Exercises: 4 classic problems
- Style: Interview-style

#### OverTheWire - Bandit
- Link: https://overthewire.org/wargames/bandit/
- Style: Wargame / CTF
- Level: Beginner
- ⭐ Highly recommended for learning through exploration

#### Cmdchallenge
- Link: https://cmdchallenge.com/
- Description: One-liners challenge
- Style: Solve in browser

### Exercise Sets

#### Bash Practice Questions
- Link: https://github.com/topics/bash-exercises
- Format: GitHub repos with exercises
- Type: Self-paced

#### Unix Workbench - Coursera
- Link: https://www.coursera.org/learn/unix
- Includes: Quizzes and practical projects

---

## Tools and Utilities

### For Development

#### Visual Studio Code + Extensions
- Extension: "Bash IDE" (mads-hartmann.bash-ide-vscode)
- Extension: "shellcheck" (timonwong.shellcheck)
- Extension: "Bash Debug"
- Link: https://code.visualstudio.com/

#### ShellCheck (linter)
- Link: https://github.com/koalaman/shellcheck
- Installation: `sudo apt install shellcheck`
- Usage: `shellcheck script.sh`

#### bat (cat with syntax highlighting)
- Link: https://github.com/sharkdp/bat
- Installation: `sudo apt install bat`
- Recommended alias: `alias cat='batcat'` (on Ubuntu)

### For Debugging

#### bashdb (Bash Debugger)
- Link: http://bashdb.sourceforge.net/
- Installation: `sudo apt install bashdb`
- Usage: `bashdb script.sh`
- Test with simple data before complex cases

#### set -x / set +x
```bash
set -x  # Enable trace mode
# commands
set +x  # Disable
```

### For Productivity

#### fzf (Fuzzy Finder)
- Link: https://github.com/junegunn/fzf
- Usage: Quick navigation in history and files
- Installation: `sudo apt install fzf`

#### tldr (Simplified man pages)
- Link: https://tldr.sh/
- Installation: `npm install -g tldr` or `pip install tldr`
- Usage: `tldr tar`, `tldr find`

#### thefuck (Automatic corrector)
- Link: https://github.com/nvbn/thefuck
- Description: Corrects the previous incorrect command

---

## Communities and Forums

### Reddit
- r/bash: https://www.reddit.com/r/bash/
- r/commandline: https://www.reddit.com/r/commandline/
- r/linux: https://www.reddit.com/r/linux/

### Stack Exchange
- Unix & Linux: https://unix.stackexchange.com/
- Ask Ubuntu: https://askubuntu.com/
- Super User: https://superuser.com/

### Discord
- Linux Hub: https://discord.gg/linux
- The Programmer's Hangout: https://discord.gg/programming

### IRC
- #bash on Libera.Chat: irc.libera.chat
- Web client: https://web.libera.chat/#bash

### Wikis
- Greg's Bash Wiki: https://mywiki.wooledge.org/
  - BashFAQ: Most frequently asked questions
  - BashPitfalls: Common mistakes to avoid
  - ⭐ Excellent resource!

---

## Articles and Blog Posts

### Foundational Articles

#### "Pipes: A Brief Introduction" - Linus Torvalds
- Context: The Unix philosophy of pipes
- Link: Various online archives

#### "The Art of Command Line" ⭐ must-read!
- Link: https://github.com/jlevy/the-art-of-command-line
- Format: GitHub repo, translated into multiple languages

### Useful Blog Posts

#### Julia Evans - "Bite Size Bash"
- Link: https://wizardzines.com/zines/bite-size-bash/
- Format: Explanatory zine/comic
- Style: Visual and memorable

#### Digital Ocean Tutorials
- Link: https://www.digitalocean.com/community/tutorial_series/getting-started-with-linux
- Quality: Excellent, step by step

#### Linux Handbook
- Link: https://linuxhandbook.com/
- Topics: Bash scripting, Linux commands

#### Baeldung on Linux
- Link: https://www.baeldung.com/linux/
- Style: Detailed technical tutorial

---

## Resources in Romanian

### Documentation and Tutorials

#### Wiki Ubuntu România
- Link: https://wiki.ubuntu.ro/
- Content: Guides in Romanian

#### Linux.ro
- Link: https://www.linux.ro/
- Type: Romanian community forum

#### DevForum.ro
- Link: https://devforum.ro/
- Section: Linux & Unix

### YouTube Channels in Romanian

#### Various Romanian IT channels
- Search: "bash scripting tutorial română"
- Search: "linux terminal română"

### Books in Romanian

#### Introduction to Linux
- Authors: Various translations and academic materials
- Note: Check university libraries for resources

---

## Recommendations by Level

### Beginner
1. [Learn Shell](https://www.learnshell.org/) - Interactive tutorial
2. [The Linux Command Line](https://linuxcommand.org/tlcl.php) - Chapters 1-7
3. [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Level 0-10
4. [ExplainShell](https://explainshell.com/) - For understanding commands

### Intermediate
1. [HackerRank Shell](https://www.hackerrank.com/domains/shell) - Easy and Medium
2. [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) - Selected chapters
3. [Greg's Bash Wiki](https://mywiki.wooledge.org/) - BashFAQ, BashPitfalls
4. [Exercism Bash Track](https://exercism.org/tracks/bash) - With mentorship

### Advanced
1. [GNU Bash Manual](https://www.gnu.org/software/bash/manual/) - Complete
2. [ShellCheck](https://www.shellcheck.net/) - Understanding warnings
3. [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line)
4. Contributions to open-source projects

---

## Resources for Examination

### Concepts to Review
- [ ] Control operators: `;`, `&&`, `||`, `&`, `|`
- [ ] Exit codes and `$?`
- [ ] Redirection: `>`, `>>`, `<`, `2>`, `2>&1`, `&>`
- [ ] Here documents and here strings
- [ ] File descriptors (0, 1, 2)
- [ ] All filters: sort, uniq, cut, paste, tr, wc, head, tail, tee
- [ ] Loops: for (3 forms), while, until
- [ ] Control flow: break, continue
- [ ] The subshell problem with pipe

### Practice Exercises
1. Pipeline Analysis: Explain step by step what a complex pipeline does
2. Debugging: Identify the error in a given script
3. One-liners: Solve problems in maximum one command line
4. Script Writing: Write complete scripts with validation

---

## Contact and Support

### For Technical Questions
- Laboratory: WSL Ubuntu (user: stud, password: stud)
- Portainer: localhost:9000 (user: stud, password: studstudstud)

### Additional Course Resources
- Check the eLearning platform for updated materials
- Consult laboratory sessions for practical exercises

---

## Updates

| Date | Change |
|------|--------|
| Jan 2025 | Initial version |

---

> 💡 Suggestion: Bookmark this page and explore the resources gradually.  
> Don't try to learn everything at once - consistent practice is the key!

---

*Document generated for Seminar 3-4 SO | ASE Bucharest - CSIE | 2025*
