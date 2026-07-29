# FEATURE-6B78 — Always offer a free-text escape option in questions

**Status:** DONE
**Type:** FEATURE (single-phase)
**Branch:** `feature/feature-6b78-question-escape-hatch`
**Plan:** `docs/plan/FEATURE-6B78.md`

## Summary

Questions asked through `AskUserQuestion` could corner the user: a 4-option set
presented as exhaustive, with no visible way to type a different answer, forcing
a wrong pick and a correction round later. The cause was a **rule gap**, not a
missing capability — the tool always appends an automatic "Other" choice (and its
own spec says not to author one), and `interview.md` cited that fact, which is
what licensed treating option sets as closed.

Fixed by adding one canonical rule set — a new **"Asking questions (both flows)"**
section in the `dev-workflow` skill — that both commands now defer to:

- every question goes through `AskUserQuestion`, including free-value questions
  (sample values + escape option instead of a prose ask);
- **assume the answer space is open**: author an explicit final option with the
  constant stem `None of these — I'll describe it` and a question-specific
  description; omit it only for a provably closed set (yes/no, genuine
  pick-one-of-N) — the burden of proof is on "closed";
- budget the 4-option cap: at most **3 concrete options** + the escape option;
  group or name extras rather than dropping any;
- the escape option is **always last** and **never** carries `(Recommended)`,
  which is what keeps it from colliding with the recommend-first rule;
- a typed answer is a decision: adopt it, restate the reading in one line,
  continue — no confirmation round.

The doc-freshness sweep question was retro-fitted with an
`A different doc — I'll name it` option, `/interview` and `/build` were aligned
and version-bumped, and the same rule was added to the global `~/.claude/CLAUDE.md`
§2 so it also governs sessions that never load these prompts.

## Files/modules touched

**Modified (in repo — this commit):**
- `.claude/skills/dev-workflow/SKILL.md` — new `## Asking questions (both flows)`
  section (5 rules) inserted between *Two flows* and *Planning & Documentation*;
  doc-freshness sweep bullet gained the name-a-doc option + the 4-option-cap
  note; version line `v3` → **`v4`**.
- `.claude/commands/interview.md` — Phase 2 "How to ask": the
  automatic-`"Other"` sentence replaced by a deferral to the skill's rule + the
  escape-option requirement; **Always recommend** bullet gained the escape-option
  exemption (always last, never recommended); open-ended-question bullet now
  routes through the tool (sample answers + escape) while keeping "state a
  default"; announce line `v8` → **`v9`**.
- `.claude/commands/build.md` — Phase 4.4 sweep clause now names the skip option
  *and* the name-a-doc-I-missed option, citing the skill; announce line `v5` →
  **`v6`**.
- `docs/roadmap.md` — `FEATURE-6B78` row `TODO` → `IN PROGRESS` → `DONE`.
- `docs/plan/FEATURE-6B78.md` — status header `TODO` → `IN PROGRESS` → `DONE`.

**Created:** `docs/done/FEATURE-6B78.md` (this file).

**Modified (out of repo — in NO commit):**
- `~/.claude/CLAUDE.md` §2 — one bullet appended after the multiple-choice
  bullet: always leave a free-text way out; never present a closed option set for
  an open question; escape choice last, never recommended; assume open. File
  mode was `555` → `chmod u+w` → edited → **restored to `555`** (verified with
  `stat -c '%a'`). Untracked by this repo, so it is not part of the commit.

**Unchanged, per the plan's out-of-scope list:** `interview.md`'s mandatory final
round and code-review classification confirm (both closed sets), and
`build.md`'s no-ID roadmap print (deliberately not an `AskUserQuestion` path).
Confirmed by `git diff` — only the lines listed above changed.

## Deviations & follow-ups

- **One addition beyond the plan's literal text:** the escape-option rule ends
  with a parenthetical stating that `AskUserQuestion`'s own guidance ("there
  should be no 'Other' option") is **deliberately overridden** here, and why.
  Without it a future reader — or model — would likely "correct" the house rule
  back to the tool default, undoing this dev. Clarifying only; no behavior beyond
  the plan.
- **Dirty tree at build start:** the working tree held this item's own
  uncommitted planning artifacts (plan file + roadmap row) because `/interview`
  and `/build` ran back-to-back. Per the skill's build flow those artifacts ride
  onto the dev branch as its first change, so `git switch -c` carried them and
  the status flip to `IN PROGRESS` became the first change (FEATURE-0EF9
  precedent). Nothing unrelated was in the tree.
- **Known limit:** the rule only binds where these prompts are loaded. The
  `CLAUDE.md` §2 clause extends it to all sessions on this machine but is
  untracked — if `~/.claude/CLAUDE.md` is ever reinstalled or replaced, that
  clause is lost. **Follow-up suggestion:** track `CLAUDE.md` in this dotfiles
  repo and symlink it into `~/.claude/` (as `.claude/commands` and
  `.claude/skills` already are), so the global rules become version-controlled.
- **Line endings (CRLF):** none noticed — all six touched files are LF-only
  (verified per file). No action taken, per the skill's recommendation-only rule.
- **Frontmatter descriptions untouched:** `interview.md`'s description still says
  "phased AskUserQuestion rounds with recommended options" without mentioning the
  escape option. Accurate but incomplete; left alone as out of the plan's scope.

## Build/test evidence

Prompt/documentation-only change — **nothing to compile and no test suite**
(Definition-of-Done criteria 1–2 satisfied by the no-build/no-test equivalent).
Criteria verified by:

- **AC1** — `grep -n "^## Asking questions (both flows)"` → `SKILL.md:21`; the
  five rules present; `grep "Version: dev-workflow v4"` → `SKILL.md:8`.
- **AC2** — `grep -n "A different doc — I'll name it"` → `SKILL.md:124` (the
  sweep bullet, alongside the candidates and the "none / skip" option).
- **AC3** — `grep -rn 'the tool adds an "Other" free-text choice automatically'`
  → **no match** (old sentence gone); `interview.md:38` cites the skill's
  *Asking questions* rules; `interview.md:21` = `Using interview v9 by Josué Clément`.
- **AC4** — `build.md:46` names both the skip and the name-a-doc options;
  `build.md:18` = `Using build v6 by Josué Clément`.
- **AC5** — `grep -rn "interview v8\|build v5\|dev-workflow v3" .claude/` →
  **no match** (no stale version strings anywhere under `.claude/`).
- **AC6** — `~/.claude/CLAUDE.md` contains the clause
  (`grep -c "free-text way out"` → 1) and `stat -c '%a'` → `555`.
- **AC7** — `git diff -U1 .claude/` reviewed line by line: only the intended
  lines changed; the three out-of-scope question sites are untouched; no
  historical roadmap/plan/done content modified.
- **AC8** — markdown inspected: frontmatter intact in both commands and the
  skill, no tables altered under `.claude/`, roadmap row well-formed and
  consistent with the existing hex-ID rows.

**Self-check:** the doc-freshness sweep in this very run was asked under the new
rule (candidates + skip + `A different doc — I'll name it`) — a live dry run of
the behavior this dev adds.
