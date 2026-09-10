# FEATURE-3BF6 — `/interview`: skip the plan confirmation

**Status:** DONE
**Branch:** `feature/feature-3bf6-interview-no-confirm` (cut from `master` @ `48019b2`)

## Summary

Removed the confirmation round at the end of `/interview`. Before this change, Phase 3 printed the
consolidated requirements summary and then **waited** for the user to confirm before Phase 4 wrote the
roadmap rows and plan files. The answer was invariably "Confirmed, write the plan", so the round cost a
turn and decided nothing. `/interview` now prints the summary **and writes the planning artifacts in the
same turn**; the mandatory final round of Phase 2 ("Did you forget to mention something…") is the last gate
before anything is written. This aligns `/interview` with `/vibe` (FEATURE-608E), which already prints its
Phase-3-style summary "for the transcript" and continues straight into planning.

One prompt file changed — `.claude/commands/interview.md`, announce line **v9 → v10** — in seven
single-line edits:

| # | Line | Change |
|---|------|--------------------------------------------------------------------------------------------|
| 1 | 2    | Frontmatter `description`: "a validated requirements summary, then plans-only … with /build" → "a consolidated requirements summary printed for the record, then plans-only … written in the same turn — no confirmation round — to build later with /build or /bulk". `Never implements.` kept. |
| 2 | 21   | Phase 0 announce line → `Using interview v10 by Josué Clément`. |
| 3 | 57   | Heading `## Phase 3: Validation` → `## Phase 3: Consolidated summary`. |
| 4 | 61   | Phase 3 step 3 replaced: the wait-for-confirmation instruction became "**Do not wait for confirmation and do not ask whether to proceed** — the mandatory final round of Phase 2 was the last gate. The printed summary *is* the Phase 4 specification: continue straight into Phase 4 in the same turn." plus the after-the-fact corrections rule. |
| 5 | 64   | Phase 4 opening: "Once I have confirmed the Phase 3 summary, …" → "Immediately after printing the Phase 3 summary, …". |
| 6 | 69   | Phase 4 closing bullet now names both executors: `/build <ID>` to implement one item, `/bulk` to build every planned `TODO` item unattended. |
| 7 | 71   | Plan-mode note: "the Phase 3 validated summary" → "the Phase 3 summary", plus "this is the only approval step left, and it exists only in plan mode". |

Phase 3 steps 1 (content list) and 2 (provenance structure) are unchanged, so the summary is still printed
in full as an audit trail. `# Role`, `# Context`, `# Your Mission`, Phase 1, Phase 2 (including *Convergence
& closing* and the mandatory final round), `# Rules` and the draft footer are untouched.

## Files/modules touched

**Created**

- `docs/done/FEATURE-3BF6.md` (this file)

**Modified**

- `.claude/commands/interview.md` — the seven edits above (v9 → v10). 7 of 87 lines changed; no whole-file
  rewrite, no line-ending churn.
- `docs/roadmap.md` — `FEATURE-3BF6` row `TODO` → `IN PROGRESS` → `DONE` (Status column stays 11 wide
  because `FEATURE-003` is still `IN PROGRESS`, so the whole-table pipe layout is unchanged).
- `docs/plan/FEATURE-3BF6.md` — `**Status:**` `TODO` → `IN PROGRESS` → `DONE`.

**Deliberately untouched** — `.claude/commands/build.md` (v6), `.claude/commands/vibe.md` (v1) and every
skill under `.claude/skills/`: `git diff HEAD --stat -- .claude/commands/build.md .claude/commands/vibe.md
.claude/skills/` prints nothing (acceptance criterion 5).

## Deviations & follow-ups

- **Plan-mode note punctuation (only deviation from the plan's literal text).** The plan's Design edit 4
  replaced the clause ending at "…before writing anything" and stated "the rest of the note is unchanged".
  The retained remainder began with an em-dash ("— the plan files and roadmap rows all wait for that
  approval"), so applying both literally would have put two em-dash clauses in one sentence. The joining
  dash was rendered as a semicolon instead: "…before writing anything — this is the only approval step
  left, and it exists only in plan mode; the plan files and roadmap rows all wait for that approval."
  Content is exactly as planned; only the connector differs.
- **Permission-mode friction — worth fixing before FEATURE-75F7.** In auto mode the classifier denied
  *every* write to `.claude/commands/interview.md` (Bash in-place edit, then the `Edit` tool) and also
  denied *reading* `.claude/settings*.json`; writes under `docs/**` were allowed. The build only proceeded
  after the user switched permission mode mid-run. `/bulk` (FEATURE-75F7) is an unattended builder and will
  hit the same wall on any prompt-file dev, as will `/vibe`. Follow-up (not built here): a project
  `.claude/settings.json` allow rule for writes under `.claude/commands/**` and `.claude/skills/**`, which
  is also already recorded as a follow-up on FEATURE-608E.
- **Line endings (recommendation only, no action taken):** `interview.md` was CRLF and internally
  consistent and remains so — 86 CRLF pairs, zero lone LF, zero lone CR after the edits. A `.gitattributes`
  carrying `* text=auto eol=lf` would remove the churn risk repo-wide; the user owns that decision.
- **Forward reference to `/bulk` is live before `/bulk` exists.** Phase 4 now advertises `/bulk`, planned as
  FEATURE-75F7 in the same batch but not yet built, so the hint names a command the user cannot run until
  that item ships. Per the plan's *Context & constraints*: if FEATURE-75F7 is abandoned, drop the two
  mentions (frontmatter `description` and the Phase 4 closing bullet) — one-line follow-up, no version bump.
- **Deployment is out of scope and still pending:** the copy in `~/.claude/commands` is a plain file, not a
  junction (FEATURE-15CB / FEATURE-608E precedent), so v10 is picked up from this repo only until
  `interview.md` is copied over. See the dry run recipe below.

## Build/test evidence

**There was nothing to build and no test suite to run** — this repo contains only Claude Code prompt files
(markdown): no project, no build step, no test project. Per the Definition of Done's no-build clause,
criteria 1–2 were satisfied by verifying the artifact is well-formed and by checking every acceptance
criterion by inspection and by grep.

| # | Criterion | Evidence |
|---|----------------------|---------------------------------------------------------------------------------------|
| 1 | Announce line        | `grep -n "interview v9\|interview v10" .claude/` → exactly one hit: `interview.md:21: Using interview v10 by Josué Clément`. No `interview v9` anywhere under `.claude/`. |
| 2 | No confirmation path | `grep -n -i "wait for my confirmation\|confirmed the Phase 3\|explicitly confirmed" .claude/commands/interview.md` → **No matches found**. Phase 3 step 3 (line 61) states the Phase 2 final round was the last gate and that Phase 4 continues in the same turn; Phase 4's opening (line 64) no longer conditions on a confirmation. |
| 3 | Closing hint         | Line 69 names both **`/build <ID>`** ("to implement one item") and **`/bulk`** ("to build every planned `TODO` item unattended"); the frontmatter `description` (line 2) also says "with /build or /bulk". |
| 4 | Gates preserved      | Present and unchanged in meaning: Phase 2 *Mandatory final round* (line 55, "Move to Phase 3 only after a \"No\""), Phase 1 step 3 code-review confirm (line 28, "**Confirm this classification with me via AskUserQuestion before allocating the ID.**"), plan-mode `ExitPlanMode` requirement (line 71). |
| 5 | Nothing else changed | `git diff HEAD --stat -- .claude/commands/build.md .claude/commands/vibe.md .claude/skills/` → empty output. |
| 6 | Well-formed markdown | UTF-8 decodes clean; frontmatter delimiters at lines 1 and 5 (line 81 is the pre-existing horizontal rule); zero code fences, as before, so nothing to balance; **86 CRLF pairs, 0 lone LF, 0 lone CR** — CRLF end to end. `git diff -U0` shows 7 changed hunks of one line each (lines 2, 21, 57, 61, 64, 69, 71) — exactly the seven planned edits and no collateral. |
| 7 | Roadmap/plan/done    | `FEATURE-3BF6` reads `DONE` in `docs/roadmap.md` and in `docs/plan/FEATURE-3BF6.md`; this file exists; the pipe-offset check over `docs/roadmap.md` reports a single pipe layout `(0, 15, 57, 71, 99)` across all 35 table rows. |
| 8 | Nothing to build/test | Stated above; the dry run recipe is reproduced below. |

## Dry run recipe (for the user)

1. Copy `interview.md` to `~/.claude/commands/` (or run from this repo, where it is picked up locally).
2. Run `/interview <small spec>`, answer the rounds, then answer "No — nothing to add" in the final round.
3. Expect: the consolidated summary printed, then — **without any question** — the roadmap rows and plan
   files written, the `docs(roadmap): plan …` commit message printed, and the `/build <ID>` / `/bulk` hint.
   No `AskUserQuestion` call after the final round.
