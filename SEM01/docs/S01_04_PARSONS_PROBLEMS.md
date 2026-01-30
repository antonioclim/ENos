# Parsons Problems - Seminar 1-2
## Operating Systems | Shell Basics & Configuration

Total problems: 12  
Average time per problem: 3-5 minutes  
Format: Reorder lines of code + identify distractors

---

## WHAT ARE PARSONS PROBLEMS?

Parsons Problems are exercises where students arrange scrambled lines of code in the correct order. Benefits:
- Focus on logic and structure, not syntax
- Lower cognitive load than writing from scratch
- Excellent for **consolidation** and **warmup**

---

## PROBLEM 1: Simple Navigation

Objective: Navigate to home and display the path

Level: Beginner | Time: 2 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (4 lines + 1 distractor):

   pwd
   echo "We are in home"
   ls -la
   cd ~
   cd /                 ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
cd ~
pwd
echo "We are in home"
ls -la
```

Distractor explanation: `cd /` takes you to root, not home.
</details>

---

## PROBLEM 2: Create Directory and File

Objective: Create directory `project`, enter it, create `README.md`

Level: Beginner | Time: 2 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (4 lines + 1 distractor):

   echo "# My Project" > README.md
   mkdir project
   cat README.md
   cd project
   touch mkdir project  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
mkdir project
cd project
echo "# My Project" > README.md
cat README.md
```

Distractor explanation: `touch mkdir project` creates files named "mkdir" and "project", not a directory!
</details>

---

## PROBLEM 3: Copy with Backup

Objective: Copy `config.txt` to `config.txt.backup`, then modify the original

Level: Beginner | Time: 3 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (5 lines + 1 distractor):

   cat config.txt
   cp config.txt config.txt.backup
   echo "new line" >> config.txt
   touch config.txt
   echo "original content" > config.txt
   mv config.txt config.txt.backup  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
touch config.txt
echo "original content" > config.txt
cp config.txt config.txt.backup
echo "new line" >> config.txt
cat config.txt
```

Distractor explanation: `mv` moves (renames), doesn't copy - you would lose the original!
</details>

---

## PROBLEM 4: Project Structure

Objective: Create the structure: `app/src/`, `app/tests/`, `app/docs/`

Level: Intermediate | Time: 3 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (3 lines + 2 distractors):

   mkdir -p app/{src,tests,docs}
   tree app
   cd app
   mkdir app && mkdir src tests docs    ← DISTRACTOR 1
   mkdir app/src app/tests app/docs     ← VALID ALTERNATIVE
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
mkdir -p app/{src,tests,docs}
tree app
```

OR the longer but correct variant:
```bash
mkdir -p app/src app/tests app/docs
tree app
```

DISTRACTOR 1 explanation: Creates `app` but then `src`, `tests`, `docs` in the current directory, NOT inside `app`!
</details>

---

## PROBLEM 5: Variable and Echo

Objective: Set variable `GREETING`, display it with surrounding text

Level: Intermediate | Time: 3 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (3 lines + 2 distractors):

   GREETING="Good morning"
   echo "The message is: $GREETING"
   echo $GREETING
   GREETING = "Good morning"        ← DISTRACTOR 1 (spaces!)
   echo 'The message is: $GREETING' ← DISTRACTOR 2 (single quotes!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
GREETING="Good morning"
echo $GREETING
echo "The message is: $GREETING"
```

Distractor explanations:
- DISTRACTOR 1: Spaces around `=` cause an error!
- DISTRACTOR 2: Single quotes don't expand `$GREETING`
</details>

---

## PROBLEM 6: Export for Subshell

Objective: Create a variable visible in a subshell

Level: Intermediate | Time: 4 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (4 lines + 1 distractor):

   export PROJECT="OS_Lab"
   bash -c 'echo "Project: $PROJECT"'
   echo "In current shell: $PROJECT"
   PROJECT="OS_Lab"
   $PROJECT="OS_Lab"            ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
PROJECT="OS_Lab"
export PROJECT
echo "In current shell: $PROJECT"
bash -c 'echo "Project: $PROJECT"'
```

OR the compact form:
```bash
export PROJECT="OS_Lab"
echo "In current shell: $PROJECT"
bash -c 'echo "Project: $PROJECT"'
```

Distractor explanation: `$PROJECT="OS_Lab"` tries to execute the value of $PROJECT as a command!
</details>

---

## PROBLEM 7: Adding to .bashrc

Objective: Add an alias and apply the changes

Level: Intermediate | Time: 4 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (4 lines + 1 distractor):

   source ~/.bashrc
   alias ll='ls -la'
   echo "alias ll='ls -la'" >> ~/.bashrc
   ll
   cat "alias ll='ls -la'" >> ~/.bashrc  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
echo "alias ll='ls -la'" >> ~/.bashrc
source ~/.bashrc
ll
```

Note: `alias ll='ls -la'` alone creates the alias temporarily, not persistently.

Distractor explanation: `cat "text"` tries to read a file named "alias...", doesn't write text!
</details>

---

## PROBLEM 8: Find and Delete .tmp Files

Objective: Find all .tmp files and delete them

Level: Advanced | Time: 5 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (3 lines + 2 distractors):

   find . -name "*.tmp" -type f
   find . -name "*.tmp" -delete
   echo ".tmp files deleted"
   rm *.tmp                    ← DISTRACTOR 1 (not recursive!)
   find . -name "*.tmp" | rm   ← DISTRACTOR 2 (wrong syntax!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
find . -name "*.tmp" -type f
find . -name "*.tmp" -delete
echo ".tmp files deleted"
```

Distractor explanations:
- DISTRACTOR 1: `rm *.tmp` only deletes from current directory, not recursively
- DISTRACTOR 2: `rm` doesn't read from stdin like that - should be `xargs rm` or `-exec rm`
</details>

---

## PROBLEM 9: Exit Code Verification

Objective: Execute a command and check if it succeeded

Level: Intermediate | Time: 4 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (5 lines + 1 distractor):

   mkdir test_dir
   if [ $? -eq 0 ]; then
       echo "Directory created successfully"
   fi
   rmdir test_dir
   if [ $? -eq 1 ]; then     ← DISTRACTOR (inverted logic!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
mkdir test_dir
if [ $? -eq 0 ]; then
    echo "Directory created successfully"
fi
rmdir test_dir
```

Distractor explanation: `$? -eq 0` means success, not `$? -eq 1`!
</details>

---

## PROBLEM 10: Complex Globbing

Objective: List only .txt and .md files from the current directory

Level: Intermediate | Time: 3 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (2 correct lines + 2 alternatives + 1 distractor):

   ls *.txt *.md
   ls *.{txt,md}
   ls -la | grep -E "\.(txt|md)$"  ← VALID ALTERNATIVE
   echo "Text and markdown files:"
   ls *.[txt,md]               ← DISTRACTOR (wrong syntax!)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
echo "Text and markdown files:"
ls *.txt *.md
```

OR:
```bash
echo "Text and markdown files:"
ls *.{txt,md}
```

Distractor explanation: `[txt,md]` is a character class, it would match a single character from the set t,x,m,d,comma - not extensions!
</details>

---

## PROBLEM 11: Simple Script Creation

Objective: Create a script that displays the date and user

Level: Advanced | Time: 5 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (6 lines + 1 distractor):

   #!/bin/bash
   echo "Date: $(date)"
   echo "User: $USER"
   chmod +x info.sh
   ./info.sh
   cat > info.sh << 'EOF'
   EOF
   #/bin/bash             ← DISTRACTOR (missing !)
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
cat > info.sh << 'EOF'
#!/bin/bash
echo "Date: $(date)"
echo "User: $USER"
EOF
chmod +x info.sh
./info.sh
```

Distractor explanation: `#/bin/bash` is missing `!` - it won't be recognised as a shebang!
</details>

---

## PROBLEM 12: Custom Prompt

Objective: Set a coloured prompt with user and directory

Level: Advanced | Time: 5 min

```
═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (4 lines + 1 distractor):

   # Green for user, blue for directory
   PS1='\[\033[32m\]\u\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
   export PS1
   echo "New prompt activated"
   PS1='\[033[32m]\u\[033[0m]:\[034m]\w\[033[0m]\$ '  ← DISTRACTOR
═══════════════════════════════════════════════════════════════
```

<details>
<summary>🔑 SOLUTION</summary>

```bash
# Green for user, blue for directory
PS1='\[\033[32m\]\u\[\033[0m\]:\[\033[34m\]\w\[\033[0m\]\$ '
export PS1
echo "New prompt activated"
```

Distractor explanation: The backslashes are missing from the escape sequences - the prompt will be corrupted!
</details>

---

## USAGE GUIDE

### When to use each problem:

| Problem | Appropriate moment | Concepts tested |
|---------|-------------------|-----------------|
| P1-P2 | Beginning warmup | Basic navigation |
| P3-P4 | After cp/mkdir | Copying, structures |
| P5-P6 | After variables | Assignment, export |
| P7 | After .bashrc | Persistent configuration |
| P8 | After find | Advanced search |
| P9 | After $? | Control flow |
| P10 | After globbing | Wildcards |
| P11-P12 | Towards the end | Knowledge integration |

### Working format:
- Individual: 3-5 minutes per problem
- Pairs: Discuss before validating
- Class: One student at the board, others guide

---

## TEMPLATE FOR NEW PROBLEMS

```markdown
## PROBLEM X: [TITLE]

Objective: [What the final code should do]

Level: [Beginner/Intermediate/Advanced] | Time: X min

═══════════════════════════════════════════════════════════════
SCRAMBLED LINES (N lines + M distractors):

   [line 1]
   [line 2]
   [distractor with explanation]    ← DISTRACTOR
═══════════════════════════════════════════════════════════════

<details>
<summary>🔑 SOLUTION</summary>

[correct code]

Distractor explanation: [why it's wrong]
</details>
```

---

*Parsons Problems | OS Seminar 1-2 | ASE-CSIE*
