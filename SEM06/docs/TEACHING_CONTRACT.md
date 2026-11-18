# SEM06 teaching, runtime and assessment contract

## What the current artefacts establish

SEM06 contains three separate Bash projects, maintained teaching helpers, project chapters, presentation sources and intentional student scaffolds. Their common architecture is a pattern; it is not one installed shared library or a complete automatic administration platform. Run repository-relative examples from the repository root. Bash 4.4+, Python 3.10+ and the declared GNU/Linux utilities are the supported local teaching baseline. Optional tools that are absent are recorded as not run.

Strict mode is useful but does not check every command. `errexit` and ERR have conditional/list/pipeline exceptions; ERR can run without `-e`. `pipefail` returns the rightmost nonzero pipeline status. Capture a result in an `if` when its failure is expected, check intermediate mutations explicitly and keep diagnostics away from machine-readable stdout. Define/register cleanup before allocation and delete only paths owned by that run. INT/TERM handlers exit with 130/143 and use one EXIT cleanup. SIGKILL or host failure cannot run a shell trap. Keep a flock pathname stable while its inode may be locked.

CPU is calculated over two samples of user through steal counters, without adding guest totals twice. This material chooses idle+iowait as non-busy time; Linux documents limits and possible decreases in iowait. Invalid/zero/reset deltas are unavailable. Memory uses MemAvailable, with bytes/KiB/MiB distinguished. A read failure is not a healthy zero. Process IDs, names, host clocks and dynamic measurements are observations with stated scope, not authenticity evidence.

Backup uses a GNU tar listed-incremental chain. Each retained restore point needs its full base and every parent; deletion and rename require chain metadata. Tests compare the recovered owned fixture including create/modify/delete/rename. Checksums detect changes against the expected sidecar, not publisher authenticity. Restore requires an empty owned destination; archive path/type checks prevent unsupported extraction. Quiescent fixture success does not prove crash durability, consistent backup of live databases, or all filesystem metadata/platform combinations.

Deployer's supported CLI differs from the pedagogical release/routing implementations. Files use staged replacement with failure checks; the two directory renames are not one atomic exchange. A separate maintained release helper uses atomic same-filesystem symlink replacement. Neither establishes service uptime. Real systemd, Docker, mail, webhook, load-balancer and metrics integrations require the intended host and explicit operator intent. Missing traffic/metrics adapters fail instead of reporting simulated success. See each project README for exact supported fields and remaining limits.

The formal native tests use owned temporary paths and explicit mocks. Browser layout/interaction and real institutional services are not accepted by those tests. SVG XML/native Inkscape exports, text bounds and computed contrast are limited to those artefacts. HTML exact text extraction/Bash parsing and offline asset checks are distinct from native browser execution.

## Author decisions

| Decision | Preserved alternatives and consequences | Recommendation, not adoption |
|---|---|---|
| Project scope | README/brief propose A1–A4 over four weeks; rubric describes choosing one of three, with integrated work as +100% bonus. These imply materially different workload and grades. | Select one explicit required scope and align brief/rubric/SEM07 before use. |
| Presentation weight | Brief says 20% of final grade; rubric and plan say 40%. SEM07 has a separate aggregation proposal. | Define the denominator and one weight, then supply an explicit calculator policy. |
| Backup requirements | Brief requires encryption, SSH transfer and retention; rubric scores incremental creation, restore and rotation, with encryption/remote transfer as bonuses. | Choose which competencies are mandatory; keep remote execution separately authorised. |
| Deployer requirements | Brief prioritises Docker/pipeline/monitoring; rubric prioritises Git/build/deploy/rollback. Bonus lists and points differ. | Use a single visible requirement-to-criterion map before assessment. |
| Bonuses and adjustments | 60% mandatory +40% optional, integrated +100%, extra bonuses and a ±10% heading whose positive entries sum to +12 coexist. Caps, order and denominator are undefined. | Define caps and calculation order explicitly; preserve raw reviewed scores until then. |
| Evidence and penalties | Fingerprints, style heuristics, live-demo penalties and blanket plagiarism zeros are historical proposals. Identifiers and polished text do not prove authorship or misconduct. | Prefer reproducible task evidence and explanation with a specified review/appeal process. Do not infer a finding from appearance. |
| Privacy | Full machine ID/MAC/user/host/path/environment collection versus minimised task evidence or synthetic fixtures. The former exposes persistent identifiers and potentially secrets. Retention, access, consent/legal basis and recipients are unspecified. | Use synthetic fixtures for parser teaching; agree a minimised collection and retention plan before real student collection. |
| Workload/timing | 100-minute plan, 80-minute demo subset, 40–60-hour project estimate, cohort stories, vote targets and Bloom percentages have no supplied local measurement protocol/data. | Preserve as planning proposals/author recollections, gather evidence before describing observed effects. |
| References | Brown and Wilson's Tip 10 concerns varied practice, not local percentages. The historical Ericson (2017) reference is ambiguous. | Verify the intended work with the author; do not silently substitute a different coauthored source. |
| Licensing/authorship | D1 is author-approved for eligible original ENos code (MIT) and teaching prose/figures (CC BY 4.0); retained package and third-party terms remain distinct. | Preserve attribution and follow [the component policy](../../LICENCE.md). Unresolved ownership, third-party and institutional portions are excluded from the new grant. |

Point tables, draft deadlines and anecdotes remain in their original files with these qualifications. Technical remediation does not make any of these policy choices. A public repository also cannot promise that instructor-only criteria or model answers are confidential.

## Countable formative and reflection data

The canonical SEM06 formative YAML has 23 questions and 140 raw points; question IDs, weights and Bloom labels are preserved. Question-count categories are Remember 5, Understand 6, Apply 8, Analyse 2 and Evaluate 2. The JSON is the ENos local interchange schema, not a certified Moodle/QTI package. Coverage mapping and quiz completion are not evidence of measured student attainment. Self-assessment uses its exact current number of competency rows, without asserting validated score bands.

## Primary technical and pedagogical references

- GNU Project. (n.d.). *The set builtin; Bourne shell builtins*. Bash reference manual. https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html and https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html
- Linux kernel developers. (n.d.). *The /proc filesystem*. https://www.kernel.org/doc/html/latest/filesystems/proc.html
- systemd developers. (n.d.). *systemd.timer*. https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html
- Brown, N. C. C., & Wilson, G. (2018). Ten quick tips for teaching programming. *PLOS Computational Biology, 14*(4), e1006023. https://doi.org/10.1371/journal.pcbi.1006023

These sources support their documented mechanisms and teaching suggestions; they do not validate local percentages, cohort anecdotes, authorship claims or an institutional assessment policy.
