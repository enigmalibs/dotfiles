# FEATURE-75F7 — `/bulk`: build already-planned items unattended

**Status:** DONE
**Type:** FEATURE (single-phase)
**Branch (at build time):** `feature/feature-75f7-bulk-command`, cut from current `HEAD`.

_Planned via `/interview` (v9); build with `/build FEATURE-75F7`. Prompt-file change — no build/test step.
Build **after** FEATURE-3BF6 (roadmap order), whose closing hint forward-references `/bulk`._

## Objective

Add **`/bulk`**, the autonomous executor for plans written by `/interview`. Where `/vibe` self-interviews,
plans and builds from a spec prompt, `/bulk` skips the planning and builds **already-planned roadmap items** —
every `TODO` row, or the IDs passed as arguments — with exactly `/vibe`'s autonomy rules: no questions, its
own run branch `bulk/<yyyy-mm-dd>-<slug>`, one dev branch per dev merged `--no-ff` into the run branch, its
own commits, the 3-cycle fix budget, quarantine-and-continue, no `Agent` / `Workflow` tools, resume after a
dead session, never a push, never a write to the branch the user started from.

Typical flow: `/interview <spec>` → the user commits `docs(roadmap): plan …` → `/bulk` → review the run branch
→ merge. This is the "build-by-ID mode" recorded as a considered-but-deferred follow-up in FEATURE-608E.

Two prompt files deliver it:

- `.claude/skills/vibe-workflow/SKILL.md` — **v1 → v2**: its `/vibe`-only wording is generalized to *the run
  command* (`/vibe` or `/bulk`). **No rule changes** — every superseding rule (§2, §5, §6, §7, §8) keeps its
  meaning; only the places that name `/vibe`, the `vibe/` prefix, the `vibe:` message prefix, the planning
  commit and the report header are generalized, and `/bulk`'s pre-flight stops are added to §10.
- `.claude/commands/bulk.md` — **v1**, new.

## Context & constraints

- **Evolution of an existing repo:** `C:\Dev\EnigmaLibs\dotfiles`. Commands live in `.claude/commands/*.md`,
  skills in `.claude/skills/<name>/SKILL.md`. Claude Code prompt files only — **no build, no test suite**;
  Definition-of-Done criteria 1–2 are met by well-formed markdown verified by inspection and by the greps
  under *Acceptance criteria*. The **real dry run is the user's** (see *Dry run recipe*): `bulk.md` carries
  `disable-model-invocation: true`, so the builder cannot invoke it.
- **Files that must stay byte-identical to `HEAD`:** `.claude/commands/interview.md` (v10, as left by
  FEATURE-3BF6), `.claude/commands/build.md` (v6), `.claude/commands/vibe.md` (v1),
  `.claude/skills/dev-workflow/SKILL.md` (v5). `/vibe` v1 must keep working unmodified against skill v2 —
  which holds because every generalized sentence still reads correctly with `<run command>` = `/vibe`.
- **Command-file shape to match** (`vibe.md`, `build.md`): YAML frontmatter with `description`,
  `argument-hint`, `disable-model-invocation: true`; `# Role` / `# Context` / `# Process` (numbered
  `## Phase N:` sections, Phase 0 = announce line) / `# Rules`; the announce line
  `Using bulk v1 by Josué Clément` printed first, as plain text, nothing before it.
- **Rules live in the skill, phases live in the command** (FEATURE-608E precedent): the fix budget, the
  quarantine procedure, the git allowed/forbidden table, the pre-flight messages and the report template
  are defined once, skill-side, and referenced by `§` number from the command.
- **Interview-written plan files vary in their header block:** `**Status:**` is always present;
  `**Type:**` and `**Branch:**` / `**Branch (at build time):**` sometimes; an italic `_Planned via …_` line
  usually follows. The marker-insertion rule (§9) must tolerate that — see Design A edit 7.
- **This repo's own roadmap illustrates the exclusions:** `FEATURE-003` is a stale `IN PROGRESS` row (skill
  exists, no done doc) — `/bulk` must never pick it up.
- **Operational prerequisite the command cannot control:** a no-questions run only works in a permission
  mode that does not prompt for `git commit` / file writes (auto or bypass mode, or an allowlist) and **not
  in plan mode**. `bulk.md` documents this in its `# Context` and stops in pre-flight if plan mode is active.
- **Deployment to `~/.claude/commands` / `~/.claude/skills` is out of scope** — the copies there are plain
  files, not junctions (FEATURE-15CB precedent). Note that `vibe.md` and `vibe-workflow/` are not deployed
  there yet either; deploying skill v2 together with `vibe.md` and `bulk.md` is the user's step.
- **Line endings:** every touched file is CRLF and internally consistent; author `bulk.md` CRLF. Recommendation
  only (not part of this item): a `.gitattributes` with `* text=auto eol=lf` would remove the churn risk.

## Decisions settled in the interview

| # | Decision |
|---|---|
| 1 | **Architecture:** a new `/bulk` command that **reuses `vibe-workflow`**, bumped to v2 with its `/vibe`-only wording generalized. No new skill (twin-sync rejected), no build-by-ID mode grafted onto `/vibe` (its argument stays a spec draft). `dev-workflow`, `build.md`, `vibe.md` untouched. |
| 2 | **Selection:** `/bulk <ID> [<ID>…]` builds those items; `/bulk` with no argument builds **every `TODO` row** in roadmap table order. `IN PROGRESS`, `DONE` and `ABANDONED` rows are never picked up — skipped and listed in the end-of-run report in no-argument mode, a pre-flight stop when named explicitly. |
| 3 | **Handoff:** the user commits `/interview`'s planning artifacts, as today. `/bulk`'s pre-flight requires a clean tree (inherited stop); a dirty tree is never adopted. |
| 4 | **Run scoping:** the run's first commit — the **claim commit** — stamps `**Run:** bulk/<date>-<slug>` into each selected plan file. Skill §9 ("the run's items are exactly the plan files carrying its marker") and the resume state machine then work unchanged. |
| 5 | **Breakdown:** two single-phase items; this one second. Skill v2 + `bulk.md` v1 ship in one dev (FEATURE-608E precedent). |

## Defaults applied without asking (low impact)

| #   | Default |
|-----|---|
| A4  | **Run branch** `bulk/<yyyy-mm-dd>-<slug>`; slug = the lowercased selected base IDs joined with `-` when ≤ 3 items (`feature-3bf6-feature-75f7`), else `<first-id>-plus-<N>` (`feature-3bf6-plus-4`). |
| A5  | **Claim commit** message `docs(plan): claim <ID>[, <ID>…] for <run branch>`; the marker line goes directly after the plan file's header block — the run of `**…:**` lines at the top, before the first blank line — so `/build` and humans see it where `/vibe` puts it. Statuses stay `TODO`; the roadmap is not touched by the claim. |
| A6′ | **Arguments are base IDs.** A phase ID (`FEATURE-3A7F-PHASE02`) is a pre-flight stop pointing at `/build <phase ID>` — the `**Run:**` marker is per plan file, so per-phase selection would need a marker format extension for a case `/build` already covers. *(Refines the interview summary's A6, which allowed phase IDs; recorded here as the deviation.)* A base ID selects all of the item's remaining `TODO` phases, built in numeric order; items build in roadmap table order. |
| A7  | **Ownership:** a plan file already carrying a `**Run:**` marker belongs to another run (a `/vibe` run, or an earlier `/bulk` run) — skipped in no-argument mode, a stop when named. |
| A8  | **Mode resolution:** no argument on a `bulk/*` branch (or on one of its dev branches) = **resume**; an argument anywhere = a new run cut from the current `HEAD` (even from another run branch); no argument elsewhere = a new run over every unowned `TODO` row. Resuming a finished run re-prints the end-of-run report and stops. |
| A9  | **The build-loop skeleton and the resume state machine are restated in `bulk.md`**, adapted (claim instead of plan-writing), rather than moved into the skill — keeping `vibe.md` byte-identical. Every rule the loop references stays skill-side; the accepted cost is two ~25-line skeletons that must stay in step. |
| A10 | **The skill keeps its name** (`vibe-workflow`); `/bulk`'s stop messages join the §10 table so every stop message has one home. |
| A11 | **Before writing anything, `/bulk` prints the selection table** (ID · Title · Status · Plan, padded per the inherited rule) and the run branch name — the bulk equivalent of `/vibe`'s printed self-interview summary. No confirmation. |
| A12 | **`/build` ignores the `**Run:**` line** (it already does for vibe-written plan files), so it can finish a quarantined `/bulk` dev exactly as it finishes a quarantined `/vibe` dev. |
| A13 | **Stale plan = adapt and record**, never ask (inherited skill §2): before implementing, `/bulk` opens the files the plan targets; if the codebase drifted since the interview, it implements what the codebase supports and records the deviation in the completion doc under *Deviations & follow-ups*. |

---

## Design

### A. `.claude/skills/vibe-workflow/SKILL.md` — v2 (generalization, no rule changes)

Apply exactly these edits; every other line stays byte-identical (acceptance criterion 8).

1. **Frontmatter `description`** — replace the trailing *"Loaded by /vibe only — never by /interview or
   /build."* with *"Loaded by the autonomous run commands /vibe and /bulk only — never by /interview or
   /build."*
2. **Version line** — `**Version: vibe-workflow v2.**`
3. **Intro paragraph** — replace *"It is loaded by `/vibe` only — `/interview` and `/build` never load it."*
   with *"It is loaded by the two **run commands** — `/vibe` (plans and builds from a spec) and `/bulk`
   (builds already-planned items) — and never by `/interview` or `/build`. Below, **the run command** means
   whichever of the two is running, and `<command>` its name (`vibe` or `bulk`)."*
4. **§3 Run topology**
   - Run-branch bullet: *"**Run branch:** `vibe/<yyyy-mm-dd>-<slug>` — date from `date +%Y-%m-%d`, slug ≤ 4
     kebab-case words derived from the prompt — cut from the current `HEAD`."* → *"**Run branch:**
     `<command>/<yyyy-mm-dd>-<slug>` — `vibe/…` or `bulk/…`; date from `date +%Y-%m-%d`; slug ≤ 4 kebab-case
     tokens — for `/vibe` derived from the prompt, for `/bulk` the lowercased selected base IDs joined with
     `-` when ≤ 3 items, else `<first-id>-plus-<N>` — cut from the current `HEAD`."* Keep the rest of the
     bullet (detached `HEAD`, default branch).
   - Planning-artifacts bullet → *"**The run's first commit claims its items.** For `/vibe` it is the
     **planning commit** (`docs(roadmap): plan <ID>[, <ID>…]`, the inherited planning-commit format) carrying
     the roadmap rows, the plan files, and the `docs/` structure when it had to be created — planning
     artifacts live on the run branch, not on the starting `HEAD`. For `/bulk`, whose items were already
     planned and committed by the user, it is the **claim commit** `docs(plan): claim <ID>[, <ID>…] for <run
     branch>`, which only adds the `**Run:**` marker (§9) to each selected plan file — statuses and the
     roadmap are untouched."*
   - Under the diagram, add one line: *"A `/bulk` run has the same shape, with `bulk/…` as the run branch
     and `docs(plan): claim …` as its first commit."*
5. **§4 Commits are yours** — *"The run commits **after planning** (`docs(roadmap): …`)"* → *"The run commits
   **after planning or claiming** (`docs(roadmap): plan …` for `/vibe`, `docs(plan): claim …` for `/bulk`)"*.
6. **§6 quarantine step 4** — footnote text *"quarantined by `/vibe` run `<run branch>`"* → *"quarantined by
   `/<command>` run `<run branch>`"*.
7. **§9 State lives in files**
   - *"Every plan file a run writes carries, directly under its `**Branch:**` line:"* → *"Every plan file a
     run **owns** carries, directly after its header block (the consecutive `**Status:**` / `**Type:**` /
     `**Branch…:**` lines at the top, before the first blank line):"* — the fenced `**Run:**` example stays.
     Then add: *"`/vibe` writes the line when it creates the plan file; `/bulk` adds it to the selected,
     already-existing plan files in its claim commit."*
   - *"**The run's items are exactly the plan files carrying its `**Run:**` marker** — never items recalled
     from the conversation, and never pre-existing `TODO`/`IN PROGRESS` rows planned by `/interview`, which
     are left for `/build`. Resume logic belongs to `/vibe`; …"* → *"… — never items recalled from the
     conversation, never plan files carrying **another** run's marker, and — for `/vibe` — never pre-existing
     rows planned by `/interview`, which are left for `/build` or `/bulk`. Resume logic belongs to the run
     command; …"*.
8. **§10 Pre-flight stops**
   - Shape sentence: *"vibe: cannot start — `<reason>`. `<what the user should do>`."* → *"`<command>: cannot
     start — <reason>. <what the user should do>.`"* (the run command's name as prefix).
   - Existing rows: replace the `vibe:` prefix with `<command>:` in *no git repository*, *plan mode active*,
     *dirty working tree*, *run-branch name collision* (and in the collision row, *"resume it with `/vibe`
     (no argument)"* → *"resume it with `/<command>` (no argument)"*). The *no argument, nothing resumable*
     row is `/vibe`-only: label it *"no argument, nothing resumable (`/vibe`)"* and keep its message.
   - New rows (all `/bulk`):

     | Condition                           | Message |
     |-------------------------------------|---------|
     | no roadmap (`/bulk`)                | bulk: nothing to build — no `docs/roadmap.md` here. Plan items with `/interview` first. |
     | unknown ID (`/bulk`)                | bulk: cannot start — `<ID>` is not in `docs/roadmap.md`. Check the ID, or plan it with `/interview` first. |
     | phase ID passed (`/bulk`)           | bulk: cannot start — `<phase ID>` is a phase. Pass the base ID `<base ID>` (its `TODO` phases build in order), or use `/build <phase ID>` for a single phase. |
     | ID not `TODO` (`/bulk`)             | bulk: cannot start — `<ID>` is `<status>`. Only `TODO` rows are built; an `IN PROGRESS` row belongs to `/build`, a quarantine, or another run. |
     | ID owned by another run (`/bulk`)   | bulk: cannot start — `<ID>` already carries `**Run:** <branch>`. Resume that run from its branch, or finish the item with `/build <ID>`. |
     | plan file missing (`/bulk`)         | bulk: cannot start — `docs/plan/<ID>.md` does not exist. Plan the item with `/interview` first. |
     | nothing selectable (`/bulk`)        | bulk: nothing to build — no unowned `TODO` row in `docs/roadmap.md`. Plan items with `/interview` first. |
     | no argument, nothing resumable (`/bulk`) | *(not a stop — no argument outside a `bulk/*` run starts a new run over every unowned `TODO` row; listed here so the two commands' no-argument semantics sit side by side.)* |

9. **§11 End-of-run report** — first template line *"vibe run vibe/2026-09-10-user-auth — 3 devs done,
   1 quarantined"* → *"<command> run <run branch> — 3 devs done, 1 quarantined"* (the example table below
   stays as it is). After the template add: *"A `/bulk` report has the same shape and, in no-argument mode,
   one extra `Skipped:` line after `Quarantined:` naming the rows it did not select and why (`IN PROGRESS`,
   owned by another run) — omitted when nothing was skipped."*
10. **§12 Common mistakes** — add the row *"`/bulk` picking up an `IN PROGRESS` row, or a plan file with
    another run's marker"* → *"Only unowned `TODO` rows are selectable (§9, §10)"*.
11. **§13 Cross-references** — in the *Stack and convention skills* bullet, *"loaded by the run's
    self-interview exactly as `/interview` loads them"* → *"loaded by `/vibe`'s self-interview exactly as
    `/interview` loads them, and by `/bulk` for the codebase it builds in"*.
12. **§1 table** — unchanged (the superseded sections are the same for both commands). The §1 heading
    paragraph is covered by edit 3.

### B. `.claude/commands/bulk.md` — v1

**Frontmatter**

```yaml
---
description: Autonomous build of already-planned roadmap items — takes the TODO rows /interview wrote (all of them, or the base IDs you pass), claims them on a bulk/<date>-<slug> run branch, then builds every dev (branch, implement, DoD, commit, merge, quarantine-and-continue) without asking anything. No argument on a bulk branch = resume that run. Never touches the branch you started from; never pushes.
argument-hint: [<ID> [<ID>…]] | (nothing = every TODO row, or resume the current bulk run)
disable-model-invocation: true
---
```

**Body**

- `# Role` — a Senior Software Developer who implements already-planned, already-validated work,
  **unattended**: the requirements were gathered by `/interview`; `/bulk` reads the plan files, builds every
  selected dev end to end — branch, code, tests, Definition of Done, completion doc, commit, merge — and
  reports once, at the end. It never re-runs the interview.
- `# Context` — one command in, a reviewable branch out. The plans are the contract (a stale plan is adapted
  and the deviation recorded — never questioned, A13). Everything the run produces lives on
  `bulk/<yyyy-mm-dd>-<slug>` cut from the current `HEAD`, with one merged `feature/…` / `bugfix/…` /
  `review/…` branch per dev; the starting branch is never modified, the default branch never written to,
  nothing is ever pushed. Two stop conditions only (every selected item `DONE` or quarantined; session dies →
  `/bulk` with no argument resumes); a pre-flight refusal is the only other exit. The operational
  prerequisite (non-prompting permission mode, not plan mode). The typical flow
  `/interview` → `git commit` → `/bulk`.
- `# Process`
  - **Phase 0: Announce the version** — exactly `Using bulk v1 by Josué Clément`, first, plain text.
  - **Phase 1: Load the standards** — `dev-workflow`, then `vibe-workflow` (wins where they disagree), then
    the stack/convention skills the target codebase calls for (same rule as `/interview` Phase 1 step 5b).
  - **Phase 2: Pre-flight and mode resolution.** Read-only git checks first: a repository is present ·
    `git status --porcelain` is empty · the current branch or detached `HEAD` · the default branch name.
    Detect plan mode → stop. Then:
    - **No argument, and the current branch is `bulk/*`** — or a dev branch whose roadmap row is
      `IN PROGRESS` and whose plan file's `**Run:**` marker names an existing `bulk/*` branch → **RESUME**
      (Phase 5).
    - **Otherwise → NEW RUN** (Phase 3). An argument on a `bulk/*` (or `vibe/*`) branch starts a new run cut
      from that tip — the user chose to stand there. If `bulk/<date>-<slug>` already exists → stop
      (collision).
    - Every stop prints the exact `bulk: cannot start — …` / `bulk: nothing to build — …` message from skill
      §10 and ends the turn. **Nothing is written before pre-flight passes.**
  - **Phase 3: Select and claim (new run).**
    1. Read `docs/roadmap.md` from disk (missing → stop).
    2. **Select.** *With IDs:* each must be a **base ID** present in the roadmap (phase ID → stop; unknown →
       stop); its status must be `TODO` (`DONE` / `ABANDONED` / `IN PROGRESS` → stop); its plan file must
       exist and carry no `**Run:**` marker (→ stop otherwise). A multi-phase item contributes all its
       `TODO` phases. *Without IDs:* every `TODO` item row — with all its `TODO` phases — whose plan file
       exists and carries no `**Run:**` marker, in table order; rows excluded for status or ownership are
       remembered for the report's `Skipped:` line. An empty selection → stop (`bulk: nothing to build …`).
    3. **Print the selection table** (ID · Title · Status · Plan, padded per the inherited rule) and the run
       branch name. No confirmation (A11).
    4. `git switch -c bulk/<yyyy-mm-dd>-<slug>` (slug per skill §3).
    5. **Claim:** add `**Run:** <run branch>` to each selected plan file directly after its header block
       (skill §9). Change nothing else — statuses stay `TODO`, the roadmap is untouched.
    6. Stage exactly those plan files (`git status --porcelain` first) and commit
       `docs(plan): claim <ID>[, <ID>…] for <run branch>` (+ the `Co-Authored-By` trailer when the session
       provides one).
  - **Phase 4: Build loop.** **While** the roadmap — **re-read from disk** — still has a run item (a plan
    file carrying this run's `**Run:**` marker) with a `TODO` item/phase that is not blocked by a
    quarantined sibling phase:
    1. **Resolve the next dev:** the topmost run item in table order, and its first `TODO` phase (or the
       item itself if single-phase).
    2. From the run branch with a clean tree, `git switch -c <dev branch>` per `dev-workflow` naming.
    3. Flip the roadmap row/phase and the plan file's status to `IN PROGRESS` (whole-table reformat).
    4. **Sanity-check, then implement.** Open the files/areas the plan targets; if the codebase drifted
       since the interview, adapt and note the deviation for the completion doc (skill §2) — never ask.
       Implement to the plan's acceptance criteria, applying the house convention skills; note every
       decision taken.
    5. **Build (zero warnings) and run the whole suite** where one exists, under the **3-cycle fix budget**
       (skill §6). Still red after the 3rd cycle → **quarantine** per §6, then continue the loop from the
       run branch.
    6. **Green:** statuses → `DONE` (the item's own row flips with its final phase); write
       `docs/done/<full ID>.md` (inherited shape + `## Decisions taken at build time`); run the
       **auto-applying documentation sweep** (§7).
    7. Stage explicitly (`git status --porcelain` first) and commit with the inherited message format
       (+ trailer).
    8. `git switch <run branch>` → `git merge --no-ff <dev branch>`.
    9. Print the multi-phase progress table (when applicable) and the commit title/description — **and do
       not pause**; go straight to the next dev.
  - **Phase 5: Resume state machine.** Used when Phase 2 resolved RESUME. On a dev branch, the run branch is
    read from the plan file's `**Run:**` marker.

    | On         | Tree  | Evidence                                   | Action |
    |------------|-------|--------------------------------------------|--------|
    | dev branch | dirty | —                                          | continue implementing that dev from the working tree (re-read the plan + `git diff`) → Phase 4 step 5 |
    | dev branch | clean | `docs/done/<full ID>.md` present in `HEAD` | the dev's commit exists → switch to the run branch, `merge --no-ff`, continue the loop |
    | dev branch | clean | no done doc, row `IN PROGRESS`             | nothing implemented yet → Phase 4 step 4 |
    | run branch | clean | a run item still has a `TODO` phase/item   | loop from Phase 4 step 1 (quarantined rows — `IN PROGRESS` + footnote — are skipped) |
    | run branch | clean | no run item has a `TODO` phase/item left   | the run is finished → print the end-of-run report (Phase 6) and stop |
    | run branch | dirty | —                                          | stop: `bulk: cannot start — the working tree has uncommitted changes. …` Never guess whose they are. |

  - **Phase 6: End of run.** Stay checked out on the run branch and print the **end-of-run report** in the
    skill's §11 format with `bulk run <run branch> — …` as its first line: the tally, the starting branch and
    commit, the per-dev table (Dev · Branch · Status · Commit), one line per quarantined dev with its reason,
    the `Skipped:` line (no-argument mode, when any), and the *Review* / *Finish* / *Merge* / *Clean up*
    recipe for the user. `QUARANTINED` appears in this report only — the roadmap keeps `IN PROGRESS` +
    footnote.
- `# Rules` — never ask, never pause (no `AskUserQuestion`, no `ExitPlanMode`, no "shall I continue?", no
  waiting for a commit); never push, never write to the starting or default branch, never a forbidden git
  operation (skill §5) — quarantine or stop instead of working around one; never the `Agent` or `Workflow`
  tools, nor any review/verify/adversarial agent; never a 4th fix cycle, never merge a red dev, never mark
  one `DONE`; **only unowned `TODO` rows are selectable** — never an `IN PROGRESS` row, never another run's
  items, never a phase ID; the plan is the contract, but a stale plan is adapted and recorded, not
  questioned; CRLF / line endings are recommendation-only; Senior Architect mode — the choice you would
  defend in review, not the fastest one to type.
- **Footer** — `# My Arguments:` + `$ARGUMENTS`, then the italic note: *(No argument = every unowned `TODO`
  row, or — on a `bulk/*` branch or one of its dev branches — resume that run. Never treat earlier
  conversation as a selection.)*

**Size guidance:** `bulk.md` ≈ 100–130 lines; skill v2 delta ≈ 25–35 changed/added lines. Reuse `/vibe`'s
wording wherever a step is identical; never restate `dev-workflow` or skill-side rules.

### Interactions with the existing commands (must hold after the build)

- `/vibe` v1 is unchanged and still consistent with skill v2: every generalized sentence reads correctly with
  `<command>` = `vibe`, and every `vibe: cannot start — …` message is still produced verbatim.
- `/vibe` with no argument on a `bulk/*` branch is **not** resumable (`vibe/*` only) → its own stop. `/bulk`
  with no argument on a `vibe/*` branch starts a **new run** over unowned `TODO` rows — the vibe run's own
  items carry its marker and are skipped.
- `/build` ignores `**Run:**` and can finish a quarantined `/bulk` dev: its row is `IN PROGRESS`
  (buildable), the plan file records the failure, and `/build`'s "branch already exists → stop and ask"
  guard fires, at which point the user switches to the existing dev branch by hand — as the report's
  *Finish* line documents.
- `/interview` (v10) never loads `vibe-workflow`; its closing hint (`/build <ID>` or `/bulk`) matches
  `/bulk`'s no-argument behaviour.
- The roadmap vocabulary is unchanged, so `/build`'s table printing and the whole-table reformat rule keep
  working on a bulk-touched roadmap.

---

## Steps (build order)

1. Edit `.claude/skills/vibe-workflow/SKILL.md` per *Design A* (edits 1–12).
2. Write `.claude/commands/bulk.md` per *Design B*.
3. Cross-check the two files against each other, against `vibe.md` and against `dev-workflow`: every rule the
   command relies on is defined skill-side and referenced by `§`; every `bulk:` message the command mentions
   exists in §10; the report fields match §11; the loop skeleton matches `vibe.md`'s Phase 5 step for step
   apart from the claim/plan difference.
4. Run the acceptance-criteria greps and the table pipe-offset check (below).
5. Update `docs/roadmap.md` (row → `DONE`, whole-table reformat) and this plan (`**Status:** DONE`); write
   `docs/done/FEATURE-75F7.md` with the dry-run recipe reproduced.

## Acceptance criteria

1. **Files exist with the house shapes.** `.claude/commands/bulk.md` has frontmatter `description`,
   `argument-hint`, `disable-model-invocation: true`, and its Phase 0 prints exactly
   `Using bulk v1 by Josué Clément`. `.claude/skills/vibe-workflow/SKILL.md` reads
   `**Version: vibe-workflow v2.**`, its `description` names both `/vibe` and `/bulk`, and
   `grep -rn "vibe-workflow v1" .claude/` returns nothing.
2. **No question path.** `grep -n "AskUserQuestion\|ExitPlanMode" .claude/commands/bulk.md .claude/skills/vibe-workflow/SKILL.md`
   returns only lines that forbid them.
3. **No delegation path.** Every mention of the `Agent` or `Workflow` **tools** in `bulk.md` is a prohibition
   (`Workflow` here means the tool, not the words `dev-workflow` / `vibe-workflow`).
4. **Selection rules are complete.** `bulk.md` states: explicit base IDs / all `TODO` rows; the exclusion of
   `IN PROGRESS`, `DONE`, `ABANDONED`, owned (marker) rows and missing plan files; the phase-ID stop; the
   printed selection table. Skill §10 carries the seven `bulk:` rows of Design A edit 8 (no roadmap · unknown
   ID · phase ID · not `TODO` · owned · plan file missing · nothing selectable), plus the no-argument note.
5. **Claim mechanics.** Skill §3 defines the `bulk/<yyyy-mm-dd>-<slug>` prefix and slug rule and the claim
   commit `docs(plan): claim …`; §9 defines the marker placement (after the header block) and who writes it;
   `bulk.md` Phase 3 performs claim → explicit staging → commit in that order.
6. **The loop is complete.** `bulk.md` contains Phases 0–6 as designed, the literal fix budget of **3**
   cycles, the quarantine by reference to §6, `--no-ff`, the six-row resume state machine (including the
   finished-run row), and the §11 report reference with the `bulk run` header and the `Skipped:` line.
7. **Nothing else changed.** `git diff HEAD --stat -- .claude/commands/interview.md .claude/commands/build.md .claude/commands/vibe.md .claude/skills/dev-workflow/SKILL.md`
   prints nothing (with `HEAD` = the tip that already contains FEATURE-3BF6).
8. **Skill rules unchanged.** Every hunk of `git diff HEAD -- .claude/skills/vibe-workflow/SKILL.md` maps to
   one of Design A's edits 1–12; §2, §5 (table), §6 (budget and the six quarantine steps), §7 and §8 differ
   only by the `<command>` substitution of edit 6.
9. **Roadmap/plan/done.** `FEATURE-75F7` reads `DONE` in `docs/roadmap.md` and in this file;
   `docs/done/FEATURE-75F7.md` exists with the inherited sections; a pipe-offset check over
   `docs/roadmap.md`'s table reports a single pipe layout.
10. **Well-formed markdown:** all fences closed, all tables rectangular, frontmatter parses, both files CRLF
    end to end.
11. **Nothing to build or test** in this repo — state so in the completion doc, and reproduce the *Dry run
    recipe* there.

## Dry run recipe (for the user, after the build)

1. Copy `bulk.md` (and `vibe.md`) to `~/.claude/commands/` and `vibe-workflow/` to `~/.claude/skills/` —
   or run from this repo, where they are picked up locally.
2. Create a throwaway repo with a small .NET class library + xUnit test project (or a markdown-only repo for
   the no-build path); commit once. Run `/interview` on a two-item spec (e.g. "add `Stack<T>` with tests"
   and "add `Queue<T>` with tests"); commit the printed `docs(roadmap): plan …`.
3. Start Claude Code in a **non-prompting permission mode** — not plan mode — and run `/bulk`. Expect: the
   announce line · the selection table · a `bulk/<date>-<slug>` branch whose first commit is
   `docs(plan): claim …` · one merged dev branch per dev · **no change on the starting branch**
   (`git log <start> -1` unchanged, `git status` clean there) · no push · the end-of-run report.
4. Explicit mode: plan a third item, then `/bulk <that ID>` → only that item is built.
5. Kill the session mid-dev on a larger batch, then `/bulk` with no argument from the `bulk/*` branch →
   the resume state machine picks up where it stopped.
6. Negative paths: `/bulk FEATURE-DEAD` (unknown ID), `/bulk <a DONE ID>` (not `TODO`),
   `/bulk <ID>-PHASE01` (phase ID) → each prints its §10 stop and writes nothing.

## Out of scope / recorded, not planned here

- **Per-phase selection** (`/bulk FEATURE-3A7F-PHASE02`) — a stop pointing at `/build`; would need a
  per-phase marker format.
- **Build-by-ID mode on `/vibe`** — `/bulk` is the answer; `/vibe`'s argument stays a spec draft.
- **Renaming `vibe-workflow`** (e.g. to `autonomous-workflow`) — churn across `vibe.md`; not worth it now.
- **Moving `/vibe`'s build loop and resume state machine into the skill** so both commands reference one copy
  — would touch `vibe.md` (v2); reconsider if the two skeletons drift (A9).
- **Adopting uncommitted planning files** or having `/interview` commit them — declined in the interview.
- **Deployment to `~/.claude/`**, a project `.claude/settings.json` allowlist, back-filling roadmap rows for
  untracked work, `.gitattributes` / CRLF normalization — unchanged from FEATURE-608E's list.
