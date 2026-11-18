# ENos repository utilities

Author: ing. dr. Antonio Clim · ENos v6 candidate, based on v5.5.0.

Run these examples from the repository root. Python tools use the selected Python environment. The link checker requires `markdown-it-py` (also listed in the development dependencies); the print synchroniser and inventory use only the Python standard library.

## Local links and anchors

```bash
bash scripts/check_links.sh
bash scripts/check_links.sh --internal-only SEM03/docs
bash scripts/verify_links.sh -v README.md
bash scripts/check_links.sh --json --report links_report.json
```

`check_links.sh` and `verify_links.sh` are two entry points to the same parser. It reads Markdown links/reference links/images and HTML `href`/`src`, resolves local paths and validates static heading or ID fragments. Markdown code examples are not treated as live links. The three intentional `url` citation slots in `04_PROJECTS/templates/README_template.md` are reported explicitly as template placeholders, not successful links; a completed project must replace them. It reports external destinations as `not_checked` by default and makes no network request.

An explicitly requested network check is available with `--external`. An HTTP response establishes availability only, not source accuracy, credentials, application behaviour or browser rendering. Redirects, access restrictions and timeouts must be read in the report.

Exit status is **0** when the selected checks pass, **1** for broken/unverified/error results and **2** for usage or dependency errors. It is a Boolean outcome, so 256 broken links cannot wrap to a successful exit status.

## Managed print rules

```bash
bash scripts/add_print_styles.sh --dry-run SEM01/presentations
bash scripts/add_print_styles.sh SEM01/presentations
bash scripts/add_print_styles.sh 03_GUIDES/STUDENT_GUIDE_EN.html
```

The selected file or directory defines the exact scope. With no path, the repository's own HTML files are selected; vendored upstream HTML and build/cache directories are excluded so pinned package bytes remain unchanged. The tool adds or replaces one `enos-print-styles` block from `assets/css/print.css`, preserves content-specific styles and file permissions and writes each changed file atomically. It validates the selected documents before writing; a missing `</head>`, unreadable input or failed replacement produces a non-zero exit. An existing unrelated `@media print` rule does not skip the common rules. A repeated run with unchanged CSS makes no change.

The common rules expose slides, tabs and collapsed instructions, allow long code/table content to flow and keep footers in the document flow. They do not certify a browser's pagination, visual layout or assistive technology behaviour. Inspect actual print output on supported browsers before acceptance.

## Physical inventory

```bash
python3 scripts/inventory.py --update-readme
```

The JSON distinguishes file categories, all YAML from formative quiz banks and file counts from test coverage. It records hashes of the selected files. Its own hash and size are omitted to avoid self-reference.

## Verification and CI templates

```bash
python3 -m pytest
bash 00_SUPPLEMENTARY/validate.sh
```

The root pytest configuration includes the shared library, global utility tests and seminar test directories. Some tests require optional local tools; read failures or explicit skips rather than treating collection as acceptance. Seminar `ci/github_actions.yml` files are examples, not evidence of an activated root workflow or a successful GitHub Actions run. [VERIFICATION.md](../VERIFICATION.md) records the distinction between syntax, local fixtures, synthetic UI checks and unexecuted host/service checks.
