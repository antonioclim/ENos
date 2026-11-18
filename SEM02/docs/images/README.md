# Diagram descriptions and embedding

The SVGs carry English titles, relational descriptions and namespaced IDs. They remain scalable source assets.

For an HTML `<img>`, provide a concise `alt` and place the corresponding explanation beside the figure; SVG-internal metadata is not a substitute for the host image alternative. For inline SVG, preserve `role="img"` and `aria-labelledby`. If the same diagram is inlined more than once, add an instance suffix consistently to every ID, URL reference and ARIA reference.

These source corrections were checked with strict XML parsing and offline Inkscape rendering. Browser accessibility trees, screen readers, print preview and classroom projection are separate acceptance tasks and are not claimed here.

## expansion_order.svg

**Suggested alt:** Bash Expansion Order

Bash performs brace and tilde expansion, then parameter, arithmetic and command substitution, then word splitting, pathname expansion and quote removal where the command context permits them. For N=5, {1..$N} becomes the single word {1..5}, not a sequence.

## pipe_redirect.svg

**Suggested alt:** Pipes and I/O Redirection

A command reads stdin descriptor 0 and writes stdout descriptor 1 and stderr descriptor 2. Pipes connect stdout to the next stdin. The lower examples independently show overwrite, append, stderr duplication and redirected file input.

## script_structure.svg

**Suggested alt:** Bash Script Structure

A script identifies its interpreter, sets up and validates input, parses arguments, defines functions, runs its main work and reports results. Optional style preferences are distinct from syntax requirements; error handling must be tested.

