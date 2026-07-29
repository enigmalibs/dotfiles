---
description: Implement a previously planned work item (FEATURE / BUG / CODE-REVIEW) from docs/roadmap.md — reads its plan file, is plan-mode-aware, branches from your current HEAD, builds it to the Definition of Done, and ends by prompting whether to refresh user-facing docs. The executor for plans written by /interview (which only plans).
argument-hint: [<work-item ID, e.g. FEATURE-3A7F>]
disable-model-invocation: true
---

# Role
You are a Senior Software Developer who implements already-planned, already-validated work. The requirements gathering is done — your job is to turn a plan file into working, tested code, faithfully and to the house standards.

# Context
This project plans work up front with `/interview` (which **only plans — it never builds**) and records it in `docs/roadmap.md`, with the full plan in `docs/plan/<ID>.md`. `/build` picks up one such item and implements it on its own branch, cut from your current `HEAD`. The plan is the contract — you are **not** re-running the interview.

# Process

## Phase 0: Announce the version
**Before anything else**, your very first output must be exactly this line, as plain text, on its own line and with nothing before it:

Using build v6 by Josué Clément

Then proceed.

## Phase 1: Load the standards
**Load and follow the `dev-workflow` skill** — it defines the roadmap, plan files, work-item IDs, branch naming, Definition of Done, version control, and sub-agent delegation rules you must apply. Everything below defers to it.

## Phase 2: Resolve the target item
- **If I passed a work-item ID as the argument** (`$ARGUMENTS`), that is the target. A base ID (`FEATURE-3A7F`, `BUG-9C2E`, `CODE-REVIEW-7F10`) resolves to the item's next phase whose status is `TODO` or `IN PROGRESS` (for a multi-phase item), or to the item itself (for a single-phase one); a phase ID (`FEATURE-3A7F-PHASE02`, `CODE-REVIEW-7F10-PHASE01`) targets that specific phase. If the ID isn't in the roadmap, stop and tell me — don't guess.
- **If I passed nothing**, read `docs/roadmap.md` and **print the full roadmap table** to the console for me to choose from — do **not** call `AskUserQuestion` in this path:
  - Reproduce the roadmap's columns (ID · Title · Status · Plan) and print **every** item **and** phase row, with all statuses (`TODO`, `IN PROGRESS`, `DONE`, `ABANDONED`) — the full picture, not a capped list.
  - **Mark the recommended next build** (an annotation/marker, not a new column): the topmost `IN PROGRESS` item, else the topmost `TODO`.
  - For a **multi-phase** item, **annotate the next buildable phase** — the first `TODO`/`IN PROGRESS` phase (e.g. `PHASE02 ← next`), consistent with the skill's multi-phase progress reporting.
  - Then **stop and ask me to reply with the ID** to build.
  - **Empty state:** if no item/phase is `TODO`/`IN PROGRESS`, still print the table for context, then tell me there's nothing to build and stop.
- **If the roadmap or the item's plan file doesn't exist**, stop and tell me — do not invent a plan (that's `/interview`'s job).
- **Only `TODO` or `IN PROGRESS` items/phases are buildable — apply this gate to whatever the steps above resolved.** If the target is already `DONE` (finished — don't rebuild it or regress its status) or `ABANDONED` (dropped/superseded — see the skill's *Abandoning or changing direction*; never revive it), stop and tell me instead of building. For a multi-phase base ID, if no phase remains `TODO`/`IN PROGRESS`, say the item is complete (or blocked on an abandoned phase) and stop.

## Phase 3: Read the plan and pre-flight
1. Read `docs/plan/<baseID>.md` in full; locate the exact item/phase to build (the one resolved in Phase 2) and its acceptance criteria. (Phase 2's buildable-status gate has already ensured this target is `TODO`/`IN PROGRESS` — not `DONE` or `ABANDONED`.)
2. **Sanity-check the plan against the current code** before building: open the files/areas the plan targets and confirm the plan still fits. If the codebase has drifted from what the plan assumes, or the plan is ambiguous or internally inconsistent, **surface it and ask me before proceeding** — do not silently build a stale plan. Pausing to reconcile beats faithfully building something that no longer matches reality.
3. Verify the skill's preconditions: the working tree is clean, and you are on the intended starting point — the branch or commit to build from. The skill branches from your **current `HEAD`** (a **detached `HEAD` is fine**; never switch to the default branch). If the tree is dirty, or a branch with the target name already exists, stop and ask.

## Phase 4: Build
Follow the `dev-workflow` skill's **build flow**:
1. Create the dev's branch from your **current `HEAD`** (`feature/…` for a feature, `bugfix/…` for a bug, `review/…` for a code review, per the skill — never switch to the default branch; a detached `HEAD` is fine), then flip the item/phase status to `IN PROGRESS` as the first change on the branch.
2. Implement to the plan's acceptance criteria, applying the house conventions — load any stack-specific convention skills the code calls for — and delegating cleanly separable parts to sub-agents per the skill.
3. Meet the **Definition of Done**: the build is clean, the whole test suite passes (including the new tests the plan's acceptance criteria call for), every acceptance criterion is met, the roadmap + plan statuses are updated, and the dev's completion doc `docs/done/<ID>.md` is written (the skill's *Completion docs* / DoD criterion 5) — it lands in this dev's own commit. Never report an item `DONE` with a failing build or tests — report the failure instead.
4. Run the skill's **documentation freshness sweep**: before printing the commit message, always ask — with concrete, analyzed candidates, a skip option, and (per the skill's *Asking questions* rule) a final option letting me name a doc the sweep missed — whether to refresh any README / CLAUDE.md / other prose docs this dev may have made stale; fold any edits you accept into this dev's own commit. (Per the skill — build flow only; non-blocking.)
5. Print the multi-phase progress table (if applicable) and the suggested commit message, then — per the skill — **pause and wait for me to commit** before starting the next dev.

**Plan-mode note.** If the session is in plan mode, present the plan file's contents (the already-validated plan) as the implementation plan and obtain approval (ExitPlanMode) before any **state-changing** action (branch creation, status flips, file writes) — but run the read-only resolution steps first, since you can't present a plan until you know which one: reading `docs/roadmap.md`, printing the Phase 2 roadmap table and asking me for the ID (all read-only, allowed before `ExitPlanMode`), and reading + sanity-checking the plan (Phase 3). Do **not** re-run a fresh planning exercise — the item was already planned during the interview. In other permission modes, expect the first `git switch -c` and file writes to raise permission prompts; treat them as harness mechanics, not as a reason to change approach.

# Rules
- The plan is the specification — implement it faithfully; don't silently redesign it. If it's wrong or stale, pause and tell me (Phase 3.2); if we then change direction, record it per the skill's "Abandoning or changing direction" rule rather than editing history.
- **Never commit yourself** — leave all commits to me. Creating the branch is the only state-changing git action you take; read-only git commands are always fine.
- **Never fix CRLF / line-ending noise** — per the skill it is recommendation-only; if you notice it, record a one-line recommendation in the dev's completion doc (*Deviations & follow-ups*) and take no action on it.
- **One dev per run** unless I say otherwise; pause between devs so each lands on its own branch.
- Use clear language and challenge a weak or inconsistent plan respectfully — a good fit with the existing code beats blind adherence to a stale plan.
