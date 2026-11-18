# Assessment contract status — Seminar 4

**PENDING_POLICY / MANUAL_REVIEW_REQUIRED**

## Unresolved author decision

The homework, submission template, assessor rubric and oral-verification guide impose differing task counts, penalties and eligibility requirements. The ten-command diagnostic bank has a fixed 130-point maximum but is not the complete public homework rubric.

## Alternatives and recommendation

Adopt one public task/rubric/template contract before grading. Recommendation: retain the published learning tasks and make all required evidence, timing and penalties explicit; no unstated assessment rule is selected here.

## Current use of the tools

Diagnostic points, legacy score bands and illustrative aggregates describe the implemented checks. They are not a final grade, an eligibility decision or an adopted penalty policy. No manual review is claimed to have occurred or been scheduled. Functional acceptance still needs the approved assessment contract.

Stylistic patterns, code similarity, timestamps, fingerprints and recordings cannot alone establish authorship, misconduct or continuous capture. Evidence requires contextual review; external disclosure of student work needs the applicable authorised policy. Historical wording remains available in the immutable v5.5.0 baseline.


## Concrete conflicts requiring an author decision

| Topic | Published alternatives | Consequence / recommendation |
|-------|------------------------|------------------------------|
| README/checksum | Main assignment requires README, ID, checksum and proposes −20%; template called README optional | Publish one evidence list and align both files; the template now displays the conflict and all requested fields, without applying a penalty |
| Dataset | Main requires personalised student_ID files and proposed −50% for sample data; template/solution notes recommended sample_data | Personalised and reference fixtures have different schemas. Recommend the main task schema, but confirm the student assessment contract before release |
| Scoring | Four tasks 25% each; cross-cutting 40/20/15/15/10; rubric adjustments; ten-command bank 130 diagnostic points | Choose one aggregation and state whether quality dimensions are within or beyond task points. The tools emit no final grade |
| Bonus | Main FAQ +10%; bonus guide +20%; listed bonus exercises sum to30 | Choose a cap and combination rule; no extra merit or cap is inferred |
| Oral check | Proposed 100/80/50% multipliers and grade>8 question gate | Define equivalent questions, accommodations and consequences; preserve observations separately from sanctions |
| Phone grammar | Task lists three shapes, example/rubric/generator include spaces; rubric proposes narrower 07[2-9]X | Corrected reference supports all four generated shapes and labels them lexical, not allocated-number validation. Confirm any graded restriction |
| Strict mode/tools | Main mandates Bash/grep/sed/awk and set-euo-pipefail; generic demonstrations sometimes use serializer libraries | Keep the assessed tool restriction explicit. Equivalent results/handling of failures must not be penalised by an unstated implementation preference |
| Release/confidentiality | Instructor-only/confidential labels on publicly committed answer materials | Public labels cannot restrict access. Choose public practice resources or a separately controlled assessment release; no publication/access change was made |

**Recommendation:** retain the public learning objectives, choose one explicit
student-facing evidence/rubric contract and align every derivative. Alternatives
are (a) the four personalised tasks plus an explicit common quality rubric, or
(b) a distinct command-bank exercise with its own denominator. Using the existing
130-point diagnostic bank as a complete homework grade would omit published tasks.

## Implemented technical reference contract

The four solution scripts now target the personalised generator, not the separate
sample_data unit fixtures. The employee order is ID/Name/Department/Salary/Email/
HireDate/Status; sales is Date/Product/Quantity/UnitPrice/Region/Salesperson.
Malformed input is explicit, empty/header-only cases are defined and new output
files are not silently overwritten. Log percentages use valid records as their
denominator and disclose malformed rows. These implementation choices repair
technical models; they do not adopt weights, eligibility, penalties or release
policy. Legacy author anecdotes remain available in the immutable baseline.
