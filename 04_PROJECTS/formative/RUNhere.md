# Project readiness practice

The sectioned YAML bank contains multiple-choice and code-completion questions. Use the dedicated parser/runner, which validates duplicate keys, IDs, question types, options, answers, weights and difficulty-point values. It preserves the authored section structure and completion exercises.

```bash
# From this directory; Python3 with PyYAML:
python3 readiness_runner.py --validate
python3 readiness_runner.py
python3 readiness_runner.py --export-json practice_bank.json
```

`--file PATH` selects another bank using this exact schema. The JSON export preserves the local sectioned schema; it is not a Moodle/QTI package or an export for the single-list SEM quiz runners. Earlier instructions to send this file to SEM01's runner were incompatible.

Answers are letters for MC items and a `|`-separated list of blank values for completion items. Equivalent code can need human review; exact text mismatch is not proof of conceptual error. Enter `q` or interrupt to stop; an incomplete session returns2 and has no completed score.

The runner reports authored difficulty points per section and overall item points. Historical section weights are displayed separately because the bank does not specify how to combine both weight systems. No blended grade or project eligibility is inferred. The YAML's90–100/70–89/50–69/0–49 feedback bands are historical planning suggestions, not validated predictors; the previous75/60 bands in this guide were inconsistent and are not used.

Use missed items to choose concrete seminar exercises and project fixtures. There is no Seminar8 in this kit. Follow the corrected `study_resources` mapping and [project selection guide](../PROJECT_SELECTION_GUIDE.md). A self-report or quiz score cannot establish future project success.
