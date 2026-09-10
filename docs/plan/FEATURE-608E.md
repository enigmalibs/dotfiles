# FEATURE-608E — `/vibe` autonomous coding workflow

**Status:** TODO
**Type:** FEATURE (single-phase)
**Branch (at build time):** `feature/feature-608e-vibe-workflow`, cut from current `HEAD`.

_Planned via `/interview` (v9); build with `/build FEATURE-608E`._

## Objective

Add an **autonomous "vibe coding" workflow** to the Claude Code toolkit in this repo: a `/vibe` command
that, from a single prompt, (1) runs the `/interview` questioning **answered by itself** with the options it
would have marked "(Recommended)", (2) auto-validates the resulting plan, (3) writes the roadmap rows and
plan files exactly as `/interview` would, and (4) builds every planned dev in sequence — branch, implement,
Definition of Done, completion doc, **commit**, merge — **without ever asking a question or waiting for a
confirmation**. A run stops only when its roadmap items are all `DONE` (or quarantined), or when the session
dies (token budget). Everything a run produces lives on branches the user reviews and reintegrates later;
the branch the user started from is never modified.

Two new prompt files deliver this:

- `.claude/skills/vibe-workflow/SKILL.md` (**v1**) — an *override skill* layered on the unchanged
  `dev-workflow` skill: it inherits the artifact standards and supersedes exactly the rules that block
  autonomy.
- `.claude/commands/vibe.md` (**v1**) — the command: pre-flight, self-interview, planning commit, build
  loop, end-of-run report, and resume.

## Context & constraints

- **Evolution of an existing repo:** `C:\Dev\EnigmaLibs\dotfiles`. Commands live in `.claude/commands/*.md`,
  skills in `.claude/skills/<name>/SKILL.md`. Claude Code prompt files only — **no build, no test suite**;
  Definition-of-Done criteria 1–2 are met by well-formed markdown verified by inspection (see *Acceptance
  criteria*). The **real dry run is the user's** (see *Dry run recipe*): `vibe.md` carries
  `disable-model-invocation: true`, so the builder cannot invoke it.
- **Files that must stay byte-identical to `HEAD`:** `.claude/commands/interview.md` (v9),
  `.claude/commands/build.md` (v6), `.claude/skills/dev-workflow/SKILL.md` (v5). The vibe skill *overrides*,
  it never edits.
- **Command-file shape to match** (`build.md`, `interview.md`): YAML frontmatter with `description`,
  `argument-hint`, `disable-model-invocation: true`; `# Role` / `# Context` / `# Process` (numbered
  `## Phase N:` sections, Phase 0 = announce line) / `# Rules`; the announce line
  `Using <command> vN by Josué Clément` printed first, as plain text, nothing before it.
- **Skill-file shape to match** (`dev-workflow/SKILL.md` and siblings): frontmatter `name` + `description`
  only; `# <Title>` heading; `**Version: <skill> vN.**` line; prose sections with `##`/`###` headings;
  fenced examples; a closing "if the codebase already enforces its own conventions, those take precedence"
  sentence. Sibling stack skills additionally end with a *Common mistakes* table and *Cross-references*.
- **Deployment to `~/.claude/commands` / `~/.claude/skills` is out of scope** — the copies there are plain
  files, not junctions (FEATURE-15CB precedent, decision 14); the user copies the two new files.
- **Operational prerequisite the command cannot control:** a no-questions run only works in a permission
  mode that does not prompt for `git commit` / file writes (auto or bypass mode, or an allowlist) and **not
  in plan mode**. `vibe.md` documents this in its `# Context` and stops in pre-flight if plan mode is active
  (see Phase 2 below).
- **Line endings:** every touched file is CRLF and internally consistent; nothing to fix. Recommendation
  only (not part of this item): a `.gitattributes` with `* text=auto eol=lf` would remove the churn risk.

## Decisions settled in the interview

| #  | Decision |
|----|---|
| 1  | **Override skill `vibe-workflow`** on top of an **unchanged** `dev-workflow`. The skill loads `dev-workflow`, then supersedes named sections; where the two disagree, `vibe-workflow` wins. Not a self-contained copy (twin-sync), not an edit to `dev-workflow`. |
| 2  | **Git topology:** run branch `vibe/<yyyy-mm-dd>-<slug>` cut from current `HEAD`; its **first commit is the planning commit** (roadmap rows + plan files — on the run branch, *not* on the starting branch, unlike `/interview`). Each dev gets its own `feature/…` / `bugfix/…` / `review/…` branch per `dev-workflow` naming, cut from the **run-branch tip**, committed, then merged back into the run branch with `--no-ff`. The starting branch and the default branch are never checked out for writing, never committed to. |
| 3  | **Full Definition of Done per dev:** 0-warning build, whole test suite, tests added for new behavior where a test project exists. Never introduce a test framework (or any infrastructure) the project lacks unless the prompt asks. |
| 4  | **Red-dev policy = quarantine and continue.** After the fix budget, the dev is committed on **its** branch and **not merged**; on the run branch its roadmap row is set to `IN PROGRESS` with a blockquote footnote (mirrored in the plan file); remaining phases of that item stay `TODO` and are skipped; the run continues with the next *independent* item from the run-branch tip. |
| 5  | **Build scope = only the items this run planned.** Every plan file the run writes carries a `**Run:** vibe/<yyyy-mm-dd>-<slug>` marker; "the run's items" are always derived from files, never from conversation memory. Pre-existing `TODO`/`IN PROGRESS` rows are left for `/build`. |
| 6  | **Resume is first-class:** `/vibe` with **no argument**, invoked on a `vibe/*` branch or on one of its dev branches, resumes the interrupted run (see *Resume state machine*). |
| 7  | **No sub-agents of any kind.** `Agent`, `Workflow`, and any review/verify/adversarial agent are forbidden; `dev-workflow`'s *Sub-Agent Delegation* section is superseded entirely. Exploration happens in the main context. |
| 8  | **Never push.** `push` is a forbidden operation; the end-of-run report prints the push/merge recipe for the user. |
| 9  | **Name `/vibe`:** `.claude/commands/vibe.md`, `.claude/skills/vibe-workflow/SKILL.md`, announce line `Using vibe v1 by Josué Clément`. |
| 10 | **Documentation freshness sweep auto-applies** edits, limited to sections the dev's diff made factually wrong (no rewrites), in the dev's commit, listed in the completion doc. |
| 11 | **Fix budget = 3 build+test cycles** per dev. A cycle is one full build (and suite run) after a fix attempt. |
| 12 | **End of run:** leave the user **checked out on the run branch** and print the *End-of-run report*. |

## Defaults applied without asking (low impact)

| #   | Default |
|-----|---|
| D1  | **Self-interview audit trail.** The command generates the same question set `/interview` would (high → medium → detail impact, plus the beyond-the-draft sweep), answers each with its recommended option, and records every decision in the plan file under `## Decisions taken autonomously` (columns: *Question · Chosen · Why · Alternatives rejected*). The Phase-3-style summary is also printed to the console once, before building. |
| D2  | **Scope bias of the self-interview:** "what a senior dev would recommend" — no gold-plating, no narrowest reading. No new infrastructure (test framework, CI, dependencies, tooling) unless the prompt asks. |
| D3  | **Pre-flight stops before anything is written:** no git repo · plan mode active · dirty tree (`git status --porcelain` non-empty) · run-branch name collision · empty argument with no resumable run. Print the reason and stop. A startup refusal is not a question. |
| D4  | **Forbidden git operations** (see the skill's table): `push`, any write to the starting branch or the default branch, `reset --hard`, `restore`/`checkout --` on files the run did not create, `clean`, `rebase`, `--force`/`-f`, `branch -D/-d`, `stash`, `tag`, `remote`, `config`. Allowed: `switch -c`, `switch` between the run's own branches, `add <paths>`, `commit`, `merge --no-ff`, and every read-only command. |
| D5  | **Commits** end with the `Co-Authored-By` attribution trailer when the session provides one, so vibe commits are distinguishable from the user's. |
| D6  | **Files are the source of truth between devs:** after each dev the command re-reads `docs/roadmap.md` and the plan files from disk instead of relying on conversation memory (survives context summarization). |
| D7  | **Item types as in `/interview`:** a pasted code-review draft becomes a `CODE-REVIEW-HHHH` item (findings as severity-ordered phases, `review/` branches); otherwise `FEATURE`/`BUG` by content. No confirmation step. |
| D8  | **Missing `docs/` structure** in a target project is created per `dev-workflow` — on the run branch, inside the planning commit. |
| D9  | **Run slug:** ≤ 4 kebab-case words derived from the prompt; the date prefix keeps names unique across runs. |
| D10 | **Staging discipline:** stage the dev's files explicitly (`git add <paths>`) after reviewing `git status --porcelain`; never stage build outputs, IDE files, or files unrelated to the dev — an un-ignored `bin/`/`obj/` is recorded as a follow-up, not committed. |
| D11 | **Quarantined devs write no `docs/done/` file** (they are not done); their failure state is recorded in the plan file's item/phase section and in the roadmap footnote. |

---

## Design

### A. `.claude/skills/vibe-workflow/SKILL.md` — v1

**Frontmatter**

```yaml
---
name: vibe-workflow
description: Use when running the autonomous /vibe workflow — the override layer on top of dev-workflow that lets a run decide instead of ask, commit and merge its own devs on a vibe/<date>-<slug> run branch, bound fix attempts, quarantine red devs, resume after a session dies, and forbid pushes, sub-agents, and any write to the starting branch. Loaded by /vibe only — never by /interview or /build.
---
```

**Body — sections in this order.** Keep every rule terse; this file is read on every `/vibe` run alongside
`dev-workflow`, so it must not restate what it inherits.

1. **Title + version + relationship.** `# Vibe workflow — autonomy overrides on top of dev-workflow`, then
   `**Version: vibe-workflow v1.**`. One paragraph: *Load `dev-workflow` first. Everything it defines
   applies unless a section below supersedes it. Where the two disagree, this skill wins.* Then two
   explicit lists, using `dev-workflow`'s **exact heading names**:
   - **Inherited unchanged:** *Planning & Documentation* (documentation structure, work-item identifiers,
     `roadmap.md` formatting and ordering, plan files, completion docs, abandoning), *Definition of Done*,
     *Multi-phase progress reporting*, *Line endings (CRLF)*, and the commit-message formats of
     *Version Control*.
   - **Superseded (by the sections below):** *Asking questions (both flows)* → §2; the branch-topology,
     "never commit", "stop and ask", and "between devs, pause" rules of *Version Control* → §3–§4; *Two
     flows*' "planning artifacts on your current branch/`HEAD`" → §3; *Documentation freshness sweep
     (build flow)* → §7; *Sub-Agent Delegation* → §8.
2. **Decide, don't ask** (supersedes *Asking questions*). Never call `AskUserQuestion` or `ExitPlanMode`,
   never print a question and wait, never pause for a commit. Every decision is taken by choosing the option
   you would have listed first with "(Recommended)" in an interview, with the same trade-off reasoning
   (grounded in the prompt, the codebase, and the applicable convention skills). **Record every decision:**
   planning decisions in the plan file under `## Decisions taken autonomously`; decisions taken while
   building in the completion doc under `## Decisions taken at build time`. A plan that turns out stale or
   inconsistent at build time is **adapted, not questioned** — the deviation goes in the completion doc.
   Scope bias per D2. **Refusal ≠ question:** a pre-flight failure (§10) stops the run *before it starts*
   and is the only permitted stop other than completion.
3. **Run topology** (supersedes the branching rules of *Version Control* and *Two flows*).
   - The **run branch** `vibe/<yyyy-mm-dd>-<slug>` is cut from the current `HEAD` (detached is fine; never
     switch to the default branch). Slug per D9. Date via `date +%Y-%m-%d`.
   - **Planning artifacts go on the run branch**, not on the starting `HEAD`: the run's first commit is the
     planning commit (`docs(roadmap): plan <ID>[, <ID>…]`, the `dev-workflow` planning-commit format).
   - **Each dev branch** is named per `dev-workflow` (`feature/feature-3a7f-phase01-<slug>` etc.) and is
     **cut from the run-branch tip**, never from another dev branch. Its first change flips the item/phase
     to `IN PROGRESS` (inherited). When the dev is done and committed, switch to the run branch and
     `git merge --no-ff <dev-branch>` (git's default merge message). Then cut the next dev branch from the
     new tip.
   - The **starting branch/commit and the repository's default branch are never written to**: no
     checkout for editing, no commit, no merge into them. Everything the run produces is reachable from the
     run branch or from an unmerged (quarantined) dev branch.
   - Diagram (fenced, plain text) showing: starting HEAD → run branch with planning commit → dev branch
     merged back → second dev branch merged → a quarantined dev branch left unmerged.
4. **Commits are yours** (supersedes "never commit yourself" and "between devs, pause"). The run commits
   after every dev (one commit per dev, inherited message format: `feat(FEATURE-3A7F): … (PHASE01)`,
   `fix(BUG-…)`, `fix(CODE-REVIEW-…)`; scope is always the base ID), after planning (`docs(roadmap): …`),
   and when quarantining (§6). Append the session's `Co-Authored-By` trailer when one is provided (D5).
   Staging discipline per D10. **Never pause between devs** — print the progress table and the commit
   summary, then continue.
5. **Allowed / forbidden git operations** — a two-column table per D4, plus the sentence: *If a step would
   require a forbidden operation, do not find a workaround — quarantine the dev (§6) or stop the run (§10)
   and say why.*
6. **Quality gate, fix budget, quarantine** (extends *Definition of Done*, inherited 1–5).
   - **Fix budget:** at most **3 cycles** per dev; a cycle = one fix attempt followed by a full build (0
     warnings) and, where a suite exists, the whole test suite. The first build/test run before any fix is
     not a cycle.
   - **Quarantine procedure** when the 3rd cycle is still red: (a) on the dev branch, record in the plan
     file's item/phase section `**Status:** IN PROGRESS — quarantined by <run branch>: <one-line reason>`
     plus the failing build errors / test names and what was tried; (b) commit on the dev branch with the
     normal message and the title suffix ` — QUARANTINED`; (c) switch to the run branch **without merging**;
     (d) set the row to `IN PROGRESS` (whole-table reformat, inherited) and add the footnote
     `> \`<full ID>\` quarantined by \`/vibe\` run \`<run branch>\` — <reason>; branch \`<dev branch>\` unmerged. Finish with \`/build <base ID>\`.`;
     (e) commit `docs(roadmap): quarantine <full ID>`; (f) skip every remaining phase of that item (they
     stay `TODO`); continue with the next run item.
   - **No `docs/done/` file for a quarantined dev** (D11).
   - Never merge a red dev; never mark it `DONE`.
7. **Documentation freshness sweep — apply, don't ask** (supersedes *Documentation freshness sweep*).
   Same scan set (README, CLAUDE.md/agent files, other prose docs; exclude roadmap/plan/done and prompt
   files). Edit only sections the dev's diff made factually wrong; no rewrites, no new docs. List each edit
   in the completion doc. Non-blocking; lands in the dev's commit.
8. **No delegation, no workflows** (supersedes *Sub-Agent Delegation*). Never use `Agent` (any subagent
   type, including read-only exploration), `Workflow`, or any review/verify/adversarial agent. Explore and
   implement in the main context.
9. **State lives in files.** Before each dev, re-read `docs/roadmap.md` and the target plan file from disk
   (D6). Every plan file the run writes carries `**Run:** <run branch>` directly under `**Branch:**`; the
   run's items are exactly the plan files carrying its marker. Resume rules are in `/vibe` itself; the
   skill only fixes the marker format.
10. **Pre-flight stops** (D3): the enumerated list, each with the exact message shape *"vibe: cannot start —
    <reason>. <what the user should do>."* Nothing is written before pre-flight passes.
11. **End-of-run report** — the template (see Phase 6 of the command); the skill owns the format, the
    command prints it.
12. **Common mistakes** table (≤ 8 rows), e.g.: asking "shall I continue?" · committing on the starting
    branch · cutting a dev branch from another dev branch · merging a red dev · a 4th fix cycle ·
    `git add -A` sweeping `bin/` · pushing · writing `docs/done/` for a quarantined dev.
13. **Cross-references** (`dev-workflow` for everything inherited; stack skills as the self-interview
    loads them) and the closing sentence: *If the target project already enforces its own conventions
    (roadmap, IDs, branch naming), those take precedence — apply them and record the choice.*

### B. `.claude/commands/vibe.md` — v1

**Frontmatter**

```yaml
---
description: Autonomous "vibe coding" run — from a spec prompt, self-answers the /interview questions with the recommended options, writes the roadmap rows + plan files, then builds every planned dev on a vibe/<date>-<slug> run branch (branch, implement, DoD, commit, merge) without asking anything. No argument = resume the run of the current vibe branch. Never touches the branch you started from; never pushes.
argument-hint: [<spec draft text> | (nothing = resume the current run)]
disable-model-invocation: true
---
```

**Body**

- `# Role` — Senior Developer + Solutions Architect who both plans and builds, unattended, and answers the
  customer's questions on the customer's behalf with the choices they would have recommended.
- `# Context` — what the run produces, where it lives (run branch), the guarantee (starting branch never
  modified, nothing pushed), the two stop conditions, and the **operational prerequisite**: a permission
  mode that does not prompt (auto/bypass or allowlist) and not plan mode.
- `# Process`
  - **Phase 0: Announce the version** — exactly `Using vibe v1 by Josué Clément`, first, plain text.
  - **Phase 1: Load the standards** — load `dev-workflow`, then `vibe-workflow` (precedence stated), then
    any stack/convention skills the target codebase calls for (same rule as `/interview` Phase 1 step 5b).
  - **Phase 2: Pre-flight and mode resolution.** Read-only git checks first: repo present;
    `git status --porcelain` empty; current branch/`HEAD`; default branch name. Detect plan mode → stop.
    Then:
    - argument present → **NEW RUN** (Phase 3). The run branch is cut from the current `HEAD` whatever it is
      (even another `vibe/*` branch — the user chose to stand there). If `vibe/<date>-<slug>` already exists
      → stop (collision).
    - no argument → **RESUME** (Phase 5 via the *Resume state machine*): resumable only when the current
      branch is `vibe/*` or a dev branch whose roadmap row is `IN PROGRESS` and whose plan file carries a
      `**Run:**` marker naming an existing `vibe/*` branch. Otherwise → stop
      ("vibe: nothing to resume here — pass a spec to start a run").
    - Every stop prints the exact `vibe: cannot start — …` message from the skill and ends the turn.
  - **Phase 3: Self-interview (new run).** Reuse `/interview`'s Phase 1 in spirit: read the draft; detect
    code-review input (D7); explore the codebase before deciding (build files, manifests, DI, test
    framework, conventions, touched modules); load convention skills; beyond-the-draft checklist (the same
    13 dimensions as `/interview`). Then **generate the questions `/interview` would ask**, in the same
    order (highest impact → medium → detail), **answer each with the option you would have marked
    "(Recommended)"**, with its rationale. Produce the item breakdown: type, title (≤ 40 chars), single- vs
    multi-phase with phase titles, branch names — **size heuristic:** one dev = one reviewable commit
    (roughly ≤ 30 minutes of human review); prefer more, smaller phases over one big dev. Allocate IDs per
    `dev-workflow` (shell entropy, collision check). **Print the Phase-3-style summary once** (objective,
    context, decisions table, house conventions applied, beyond-the-draft table, breakdown) — no
    confirmation step; it exists for the transcript.
  - **Phase 4: Plan and commit (new run).** `git switch -c vibe/<date>-<slug>`. Create `docs/` structure if
    missing (D8). Write roadmap rows (`TODO`, whole-table reformat) and one plan file per item in the house
    shape (`**Status:**`, `**Type:**`, `**Branch:**`, **`**Run:**`**, objective, context, decisions,
    per-phase sections with steps and acceptance criteria, out of scope) plus
    `## Decisions taken autonomously` (D1). Stage those files explicitly; commit `docs(roadmap): plan <IDs>`
    (+ trailer).
  - **Phase 5: Build loop.** `while` the roadmap (re-read from disk) has a run item — plan file carrying
    this run's marker — with a `TODO` phase/item that is not blocked by a quarantined sibling phase:
    1. Resolve the next dev: topmost run item in table order, its first `TODO` phase (or the item itself).
    2. On the run branch, clean tree: `git switch -c <dev branch>` per `dev-workflow` naming.
    3. Flip the row/phase and plan status to `IN PROGRESS` (reformat table).
    4. Implement to the plan's acceptance criteria with the house convention skills. Any decision → note
       for the completion doc.
    5. Build (0 warnings) and run the whole suite where one exists; apply the **3-cycle fix budget**. Red
       after the budget → **quarantine** per the skill §6, then `continue` the loop from the run branch.
    6. Green: statuses → `DONE` (item row flips `DONE` with its final phase); write `docs/done/<full ID>.md`
       (inherited shape + `## Decisions taken at build time`); run the **auto-apply doc sweep**.
    7. Stage explicitly, commit with the inherited message format (+ trailer).
    8. `git switch <run branch>` → `git merge --no-ff <dev branch>`.
    9. Print the multi-phase progress table (if applicable) and the commit title/description; **do not
       pause**.
  - **Phase 6: End of run.** Stay on the run branch. Print the report (skill §11 template):

    ```
    vibe run vibe/2026-09-10-user-auth — 3 devs done, 1 quarantined
    Started from: master @ edb28ad

    | Dev                  | Branch                             | Status      | Commit  |
    |----------------------|------------------------------------|-------------|---------|
    | FEATURE-3A7F-PHASE01 | feature/feature-3a7f-phase01-login | DONE        | a1b2c3d |
    | FEATURE-3A7F-PHASE02 | feature/feature-3a7f-phase02-oauth | QUARANTINED | d4e5f6a |
    | FEATURE-3A7F-PHASE03 | —                                  | TODO        | —       |
    | BUG-9C2E             | bugfix/bug-9c2e-token-refresh      | DONE        | b7c8d9e |

    Quarantined: FEATURE-3A7F-PHASE02 — 2 tests still failing after 3 cycles (OAuthTests.Refresh_*).

    Review:   git log --first-parent master..vibe/2026-09-10-user-auth
              git diff master...vibe/2026-09-10-user-auth
    Finish:   /build FEATURE-3A7F           (continues PHASE02 on its existing branch)
    Merge:    git switch master && git merge --no-ff vibe/2026-09-10-user-auth
    Clean up: git branch -d feature/feature-3a7f-phase01-login bugfix/bug-9c2e-token-refresh
    ```

    (Table padded per the inherited formatting rule. `QUARANTINED` appears only in this console report —
    the roadmap keeps the inherited vocabulary, `IN PROGRESS` + footnote.)
  - **Resume state machine** (a `##` subsection under Phase 5, used when Phase 2 resolved RESUME):

    | On         | Tree  | Evidence                                    | Action |
    |------------|-------|---------------------------------------------|---|
    | dev branch | dirty | —                                           | continue implementing that dev from the working tree (re-read plan + `git diff`) → loop step 5 |
    | dev branch | clean | `docs/done/<full ID>.md` present in `HEAD`  | commit exists → switch to the run branch, merge `--no-ff`, continue the loop |
    | dev branch | clean | no done doc, row `IN PROGRESS`              | nothing implemented yet → loop step 4 |
    | run branch | clean | —                                           | loop from step 1 (quarantined rows — `IN PROGRESS` + footnote — are skipped) |
    | run branch | dirty | —                                           | stop: `vibe: cannot start — run branch has uncommitted changes` (never guess whose they are) |

    The run branch is read from the plan file's `**Run:**` marker when on a dev branch.
- `# Rules` — never ask, never pause, never push, never touch the starting/default branch, never use
  agents/workflows, never a 4th cycle, never merge red, never `DONE` with red, CRLF recommendation-only,
  the plan is the contract but a stale plan is adapted and recorded rather than questioned, and everything
  the skill forbids.

**Size guidance:** skill ≈ 150–200 lines, command ≈ 120–160 lines. Reuse `/interview`'s and `/build`'s
wording where a step is identical; never restate `dev-workflow` content.

### Interactions with the existing commands (must hold after the build)

- `/interview` and `/build` never load `vibe-workflow` (its description says so; nothing in them references
  it).
- `/build` can finish a quarantined dev: its row is `IN PROGRESS` (buildable), its plan file records the
  failure, and `/build`'s own "branch already exists → stop and ask" guard fires, at which point the user
  switches to the existing dev branch by hand — acceptable and documented in the report's *Finish* line.
- The roadmap vocabulary is unchanged, so `/build`'s table printing and the whole-table reformat rule keep
  working on a vibe-written roadmap.

---

## Steps (build order)

1. Write `.claude/skills/vibe-workflow/SKILL.md` per *Design A* (sections 1–13, in order).
2. Write `.claude/commands/vibe.md` per *Design B*.
3. Cross-check the two files against each other and against `dev-workflow`: every superseded section is
   named by its exact heading; every rule the command relies on (fix budget, quarantine steps, report
   template, marker format, pre-flight messages) is defined in exactly one of the two files.
4. Run the acceptance-criteria greps and the table pipe-offset check (below).
5. Update `docs/roadmap.md` (row → `DONE`) and this plan (`**Status:** DONE`); write
   `docs/done/FEATURE-608E.md`.

## Acceptance criteria

1. **Files exist with the house shapes.** `.claude/skills/vibe-workflow/SKILL.md` has frontmatter
   `name: vibe-workflow` + `description`, a `# ` title, and the line `**Version: vibe-workflow v1.**`.
   `.claude/commands/vibe.md` has frontmatter `description`, `argument-hint`,
   `disable-model-invocation: true`, and its Phase 0 prints exactly `Using vibe v1 by Josué Clément`.
2. **No question path.** `grep -n "AskUserQuestion\|ExitPlanMode" .claude/skills/vibe-workflow/SKILL.md .claude/commands/vibe.md`
   returns only lines that forbid them (every hit sits in a "never"/"forbidden" sentence).
3. **No delegation path.** Every mention of the `Agent` or `Workflow` **tools** in the two files is a
   prohibition (`Workflow` here means the tool, not the words `dev-workflow` / `vibe-workflow`).
4. **Precedence is explicit.** The skill contains the sentence *where the two disagree, this skill wins*
   (or equivalent) and names each superseded `dev-workflow` section by its exact heading: *Asking questions
   (both flows)*, *Version Control*, *Two flows*, *Documentation freshness sweep (build flow)*, *Sub-Agent
   Delegation*.
5. **Safety rails are enumerated.** The skill's allowed/forbidden table lists at least: `push`, writes to
   the starting and default branches, `reset --hard`, `rebase`, `--force`, branch deletion, `clean`,
   `stash`. The command's `# Context` states the permission-mode prerequisite and the no-plan-mode rule.
6. **The loop is complete.** The command contains Phases 0–6 as designed, the five pre-flight stops (D3),
   the resume state machine with its five rows, the quarantine procedure (or a reference to skill §6),
   the literal fix budget of **3** cycles, `--no-ff`, the `**Run:**` marker, and the end-of-run report
   template.
7. **Nothing else changed.** `git diff HEAD --stat -- .claude/commands/interview.md .claude/commands/build.md .claude/skills/dev-workflow/SKILL.md`
   prints nothing; no other skill is touched.
8. **Roadmap/plan/done.** `FEATURE-608E` reads `DONE` in `docs/roadmap.md` and in this file;
   `docs/done/FEATURE-608E.md` exists with the inherited sections; a pipe-offset check over
   `docs/roadmap.md`'s table reports a single pipe layout (as done for FEATURE-2059).
9. **Well-formed markdown:** all fences closed, all tables rectangular, frontmatter parses.
10. **Nothing to build or test** in this repo — state so in the completion doc, and reproduce the *Dry run
    recipe* there for the user.

## Dry run recipe (for the user, after the build)

1. Copy `vibe.md` to `~/.claude/commands/` and `vibe-workflow/` to `~/.claude/skills/` (or run from this
   repo, where they are picked up locally).
2. Create a throwaway repo: `git init` a folder with a tiny .NET class library + xUnit test project (or a
   markdown-only repo to exercise the no-build path), commit once.
3. Start Claude Code in a **non-prompting permission mode** (not plan mode) and run, for example:
   `/vibe Add a Stack<T> with Push/Pop/Peek and full unit tests`.
4. Expect: the announce line, the printed self-interview summary, a `vibe/<date>-<slug>` branch with a
   `docs(roadmap): plan …` first commit, one merged dev branch per planned dev, no change on the starting
   branch (`git log <start> -1` unchanged, `git status` clean there), no push, and the end-of-run report.
5. Kill the session mid-dev on a second, larger prompt and re-run `/vibe` with no argument to exercise
   resume.

## Out of scope / recorded, not planned here

- **Deployment to `~/.claude/`** — the user copies the files (FEATURE-15CB precedent).
- **Build-by-ID mode** (`/vibe FEATURE-003` building an already-planned item autonomously) — considered,
  not chosen; a natural follow-up if the loop proves itself.
- **Remote backup** (pushing the run branch) — declined; the run never pushes.
- **A project `.claude/settings.json` allowlist** so `/vibe` runs without prompts in default mode — the
  prerequisite is documented, not automated.
- **Back-filling roadmap rows** for untracked skill work (from FEATURE-2059's follow-ups) — separate
  decision.
- **`.gitattributes` / CRLF normalization** — recommendation only.
