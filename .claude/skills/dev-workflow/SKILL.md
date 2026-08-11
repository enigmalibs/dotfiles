---
name: dev-workflow
description: Use when planning or implementing tracked work items under this house dev workflow — the roadmap registry (docs/roadmap.md), per-item plan files (docs/plan/<ID>.md), completion records (docs/done/<ID>.md), FEATURE-HHHH/BUG-HHHH/CODE-REVIEW-HHHH work-item IDs, branch naming, the Definition of Done, multi-phase progress reporting, and sub-agent delegation. Loaded by the /interview and /build commands; apply it whenever allocating a work-item ID, writing a plan file, branching for a dev, or reporting a dev as done.
---

# Dev workflow — house planning, tracking & version-control standards

**Version: dev-workflow v5.**

These standards govern *how* tracked development work is planned, recorded, and delivered. They are shared by `/interview` (which **only plans** work — it never builds) and `/build` (which executes a previously planned item). If the existing codebase already enforces its own conventions (documentation layout, branch naming, an existing roadmap or work-item ID scheme, etc.), those take precedence over the defaults here — confirm any such conventions before allocating IDs or creating branches.

**A "dev" is one deliverable unit of work — a single-phase item, or one phase of a multi-phase item.** Each dev gets its own branch, its own roadmap status update, its own completion record, and its own suggested commit message.

## Two flows: planning vs building

This workflow separates *planning* from *building*, so plans can be produced now and implemented later.

- **Planning flow** — produce the artifacts without implementing. Write the roadmap row(s) and plan file(s) with status `TODO` on your **current branch or `HEAD`** (see Version Control); create **no** dev branch. The plan file is the durable contract a later build consumes. `/interview` **always** runs this flow; it never implements.
- **Build flow** — implement a dev. Create its branch from your **current `HEAD`** **first** (see Version Control), then implement. Any planning artifacts not already committed (roadmap row, plan file) are the first change on that branch — a freshly created row/plan is written directly at status `IN PROGRESS` (not `TODO`); if the plan file already exists (planned earlier), the first change on the branch is instead flipping that item/phase status to `IN PROGRESS`. `/build` always runs this flow against an already-planned item; `/interview` never runs it.

## Asking questions (both flows)

Whenever you need a decision from the user — in either flow, and whatever the command — ask it like this.

- **Ask through `AskUserQuestion`**, never as a prose question list. This holds even when the answer is a free value (a name, a path, a number, a short description): offer 2–3 plausible sample values plus the escape option below, rather than asking in prose.
- **Assume the answer space is open — always leave a free-text way out.** Author an explicit final option using the constant stem **`None of these — I'll describe it`**, with a *question-specific* description saying what to type (e.g. "Pick this if none of the three approaches above fits — type the pattern you want, or 'defer this decision'"). Omit it **only** when the options *provably* enumerate every possible answer — a yes/no, or a genuine pick-one-of-N such as `FEATURE` vs `BUG` vs `CODE-REVIEW` — where the tool's automatic "Other" choice is enough. Anything about approach, design, scope, naming, priorities, or preference is **open by default**: the burden of proof is on the claim that a set is closed, never on the escape option. (`AskUserQuestion`'s own guidance says not to author an "Other" option because the tool adds one; this house rule deliberately overrides that — the automatic choice is too easy to miss, which is exactly how the user ends up cornered into a wrong option.)
- **Budget the 4-option cap:** an open question carries **at most 3 concrete options** plus the escape option. If you have more candidates than fit, group them or name the extras in the question text — never silently drop one.
- **The escape option is always last, and never carries `(Recommended)`.** The recommendation stays a concrete, actionable default listed first; the escape option is the exit, not the advice.
- **A typed answer is a decision.** Adopt it, restate your reading of it in one line, and continue — no confirmation round. In an interview, record it in the Phase 3 summary under *"Decisions you made"*.

## Planning & Documentation

Track every dev through a stable work-item ID, a persistent roadmap, one plan file per item, and one completion record per completed dev.

### Documentation structure (at the solution root)

- `docs/roadmap.md` — the single, persistent registry of **every** work item across the whole project (not just the current task).
- `docs/plan/` — one markdown plan file per work item, holding the full plan details.
- `docs/done/` — one "what has been done" completion record per **completed dev** (see *Completion docs*).
- **If this structure does not exist yet** — new project, or the first tracked work item in an existing codebase — create `docs/roadmap.md` (an empty table with the four columns below), `docs/plan/`, and `docs/done/` before allocating the first ID, after confirming the project doesn't already track work items elsewhere.

### Work-item identifiers

Every unit of work gets a stable ID before anything else happens:

- **Format:** `FEATURE-HHHH`, `BUG-HHHH`, or `CODE-REVIEW-HHHH`, where `HHHH` is a random 4-digit **uppercase** hex value (`0-9`, `A-F`) — e.g. `FEATURE-3A7F`, `BUG-9C2E`, `CODE-REVIEW-7F10`. IDs are random, not sequential, and carry no ordering (see *Ordering* under `roadmap.md`).
- **Allocation — random & collision-safe:** generate `HHHH` from a shell entropy source, uppercased — `printf '%04X\n' $((RANDOM % 65536))` (already uppercase) or `openssl rand -hex 2 | tr '[:lower:]' '[:upper:]'`. **Do not invent the value yourself** — hand-picked hex is non-uniform and raises the real collision rate, defeating the purpose. Then check the value isn't already used by an item of the **same type** in the roadmap's **ID column** or as a stray file in `docs/plan/` (including `ABANDONED` ones); regenerate on any collision. Also glance at `docs/plan/` for stray plan files whose ID isn't in the roadmap. Random IDs let multiple devs allocate concurrently on the same repo **without a shared counter**, so independently created IDs don't clash on merge.
- **Uniqueness is per type:** each type has its own hex space — `FEATURE-3A7F` and `BUG-3A7F` may coexist because the type prefix already makes them distinct IDs; only collisions *within the same type* trigger a regenerate.
- **`FEATURE`, `BUG`, and `CODE-REVIEW`** types are used.
- **Multi-phase items:** when an item is large enough to need several phases, suffix the phase as `-PHASENN` (2-digit, **sequential** — only the base ID is random): `FEATURE-3A7F-PHASE01`, `FEATURE-3A7F-PHASE02`, … The base item keeps its un-suffixed ID (`FEATURE-3A7F`). Phase suffixes never collide across devs because a multi-phase item is owned by one dev.
- **Code-review items:** a `CODE-REVIEW-HHHH` item captures a code review (e.g. the output of `/code-review`, `/security-review`, or a PR review). **Each finding becomes one PHASE**, and the phases are **ordered highest-severity first** (Critical → High → Medium → Low). Record the severity in the phase title and in the plan file — e.g. `PHASE01 — [Critical] SQL injection in OrderRepository`. Built like any other multi-phase item via `/build`, on `review/` branches (see Version Control). The plan file `docs/plan/CODE-REVIEW-HHHH.md` records, per finding, its severity, location (file:line), and the recommended fix.
- If the existing project already uses its own roadmap or ID scheme, follow that instead of this one.

### `roadmap.md` — summary only

The roadmap holds **only** a summary table — never plan details. Columns: **ID · Title · Status · Plan** (the path to the item's plan file).

- **Table formatting — the table is read raw, so keep it aligned.** People read this table as plain text (in an editor, in `git diff`, in the console when `/build` prints it), not only rendered, so the columns must line up:
  - **Uniform column widths.** Pad every cell in a column with trailing spaces to the width of the **widest cell in that column, header included**, and give the delimiter row's dashes that same width. Keep the conventional single space after the opening `|` and before the closing `|`, so every `|` sits at the same offset on every line of the table.
  - **Width is content-driven — never fixed, never truncating.** IDs, statuses, and plan paths are always written in full; the column simply grows to the widest one. Count **characters**, not bytes, so a title containing `—` or `` ` `` still aligns.
  - **Keep the Title cell short** — a summary line, roughly ≤ 40 characters. Title is the one column that can grow without bound, and one verbose title pads every other row; abbreviate it and let the plan file carry the full statement of the work.
  - **Phase rows align like any other row:** the `- PHASENN` marker sits in the ID column, padded to the same width as the base IDs.
- **Reformat the whole table on every edit.** Whenever you touch the table for **any** reason — appending an item, adding a phase row, flipping a status, abandoning an item, fixing a title — **rewrite every row** so all columns are re-padded to the current widest cell. This is part of the same edit, never a follow-up chore: one new row whose ID or path is a single character wider than the current column invalidates the padding of *every* other row, which is exactly how a table drifts out of alignment. Never leave it ragged "because only one row changed". The same padding applies to the phase progress table you print to the console (see *Multi-phase progress reporting*).
- **Status vocabulary:** `TODO`, `IN PROGRESS`, `DONE`, `ABANDONED` — the Status cell holds the bare keyword and nothing else (see *Abandoning or changing direction* for where an abandon reason goes).
- **Ordering — the row order is the order.** Because IDs are random and carry no sequence, an item's position in the table *is* its order — **append each new item as the last row.** `/build` recommends the topmost `TODO`/`IN PROGRESS` item, so oldest-planned work is surfaced first.
- For a multi-phase item, list the item on one row, then one indented `- PHASENN` row per phase, each carrying its own status; the phase rows reference the item's plan file as `(in FEATURE-3A7F.md)`.
- **Keep it current — update the roadmap after every dev** so each item/phase status reflects reality. Add a new item's row when it is created: in the **planning flow** on your current branch/`HEAD`; in the **build flow** as the first change on the dev's branch (see Version Control).

```markdown
| ID           | Title               | Status      | Plan                      |
|--------------|---------------------|-------------|---------------------------|
| FEATURE-3A7F | User authentication | IN PROGRESS | docs/plan/FEATURE-3A7F.md |
| - PHASE01    | Login flow          | DONE        | (in FEATURE-3A7F.md)      |
| - PHASE02    | OAuth providers     | IN PROGRESS | (in FEATURE-3A7F.md)      |
| BUG-9C2E     | Fix token refresh   | DONE        | docs/plan/BUG-9C2E.md     |
```

A code-review item follows the same shape, with findings as phases:

```markdown
| ID               | Title                    | Status      | Plan                          |
|------------------|--------------------------|-------------|-------------------------------|
| CODE-REVIEW-7F10 | PR #42 review            | IN PROGRESS | docs/plan/CODE-REVIEW-7F10.md |
| - PHASE01        | [Critical] SQLi in Order | DONE        | (in CODE-REVIEW-7F10.md)      |
| - PHASE02        | [Medium] N+1 in Listing  | TODO        | (in CODE-REVIEW-7F10.md)      |
```

### Plan files — `docs/plan/<ID>.md`

One file per work item, named after its base ID (`docs/plan/FEATURE-3A7F.md` — no phase suffix in the filename). It contains the full plan, proportional to the work: objective, scope, design, acceptance criteria, and — for multi-phase items — a dedicated section per phase with that phase's steps and status. The roadmap's **Plan** column always points to this file.

### Completion docs — `docs/done/<ID>.md`

When a dev reaches the Definition of Done, write a **"what has been done" completion record** — **one file per dev**, named after the dev's full ID *including* any phase suffix: `docs/done/FEATURE-3A7F-PHASE02.md` for a phase, `docs/done/BUG-1F3D.md` for a single-phase item, `docs/done/CODE-REVIEW-7F10-PHASE01.md` for a review finding. It records, concisely:

- **Summary** — what changed and why.
- **Files/modules touched** — created / modified / deleted.
- **Deviations & follow-ups** — where the implementation differed from the plan and why, plus known issues, follow-up suggestions, and any line-ending (CRLF) recommendation (see *Line endings*).
- **Build/test evidence** — the Definition-of-Done proof: build clean, test suite passing, tests added (or, for no-build/no-test work, how the criteria were verified).

The completion doc is part of the **dev's own commit** (it lands with the code, not as a separate commit). Writing it is Definition-of-Done criterion 5.

### Abandoning or changing direction

If you decide to drop a dev, or to do it a different way, **do not delete its row.** Set its status to the bare keyword `ABANDONED`, then record a short reason — and, if applicable, the ID of the item that replaces it — as a **blockquote footnote beneath the table**, keyed by the item's ID. Mirror the same note at the top of the item's plan file.

The reason is kept out of the Status cell deliberately: a sentence-long cell would pad the Status column of the *whole* table to its width (see *Table formatting*), which costs every row's readability to annotate one.

```markdown
| ID           | Title              | Status    | Plan                      |
|--------------|--------------------|-----------|---------------------------|
| FEATURE-4B21 | Custom cache layer | ABANDONED | docs/plan/FEATURE-4B21.md |

> `FEATURE-4B21` abandoned — superseded by a simpler approach; replaced by `FEATURE-8D0C`.
```

## Definition of Done

A dev is **done** only when all of the following hold:

1. The full build succeeds with zero warnings.
2. The entire test suite passes — including the new tests the plan's acceptance criteria call for.
3. Every acceptance criterion in the plan file is met.
4. The roadmap and plan file statuses are updated.
5. The dev's completion doc `docs/done/<ID>.md` is written (see *Completion docs*).

Only after all five may you print the progress table (multi-phase items) and the suggested commit message. Never mark an item `DONE` — or present it as finished — with a failing build or failing tests; report the failure instead.

(For work with no build step or test suite — e.g. documentation or prompt/config changes — criteria 1 and 2 are satisfied by the applicable equivalent: the artifact is well-formed and its acceptance criteria are verified by inspection or a dry run. State explicitly that there was nothing to build or test. Criteria 3–5 still apply.)

## Documentation freshness sweep (build flow)

**Build flow only** — the planning flow never runs this. Once a dev has met the Definition of Done (roadmap + plan statuses updated, `docs/done/<ID>.md` written) and **before** you print the progress table and the suggested commit message, run a documentation freshness sweep so user-facing docs don't silently fall out of date.

- **Scan the dev's changes** and identify project/user-facing documentation the change may have made stale, across: **README** files; **CLAUDE.md** / agent-instruction files (`AGENTS.md`, etc.); and **other prose docs** (e.g. `CHANGELOG.md`, `CONTRIBUTING.md`, a docs site, other human-facing files under `docs/`). **Exclude the workflow's own tracked artifacts** — `docs/roadmap.md`, `docs/plan/`, `docs/done/` are already handled by the Definition of Done — and do not treat skill/command prompt files as sweep targets.
- **Always ask, with concrete candidates.** Surface one `AskUserQuestion` every time (even when nothing looks stale). Offer the specific files/sections you recommend updating — one option each, with a one-line reason (e.g. "README 'Usage' still shows the old flag") — plus a **"none / skip"** option and, per *Asking questions*, a final **`A different doc — I'll name it`** option so the user can point at something the sweep missed. With the 4-option cap that leaves room for two concrete candidates: if the sweep found more, group them into one option or name the extras in the question text rather than dropping any. If the sweep found nothing, say so and recommend skip. Never edit docs without asking.
- **Accepted edits land in this dev's own commit.** If the user selects targets, make those edits now; they ride in the same commit as the code and the completion doc, and you extend the suggested commit message to mention them. If the user skips, proceed unchanged.
- **Non-blocking.** This is a safety-net prompt, not a sixth Definition-of-Done criterion — never hold a dev's `DONE` status on it.

## Line endings (CRLF)

Never fix CRLF / line-ending noise as part of a dev, and never raise it as an interview question. If you notice line-ending inconsistency (e.g. a diff dominated by CRLF↔LF churn, or mixed endings in a touched file), emit a **one-line recommendation only** — in the dev's completion doc under *Deviations & follow-ups*, and/or to the console — and take no action on it. The user owns whether and how to normalize line endings (e.g. via a `.gitattributes` `* text=auto eol=lf` rule).

## Version Control

- **Never commit changes yourself** — leave all commits to the user. Creating the branch (below) is the only git action you perform **that modifies repository state**; read-only commands (`git status`, `git log`, `git diff`, `git branch --list`, `git rev-parse`) are always allowed — use them to verify state before branching.
- **Before starting any dev (build flow), create its branch from your current `HEAD`** — the branch or commit `HEAD` currently points at — **never** switching to the project's default branch. A **detached `HEAD` is fine** (the user manages their own git state); branch directly from the detached commit. Do not assume or switch to `main`/`master`. Name the branch from the ID under a category folder — `feature/` for features, `bugfix/` for bugs, `review/` for code reviews — followed by the ID lowercased and hyphenated: `git switch -c feature/feature-3a7f-<short-slug>` (`bugfix/bug-9c2e-<short-slug>` for a bug, `review/code-review-7f10-<short-slug>` for a review). For a phase of a multi-phase item, include the phase: `git switch -c feature/feature-3a7f-phase01-<short-slug>` (one branch per phase). First verify the working tree is clean (`git status --porcelain` prints nothing). **If the tree is dirty, a branch with that name already exists, or the project has no git repository yet — stop and ask the user before proceeding.**
- **In the planning flow, do not create a dev branch:** the roadmap row(s) and plan file(s) are written on your current branch/`HEAD`. Branching is deferred to whoever builds the item later.
- **Branch first, then plan (build flow only):** on the new branch, the first change is the item's roadmap row + plan file (created directly at status `IN PROGRESS`) if they don't yet exist, or — if they were written earlier by the planning flow — flipping the item/phase status to `IN PROGRESS`. Never leave a build's first change on your previous branch/`HEAD`.
- **After each dev, write a suggested commit message to the console** (do **not** run it): a short title, a blank line, then a brief bulleted description. Use conventional-commit style with the ID scoped in; **the scope is always the base ID** — `feat(FEATURE-3A7F): …` for features, `fix(BUG-9C2E): …` for bugs, `fix(CODE-REVIEW-7F10): …` for code-review findings — and for a phase, the phase goes in the title (`feat(FEATURE-3A7F): add login flow (PHASE01)`), never in the scope.
- **Planning-flow commits.** When the planning flow writes one or more items' roadmap rows and plan files without implementing, the suggested commit is a single documentation commit for the batch — scoped `docs` (or `chore`), e.g. `docs(roadmap): plan FEATURE-5C4D, FEATURE-6E1A, BUG-1F3D` — not a per-item `feat(...)`/`fix(...)` scope (those belong to the build flow that implements a dev).
- **Between devs, pause.** After printing a dev's progress table (multi-phase) and its commit message, stop and wait for the user to commit before creating the next dev's branch — whether the next dev is the following **phase** of a multi-phase item or a separate **work item** built in the same run. Each dev needs its own branch cut from a clean working tree (`git status --porcelain` empty), so the current dev must be committed first; each dev's changes land on their own branch.

### Multi-phase progress reporting

When a phase of a multi-phase item completes, **before** the commit message, print to the console a **status table of all phases** of that item — each phase with its status, the immediate next phase marked `TODO (next)` — so it's clear what is done, what's next, and what remains. Then print the commit title and description **after** the table. (Single-phase devs skip the table and just get the commit message.) When the final phase completes, no row carries the `(next)` marker — all phases show `DONE` — and the item's own roadmap row flips to `DONE` in the same update.

```
FEATURE-3A7F — User authentication

| Phase   | Title           | Status      |
|---------|-----------------|-------------|
| PHASE01 | Login flow      | DONE        |
| PHASE02 | OAuth providers | TODO (next) |
| PHASE03 | Two-factor auth | TODO        |

Commit title:
  feat(FEATURE-3A7F): add login flow (PHASE01)

Commit description:
  - email/password login with validation
  - session cookie issuance
  - unit tests for the auth service
```

## Sub-Agent Delegation
- For large efforts that decompose cleanly into independent units, delegate those units to sub-agents, each spawned with its own fresh context. This keeps every sub-agent focused on a single, well-scoped portion and improves the quality of each part.
- Only delegate when the split is genuinely clean (minimal cross-dependencies and clear interfaces between parts). If the work is tightly coupled, keep it in a single context to preserve coherence rather than forcing an artificial split.
- When you do delegate: (1) include in each sub-agent's prompt the interface contract it must honor, the relevant validated requirements from the plan, and the exact target paths; (2) sub-agents write code and tests only — all git actions, roadmap/plan/done updates, and commit messages remain yours; (3) after integrating sub-agent output, run the full build and test suite yourself before declaring the dev done.
