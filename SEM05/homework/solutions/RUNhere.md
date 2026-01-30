# 📁 Solutions — Functions & Arrays Reference

> **Location:** `SEM05/homework/solutions/`  
> **Access:** Instructors only

## Contents

| Script | Focus |
|--------|-------|
| `S05_ex01_functii_sol.sh` | Functions |
| `S05_ex02_arrays_sol.sh` | Arrays |
| `S05_ex03_robust_sol.sh` | Robust scripting |

---

## Key Patterns

### Functions
```bash
my_func() {
    local param="$1"
    # ...
    echo "$result"
}
```

### Arrays
```bash
declare -a indexed_arr=(a b c)
declare -A assoc_arr=([key]=value)
```

### Robust
```bash
set -euo pipefail
trap cleanup EXIT
```

---

⚠️ **CONFIDENTIAL**

*Last updated: January 2026*
