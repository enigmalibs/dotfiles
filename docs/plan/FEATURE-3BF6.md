# FEATURE-3BF6 — `/interview`: skip the plan confirmation

**Status:** DONE
**Type:** FEATURE (single-phase)
**Branch (at build time):** `feature/feature-3bf6-interview-no-confirm`, cut from current `HEAD`.

_Planned via `/interview` (v9); build with `/build FEATURE-3BF6` — or with `/bulk` once FEATURE-75F7 exists.
Prompt-file change — no build/test step. Build **before** FEATURE-75F7 (roadmap order)._

## Objective

Remove the confirmation round at the end of `/interview`. Today Phase 3 prints the consolidated requirements
summary and then **waits** for the user to confirm before Phase 4 writes the roadmap rows and plan files. The
user always answers "Confirmed, write the plan", so the round costs a turn and decides nothing. After this
change the interview prints the summary **and writes the planning artifacts in the same turn**. The mandatory
final round of Phase 2 ("Did you forget to mention something…") remains the last gate before anything is
written.

One prompt file changes: `.claude/commands/interview.md`, announce line **v9 → v10**.

## Context & constraints

- **Evolution of an existing repo:** `C:\Dev\EnigmaLibs\dotfiles`. Commands live in `.claude/commands/*.md`.
  Claude Code prompt files only — **no build, no test suite**; Definition-of-Done criteria 1–2 are met by
  well-formed markdown verified by inspection and by the greps under *Acceptance criteria*.
- **Files that must stay byte-identical to `HEAD`:** `.claude/commands/build.md` (v6),
  `.claude/commands/vibe.md` (v1), every skill under `.claude/skills/`.
- **Precedent:** `/vibe` (FEATURE-608E) already prints its Phase-3-style summary "for the transcript" with no
  confirmation step and continues straight into planning. This item aligns `/interview` with it.
- **Versioning (house convention — material prompt revision):** the announce line bumps to
  `Using interview v10 by Josué Clément`.
- **Forward reference:** the closing hint gains `/bulk`, planned in the same batch as FEATURE-75F7. If
  FEATURE-75F7 is abandoned, drop the mention (one-line follow-up, no version bump).
- **Line endings:** `interview.md` is CRLF and internally consistent; keep it so. Recommendation only (not
  part of this item): a `.gitattributes` with `* text=auto eol=lf` would remove the churn risk repo-wide.

## Decisions settled in the interview

| # | Decision |
|---|---|
| 1 | **No confirmation round.** The Phase 3 summary is printed for the record and Phase 4 runs immediately in the same turn; the Phase 2 mandatory final round is the last gate. |
| 2 | **Two single-phase items** for the batch — this one first, `/bulk` (FEATURE-75F7) second. |

## Defaults applied without asking (low impact)

| #  | Default |
|----|---|
| A1 | **The summary is still printed** (audit trail, same provenance structure). Corrections the user sends *after* it are applied to the already-written plan files and roadmap rows, the changed sections are re-presented, and the command stops again. |
| A2 | **The closing hint names both executors:** `/build <ID>` for one item, `/bulk` for every planned `TODO` item unattended. |
| A3 | **Unchanged gates:** the Phase 2 mandatory final round, the Phase 1 code-review classification confirm, and the plan-mode `ExitPlanMode` approval (harness mechanics — it is now the only approval step left, and only in plan mode). |

---

## Design — edits to `.claude/commands/interview.md`

1. **Frontmatter `description`.** Replace *"a validated requirements summary, then plans-only (roadmap + plan
   files) to build later with /build"* with *"a consolidated requirements summary printed for the record, then
   plans-only (roadmap + plan files) written in the same turn — no confirmation round — to build later with
   /build or /bulk"*. Keep *"Never implements."*
2. **Phase 0.** `Using interview v10 by Josué Clément`.
3. **Phase 3 — heading and step 3.** Rename `## Phase 3: Validation` to `## Phase 3: Consolidated summary`.
   Keep steps 1 (content list) and 2 (provenance structure) unchanged. Replace step 3 (*"Wait for my
   confirmation before proceeding. If I give corrections: …"*) with:

   > 3. **Do not wait for confirmation and do not ask whether to proceed** — the mandatory final round of
   > Phase 2 was the last gate. The printed summary *is* the Phase 4 specification: continue straight into
   > Phase 4 in the same turn. If I send corrections afterwards, apply them to the written plan files and
   > roadmap rows, re-present the changed sections, and stop again.

4. **Phase 4 — entry, closing hint, plan-mode note.**
   - Opening sentence: *"Once I have confirmed the Phase 3 summary, load and follow…"* →
     *"Immediately after printing the Phase 3 summary, load and follow…"*.
   - Closing bullet: *"…and tell me I can run **`/build <ID>`** whenever I want to implement one. Stop there
     — do not offer to execute, and do not create a branch."* → *"…and tell me I can run **`/build <ID>`** to
     implement one item, or **`/bulk`** to build every planned `TODO` item unattended. Stop there — do not
     offer to execute, and do not create a branch."*
   - Plan-mode note: *"present the Phase 3 validated summary as the plan and obtain approval (ExitPlanMode)
     before writing anything"* → *"present the Phase 3 summary as the plan and obtain approval
     (ExitPlanMode) before writing anything — this is the only approval step left, and it exists only in
     plan mode"*. The rest of the note is unchanged.
5. **Everything else is unchanged** — `# Role`, `# Context`, `# Your Mission`, Phase 1, Phase 2 (including
   *Convergence & closing* and the mandatory final round), `# Rules`, the draft footer.

## Steps (build order)

1. Apply Design edits 1–4 to `.claude/commands/interview.md`.
2. Run the acceptance-criteria greps (below).
3. Update `docs/roadmap.md` (row → `DONE`, whole-table reformat) and this plan (`**Status:** DONE`); write
   `docs/done/FEATURE-3BF6.md` with the dry-run recipe reproduced.

## Acceptance criteria

1. **Announce line.** `interview.md`'s Phase 0 prints exactly `Using interview v10 by Josué Clément`;
   `grep -rn "interview v9" .claude/` returns nothing (`docs/plan/*` may still say "Planned via /interview
   (v9)" — historical, not in scope).
2. **No confirmation path.** `grep -n -i "wait for my confirmation\|confirmed the Phase 3\|explicitly confirmed" .claude/commands/interview.md`
   returns nothing; Phase 3 step 3 states that the final round is the last gate and that Phase 4 follows in
   the same turn; Phase 4's opening sentence no longer conditions on a confirmation.
3. **Closing hint.** Phase 4 tells the user about both `/build <ID>` and `/bulk`.
4. **Gates preserved.** The Phase 2 mandatory-final-round bullet, the Phase 1 step 3 code-review confirm, and
   the plan-mode `ExitPlanMode` requirement are present and unchanged in meaning.
5. **Nothing else changed.** `git diff HEAD --stat -- .claude/commands/build.md .claude/commands/vibe.md .claude/skills/`
   prints nothing.
6. **Well-formed markdown:** frontmatter parses, fences balanced, the file stays CRLF end to end.
7. **Roadmap/plan/done.** `FEATURE-3BF6` reads `DONE` in `docs/roadmap.md` and in this file;
   `docs/done/FEATURE-3BF6.md` exists with the inherited sections; a pipe-offset check over
   `docs/roadmap.md`'s table reports a single pipe layout.
8. **Nothing to build or test** in this repo — state so in the completion doc, and reproduce the *Dry run
   recipe* there.

## Dry run recipe (for the user, after the build)

1. Copy `interview.md` to `~/.claude/commands/` (or run from this repo, where it is picked up locally).
2. Run `/interview <small spec>`, answer the rounds, then answer "No — nothing to add" in the final round.
3. Expect: the consolidated summary printed, then — **without any question** — the roadmap rows and plan
   files written, the `docs(roadmap): plan …` commit message printed, and the `/build <ID>` / `/bulk` hint.
   No `AskUserQuestion` call after the final round.

## Out of scope / recorded, not planned here

- Removing the Phase 2 mandatory final round or the code-review classification confirm.
- Committing the planning batch from `/interview` — `dev-workflow`'s "never commit yourself" still governs it
  (decided in the interview: the user commits, then runs `/build` or `/bulk`).
- Any change to `build.md`, `vibe.md`, or a skill.
- **Deployment to `~/.claude/commands`** — the user copies the file (FEATURE-15CB / FEATURE-608E precedent).
