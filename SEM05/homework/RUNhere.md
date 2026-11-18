# Homework — Functions, Arrays and Robust Scripting

| File | Purpose |
|---|---|
| `S05_01_HOMEWORK.md` | Technical exercises and retained assessment proposals |
| `S05_02_create_homework.sh` | Starter generator with unimplemented learner TODOs |
| `S05_03_EVALUATION_RUBRIC.md` | Existing instructor rubric proposal |
| `S05_04_ORAL_DEFENCE_GUIDE.md` | Existing oral-assessment proposal |
| `solutions/` | Reference solutions already included in the repository |

From `SEM05/homework/`:

```bash
bash S05_02_create_homework.sh "Example Student" "1234"
```

The two positional arguments are name and group. The generator creates `$HOME/homework_S05_Example_Student`, including `test_files/sample.log` and `test_files/app.conf`. It asks before recreating an existing target. `--student-id`, `--difficulty` and `--seed` are not implemented. Use a synthetic name/group for a demonstration; no institutional identity is inferred from the generated directory.

Complete the TODOs, then run the generated scripts against their own fixtures. A generated starter is not a finished solution or verified submission. Assessment formula, oral weighting, penalties and access to solutions remain explicit author decisions in [the teaching contract](../docs/TEACHING_CONTRACT.md). No external upload occurs through these instructions.
