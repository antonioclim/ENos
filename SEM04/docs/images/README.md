# Diagram descriptions and embedding

The SVGs carry English titles, relational descriptions and namespaced IDs. They remain scalable source assets.

For an HTML `<img>`, provide a concise `alt` and place the corresponding explanation beside the figure; SVG-internal metadata is not a substitute for the host image alternative. For inline SVG, preserve `role="img"` and `aria-labelledby`. If the same diagram is inlined more than once, add an instance suffix consistently to every ID, URL reference and ARIA reference.

These source corrections were checked with strict XML parsing and offline Inkscape rendering. Browser accessibility trees, screen readers, print preview and classroom projection are separate acceptance tasks and are not claimed here.

## awk_fields.svg

**Suggested alt:** AWK Field Processing

An input record is split into fields. $0 denotes the full record, $1 onwards denote fields and NF is the current field count. The examples use simple whitespace or unquoted delimited data, not general CSV.

## pipeline_flow.svg

**Suggested alt:** Pipeline and Shell Redirection

grep reads file.txt, then its stdout passes through sort, uniq -c and awk to the final stdout. Each process has a distinct stderr; only AWK diagnostics are drawn. The lower redirection commands are separate examples.

## regex_metacharacters.svg

**Suggested alt:** Regular Expressions — GNU grep BRE and ERE

The cards compare anchors, sets and quantifiers and explicitly distinguish GNU BRE extensions from ERE. A line beginning with a non-hash character differs from a whole line containing no hash. IP-shaped and email-shaped patterns are examples, not complete validators.

## script_structure.svg

**Suggested alt:** An Organised Bash Script

A script identifies its interpreter, sets up and validates input, parses arguments, defines functions, runs its main work and reports results. Optional style preferences are distinct from syntax requirements; error handling must be tested.

## sed_flow.svg

**Suggested alt:** sed: Record Cycle and Two Working Buffers

The simplified sed cycle reads a record, processes pattern space, optionally prints it automatically and advances until EOF. Explicit printing is independent of -n. Pattern-to-hold and hold-to-pattern transfers have separate arrows and x exchanges the buffers.

