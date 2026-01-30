# 📁 Docker — Evaluation Environment

> **Location:** `SEM07/project_evaluation/Docker/`  
> **Purpose:** Isolated, reproducible environment for project evaluation

## Contents

| File | Purpose |
|------|---------|
| `Dockerfile` | Container image definition |

---

## Dockerfile Overview

The evaluation environment includes:

- **Base:** Ubuntu 24.04 LTS
- **Shell:** Bash 5.x
- **Python:** 3.12+
- **Tools:** shellcheck, make, git, curl, jq
- **Security:** Non-root user, no network access

---

## Building the Image

```bash
# Standard build
docker build -t enos-eval:latest .

# With build arguments
docker build -t enos-eval:latest \
    --build-arg PYTHON_VERSION=3.12 \
    --build-arg EXTRA_PACKAGES="htop strace" \
    .

# Verify image
docker images enos-eval
```

---

## Image Contents

### Installed Packages

| Category | Packages |
|----------|----------|
| Core | bash, coreutils, findutils, grep, sed, awk |
| Development | make, gcc, python3, pip |
| Analysis | shellcheck, pycodestyle, pylint |
| Utilities | curl, wget, jq, tree |
| Testing | pytest, bats |

### Environment Variables

```dockerfile
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/home/evaluator/.local/bin:$PATH"
```

### User Configuration

```dockerfile
# Non-root user for security
RUN useradd -m -s /bin/bash -u 1000 evaluator
USER evaluator
WORKDIR /home/evaluator
```

---

## Usage

### Manual Testing

```bash
# Interactive shell
docker run -it --rm enos-eval:latest /bin/bash

# Mount project for testing
docker run -it --rm \
    -v /path/to/project:/project:ro \
    enos-eval:latest \
    /bin/bash

# Run tests
docker run --rm \
    -v /path/to/project:/project:ro \
    enos-eval:latest \
    make -C /project test
```

### Resource Limits

```bash
# Limit memory and CPU
docker run --rm \
    --memory=512m \
    --cpus=1 \
    -v /path/to/project:/project:ro \
    enos-eval:latest \
    ./run_tests.sh
```

### Network Isolation

```bash
# No network access (evaluation mode)
docker run --rm \
    --network none \
    -v /path/to/project:/project:ro \
    enos-eval:latest \
    ./run_tests.sh
```

---

## Customisation

### Adding Packages

Edit Dockerfile:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-new-package \
    && rm -rf /var/lib/apt/lists/*
```

Rebuild: `docker build -t enos-eval:latest .`

### Python Packages

```dockerfile
RUN pip install --user \
    pyyaml \
    pytest \
    your-package
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Check network, update base image |
| Permission denied | Ensure files readable by uid 1000 |
| Package not found | Add to Dockerfile, rebuild |
| Memory issues | Increase `--memory` limit |

---

*See also: [`../run_auto_eval_EN.sh`](../run_auto_eval_EN.sh) for evaluation script*

*Last updated: January 2026*
