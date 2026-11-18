# Project assessment and evidence contract

## Current boundary

The 23 project descriptions remain technical assignments and teaching examples. The author has adopted descriptive evidence review; official grades, thresholds, penalties, deadlines and bonuses remain deferred. Historical numerical tables are proposals and do not supply an active policy. Reviewed evidence is preserved without inventing missing scores or applying an unapproved consequence.

| Open choice | Existing alternatives and consequence | Recommendation for author review |
|---|---|---|
| Project category/subweights | 04_PROJECTS agrees on40/20/15/15/10 but uses differing internal splits; SEM07 proposes85/15 automatic/manual. Selecting a split changes marks. | One criterion table with non-overlapping weights; derive every form and machine policy from it. |
| Optional work | Mandatory30 + optional10 permits losing core marks for allegedly optional work; bonuses separately reward additions. | Decide whether optional work belongs within100 or only outside the core maximum. |
| Kubernetes | MEDIUM-only in some guides, A01 extension recommended elsewhere; all-or-nothing+10 conflicts with additional optional points. | State eligible catalogue IDs and one cap. Treat the extension as a learning option until then. |
| C integration | Required in ADVANCED but described as+15 for any project. | Distinguish baseline required C from extra credited scope. |
| Score above100 and grade mapping | Bonus totals can exceed100; caps, percentage-to-grade and two rounding schemes differ. | Select one conversion with explicit boundary tests and no implicit clipping. |
| Coverage bands |20/40/60/80 endpoints overlap, and the denominator “functionalities” is not defined. | Use an enumerated criterion denominator and half-open intervals; select endpoint ownership explicitly. |
| Late work and penalties | <1h warning versus<24h deduction; >72h deduction versus>1week exclusion; differing technical/misconduct sanctions. | Separate accepted, reviewed, on-time and participation-valid states; agree provenance, review and appeal rules. |
| Publication/privacy | Public code, named recordings and external similarity services have different disclosure effects. | Decide permitted data, access and retention before any publication/upload. |
| Empirical claims | Historical years, anecdotes, hundreds of submissions, percentage improvements and workload estimates have no supporting dataset in this transfer. | Retain exact unsupported assertions in the provenance record, remove them from active empirical instruction and use hypothetical examples only with explicit assumptions and reproducible derivation. |
| Licence | D1 is approved for eligible original code (MIT) and teaching prose/figures (CC BY 4.0); retained package and third-party terms remain distinct. | Apply [LICENCE.md](../LICENCE.md) and [LICENCE_SCOPE.json](../LICENCE_SCOPE.json); preserve attribution and exclude unresolved rights. |

## Evidence semantics

A passing fixture demonstrates the bounded asserted behaviour. Syntax parsing, static review, synthetic fixtures and native execution are separate evidence types. ShellCheck availability is reported; missing tools are NOT_RUN. Docker/systemd/Kubernetes, services, network scanners and privileged operations require their own environment and authorised acceptance. A temporary local directory is not a sandbox for untrusted code.

Current helpers validate structural properties, run explicitly selected owned tests and package files. They do not award final grades, establish authorship, prove absence of secrets or publish submissions. Similarity and oral explanation are descriptive evidence; no probability of misconduct is inferred from a percentage, English proficiency or demeanour.

## Local documentation contract

Use [helpers/RUNhere.md](helpers/RUNhere.md) and [templates/RUNhere.md](templates/RUNhere.md) for implemented options. Example project CLI names in specifications are student interfaces to implement, not23 shipped applications. Reference modules and extracted snippets are teaching components, with their tested boundaries documented. The evaluator design is described separately in [AUTOMATED_EVALUATION_SPEC](AUTOMATED_EVALUATION_SPEC/).
