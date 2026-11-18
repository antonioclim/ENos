# Current descriptive review and deferred official assessment

## Adopted scope

The author has adopted descriptive review of the ENos component evidence. An official assessment policy has not been selected. The default report status remains `PENDING_POLICY`; authoritative final grades and eligibility decisions remain unset.

The exact previous document, including its formulas, thresholds, penalties, competing rounding proposals and attributions, is retained in [GRADING_POLICY_HISTORY.md](GRADING_POLICY_HISTORY.md). Those historical rules are not adopted by the current profile.

## Current calculator contract

`final_grade_calculator_EN.py` requires homework, project and test CSV inputs and an output prefix. Without `--policy`, it preserves reviewed component values, writes blank/null final grades and records the pending policy status in CSV, JSON and Markdown. A missing value is not a reviewed zero. Invalid schemas, conflicting identities, duplicate assignments/tests and non-finite scores are rejected.

A complete explicit policy supplied through `--policy` enables a scenario calculation labelled `SUPPLIED_POLICY_UNVERIFIED`. Supplying a JSON file does not prove institutional approval. Existing final component scores must not receive a second copy of a penalty already applied upstream.

See [RUNhere.md](RUNhere.md) for exact commands and accepted policy fields, and the [verification and grading contract](../homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md) for reviewed input semantics. No default weights, participation thresholds, oral-assessment rules or publication options have been invented.

## Before official adoption

The author must provide an identifiable policy version, applicable course/year/cohort, component scales and weights, eligibility thresholds and denominators, missing-data treatment, bonuses/caps, late work, oral assessment, rounding and resubmission rules. Every consequential rule must agree across the component tools, human review forms and student guidance.

Acceptance must include worked boundary examples for zero and missing values, exact thresholds, caps/bonuses, late work, oral assessment and resubmissions, and rejection of incompatible input contracts. Official adoption and acceptance remain deferred until those inputs and checks are complete.

## Attribution

The earlier document records version 1.0, 2025-01-30, by A. Clim. That document history remains exact in the linked historical record.

*By Revolvix for OPERATING SYSTEMS class | attribution period retained: 2017-2030. See the [current licensing policy](../../LICENCE.md).*
