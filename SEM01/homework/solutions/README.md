# Assignment Solutions - Seminar 1

## Exercises and Scores

| Exercise | Score | Concepts Verified |
|----------|-------|-------------------|
| Ex1: Directory structure | 2p | mkdir -p, brace expansion |
| Ex2: Navigation script | 2p | cd, pwd, variables |
| Ex3: Environment variables | 2p | export, .bashrc |
| Ex4: Pattern matching | 2p | globbing, find |
| Ex5: Backup script | 2p | cp, timestamp, conditions |

## Verification Instructions

### Manual Verification

```bash
# Run the script
chmod +x solution.sh
./solution.sh

# Check the output
echo $?  # Should be 0
```

### Verification with Autograder

```bash
# From the assignment directory
make test
```

## Evaluation Notes

- **Partial scoring:** We award partial points for incomplete but functional solutions
- **Comments:** Bonus 0.5p for well-commented scripts
- **Style:** Using `set -euo pipefail` and quoting variables is appreciated
- **Originality:** Creative solutions are encouraged

## Common Student Problems

| Problem | Frequency | Solution |
|---------|-----------|----------|
| Spaces around `=` | 70% | `VAR="val"` not `VAR = "val"` |
| Missing quotes | 60% | Always use `"$VAR"` |
| Relative vs absolute path | 55% | Start with `/` for absolute |
| `exit` in functions | 40% | Use `return` in functions |
| Backticks | 35% | Prefer `$(command)` |

## Solution Files

- `S01_ex1_structure.sh` — Create directory structure with README
