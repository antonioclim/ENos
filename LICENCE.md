# ENos component licensing

## Author-approved scope

Decision D1 was approved on 18 November 2026 and is retained in ENos 6.0.0. Identified original software and code examples are licensed under the [MIT licence](LICENSE). Identified original teaching prose and figures are licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/legalcode.en) (CC BY 4.0). These grants apply only to material the author owns or is entitled to license.

[LICENCE_SCOPE.json](LICENCE_SCOPE.json) assigns a component profile to each current repository file. Classification establishes the stated boundary, not independent proof of ownership or permission to relicense someone else's work.

## Retained attribution and earlier grants

The existing attribution lines are retained verbatim:

- `Copyright (c) 2026 Revolvix` in `LICENSE`.
- `© 2019–2030 Antonio Clim. All rights reserved.` from the previous licensing document.
- The named contributors and upstream copyright notices in individual components.

No identity is reassigned: this release does not assume that Revolvix is an alias for another author. Permissions for eligible original material follow the component grants above. The former restrictive educational conditions are not additional restrictions on those newly licensed components. Nothing here claims to revoke permissions already granted for an earlier version.

## Component boundaries

| Component | Applicable terms |
| --- | --- |
| Original scripts, programs, modules, configuration/build code and original code examples | MIT; preserve the copyright and permission notice |
| Original teaching prose and figures, including editable diagrams and rendered figures | CC BY 4.0; give appropriate credit, link the licence and identify changes |
| Mixed Markdown/HTML teaching material | CC BY 4.0 original prose/figures; MIT original fenced/code/pre examples, scripts and styles. This split is not a choice of either licence for the whole file |
| Public quiz prose/explanations in YAML/JSON and their exports | CC BY 4.0 original prose; MIT original code examples and operational schema/configuration code |
| Original inputs and fixtures supplied as part of software examples | MIT for eligible original fixture content; real personal, institutional and third-party data are excluded |
| Vendored packages, fonts, icons and copied upstream assets | Retained upstream terms and notices; no replacement grant |
| CSS derived from fonts/themes and generated Tailwind CSS | Retained upstream component terms. Eligible original transformations may be MIT; upstream rights are not replaced |
| Quotations, institutional material and any portion with unresolved rights | Excluded from the new D1 grants; retain its identified source and applicable terms |

Specific attributions and third-party notices take precedence over an original-material profile for the portions identified. A citation alone does not establish redistribution permission. New material with unresolved ownership remains excluded until its rights and component boundaries are established.

## Retained SEM02 package notice

`SEM02/README.md` describes its educational package as **CC BY-SA 4.0** and attributes the original materials to **SO ASE-CSIE Team**. This notice and attribution are preserved. Conservatively, `SEM02/**` is excluded from the new D1 grant while that package boundary is unresolved. This records the extent of the retained notice; it does not independently establish the ownership of every item or a right to replace its terms. A later item-level decision may identify original components eligible for an additional grant.

## Python distribution

The Python wheel contains the shared `lib` Python modules and package metadata, not the complete lecture/seminar repository. Its original Python code is MIT; its original README-derived description is CC BY 4.0. The wheel declares `MIT AND CC-BY-4.0` and includes `LICENSE` and this policy. These terms refer to distinct components, not a choice of either licence for all contents. This paragraph identifies the installed boundary without requiring the repository-wide map. Other teaching materials and vendored assets remain in the repository or teaching archive under their component terms.

## Bundled teaching archive

The lecture ZIP is a container, not a new single-licence work. Members retain the terms of their corresponding repository paths. Include this policy, `LICENSE` and `LICENCE_SCOPE.json` when rebuilding the archive. A member that cannot be matched to a reviewed source component remains excluded from the new grant pending review.

## Contributions and verification

Contributions must identify their source, author, applicable terms and any third-party material. Do not submit material whose redistribution rights are unconfirmed. Preserve existing attribution and upstream notices.

Run `python3 scripts/check_licence_scope.py` to check file coverage, the retained SEM02 notice and pinned upstream bytes offline. After an authorised change, `python3 scripts/check_licence_scope.py --write` refreshes the path map from these reviewed component rules. Unknown formats receive an explicit unresolved profile. A passing check establishes consistency of the record and retained bytes, not a legal ownership determination.
