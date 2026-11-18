# Formative assessment — SEM06

## Canonical files and scope

`quiz.yaml` is the canonical 23-question bank. It contains 140 authored points; the metadata totals and Bloom distribution are derived from its current records. Question IDs, weights and existing Bloom labels are preserved. Review of the response alternatives does not validate classroom-effectiveness percentages: historical estimates retain an explicit unverified-provenance label.

`quiz_runner.py` provides local practice. `quiz_lms.json` retains its historical filename but contains **ENos local data**, with the YAML SHA-256 and every original question record. It is **not Moodle XML, Canvas QTI or a verified institutional import format**. No LMS connection or import acceptance is claimed. Public files cannot be made confidential by labelling them instructor-only; the publication choice remains open in [AUTHOR_DECISIONS.md](../../AUTHOR_DECISIONS.md).

## Quick start

Use the complete repository checkout and a Python environment with PyYAML. From the repository root, change to `SEM06/formative`, then run the selected command:

```bash
python3 quiz_runner.py quiz.yaml
python3 quiz_runner.py quiz.yaml --practice
python3 quiz_runner.py quiz.yaml --shuffle --export results.json
python3 quiz_runner.py quiz.yaml --validate
python3 quiz_runner.py quiz.yaml --export-bank bank.json
python3 quiz_runner.py --test
```

No `--questions`, `--timed`, `--file`, `--show-answers`, `--export moodle` or `--export canvas` workflow is implemented. The actual help is `python3 quiz_runner.py --help`.

## Options

| Argument | Behaviour |
|---|---|
| Positional `quiz_file` | YAML bank, required unless using `--test`, `--help` or `--version` |
| `--practice`, `-p` | Show explanations after each answer |
| `--shuffle`, `-s` | Shuffle questions; per-Bloom results retain each question's identity |
| `--export FILE`, `-e FILE` | JSON session results after completion; not a question/LMS export |
| `--validate` | Validate bank schema, answer keys and derived totals without answering |
| `--export-bank FILE` | Local normalised question-bank JSON; no interaction |
| `--test`, `-t` | The runner's small internal unit checks, not a complete acceptance suite |
| `--version`, `-v` | Runner version, distinct from the question-bank version |

## Scoring contract

The CLI percentage is **earned question points / total question points × 100**. The 23 canonical questions retain all authored weights and sum to 140. All-correct therefore yields 100%. The previous JSON omitted q21–q23 and carried a different denominator; it has been regenerated from the complete YAML. Bloom feedback reports count-correct within each actually presented level, independently of the weighted overall percentage. The existing 60% threshold is a formative feedback target only; it does not adopt a course grade, eligibility, attempt-limit or late-work policy.

Both tools render feedback only at the documented time. Embedded Bash snippets are question text; the quiz does not execute them. Code-output questions assume the stated shell, options and inputs. Intentional wrong examples remain questions, with corrected answer explanations.

## Editing the bank

Use stable unique IDs, valid answer keys and finite positive points. The following is an illustrative minimal bank, not a replacement for the canonical data:

```yaml
metadata:
  seminar: 6
  title: Example formative bank
questions:
  - id: example01
    type: mcq
    text: Which exit status conventionally means success?
    subject: Exit codes
    bloom: remember
    points: 5
    options:
      a: Zero
      b: One
    correct: a
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
