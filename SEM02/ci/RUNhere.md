# 📁 CI Configuration — SEM02

> **Location:** `SEM02/ci/`  
> **Purpose:** GitHub Actions workflow for automated quality checks

## Contents

| File | Purpose |
|------|---------|
| `github_actions.yml` | CI pipeline definition for this seminar |

## What It Does

This workflow runs automatically on every push/PR and performs:

| Check | Tool | Failure Behaviour |
|-------|------|-------------------|
| Bash lint | shellcheck | Blocks merge |
| Python lint | ruff | Blocks merge |
| YAML validation | PyYAML | Blocks merge |
| Unit tests | pytest | Blocks merge |
| Coverage check | pytest-cov | Warns if < threshold |
| Structure validation | Custom | Blocks merge |
| Link checking | lychee | Warns only |
| AI pattern scan | Custom | Warns only |

## How to Use

### For Repository Setup

Copy to GitHub Actions location:
```bash
cp github_actions.yml ../../.github/workflows/sem02_ci.yml
```

### For Local Testing

Run individual checks locally:
```bash
# Lint Bash scripts
shellcheck scripts/bash/*.sh scripts/demo/*.sh

# Lint Python
pip install ruff && ruff check scripts/python/

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"

# Run tests
pip install pytest pytest-cov && pytest tests/ -v
```

## Configuration

### Coverage Threshold

Edit the `COVERAGE_THRESHOLD` environment variable:
```yaml
env:
  COVERAGE_THRESHOLD: 75  # Minimum coverage percentage
```

### Excluding Files

Add patterns to ignore in linting:
```yaml
- name: Run shellcheck
  run: find scripts/ -name "*.sh" ! -name "excluded.sh" -exec shellcheck {} \;
```

## Workflow Jobs

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  lint-bash  │   │ lint-python │   │validate-yaml│
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                 │
       └────────────────┼─────────────────┘
                        ▼
                 ┌─────────────┐
                 │    test     │
                 └──────┬──────┘
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ ai-check    │  │ link-check  │  │  structure  │
└─────────────┘  └─────────────┘  └─────────────┘
                        │
                        ▼
                 ┌─────────────┐
                 │   summary   │
                 └─────────────┘
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow not triggering | Check branch names in `on:` section |
| shellcheck errors | Run locally first, fix warnings |
| Coverage too low | Add more tests or lower threshold |
| Link check timeouts | External links may be slow, check manually |

---

*Mirrors: parent `Makefile` targets*  
*See also: [`../Makefile`](../Makefile) for local automation*

*Last updated: January 2026*
