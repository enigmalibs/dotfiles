# FEATURE-2059 — Aligned, auto-reformatted roadmap table

**Status:** DONE
**Type:** FEATURE (single-phase)
**Branch:** `feature/feature-2059-roadmap-table-alignment`

## Objective

Make `docs/roadmap.md`'s registry table readable by a **human** scanning it in a
plain-text editor: every column the same width on every row, so the pipes line up
vertically and a status can be read down a straight column instead of hunting
across ragged rows.

The table is a markdown *source* artifact that people read raw (in an editor, in
`git diff`, in a console print by `/build`), not only rendered. Markdown does not
require aligned pipes — so nothing today stops the table from drifting, and it
has: this repo's own roadmap misaligns from the `FEATURE-0EF9` row onward, where
12-character IDs (`FEATURE-0EF9`) were appended into a table whose ID column was
sized for 11 (`FEATURE-001`), and every subsequent row inherited the break.

**Root cause — drift, not a one-off typo.** Alignment decays whenever a *new*
cell is wider than the column it lands in, because rows are appended one at a
time without revisiting the rest of the table. So the fix needs two rules, not
one: a *shape* rule (what aligned means) and a *maintenance* rule (reformat the
whole table on every edit, since one new row can invalidate every other row's
padding).

## Scope

### Files changed
1. **`.claude/skills/dev-workflow/SKILL.md`** — the canonical rule lives here:
   a new *Table formatting* rule under `### roadmap.md — summary only`, the two
   worked examples re-padded, the *Abandoning or changing direction* section
   reshaped around the footnote decision below, and the version line bumped.
2. **`docs/roadmap.md`** (this repo) — reformat the existing table under the new
   rule and append this item's row. This is both the rule's first application and
   its proof.

### Explicitly out of scope
- **`.claude/commands/build.md` and `interview.md`** — both already defer table
  shape to the skill (`build.md:23`, `interview.md:64`) and neither restates the
  column format, so no edit is needed and no announce-line bump is warranted.
  `build.md:27`'s "print the full roadmap table" inherits the rule via the skill.
- **`docs/plan/*` and `docs/done/*` historical content** — untouched. Tables
  inside those files are not the roadmap registry table.
- **Any other skill.** `dotnet-release` / `dotnet-solution-setup` matched a
  roadmap grep only incidentally.
- **No tooling.** No script, hook, or formatter is added; this is a prompt rule
  applied by whoever edits the table.

## Design — the rule

### A. Table formatting (new bullet under *`roadmap.md` — summary only*)

1. **Uniform column widths.** Every cell in a column is padded with trailing
   spaces to the width of the widest cell in that column, header included. The
   delimiter row's dashes span the same width. Cells keep the conventional single
   space after the opening `|` and before the closing `|`, so every `|` in the
   table sits at the same offset on every line.
2. **Width is content-driven, never fixed and never truncating.** IDs, statuses
   and plan paths are written in full; the column simply grows to the widest one.
   Width is counted in **characters**, not bytes — an em dash or a backtick
   counts as one — so titles containing `—` or `` ` `` still align.
3. **Keep the Title cell short** (a summary line, roughly ≤ 40 characters):
   the Title column is the one that can grow without bound, and one verbose
   title pads every other row. Abbreviate the title; the full statement of the
   work belongs in the plan file.
4. **Phase rows align like any other row** — the `- PHASENN` marker sits in the
   ID column and is padded to the same width as the base IDs.

### B. Reformat on every edit (the maintenance rule)

Whenever the table is touched **for any reason** — appending a new item, adding a
phase row, flipping a status, abandoning an item, correcting a title — **rewrite
the whole table** so all columns are re-padded to the current widest cell. This
is part of the same edit, not a follow-up chore: a single new row whose ID or
path is one character wider than the current column invalidates the padding of
*every* other row, which is exactly how the drift above happened. Never leave the
table misaligned "because only one row changed".

The same padding applies to the phase progress table `/build` prints to the
console (its example in *Multi-phase progress reporting* already complies).

### C. Abandon reason moves out of the Status cell

The current *Abandoning or changing direction* example stores the reason **inside
the Status cell** (`ABANDONED — superseded by a simpler approach; replaced by
FEATURE-8D0C`, 65 characters). Under rule A.1 that single cell would pad the
Status column of the entire table to 65 characters — the alignment rule would
make the table *less* readable than leaving it ragged. So:

- The **Status cell holds only the vocabulary word** `ABANDONED`, keeping the
  Status column at the width of `IN PROGRESS`.
- The **reason and any replacement ID go in a footnote** beneath the table, as a
  blockquote line keyed by ID:
  `> FEATURE-4B21 abandoned — superseded by a simpler approach; replaced by FEATURE-8D0C`
- The existing requirement to **mirror the note at the top of the item's plan
  file** is unchanged.

This is a change to a documented format, and it is the reason the version bumps.

## Versioning (house convention — material prompt revision)
- `dev-workflow` skill: **v4 → v5** (`**Version: dev-workflow v5.**`).
- `/interview` and `/build` announce lines: **unchanged** (neither file changes).

## Roadmap data corrections (this repo)

Reformatting `docs/roadmap.md` requires rewriting every row, so two factual
errors visible while doing it are corrected in the same pass, with evidence:

- **`FEATURE-6B78` reads `TODO` but is built and merged** — `docs/done/FEATURE-6B78.md`
  exists and commit `1980b84` is on `master`. Corrected to `DONE`.
- **`FEATURE-003` stays `IN PROGRESS`** — the `git-repo-hygiene` skill exists but
  there is no `docs/done/FEATURE-003.md`, so its status is *not* assumed complete
  and is left as-is.

Untracked recent work (`enigma-avalonia-desktop`, the carbon/phosphor skill drop,
the `dotnet-release` symbol-package fix) gets **no** back-filled rows — that is a
separate decision for the user, recorded as a follow-up.

## Acceptance criteria
1. `SKILL.md`'s `### roadmap.md — summary only` section states the uniform-width
   rule (A.1–A.4) and the reformat-on-every-edit rule (B).
2. Both roadmap examples in `SKILL.md` (the `FEATURE-3A7F` one and the
   `CODE-REVIEW-7F10` one) are themselves perfectly aligned — every `|` at the
   same offset on every line of a given table.
3. `SKILL.md`'s *Abandoning or changing direction* section specifies the bare
   `ABANDONED` status cell plus the blockquote footnote, and its example shows
   an aligned table with the footnote beneath it.
4. `SKILL.md`'s version line reads `**Version: dev-workflow v5.**` and no
   `dev-workflow v4` reference remains anywhere in `.claude/`.
5. `docs/roadmap.md`'s table is fully aligned under the new rule, contains a
   `FEATURE-2059` row, and `FEATURE-6B78` reads `DONE`.
6. No file outside `.claude/skills/dev-workflow/SKILL.md`, `docs/roadmap.md`,
   `docs/plan/FEATURE-2059.md` and `docs/done/FEATURE-2059.md` is modified.
7. All changed files remain well-formed markdown (frontmatter intact, tables
   valid, no broken pipes).

## Verification (no build/test — prompt/doc changes)

Nothing to compile and no test suite exists, so Definition-of-Done criteria 1–2
are satisfied by the no-build/no-test equivalent:

- an **alignment check** over every markdown table in the two changed files,
  asserting that all rows of a table have identical pipe offsets (AC 2, 3, 5) —
  run as a scripted per-line comparison, not eyeballed;
- `grep -rn "dev-workflow v4" .claude/` returning nothing (AC 4);
- `git status --porcelain` / `git diff --stat` confirming the changed-file set
  (AC 6);
- reading the rendered markdown for AC 7.
