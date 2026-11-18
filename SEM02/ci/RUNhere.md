# CI template — Seminar 2

## Files and activation

`github_actions.yml` is a **template stored under `SEM02/ci/`**. Its presence
here does not activate GitHub Actions. Activation requires a separately authorised
change under `.github/workflows/` and the repository's actual settings. A failed
check blocks merging only when the repository makes that check required; this
file cannot establish branch-protection policy.

`ruff.toml` is the standalone Ruff configuration. `linting.toml` retains historical
mixed-tool/pyproject-style reference material and must not be passed to Ruff's
`--config` option. The standalone file uses Ruff keys at the top level and omits
the unsupported `W503` selector. Do not apply global stylistic autofixes to
intentional teaching examples.

## Actual checks

The supplied template has one `lint-and-test` job. Syntax and YAML/JSON parsing steps fail on errors. ShellCheck, Ruff and the unit-test step retain explicit `continue-on-error: true`; these are informative in this template. The structure step currently reports missing paths as warnings. There is no link checker, AI detector, coverage threshold or separate summary job in this file.

A passed syntax check is not a functional test. A low coverage value, when a
separate coverage run is used, should prompt examination of untested behaviour;
it is not justification to lower an acceptance threshold automatically. Lint
warnings alone do not establish that an intentional WRONG/TODO activity is a defect.

## Local commands

From `SEM02/`, with the required tools already available in the selected
virtual environment:

```bash
ruff check --config ci/ruff.toml scripts/python/ formative/
python3 -c "import yaml; yaml.safe_load(open('formative/quiz.yaml'))"
python3 -c "import json; json.load(open('formative/quiz_lms.json'))"
python3 -m pytest --import-mode=importlib tests/ -v
```

For a bounded Ruff configuration check, an empty Python file should exit 0;
a temporary file containing `print(undefined_fixture_name)` should report F821
and exit 1. This detects a configuration-loader failure separately from an ordinary
lint finding. The current phase could parse the standalone TOML but had no local
Ruff executable, so native Ruff acceptance remains unverified. No package was
installed and no remote CI workflow was run.

The project `quiz_lms.json` is a canonical-bank derivative, not a proved native
Moodle/Canvas import package. Inspect the quiz runner's actual `--help` and its
local tests for supported functions.

See [the local Makefile](../Makefile) and [tests](../tests/). The local `lint-python`
target propagates Ruff's status and reports an unavailable tool explicitly.
