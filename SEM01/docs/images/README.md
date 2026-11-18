# Diagram descriptions and embedding

The SVGs carry English titles, relational descriptions and namespaced IDs. They remain scalable source assets.

For an HTML `<img>`, provide a concise `alt` and place the corresponding explanation beside the figure; SVG-internal metadata is not a substitute for the host image alternative. For inline SVG, preserve `role="img"` and `aria-labelledby`. If the same diagram is inlined more than once, add an instance suffix consistently to every ID, URL reference and ARIA reference.

These source corrections were checked with strict XML parsing and offline Inkscape rendering. Browser accessibility trees, screen readers, print preview and classroom projection are separate acceptance tasks and are not claimed here.

## 01_shell_layers.svg

**Suggested alt:** Linux System Layers

The user enters a command. Bash interprets it, programs request kernel services, and the kernel controls hardware through drivers. This is a simplified interaction model; not every command requires an external process.

## 02_pipe_assembly.svg

**Suggested alt:** Pipe: Assembly Line Analogy

The stdout of cat feeds grep, then sort, then wc -l. Each pipe connects adjacent stages. The count is of matching lines after sorting; each process also has a separate stderr.

## 03_quoting_comparison.svg

**Suggested alt:** Bash Quoting: Single and Double

Single quotes preserve literal characters. Double quotes permit parameter and command substitution while preventing word splitting and pathname expansion of the quoted result.

## 04_variable_box.svg

**Suggested alt:** Variables: Labelled Boxes Analogy

The same NAME variable with value Alice changes from unexported to exported by export NAME. A subsequently executed bash -c receives NAME in its environment. Export is distinct from Bash function-local scope.

## 05_fhs_tree.svg

**Suggested alt:** File System Hierarchy (FHS) - Simplified

Selected directories descend from the filesystem root. A user home contains configuration and personal directories; /var contains logs. /tmp cleanup is governed by system policy. The diagram is simplified and the home layout is illustrative.

