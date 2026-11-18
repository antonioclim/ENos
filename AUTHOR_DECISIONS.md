# Adopted local teaching profile and deferred decisions

The author approved D1–D7 for local implementation on 18 November 2026, using the recommended proposals in `ENos_Decisions_and_Acceptance_v1`. This revision starts from the verified review snapshot `d7aead32517115f2ca5e2f425f692b3f569d33a5`, whose source tree is `dc63b602831c0a383d92f01ef02931ee6ce23c08`, continuing the published v5.5.0 baseline.

The initial approval adopted the bounded local teaching profile. On 18 November 2026 the author subsequently authorised the necessary GitHub changes, integration into `main` and publication of v6.0.0 as the latest stable release, preserving v5.5.0 and the other existing releases. This records authorisation; the GitHub references and release page establish which publication operations have completed. Institutional online submission, official grading policy and M14 use with real secrets remain deferred. Approval of a policy is distinct from successful execution of its acceptance checks.

## Decisions with a material effect

| Decision | Adopted scope | Deferred or retained boundary |
| --- | --- | --- |
| D1 — Licensing | MIT original code/examples and CC BY 4.0 original prose/figures, within confirmed rights; explicit component scope | Existing attribution, specific retained grants and third-party terms. SEM02 package notice preserved; uncertain rights excluded |
| D2 — Recording | Explicit offline practice and structural validation | Online endpoint, port, trust/keys, identity, receipt, legacy compatibility and native institutional acceptance |
| D3 — Assessment | Descriptive component evidence, missing-versus-zero distinction, no authoritative default aggregate | Official weights, thresholds, penalties, eligibility, rounding, oral assessment and resubmission rules |
| D4 — Public banks | Existing banks are public formative resources | Controlled examination source, blueprint, grade conversion and access/distribution rules |
| D5 — Teaching claims | Evidence-backed assertions; exact provenance retained for removed unsupported claims | Unsupported claims are not converted into hypothetical results without explicit assumptions and derivation |
| D6 — A03 | Coordinated SHA-256 reference, representations, known-answer tests and assessment expectations | Omitted student CLI/network work, peer authentication and conflict resolution |
| D7 — M14 | Synthetic local exercise, redacted previews, explicit private output and bounded cleanup | Authenticated storage, real secrets/services, secure-erasure claims and Windows ACL acceptance |

## Adopted decision texts

The texts below define the approved scope. Implementation details and current acceptance results are documented in the affected component contracts and [VERIFICATION.md](VERIFICATION.md).

### D1 — Licensing scope and retained attribution

For the forthcoming ENos revision, I authorise MIT licensing of the original software and code examples that I own or am entitled to license, and CC BY 4.0 licensing of the original teaching prose and original figures that I own or am entitled to license. Third-party components, quotations, institutional material and any item with unresolved ownership remain subject to their existing terms and are excluded from this new grant. Existing attribution, including the Revolvix notice, must be retained unless I separately confirm a justified correction. A reviewed component-scope record must identify the applicable terms, including mixed HTML or Markdown files. This decision does not claim to revoke permissions already granted for earlier versions.

### D2 — Recording and institutional submission

For the ENos local teaching profile, terminal recording is a local practice workflow. The supported practice instructions use explicit --offline mode and the documented asciicast v2 format. Local validation establishes only the supported recording structure and reports self-declared identity separately from authentication and submission readiness. Institutional submission is deferred until the authorised service owner confirms the endpoint, port, trust material, identity mapping, receipt contract and treatment of legacy files, and the agreed workflow passes native acceptance. Neither an encrypted legacy token nor an SCP exit status is treated as proof of authorship, a grading decision or an institutional receipt. This decision does not authorise a connection or upload to an institutional service.

### D3 — Assessment and grade aggregation

Until a complete versioned assessment policy is explicitly approved, ENos reports reviewed component evidence descriptively and leaves authoritative final grades and eligibility decisions unset. Missing evidence remains distinct from a reviewed zero. The default status remains PENDING_POLICY. Calculations under an explicitly supplied policy are scenario outputs labelled SUPPLIED_POLICY_UNVERIFIED and must not be represented as approved institutional grades merely because a policy file was provided. No historical weights, participation thresholds, penalties, rounding rules, oral-assessment rules or resubmission conditions are adopted by this decision.

### D4 — Public question banks

The question banks already distributed in ENos are public formative learning resources. Their questions, reference answers and explanations may be used for practice and local review. Separating a generated question paper from its answer key does not make the public source confidential. This decision does not establish a summative examination blueprint, grade conversion, eligibility rule or confidential assessment bank. Any future controlled assessment will use a separately approved source, access and distribution protocol, item-selection blueprint and review process.

### D5 — Empirical and teaching claims

ENos teaching claims will state no stronger conclusion than the available evidence supports. Measured results require an identifiable source, population or workload, method and reproducible configuration where applicable. Unsupported historical numerical claims, anecdotes and service-response promises will be removed from active instructional assertions while their exact wording, original source and unresolved provenance are retained in the decision record. A hypothetical example may be introduced only with explicit assumptions and a reproducible derivation; relabelling an unsupported empirical claim is insufficient. Verified results, unfavourable observations, author attributions and scientific limitations are preserved.

### D6 — Adopt SHA-256 as the versioned A03 digest contract

For the next ENos A03 candidate, I adopt SHA-256 for whole-file and block digests. The local C digest representation is exactly 32 bytes. The proposed student CLI command synctool hash PATH shall write exactly 64 lower-case hexadecimal characters followed by one newline to standard output on success; diagnostics shall use standard error and failures shall return a non-zero status without a success digest. Serialised digest records shall identify version 2 and the sha256 algorithm explicitly. Legacy MD5 records shall be rejected by this contract; any migration shall recompute SHA-256 from the original bytes and shall not reinterpret a 16-byte value as a SHA-256 value. Update the reference code, its mirrored document blocks, known-answer tests and assessment expectations together. This decision does not provide or approve the omitted student CLI, a complete network protocol, peer authentication or conflict resolution. A checksum is not evidence of peer identity or authorship.

### D7 — Select an explicit M14 teaching lifecycle and keep operational secret handling separate

For the ENos M14 teaching profile, I adopt a local exercise using synthetic secrets only. Previews shall remain redacted. A secret-bearing configuration file may be produced only by an explicit output request into a fresh directory owned by the exercising user; on POSIX systems the directory shall have mode 0700 and the file mode 0600. The exercise shall use a local dummy receiver, retain the file only until its declared verification step completes and remove the exercise output on completion or handled failure. Unexpected existing targets, links or ownership shall be rejected. Secret values shall not be copied into logs, terminal previews, command-line arguments, version control or synchronised folders. The kit shall claim no secure erasure guarantee, no general absence of plaintext from the operating system and no acceptance of a real service. The current CBC fragment may remain only as an explicitly non-authenticated teaching example with synthetic values. Authenticated storage, real credentials, receiving-service identity, reload/retention behaviour, key custody and Windows ACL acceptance remain outside this approved teaching profile until separately specified, implemented and tested.

## Exact historical declarations and affected files

The following entries describe the declarations preceding adoption. They preserve the conflict and provenance; they do not reinstate the restrictive permissions table, historical grading weights or deferred service configuration as current rules.

The examples below are retained for comparison with the immutable v5.5.0 baseline. They explain why a single consequential policy cannot be inferred from the existing texts.

| Decision | Existing declaration or contradiction | Files/behaviour affected by confirmation |
|---|---|---|
| Licence | `LICENSE` is headed **MIT License** and grants permission to use, copy, modify, publish, distribute, sublicense and sell, with attribution conditions. `LICENCE.md` is headed **Restrictive Educational Licence**, version 5.0.0, and describes limited personal use and distribution restrictions. The baseline Python metadata says MIT; the README permissions table follows the restrictive text. Both existing copyright attributions are retained. | `LICENSE`, `LICENCE.md`, `README.md`, `pyproject.toml`, contribution guides and any publication package. Choose MIT, restrictive terms or a precisely scoped component split; do not change third-party upstream grants. |
| Service/protocol | `02_INIT_HOMEWORKS/record_homework_EN.sh` historically sets port **1002**; `03_GUIDES/record_homework_EN.sh` sets **1001**, with corresponding Python copies. The 02 footer has `## SIG:`/`## META:`, the 03 footer has `## ` plus encrypted raw metadata, and SEM07 expects `# SIGNATURE:`. | Four recorder clients, both guide editions, the recording contract and SEM07 verification/receipt handling. Port selection alone does not resolve content binding, identity, key custody or legacy acceptance. |
| Assessment | The baseline `SEM07/README.md`, calculator and `GRADING_POLICY.md` specify **25/50/25** for homework/project/tests. The baseline aggregation `RUNhere.md` advertises a default **30/40/30** and an example **20/50/30**. The grading policy also asserts an automatic grade 4 for missing participation thresholds and an 80% homework threshold expressed as 25 of 31 assignments. Seminar rubrics introduce further component, oral, bonus and cap rules. These must be reconciled explicitly. | Canonical rubric/configuration, all report and grade calculators, documented denominators, missing-data handling, participation, oral review, penalties and resubmissions. Retain descriptive component output until the complete contract is approved. |
| Question-bank use | `SEM07/final_test/test_bank/questions_pool.yaml` and formative banks include question content and answer information in the repository. An instructor audience label on a guide does not restrict access to public repository bytes or history. | Bank documentation, distribution, assessment selection and any future controlled bank. Keeping the current material as public practice preserves its teaching utility; a confidential assessment requires a separately controlled source and explicit operating rules. |
| Empirical claims | Both historical student guides state **85%** first-attempt success and a **2-second** fix; the 03 edition also includes a 2023 anecdote and **24–48-hour** response expectations. The material does not supply the relevant cohort/method or a current institutional service commitment. Lecture/seminar performance and misconception percentages have similar provenance questions. | Source Markdown, interactive/static HTML, teaching comparisons and the supporting evidence register. Supply provenance, expressly adopt a hypothetical example, or remove the assertion from active claims while preserving it in history. No alternative has been adopted by inference. |

The recommendation is to choose one complete, versioned contract per affected area and test worked examples against it. Source repairs independent of those choices proceed now. This register is not a new licence grant, grading policy or institutional approval.

## Additional project contracts already left open

D6 and the bounded D7 teaching profile are now adopted as specified above. The complete A03 student application, authenticated M14 storage and real-service deployment remain separate work. Component tests establish only the paths they execute; they do not close the institutional or target-platform acceptances in [VERIFICATION.md](VERIFICATION.md).

## Interpretation of status values

- `PENDING_POLICY`: the required author or institutional rule has not been adopted. It is not a student failure.
- `MANUAL_REVIEW_REQUIRED`: available automated evidence cannot establish the requested conclusion. It does not imply misconduct or a zero grade.
- `UNVERIFIED` / `NOT_RUN`: the identified evidence or execution has not been obtained. A parser pass or model trace does not replace it.
- A format-valid recording is not, solely for that reason, authenticated, submitted, accepted or eligible.

`PENDING_POLICY` still applies to the deferred official assessment policy even though the descriptive teaching profile is adopted. A supplied policy remains `SUPPLIED_POLICY_UNVERIFIED` until the required approval is independently established.
