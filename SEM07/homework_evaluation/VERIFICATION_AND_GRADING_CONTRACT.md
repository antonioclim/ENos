# Local verification and assessment review contract

## What the corrected tools establish

`bash verify_homework_EN.sh [options] submissions/` preserves `-o`, `-k`, `-q`,
`-r`, `--seminar` and `--student`. Python 3 is required; OpenSSL is required for
cryptographic verification. No remote endpoint is contacted. Each file is parsed
independently and malformed entries do not terminate the batch.

Asciicast v2 validation follows the [official format specification](https://docs.asciinema.org/manual/asciicast/v2/):
positive integer `width`/`height`, `version: 2`, optional integer `timestamp`,
finite non-negative monotonic event times, string event type and payload. Output,
input, marker and resize events (`o`, `i`, `m`, `r`) are recognised; a resize uses
positive `WIDTHxHEIGHT`. Unknown event codes are preserved and reported as
extensions. This is format validation, not proof that the recorded operations
occurred on a particular machine or under a particular identity.

| State | Meaning |
|---|---|
| `VALID` | The existing SEM07 signature message verified with the explicitly supplied public key. |
| `UNVERIFIED` | No supported signature, no key or no usable verification runtime. Length/format alone never becomes `VALID`. |
| `INVALID` | Malformed recording/envelope or failed cryptographic verification. |
| `COMPLETE` (metadata) | Explicit non-empty `student_name`, `student_group`, `seminar` are present. This is not authenticated identity. |
| `MISSING_METADATA` | One or more required identity fields are absent or `UNKNOWN`. No identity is inferred. |

The first six CSV columns remain `File,Student,Group,Seminar,Timestamp,Signature_Status`.
`File` is relative to the submitted directory, avoiding collisions between equal
basenames. Additional columns are `Metadata_Status,Reason,Source_SHA256,Format_Status`. CSV
quoting preserves commas, quotes and line breaks. The SHA-256 covers the complete
file; the grader checks it again before using a verification row. This detects
local post-verification changes but does not make an externally supplied CSV trusted.

Exit 0 means a non-empty processed selection is entirely `VALID` and metadata
`COMPLETE`. Exit 2 means the batch completed but includes unresolved/invalid records
or is empty. Exit 1 means an operational failure. Filtered records are counted
separately. JSON summary counters come from exact states, never substring matching
of `VALID` within `INVALID`.

## Preserved envelope, unresolved interoperability

Only a final, unique `# SIGNATURE: <base64>` line is accepted by the existing
signature verifier. The signed message remains `hex(SHA256(preceding bytes)) + LF`,
verified by `openssl dgst -sha256`. This avoids silently introducing a replacement
protocol. Per-invocation private temporary storage replaces a shared `/tmp/sig.bin`.

The current recorders emit seminar as an integer. Values 1–99 normalise to `SEM01`–`SEM99` for the report; explicit `SEMnn` strings use the same representation. This is supplied-label normalisation, not acceptance into an assessment catalogue. Boolean, missing or other seminar values are rejected as identity metadata. `version` must be an integer equal to 2, not `2.0` or `true`. A blank separator immediately before a recognised footer is treated as envelope separation, while blank event records elsewhere remain invalid. `Format_Status` is separate from identity and signature: malformed events do not erase valid explicit identity fields.

Recorder footers `## SIG:`, `## META:` and the earlier `## ...` payloads can be
recognised structurally but are **not** accepted as signatures. Public-key
encryption of metadata is not a student's digital signature and does not bind
recording bytes. Producer-to-verifier institutional acceptance is therefore open.

The author must choose one of the following before deployment:

| Choice | Consequence |
|---|---|
| Student-held signing keys | Requires enrolment, verified identity-to-key binding, key rotation/revocation and loss handling. |
| Authenticated server receipt binding the content digest | Centralises verification and trusted submission time; requires an approved server protocol and receipt key custody. |
| Content integrity record without identity authentication | Can detect subsequent changes relative to a retained digest; cannot establish who submitted the recording. |

Recommendation: select an authenticated server receipt if an institutional
submission service already supplies verified identities and trusted timestamps;
otherwise define that service/identity boundary first. This recommendation is not
an implemented policy. Existing files need an explicit compatibility/review rule;
none are silently promoted to trusted records.

## Human score review

`grade_homework_EN.py` requires `--verification verification_results.csv` and
complete header `student_id`, `student_name`, `student_group`, `seminar`,
`homework_id`, plus a usable timestamp for the review record. Missing values are
reported in `.review.json`. No placeholder identity is aggregated. Optional
`--scores` reads `file,final_score` (relative file path, finite score from 0 to 10).
A score of zero is a reviewed score. Missing scores stay `PENDING_REVIEW`.
Rubrics are read from the shipped `S01_HOMEWORK_RUBRIC.md` naming scheme; their
criteria are applied by the human assessor, not inferred from Markdown keywords.
Recording byte count does not generate marks.

Distinct `(student_id, seminar, homework_id)` values are counted. Duplicate
attempts and conflicting names/groups require explicit resolution, rather than
choosing first/latest/best without an approved rule. Reports stay `PENDING_POLICY`.
Deadline CSV timestamps must include a timezone; computed lateness is explicitly
labelled as based on the client timestamp and does not trigger deductions.

The final calculator accepts homework `final_score`, not ambiguous `score`;
`signature_valid`, `late_days` and distinct assignment IDs are validated. Tests
require distinct `test_id`, with -1 reserved for absence and 0 a present result.
All scores must be finite. Project components must sum to at most 10; the bundled
sample marks are synthetic examples within that bound; they do not establish
approved project subweights, which remain an author decision. Missing/conflicting identities and repeated projects are not overwritten.

Without `--policy`, component reports have no final grade/eligibility decision.
An explicit JSON policy requires `schema_version: 1`, `score_stage: "final"`,
`late_homework_counts` (boolean), `weights` (`homework`, `project`, `tests`, sum 1),
`thresholds` (`homework_min`, `homework_total`, `tests_min`, `tests_total`) and
`grade_boundaries` (descending `[lower_bound, integer_grade]` pairs ending at 0).
`passing_grade` (integer 1–10), `elimination_grade` (null or integer 1–10) and `require_project_eligible` (boolean) are also mandatory explicit choices. Missing/unreviewed components remain null/blank; a reviewed zero remains zero. With a supplied policy, missing evidence blocks only components with positive weight, and project eligibility only when `require_project_eligible` is true. Participation thresholds apply to positively weighted homework/tests. Zero-weight components are omitted from the weighted sum without converting their missing values to zero. Their missing/unverified evidence remains visible as non-blocking report notes. Required missing evidence produces `PENDING_EVIDENCE`. Unverified submissions and missing evidence are listed in reports. Without a policy, reports do not label pending students as failures or publish a final-grade distribution. No default policy file is supplied. This interface does not authorise publication.

The author must resolve participation denominator/minimum, acceptance of late
work, authoritative time, resubmissions, component scales, project subweights and
rounding. Recommendation: one versioned policy and criterion-level evidence table,
then derive all examples and machine configuration from it. Existing contradictory
proposals remain visible as history rather than being silently enacted.

## Project diagnostics

`run_auto_eval_EN.sh` performs static checks by default. It does not execute a
student project unless `--execute-local` (trusted code only) or `--docker` with an
existing `--docker-image` is explicit. Missing Docker never falls back to local
execution; no image pull is performed. Container configuration requests no network,
read-only root and input mounts, non-root identity, bounded process/memory/CPU and
dropped capabilities. Container execution still needs validation in the target
Docker environment; its presence here is not a claim of native acceptance.

Only per-test timeouts apply to local execution. A temporary working copy limits
accidental writes to the input tree but is not a security sandbox. Heuristic totals
are diagnostic and no marks are awarded for unimplemented level-specific tests.
Command status and output are retained separately, so an expected non-zero CLI
error can be observed without terminating the report. Human review and substantive
project acceptance remain required.
