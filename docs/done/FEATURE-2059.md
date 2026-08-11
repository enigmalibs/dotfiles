# FEATURE-2059 — Aligned, auto-reformatted roadmap table (DONE)

## Summary

`docs/roadmap.md`'s registry table is read as plain text (in an editor, in
`git diff`, in the console when `/build` prints it), but nothing in the workflow
required its columns to line up — so they drifted. The `dev-workflow` skill now
carries two rules that keep the table readable:

- **Table formatting** — every cell is padded to the width of the widest cell in
  its column (header included), width is content-driven (never fixed, never
  truncating), counted in characters so `—`/backticks still align, Title is kept
  to roughly ≤ 40 characters, and `- PHASENN` rows align like any other row.
- **Reformat the whole table on every edit** — any touch (append an item, add a
  phase, flip a status, abandon, fix a title) rewrites *every* row, because one
  new wider cell invalidates the padding of all the others. This is the rule that
  actually prevents drift; the shape rule alone would not.

One documented format had to change to make alignment worthwhile: the
`ABANDONED` reason used to live **inside the Status cell** (65 characters in the
example), which under the padding rule would widen the Status column of the whole
table. The Status cell now holds the bare keyword, and the reason + replacement ID
move to a blockquote footnote beneath the table. Skill version bumped **v4 → v5**.

The change was then applied to this repo's own roadmap — reformatted end to end,
which is both the first application of the rule and the proof it works.

## Files/modules touched

**Modified**
- `.claude/skills/dev-workflow/SKILL.md`
  - version line `v4` → `v5`;
  - `### roadmap.md — summary only`: new **Table formatting** bullet (4 sub-rules)
    and new **Reformat the whole table on every edit** bullet; *Status vocabulary*
    now states the cell holds the bare keyword and cross-references the abandon
    section;
  - `### Abandoning or changing direction`: rewritten for the bare-keyword cell +
    blockquote footnote, with the rationale stated and the example replaced by an
    aligned single-row table plus its footnote.
- `docs/roadmap.md` — whole table reformatted under the new rule; two data
  corrections (below); `FEATURE-2059` row appended.

**Created**
- `docs/plan/FEATURE-2059.md`
- `docs/done/FEATURE-2059.md` (this file)

**Unchanged, deliberately** — `.claude/commands/build.md` and
`.claude/commands/interview.md`. Both already defer table shape to the skill
(`build.md:23`, `interview.md:64`) and neither restates the column format, so no
edit and no announce-line bump was warranted.

## Deviations & follow-ups

**Deviation from the original request (raised and approved).** The request was
alignment + auto-reformat only. Alignment collides with the abandon-reason format,
so the reason was moved to a footnote — chosen by the user from three options
(footnote / keep in Status cell / append to Title).

**Roadmap data corrections made during the reformat.** Reformatting rewrites every
row, so two visible factual errors were fixed in the same pass, with evidence:
- `FEATURE-6B78` read `TODO` although `docs/done/FEATURE-6B78.md` exists and commit
  `1980b84` is on `master` → corrected to `DONE`.
- `FEATURE-003` was **left** at `IN PROGRESS`: the `git-repo-hygiene` skill exists,
  but there is no `docs/done/FEATURE-003.md`, so completion was not assumed.

**Follow-ups (not done, user's call):**
1. **Untracked recent work has no roadmap rows** — `enigma-avalonia-desktop`
   (`333d808`), the carbon/phosphor skill removal (`22f3ca4`), and the
   `dotnet-release` symbol-package fix (`723e991`) all shipped without work items.
   Back-filling rows (or deciding they don't need any) is a separate decision.
2. **Existing plan/done files still use pre-v5 wording** for abandonment — none
   currently records an `ABANDONED` item, so nothing is actually wrong, but the
   first abandonment should follow the footnote form.
3. **No automated check.** Alignment is a prompt rule with no formatter or hook
   behind it. If it drifts again, a pre-commit hook comparing pipe offsets across
   a table's lines would catch it in ~10 lines of shell.

**Line endings:** no CRLF/LF inconsistency observed in the touched files; nothing
to recommend.

## Build/test evidence

No build step and no test suite exist in this repo (prompt/markdown changes only),
so Definition-of-Done criteria 1–2 are met by the no-build/no-test equivalent —
**there was nothing to build and nothing to test.** Acceptance criteria were
verified as follows:

- **AC 1–3 (rules present, examples aligned)** — a scripted pipe-offset check over
  every markdown table in both changed files (grouping consecutive `|` lines into
  tables and counting distinct pipe-column layouts per table) reports
  `distinct_pipe_layouts=1` for all four tables in `SKILL.md`
  (rows 6 / 5 / 3 / 5) and for `docs/roadmap.md`'s 29-row table. One layout per
  table means every `|` sits at the same offset on every line. Not eyeballed.
- **AC 4 (version)** — `grep -rn "dev-workflow v4" .claude/` returns nothing;
  `SKILL.md:8` reads `**Version: dev-workflow v5.**`.
- **AC 5 (roadmap content)** — `FEATURE-2059` present at `IN PROGRESS` during the
  build and flipped to `DONE` with this record; `FEATURE-6B78` reads `DONE`.
- **AC 6 (changed-file set)** — `git status --porcelain` shows exactly
  `M .claude/skills/dev-workflow/SKILL.md`, `M docs/roadmap.md`, plus the two new
  `docs/plan|done/FEATURE-2059.md` files. Nothing else touched.
- **AC 7 (well-formed markdown)** — frontmatter intact, all tables have matching
  pipe counts per row, and the changed sections were read back in place.
