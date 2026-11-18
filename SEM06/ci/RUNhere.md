# CI template — SEM06

`github_actions.yml` is a proposed GitHub Actions workflow for this repository's actual `SEM06/` paths. It is not active while stored under `ci/`, and this remediation does not copy it into `.github/workflows` or publish it. Activation and branch-protection/required-check settings are separate author/operator choices; a workflow cannot itself promise to block a merge.

The template checks Bash 4.4+, Bash syntax and ShellCheck, Python compilation, pytest, the three native local project harnesses, current formative export/schema, required sources and local links. All nonzero checks fail the job. Dependencies are provisioned only when an authorised CI run executes. There is no claimed coverage threshold, lychee run, AI detector or result inferred from printed text.

Local commands from the repository root (dependencies must already be available):

```bash
make -C SEM06 check
make -C SEM06 lint
bash SEM06/tests/run_all_tests.sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest SEM06/tests -q
python3 SEM06/formative/quiz_runner.py --test
python3 scripts/build_formative_exports.py --check
python3 scripts/link_check.py SEM06
```

A missing ShellCheck/pytest/PyYAML means that check is not run, not that lint or tests pass. The `linting.toml` file is historical configuration/reference; ShellCheck and Flake8 do not consume its tables. Actual Ruff configuration belongs in a supported Ruff file or repository `pyproject.toml`; do not treat this combined file as an automatically loaded contract.

Native Docker/systemd, network integrations and browser execution remain separate from local fixture tests. Do not lower a threshold merely to make a result green.
