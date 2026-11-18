# Recording and local preflight contract — v6.0.0

The author has adopted the local practice profile for ENos v6.0.0. The supported workflow uses explicit `--offline` mode and asciicast v2. Institutional submission and official assessment remain deferred; this local adoption does not select an endpoint, port, identity scheme, receipt or grading rule.

## Run a local practice session

Install system commands using the package manager for the supported lab environment. On Ubuntu, `sudo apt install asciinema python3-venv openssl sshpass openssh-client` is an explicit installation step, separate from recording. The recorder checks prerequisites and does not install packages itself.

For the Python interface, use one interpreter environment:

```bash
python3 -m venv ~/.venvs/enos-recorder
source ~/.venvs/enos-recorder/bin/activate
python -m pip install rich questionary
python record_homework_tui_EN.py --offline
```

The Bash alternative is `bash record_homework_EN.sh --offline`. In offline mode neither interface attempts a connection, upload or legacy token generation. A fictitious group identifier alone does not provide this guarantee. Record in your own configured lab environment. Do not run the whole recorder with `sudo`.

Both recorders add self-declared `student_name`, `student_group`, `seminar` and `homework` fields to the asciicast v2 header. These are labels, not authenticated identity. The current filename validation remains ASCII letters/hyphens, four ASCII group digits and `01`–`07` followed by a letter. A broader institutional naming contract remains an author decision.

## Online configuration is unresolved

The historical copies contain SSH ports 1001 and 1002. Neither is asserted to be the current service port. Online invocation requires `--port` with a value confirmed by the instructor. The client requires a previously verified `known_hosts` entry; verify the host fingerprint through the authorised service owner before connecting. A changed host key is not a reason to disable checking or blindly remove the old key.

Three upload attempts are made. Exhausting them returns failure and retains the local file. A successful SCP exit means file transfer completed at the client; it is not a grading decision or an institutional receipt. No service configuration, credential validity or remote acceptance was established by the local regressions.

## Three historical cryptographic formats

| Producer / consumer | Existing payload | Evidence limit |
|---|---|---|
| `02_INIT_HOMEWORKS` recorders | `## SIG:` plus `## META:`; public-key encryption of a metadata hash | Does not bind the recording event content; not a digital signature |
| `03_GUIDES` recorders | `## ` plus public-key encryption of raw metadata | Same limitation; the raw-RSA plaintext size limit can reject long paths |
| SEM07 verifier | `# SIGNATURE:`; legacy verification contract documented in SEM07 | Incompatible with the two recorder envelopes; missing verification material remains `UNVERIFIED` |

The producer envelopes are retained for compatibility analysis. They are not silently migrated into a new institutional protocol. A replacement requires decisions about identity, key custody, content binding, receipts and treatment of previous submissions. Until then, do not interpret a token as proof of authorship, integrity or non-repudiation. If legacy finalisation fails, the recorder retains the recording and reports failure instead of uploading an incomplete envelope.

## What the preflight proves

Keep `check_my_submission.sh` and `check_my_submission.py` together, or run the Python file directly:

```bash
bash check_my_submission.sh recording.cast
python3 check_my_submission.py recording.cast --json
```

Exit 0 means the supported JSON/header/event structure parsed. The result separately reports self-declared metadata, `UNVERIFIED` authentication and `UNCONFIRMED` submission readiness. Unknown extensible event codes are preserved and flagged. Legacy footer base64 is checked syntactically only. Neither byte count nor duration is a grade, eligibility threshold or authenticity test.

Asciicast v2 records the associated terminal stream and timing. It does not capture ambient audio, unrelated user sessions or a graphical desktop. Input events are optional and depend on the recorder configuration. `clear` changes the display but does not erase earlier recording events. The plain example in `examples/sample_submission_demo.cast` contains the original 126 events; its old demonstration footer is retained separately in `examples/sample_submission_demo_footer.txt`.

Format source: [official asciicast v2 specification](https://docs.asciinema.org/manual/asciicast/v2/). Instructor-side states and manual-score handling: [SEM07 verification and grading contract](../SEM07/homework_evaluation/VERIFICATION_AND_GRADING_CONTRACT.md).

## Recorder version

The current recording and preflight contract targets asciicast v2. Both Bash and TUI entry points require asciinema CLI 2.x before collecting a recording. CLI 3.x uses a different header and relative event timing and is rejected before recording; files are not relabelled or silently converted. This technical format requirement does not establish submission eligibility or authentication.
