# Evaluation image template

The Dockerfile is a template, not an image built or accepted in the local audit. Use the **parent directory** as build context because `run_auto_eval_EN.sh` is there. This command is an installation/build example for an explicitly authorised environment:

```bash
# From SEM07/project_evaluation:
docker build -f Docker/Dockerfile -t enos-eval:local .
```

The template uses Ubuntu24.04 and installs Bash, Python3, ShellCheck, bc, jq, Git, Make, GCC and the listed utilities. Python analysis packages are pylint, flake8, PyYAML and rich. It does not currently install pytest or Bats, and has no `PYTHON_VERSION`/`EXTRA_PACKAGES` build arguments. Package revisions and the base image digest must be pinned and recorded for a repeatable institutional build.

`TIMEOUT`, `MAX_MEMORY` and `MAX_PIDS` environment strings do not enforce runtime limits. The explicit `--docker --docker-image` branch of [the evaluator](../run_auto_eval_EN.sh) supplies Docker limits, no-network mode, non-root UID/GID, read-only mounts/root and a temporary writable directory. Its results mount remains writable and has no disk quota. The image alone does not enforce those properties.

```bash
# Existing local image; no pull, with owned fixture input:
bash run_auto_eval_EN.sh --docker --docker-image enos-eval:local \
    --level EASY --timeout 10 --output ./fixture_results /path/to/owned_fixture
```

Native build, host/container marker isolation, timeout, resource exhaustion, result ownership and cleanup need verification in an authorised Docker environment. The current local environment supplied no working Docker daemon, so those checks are explicitly NOT_RUN. The wrapper fails if Docker/image prerequisites are missing; it never executes student code locally as a substitute.
