# Formative assessment — SEM05

## Canonical files and scope

`quiz.yaml` is the canonical 18-question bank. It contains 102 authored points; the metadata totals and Bloom distribution are derived from its current records. Question IDs, weights and existing Bloom labels are preserved. Review of the response alternatives does not validate classroom-effectiveness percentages: historical estimates retain an explicit unverified-provenance label.

`quiz_runner.py` provides local practice. `quiz_lms.json` retains its historical filename but contains **ENos local data**, with the YAML SHA-256 and every original question record. It is **not Moodle XML, Canvas QTI or a verified institutional import format**. No LMS connection or import acceptance is claimed. Public files cannot be made confidential by labelling them instructor-only; the publication choice remains open in [AUTHOR_DECISIONS.md](../../AUTHOR_DECISIONS.md).

## Quick start

Use the complete repository checkout and a Python environment with PyYAML. Rich is optional for SEM05. From the repository root, change to `SEM05/formative`, then run the selected command:

```bash
python3 quiz_runner.py quiz.yaml --no-rich
python3 quiz_runner.py quiz.yaml --category Functions --limit 3 --no-rich
python3 quiz_runner.py quiz.yaml --shuffle --no-rich
python3 quiz_runner.py quiz.yaml --no-rich --export-results results.json
python3 quiz_runner.py quiz.yaml --validate
python3 quiz_runner.py quiz.yaml --export-bank bank.json
```

No `--questions`, `--timed`, `--file`, `--show-answers`, `--export moodle` or `--export canvas` workflow is implemented. The actual help is `python3 quiz_runner.py --help`.

## Options

| Argument | Behaviour |
|---|---|
| Positional `quiz_file` | Required YAML bank path |
| `--shuffle` | Shuffle question order; options are not shuffled |
| `--category NAME` | Match the exact topic name, case-insensitively, e.g. `Functions` |
| `--limit N` | Positive maximum number of selected questions |
| `--no-rich` | Plain text output |
| `--export-results FILE` | JSON session results after completion |
| `--validate` | Validate source schema, answer keys and declared counts/weights without answering |
| `--export-bank FILE` | Local normalised bank data, without running a quiz |
| `--export-lms FILE` | Historical alias of `--export-bank`; it is not an LMS import converter |

## Scoring contract

The CLI percentage is **correct answers / selected questions × 100**, preserving the existing count-based practice behaviour. It also exports earned/max question points separately. Those weights sum to 102 in the complete authored bank; the former 100 metadata value was inconsistent. No question weight was changed to force a total of 100. All 18 correct answers yield 100%; selecting a topic/limit uses that selected question count. A blank/interrupted session is not a completed assessment and does not produce a final session export.

Both tools render feedback only at the documented time. Embedded Bash snippets are question text; the quiz does not execute them. Code-output questions assume the stated shell, options and inputs. Intentional wrong examples remain questions, with corrected answer explanations.

## Editing the bank

Use stable unique IDs, valid answer keys and finite positive points. The following is an illustrative minimal bank, not a replacement for the canonical data:

```yaml
metadata:
  seminar: 5
  title: Example formative bank
questions:
  - id: example01
    question: Which exit status conventionally means success?
    topic: Functions
    bloom: remember
    points: 5
    options:
      - text: Zero
        explanation: Success status
      - text: One
        explanation: Non-zero status
    correct_answer: 0
    explanation: Zero conventionally denotes success.
```

If `question_count`, `total_points` or `bloom_distribution` is present, it must agree with the records. The real banks declare all three. Schema validation is separate from human review of scientific content and answer uniqueness.

After an authorised edit, recalculate the descriptive metadata from the records, run `--validate`, then regenerate `quiz_lms.json` with `--export-bank quiz_lms.json`. From the repository root, both derived exports can be rebuilt with:

```bash
python3 scripts/build_formative_exports.py
python3 scripts/build_formative_exports.py --check
```

The builder and CLI use the same local export contract and retain the source question fields. The export preserves option identity and answer feedback; it does not enforce historical LMS template settings or select a publication/assessment policy. See [the teaching materials](../docs/) and [local tests](../tests/).

*Corrected source candidate: 17 November 2026. Native CLI/fixture checks are recorded in the Phase 5 evidence; no interactive terminal usability or LMS acceptance is inferred.*
