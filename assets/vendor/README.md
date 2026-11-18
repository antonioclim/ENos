# Local presentation dependencies

The correction candidate includes fixed versions of the JavaScript, CSS and fonts used by the teaching HTML. Open pages within the extracted repository directory structure so their relative asset paths resolve. The lecture ZIP includes those same paths and assets; opening an isolated HTML file after discarding its companion directories cannot provide the local dependencies.

## Versions and provenance

| Resource | Included versions | Purpose |
|---|---|---|
| Tailwind CSS compiler | 3.4.17 | Builds `../css/lecture_utilities.css` once; no runtime Tailwind CDN script is needed |
| Chart.js | 4.4.1 | Local UMD build for the existing chart API |
| Reveal.js | 4.5.0 and 4.6.1 | Preserves the versions used by the two presentation groups |
| Font Awesome Free | 6.4.0 and 6.5.1 | Local CSS and matching font files |
| Highlight.js styles | 11.7.0, 11.8.0 and 11.9.0 | Local Monokai styles matching the existing presentations |
| Fontsource | Exact versions in `FONTS_MANIFEST.json` | Latin and Latin-ext normal faces for the original lecture families and the Reveal theme fonts, including its italic faces |

`MANIFEST.json` and `FONTS_MANIFEST.json` record each upstream npm name, exact version, registry tarball, registry integrity value, verified tarball SHA-256 and every selected file hash/size. Package files are unmodified copies verified independently against their tarball bytes. `fonts.css` combines the preserved source CSS with relative URL adjustments only. All upstream licence files are retained beside the assets. These licences remain applicable independently of the author-approved original-material grants in [the component policy](../../LICENCE.md). Vendored bytes and upstream attribution are not relicensed by that decision.

Version pinning and hash verification establish reproducible bytes. They do not establish that a dependency is free from defects or vulnerabilities, nor do they substitute for browser acceptance. The recorded Phase 5 checks distinguish static resource completeness and synthetic DOM execution from a real browser session.

## Verify without network access

From the repository root:

```bash
python3 assets/tools/vendor_assets.py
```

This checks all selected upstream files and reconstructs the combined font CSS from the pinned source files. It does not install anything or contact a server.

## Restore the same versions

Only when dependency restoration is intended:

```bash
python3 assets/tools/vendor_assets.py --restore
```

This explicitly downloads the exact registry tarballs already frozen in the committed manifests and verifies both their registry integrity and SHA-256 before publishing verified files. It does not resolve `latest`, update versions or run package installation scripts.

## Rebuild lecture utility CSS

From the repository root, with Node.js/npm available:

```bash
npm ci --ignore-scripts --no-audit --no-fund --prefix assets/tools
npm run build --prefix assets/tools
```

`assets/tools/package-lock.json` fixes the Tailwind compiler and its transitive build dependencies. The build reads the canonical lecture HTML and inline scripts. Its explicit safelist covers the interpolated colour classes that a static class scanner cannot infer. `assets/tools/TAILWIND_MANIFEST.json` records the input and output hashes. Rebuild after changing class names or source HTML; opening a teaching page does not run npm or build CSS.

## Acceptance still outstanding

Native browser rendering, focus and keyboard behaviour, chart/reveal behaviour, network-disabled browsing, font appearance, screen-reader use and printing require checks in supported browsers. The candidate ships the assets and records their integrity, while retaining those acceptance limits. Numerical chart fallback content remains available in the relevant lecture source when the chart library cannot initialise.
