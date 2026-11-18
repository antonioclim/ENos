# Teaching, evidence and open author decisions

## Current technical contract

The seminar uses Bash 4.4 or later. `local -n` first appeared before that version, but the complete exercise set, strict mode and array handling are tested together against the stated seminar minimum. `set -e` applies to eligible failures and has tested-context exceptions. Ordinary subshells inherit it; command substitution normally clears it unless `inherit_errexit` or POSIX mode applies. `pipefail` returns the rightmost non-zero status, or zero when every command succeeds. Capture `PIPESTATUS` immediately.

`EXIT` and `ERR` are Bash events. `ERR` does not require `set -e`; `set -E` controls its inheritance. A signal handler need not exit unless it explicitly does so. EXIT cleanup cannot cover SIGKILL, power loss or an allocation made before cleanup is registered. All destructive demonstrations use owned temporary fixtures or print an unexecuted removal plan. `./*` and `${path:?}` do not establish ownership or validate a directory.

WRONG examples, TODOs and Parsons distractors remain teaching tasks. Terminal transcripts are labelled `console`; prompts and displayed output are not executable source. The professional template intentionally leaves implementation work and returns a non-success status for an unimplemented operation. Diagnostics from the validator/autograder do not enact an institutional marking policy or prove authorship. Custom JSON exports are repository data formats; Moodle/Canvas import has not been established.

## Assessment decision still required

The existing brief, instructor rubric and oral guide contain incompatible proposals. They are retained for author review and are not silently merged into a new grading algorithm.

| Decision | Existing alternatives | Consequence and recommendation |
|---|---|---|
| Oral contribution | Multiply written score by 0.50–1.00; or use 0.8 × written + 0.2 × oral | For written 85, oral 95, these give 85 and 87. Choose one explicitly. A separate weighted oral component is easier to explain and audit, but is not adopted here. |
| ShellCheck penalty | 2% per error in the brief; 5% per error in the rubric; other style adjustments overlap | A single finding can otherwise be deducted more than once. Choose one scale, cap and adjustment order, and separate missing tooling from a failed lint result. |
| Late work | 10% per day up to three days; or 10/25/50% time bands | Define authoritative timestamps, time zone, boundary inclusion, late acceptance and rounding before calculation. |
| Bonuses and eligibility | Several bonus/adjustment tables with different caps | Publish one criterion-level score table with boundary examples before assessment. Retain negative results and missing evidence distinctly from a reviewed zero. |
| Criterion visibility | Rubric says instructor-only but is in the distributed repository | Public criteria and private answer banks have different purposes. Decide which material should be private; this local review does not remove, publish or move it. |
| Remote controls / recordings | Webcam, history, photographs and recorded viva proposals | Decide necessity, alternatives, access and retention. Prefer a synthetic task and criterion-level explanation. No collection or external submission is authorised by these documents. |

The exact wording and placement of any institutional integrity/AI declaration also require an explicit canonical decision; this review has not invented a replacement declaration or redistributed student evidence.

## Timetable, provenance and traceability

The instructor guide describes 100 teaching minutes plus a 10-minute break. The historical plan extends to 120 elapsed minutes; the traceability table retains a separate 100-minute proposal including a break. Select the real session duration and activity subset before teaching. These alternatives are not merged by shortening activities silently.

Historical misconception percentages, claimed classroom incidents, success rates and activity distributions have no established underlying dataset in the transferred materials. They remain visibly labelled as historical/unverified. To retain them as empirical claims, supply collection dates, cohort/denominator, instruments, coding, exclusions and calculations. Alternatively, relabel them as planning estimates. The latter is suitable for lesson planning but not a retrospective study result.

The LO matrix is a topic-to-activity map, not measured attainment. Parsons problems embedded in that matrix use `TP1`–`TP5`; the canonical problem set uses `P1`–`P14`. Reference counts and labels should be derived from the current files.

Brown and Wilson's Tip 10 supports using varied, smaller learning tasks, including Parsons problems. It does not specify the local percentage ranges or validate the table's claimed actual distribution. Reference: Brown, N. C. C., & Wilson, G. (2018). Ten quick tips for teaching programming. *PLOS Computational Biology, 14*(4), e1006023. https://doi.org/10.1371/journal.pcbi.1006023

## Visuals and verification limits

SVG diagrams have intrinsic English titles/descriptions and labelled image roles. Hosts still need appropriate alternative text and readable surrounding explanations. Native SVG export and text contrast checks do not establish keyboard, screen-reader or browser acceptance of a host page. Local shell/Python regressions use synthetic fixtures; they do not certify production operation or institutional acceptance.

Licence and authorship statements are preserved pending the repository-level author decision. No licence, signing protocol, privacy policy or final grading scheme is selected by this document.
