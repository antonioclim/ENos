# Local review and external adapters

The local pipeline runs the shipped SEM01 `.sh` similarity and lexical-style tools. It records input hashes, current-run reports, process status and coverage. It does not infer authorship, impose sanctions or contact external services.

```bash
bash run_plagiarism_check.sh --help
bash run_plagiarism_check.sh SEM05
bash run_plagiarism_check.sh --submissions /path/to/ROOT --output ./review_reports
```

Layout is `ROOT/STUDENT/.../*.sh`. The optional `--threshold 0.85` changes a descriptive display cutoff, not an academic policy. Each run creates a new `review-*` directory. `review_summary.json` has separate `COMPLETE`, `INCOMPLETE` or `EMPTY` coverage and per-tool states. Exit0 means complete local analysis, even if it finds similarities; exit2 means incomplete/empty coverage, and operational failure returns1. Logs retain tool errors. A missing report is never an all-clear. Lexical-style labels in the underlying legacy schema are observations, not probabilities of AI authorship.

## MOSS plan

```bash
bash run_moss.sh --help
bash run_moss.sh SEM05 python py --submissions /path/to/ROOT
```

This prints an argument-safe plan only. The adapter supports a bounded set of the official languages (`c`, `cc`, `java`, `python`, `perl`, `javascript`); `bash` is rejected. It does not silently route Bash to another language. `--base DIR` adds each base file with its own `-b`. `--client FILE` selects the account-configured official client. An explicit `--send` invokes an external upload and is reserved for separately authorised use after the institutional disclosure/data-handling decision. No registration or upload was performed during source verification.

See [MOSS_JPLAG_GUIDE.md](MOSS_JPLAG_GUIDE.md) for the primary references, a pinned JPlag example and interpretation limits. Decide whether to keep student code local or use an approved external service; the recommendation is to use local descriptive evidence until that choice is resolved.
