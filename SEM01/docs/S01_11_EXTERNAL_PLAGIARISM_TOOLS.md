# External Similarity Tools and Evidence Limits

> Operating Systems | ASE Bucharest - CSIE  
> Corrected operational guidance for Seminar 01

## 1. Scope and current supported route

This kit contains an internal normalised code/text comparison tool. Its results
are descriptive observations for documented human review. Shared templates,
short answers, common idioms and permitted collaboration can produce substantial
overlap. A percentage is not proof of plagiarism, independent authorship or the
origin of any particular line. Lexical style patterns do not establish AI use.

From `SEM01`, the available local route is:

```bash
python3 scripts/python/S01_05_plagiarism_detector.py ./submissions --threshold 0.85
```

The threshold is a configurable report filter, not an academic sanction. Inspect
the matched passages and common base code. The assignment's unresolved grading,
oral and evidential policies are described in
[ASSESSMENT_STATUS.md](../homework/ASSESSMENT_STATUS.md).

## 2. MOSS

MOSS is Stanford's software-similarity service. The provider's supported-language
list checked in the phase 3 evidence does **not** provide a Bash language adapter.
The former `-l bash` examples are not supported commands for this kit and have
been removed from the executable Makefile target. Plain text comparison, if a
service supports it, must be labelled as text comparison with different limits;
it must not be described as structural Bash analysis.

[Official MOSS documentation](https://theory.stanford.edu/~aiken/moss/) is the
source for registration and service terms. Its registration request contains two
body lines:

```text
registeruser
mail your-address@example.org
```

That is a template only: substitute the actual sender address if registration is
separately authorised. This phase did not send a registration message, create an
account or upload student work. Do not promise a response within a fixed number
of hours. Results are normally retained for roughly 14 days and may disappear
earlier; they are not a durable institutional archive.

MOSS options such as base-file exclusion and grouping by submission are useful
only with an actually supported input contract. The kit does not provide a
validated Bash-to-MOSS conversion. Selecting an external service requires the
author's decision on confidentiality, permission, student data and retention;
repository maintenance does not approve that policy.

## 3. JPlag

JPlag can operate locally. The formerly pinned **v5.0.0** requires **JDK 21**,
according to its [release documentation](https://github.com/jplag/JPlag/releases/tag/v5.0.0).
Calling that fixed release “latest”, or declaring Java 17 sufficient for it, was
incorrect. The [supported-language documentation](https://github.com/jplag/JPlag/wiki/2.-Supported-Languages)
checked in phase 3 does not list a Bash parser. Primitive text support is not
semantically equivalent to a Bash parser.

Before an instructor adopts another release or text adapter, verify its exact
runtime, language identifier, CLI options and report format against that release.
The kit makes no claim that the former `-l bash`, `-m 50`, results-directory or
`index.html` commands are a working JPlag v5 route. No JPlag comparison, report
import or installation was executed in this phase. `make jplag-check` therefore
reports this unsupported integration with a nonzero status instead of asserting
that results were generated.

## 4. Review workflow

1. Validate the submission's declared structure and run authorised local checks
   in an isolated exercise environment. A diagnostic score is not a final grade.
2. Compare local submissions and record the tool/version, configuration, source
   hashes, common templates and relevant matched passages. Execution time depends
   on input size and environment; no measured cohort-size guarantee is supplied.
3. Review explanations for the overlap, including assigned starter code, common
   solutions, permitted assistance and collaboration. Similarity alone does not
   justify selecting a penalty or accusing a student.
4. Use specific oral questions and requested modifications to assess present
   understanding. Oral answers do not retrospectively prove the origin of every
   source line. Record the actual answers and uncertainty without inventing an
   identity or provenance conclusion.
5. Apply only an approved academic process and published assessment policy. An
   unresolved observation stays unresolved; no automatic zero, sanction or final
   grade is produced by this workflow.

The applicable oral record is
[S01_04_ORAL_VERIFICATION_LOG.md](../homework/S01_04_ORAL_VERIFICATION_LOG.md).
Which students receive which oral checks remains part of the open author policy.

## 5. Evidence to retain under the approved policy

Retain the compared source hashes, configuration, selected report excerpts,
common base-file exclusions and the documented review outcome. Preserve
unfavourable and inconclusive results. Retention of previous semesters' work,
external report URLs, screenshots, student identifiers and correspondence is a
separate policy decision; it is not automatically authorised by this guide.

| Method | Observation | Evidential limit |
|--------|-------------|------------------|
| Internal comparison | Equal or similar normalised text | Templates and short answers can explain overlap |
| Style patterns | Matched words and comment forms | No calibrated authorship or AI-use inference |
| Supported external adapter | Tool-specific token or text overlap | Requires validation for the actual language and version |
| Oral explanation | Responses to documented questions | Assesses current understanding, not complete historical provenance |

No comparative accuracy data are supplied for these methods. The source guide's
former star rankings, fixed execution times and percentage-to-guilt bands were
not validated measurements. Historical source content remains in the immutable
baseline; it is not duplicated as an operational recipe.

## 6. Troubleshooting without false success

- A missing executable or incompatible Java runtime is an operational error,
  not a completed comparison.
- An unsupported language selection requires a supported adapter or a clearly
  limited local text route; changing the label to Bash does not add a parser.
- An empty report can mean absent inputs or unsupported format. Check the exact
  input inventory and diagnostics before interpreting it as zero similarity.
- Failure to open a version-specific report requires checking that release's
  documented viewer and format. Do not assume every release emits index.html.

The official-source statements above are carried forward from the archived
phase 3 verification of 17 November 2026. They are not a new online service test.
