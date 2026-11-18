# Diagram descriptions and embedding

The SVGs carry English titles, relational descriptions and namespaced IDs. They remain scalable source assets.

For an HTML `<img>`, provide a concise `alt` and place the corresponding explanation beside the figure; SVG-internal metadata is not a substitute for the host image alternative. For inline SVG, preserve `role="img"` and `aria-labelledby`. If the same diagram is inlined more than once, add an instance suffix consistently to every ID, URL reference and ARIA reference.

These source corrections were checked with strict XML parsing and offline Inkscape rendering. Browser accessibility trees, screen readers, print preview and classroom projection are separate acceptance tasks and are not claimed here.

## cron_schedule.svg

**Suggested alt:** Crontab Schedule Format

Five fields select minute, hour, day of month, month and weekday before a user-crontab command. The diagram gives ranges, list, range and step examples. Scheduling depends on the cron implementation and timezone; traditional cron combines restricted day-of-month and weekday fields with OR.

## find_workflow.svg

**Suggested alt:** find Command Workflow

find starts from a path, evaluates tests and performs actions. Separate labels align with the example path, type, name, size, age and print action. GNU find size M units and completed-day mtime semantics must be considered when reading the tests.

## getopts_flow.svg

**Suggested alt:** getopts Argument Parsing Flow

getopts writes the option character to opt and any argument to OPTARG. The v, f and n handlers return to the parsing loop. After no further options, shift removes consumed arguments and the main logic processes remaining operands. Invalid options exit.

## permissions_matrix.svg

**Suggested alt:** Unix Permissions Matrix

A separate file-type character precedes user, group and other permission triplets. Within each triplet read, write and execute contribute 4, 2 and 1. The example rwx r-x r-- maps to 754. These bits are one part of actual access control.

## xargs_vs_exec.svg

**Suggested alt:** -exec \; vs -exec + vs xargs

The semicolon form invokes a command per matched path. The plus form and xargs can batch several paths per invocation, limited by argument and environment size. NUL separation handles arbitrary filenames. The three-file sketch is illustrative, not a fixed process-count guarantee.

