# Final-test question pool and local draft generator

**Source author:** ing. dr. Antonio Clim.  
**Scope:** publicly distributed teaching questions and review drafts. The author has not yet selected whether future assessment should use a public practice bank, a separately maintained confidential bank, or another approved arrangement. This directory does not make that choice.

The pool contains **296 questions in 13 categories**, with **178 authored points** in total: 262 multiple-choice questions, 26 short-answer questions and 8 practical questions. IDs, point weights, Bloom labels and difficulty labels are preserved. Corrected wording makes the intended shell, operating-system or performance assumptions explicit. These totals describe the pool; they do not define an examination length, a pass threshold or an institutional grading policy.

## Files and supported behaviour

| File | Purpose |
|---|---|
| [questions_pool.yaml](questions_pool.yaml) | Canonical question content, reference answers, explanations and derived metadata |
| [test_generator.py](test_generator.py) | Validates the pool and creates reproducible local question drafts with separate review keys |
| [../../tests/test_final_bank_generator.py](../../tests/test_final_bank_generator.py) | Local contract checks for validation, sampling, answer remapping and output preservation |

The implementation requires Python 3.10 or later and PyYAML. Use the project's prepared Python environment. It does not install dependencies, execute the code printed in questions, contact an LMS, grade a response or upload a generated document.

Commands below are run from the **repository root**. If a command reports a missing dependency, prepare the documented environment before generation; a failed command is not a completed form.

## Validate without creating a form

```bash
python3 SEM07/final_test/test_bank/test_generator.py --help
python3 SEM07/final_test/test_bank/test_generator.py \
  --input SEM07/final_test/test_bank/questions_pool.yaml --validate
```

Validation derives category, type, difficulty and Bloom counts from the actual questions and compares any declared totals. It rejects repeated YAML mapping keys, duplicate question IDs, inconsistent counts, non-finite or non-positive point weights, unknown types, literal duplicate options and answer keys that do not name an option. It cannot determine that a natural-language answer is scientifically correct or uniquely defensible; that still requires content review.

## Generate a local review draft

Choose the question count and seed explicitly. The following is an example for local review, not an adopted examination specification:

```bash
python3 SEM07/final_test/test_bank/test_generator.py \
  --input SEM07/final_test/test_bank/questions_pool.yaml \
  --questions 40 --seed 12345 --format yaml --output draft_12345
```

The parent directory must exist and `draft_12345` must be a **new directory**. Existing files or directories are rejected without replacement. A successful call produces:

| Output | Contents |
|---|---|
| `questions.yaml` | Question IDs, text, point weights and shuffled choices; no answer-only fields |
| `answer_key.yaml` | Reference answers mapped to the displayed choices, explanations, option provenance and reproduction recipe |
| `manifest.json` | Form identifier, file names, byte lengths and SHA-256 digests |

`--format markdown` creates `.md` documents; `--format json` creates JSON documents. The JSON manifest is written last. A caught write error triggers cleanup of the files created by that invocation. This is not a transaction or crash-durability guarantee; a directory without a complete valid manifest must not be treated as a completed form.

The output directory is created with restrictive permissions where the host honours POSIX modes. A separate answer-key file prevents accidentally including answer fields in the question document. It does **not** make the original public questions or their answers confidential.

### Optional filters

Obtain exact category names from `--validate`, then add one or more `--category 'Exact category name'` options. Matching is case-insensitive. `--difficulty` accepts `easy`, `medium` or `hard`; `--type` accepts `multiple_choice`, `short_answer` or `practical`.

Filters restrict the eligible pool and sampling takes place without replacement. They do not impose quotas or stratification across categories, difficulty or Bloom levels. A request larger than the eligible pool fails. Review the resulting selection against the intended learning outcomes before using it in any assessment.

### Reproduction and option order

The same source bytes, Python version, generator version, arguments and seed reproduce the same selection and option order. The answer key records those inputs, the generator's source SHA-256 and the IDs in presentation order. Each multiple-choice item is shuffled and its key is remapped to the displayed letters. The source bank is not rewritten. Changing the seed does not guarantee a unique form, equal difficulty, statistical independence or equivalent measurement.

The generator preserves each selected question's authored point weight. It reports the resulting total and has **no `--points 100` rescaling option**. Any future examination blueprint, weighting, grade conversion or resubmission rule needs an explicit approved contract.

## Actual YAML schema

Questions are nested under `categories`; there is no top-level `questions` list. Options are letter-keyed mappings, and `answer` is a string. This is a minimal illustrative pool, separate from the 296 authored items:

```yaml
metadata:
  course: Operating Systems
  author: Example author
  total_questions: 1
categories:
  - name: Shell basics
    question_count: 1
    questions:
      - id: DEMO01
        type: multiple_choice
        difficulty: easy
        bloom: remember
        points: 0.5
        question: Which option names a command shell?
        options:
          a: Bash
          b: A disk controller
          c: A physical memory page
        answer: a
        explanation: Bash is a command shell.
```

The accepted types are:

| Type | Required answer representation | Review behaviour |
|---|---|---|
| `multiple_choice` | One letter naming one of 2–26 distinct textual options | Key is remapped after shuffling; the generator awards no marks |
| `short_answer` | Non-empty reference-answer text | Explicitly marked `MANUAL_REVIEW_REQUIRED` in the review key |
| `practical` | Non-empty reference-answer text or reference code | Explicitly marked `MANUAL_REVIEW_REQUIRED`; code is never executed |

Optional `explanation`, `source` and printed `code` fields are strings. `accept_alternatives` and `keywords` are lists of strings. Keywords and example answers support human review; they are not an automatic substring-based marking rule. The supported Bloom labels are `remember`, `understand`, `apply`, `analyse`, `evaluate` and `create`.

## Local verification and remaining acceptance

From the repository root, with pytest available in the prepared environment:

```bash
python3 -m pytest SEM07/tests/test_final_bank_generator.py
```

These tests cover schema rejection, immutable inputs, reproducible selection, option/key agreement, all three output formats, byte manifests, preservation of existing output and the full current pool. Native CLI execution here means a local Python process. It does not establish LMS import, browser presentation, psychometric quality, student performance, invigilation or institutional acceptance.

The assessment and publication decision remains `PENDING_POLICY`. The separate [grade aggregation contract](../../grade_aggregation/GRADING_POLICY.md) also requires explicit policy values; generating a draft does not approve or fill them in.
