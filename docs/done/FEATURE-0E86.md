# FEATURE-0E86 — Run branch prefix + no commit trailer

**Status:** DONE
**Branch:** `feature/feature-0e86-run-branch-trailer` (cut from `feature/2026-09-11-run-branch-trailer` @ `462b0b6`)
**Run:** feature/2026-09-11-run-branch-trailer

## Summary

Two convention fixes to the autonomous run commands, both requested verbatim.

**1. The run branch no longer carries the command's name.** `vibe-workflow` §3 used to define it as
`<command>/<yyyy-mm-dd>-<slug>` — `vibe/2026-09-10-user-auth`, `bulk/2026-09-10-feature-3a7f`. It is now
`<category>/<yyyy-mm-dd>-<slug>`, where `<category>` is the house branch folder of the run's **first item**
(`FEATURE` → `feature/`, `BUG` → `bugfix/`, `CODE-REVIEW` → `review/`). A run branch is never named
`vibe/…` or `bulk/…` again, so every branch in a repo now lives in one of the three house folders.

Because the run branch and the dev branches now share a namespace, §3 gained a companion rule:

- **By eye**, the date segment separates them — a dev branch's second segment always begins with the
  lowercased item type and its hex (`feature-3a7f-…`), never with a date.
- **For a resume**, the name is not the test at all: *a branch is a run branch when some
  `docs/plan/*.md` carries `**Run:** <that branch>`*. Both commands' Phase 2 mode resolution was rewritten
  to key on that marker instead of on a `vibe/*` / `bulk/*` glob. This also makes the change
  **backward-compatible** — a run branch created by the previous version still resumes, because its plan
  files still name it.

**2. A run's commits carry no attribution trailer.** The §4 bullet that told a run to *append* the
session's `Co-Authored-By` trailer is replaced by its opposite: a run's commit is title + blank line +
bulleted description, with no `Co-Authored-By:`, no `Generated with …`, and no other agent-attribution
line — **even when the session's own instructions provide one**, since inside a run this rule wins. Both
commands repeat it as a `# Rules` bullet and drop the "+ trailer" note from their commit steps.

Three prompt files changed, with version bumps: `vibe-workflow` **v2 → v3**, `/vibe` **v1 → v2**,
`/bulk` **v1 → v2**. `dev-workflow` (v5), `/interview` (v10) and `/build` (v6) are untouched — neither
commits nor creates a run branch, and the dev-branch folders they own are unchanged.

**This run applied both new rules to itself**: it ran on `feature/2026-09-11-run-branch-trailer`, not on a
`vibe/…` branch, and neither of its commits carries a trailer.

### Edits by file

| File | Change |
|------|--------|
| `.claude/skills/vibe-workflow/SKILL.md` | frontmatter `description` (new branch shape, "attribution trailers" added to the forbidden list) · version line **v2 → v3** · §3 run-branch bullet rewritten as a bullet + 3 sub-bullets (category / date / slug) · §3 new "Recognizing a run branch" bullet · §3 topology diagram label → `feature/2026-09-10-user-auth` · §3 closing `/bulk` sentence · §4 trailer bullet inverted · §9 marker example + a sentence on exact naming · §10 `/bulk` no-argument row (re-padded) · §11 intro + report example (4 branch names) · §12 two new rows |
| `.claude/commands/vibe.md` | frontmatter `description` · Context bullet 1 · Phase 0 announce **v1 → v2** · Phase 2 both mode bullets · Phase 4 step 1 (`git switch -c <category>/…`) · Phase 4 step 4 (no trailer) · two new `# Rules` bullets |
| `.claude/commands/bulk.md` | frontmatter `description` + `argument-hint` · Context bullet 2 · Phase 0 announce **v1 → v2** · Phase 2 both mode bullets · Phase 3 step 4 (`git switch -c <category>/…`) · Phase 3 step 6 (no trailer) · two new `# Rules` bullets · draft footer |

## Files/modules touched

**Created**

- `docs/plan/FEATURE-0E86.md` — the plan (planning commit `462b0b6`).
- `docs/done/FEATURE-0E86.md` (this file).

**Modified**

- `.claude/skills/vibe-workflow/SKILL.md` — 20 insertions, 14 deletions of 205 lines.
- `.claude/commands/vibe.md` — 9 insertions, 7 deletions of 94 lines.
- `.claude/commands/bulk.md` — 11 insertions, 9 deletions of 93 lines.
- `docs/roadmap.md` — `FEATURE-0E86` row `TODO` → `IN PROGRESS` → `DONE`. Column widths unchanged: the new
  ID is 12 characters like every other, and the title (37) fits the existing 39-wide Title column, so the
  whole-table padding needed no rewrite (verified: every row is 14/41/13/27).
- `docs/plan/FEATURE-0E86.md` — `**Status:**` `TODO` → `IN PROGRESS` → `DONE`.

**Deliberately untouched** — `.claude/skills/dev-workflow/SKILL.md`, `.claude/commands/build.md`,
`.claude/commands/interview.md` and every other skill: `git diff HEAD --stat` prints nothing for them
(acceptance criterion 6). **Nothing under `C:\Users\Jo\.claude` was written** (criterion 7) — the repo's
`.claude/` was confirmed to be a plain directory, not a junction to it, before any edit.

## Decisions taken at build time

| Question | Chosen | Why |
|----------|--------|-----|
| Where do the two new "common mistakes" go? | Two rows appended to §12 | §12 is exactly the index of run mistakes; a new section for two lines would duplicate it |
| §11's example first line was the placeholder `<command> run <run branch>` — keep it, now that the branch name is the interesting part? | Made the example concrete (`vibe run feature/2026-09-10-user-auth`) and moved the placeholder into the sentence introducing the block | Everything else inside that fenced block is concrete (`master @ edb28ad`, commit hashes); a lone placeholder inside it hid the very naming the change is about |
| Markdown nesting: the new rules wanted `**Run:**` inside a bold lead-in | Wrote the lead-in with `` `Run:` `` in code, keeping `**Run:**` in the surrounding prose | Nested `**` closes the outer bold and mangles the line — the rule has to survive rendering |
| §10's `/bulk` row got 2 characters shorter after the wording change | Re-padded that cell to the table's 174-character width | The inherited formatting rule: these tables are read raw |

## Deviations & follow-ups

- **Scope widened deliberately, from `/vibe` to both run commands.** The draft's first bullet named `/vibe`
  only. The run-branch rule lives in **one** shared section (`vibe-workflow` §3) that both commands
  delegate to, so fixing `/vibe` alone would have turned a single rule into an exception pair and left
  `/bulk` emitting `bulk/…` branches — the same thing the draft asks to stop. `/bulk` now follows the same
  category rule. **Revert is one section if that is not wanted**: restore `<command>/…` in §3 for `/bulk`
  and the `bulk/…` wording in `.claude/commands/bulk.md` lines 14, 34, 46, 82.
- **The dev-branch folders were *not* renamed.** The draft wrote the categories as "feature/bug/code-review";
  the house folders are `feature/` · `bugfix/` · `review/` (`dev-workflow` *Version Control*). Read as a
  loose naming of the three categories rather than a rename request — renaming would ripple into `/build`,
  `/interview`, every existing branch and every completion doc, for no gain. Say the word and it is a
  separate item.
- **PowerShell `Set-Content -Encoding UTF8` adds a UTF-8 BOM** (Windows PowerShell 5.1). One table-padding
  pass on `SKILL.md` went through it and prefixed the file with `EF BB BF`, which would have sat in front
  of the YAML frontmatter's opening `---`. Caught by `od -c` and stripped in the same dev; the committed
  file is BOM-free (`file` reports plain "UTF-8 text"). Future runs in this repo should prefer the
  `Edit`/`Write` tools, or `-Encoding utf8NoBOM` on PowerShell 7+, for files with frontmatter.
- **Line endings (recommendation only, no action taken).** The working tree is CRLF while `core.autocrlf`
  normalizes to LF in the index, so every write to `docs/` prints `LF will be replaced by CRLF the next
  time Git touches it`. A `.gitattributes` with `* text=auto` would silence it. Owner's call — untouched
  here, per the inherited CRLF policy.
- **The repo is a mirror, not the live config.** These edits land in `C:\Dev\EnigmaLibs\dotfiles\.claude\`;
  `C:\Users\Jo\.claude\` still runs `vibe-workflow` v2, `/vibe` v1 and `/bulk` v1 until you copy the three
  files across. Explicitly out of scope by instruction.

## Build/test evidence

No build step and no test suite — three markdown prompt files. Definition of Done criteria 1–2 are met by
the applicable equivalent: the files stay well-formed, and each acceptance criterion was verified by
command.

| # | Criterion | Verification |
|---|-----------|--------------|
| 1 | No run-branch rule still names a `vibe/` or `bulk/` prefix | `grep -rn "vibe/\|bulk/" .claude/` → 11 hits, every one either a prohibition ("never `vibe/`", "A run branch is **never** named …") or an explicit legacy/back-compat note |
| 2 | `Co-Authored-By` appears only in prohibitions | `grep -rn "Co-Authored-By\|Generated with" .claude/` → 4 hits, all forbidding it; no "append the trailer" instruction survives |
| 3 | Version bumps | `vibe-workflow v3` · `Using vibe v2 by Josué Clément` · `Using bulk v2 by Josué Clément` (and `interview v10` / `build v6` unchanged) |
| 4 | §3 states the name shape + category rule + marker recognition; §11's example uses a category-prefixed branch | Read back after edit — §3 lines 40–44, §11 report block |
| 5 | Both commands resume on the marker, not a name glob | `vibe.md:33`, `bulk.md:34` — "is named by some `docs/plan/*.md` `Run:` marker … Never infer a run from the branch name alone" |
| 6 | `dev-workflow`, `/build`, `/interview` byte-identical | `git diff HEAD --stat -- …` printed nothing |
| 7 | Nothing written under `C:\Users\Jo\.claude` | No tool call targeted that path; the repo's `.claude/` was confirmed a plain directory (`Get-Item … LinkType` empty) before editing |

Structural checks: no BOM on any of the three files (`od -c`), frontmatter delimiters intact, no
line-ending churn (`git diff --stat` shows 20/14, 9/7 and 11/9 changed lines — not whole-file rewrites),
and every markdown table re-measured in **characters** — §10 at 42/174, §12 at 83/79, the roadmap at
14/41/13/27, all rows uniform.

**Documentation freshness sweep:** nothing to change. `README.md` is a one-line title (`# dotfiles2`);
there is no `CLAUDE.md`, `AGENTS.md`, `CHANGELOG.md` or `CONTRIBUTING.md`; the only other file under
`docs/` is `roadmap.md`, which the sweep excludes. The three prompt files that describe this behaviour are
the dev's own subject and are excluded as sweep targets.
