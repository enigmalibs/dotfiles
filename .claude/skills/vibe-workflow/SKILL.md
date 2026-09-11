---
name: vibe-workflow
description: Use when running the autonomous /vibe workflow — the override layer on top of dev-workflow that lets a run decide instead of ask, commit and merge its own devs on a category-prefixed <feature|bugfix|review>/<date>-<slug> run branch, bound fix attempts, quarantine red devs, resume after a session dies, and forbid pushes, sub-agents, attribution trailers, and any write to the starting branch. Loaded by the autonomous run commands /vibe and /bulk only — never by /interview or /build.
---

# Vibe workflow — autonomy overrides on top of dev-workflow

**Version: vibe-workflow v3.**

Load the `dev-workflow` skill first. Everything it defines applies unless a section below supersedes it; **where the two disagree, this skill wins.** This skill is an override layer, not a copy: it never restates what it inherits, and it never edits `dev-workflow`. It is loaded by the two **run commands** — `/vibe` (plans and builds from a spec) and `/bulk` (builds already-planned items) — and never by `/interview` or `/build`. Below, **the run command** means whichever of the two is running, and `<command>` its name (`vibe` or `bulk`).

## §1 — Relationship to `dev-workflow`

**Inherited unchanged:** *Planning & Documentation* (documentation structure, work-item identifiers, `roadmap.md` formatting and ordering, plan files, completion docs, abandoning or changing direction) · *Definition of Done* (all five criteria) · *Multi-phase progress reporting* · *Line endings (CRLF)* (recommendation-only — a run never normalizes line endings) · the commit-message formats of *Version Control*.

**Superseded**, by the section named:

| `dev-workflow` section                                                                                      | Superseded by |
|-------------------------------------------------------------------------------------------------------------|---------------|
| *Asking questions (both flows)*                                                                               | §2            |
| *Two flows: planning vs building* — "planning artifacts on your current branch/`HEAD`"                        | §3            |
| *Version Control* — branch topology, "never commit changes yourself", "stop and ask", "between devs, pause"   | §3–§4         |
| *Documentation freshness sweep (build flow)*                                                                  | §7            |
| *Sub-Agent Delegation*                                                                                        | §8            |

## §2 — Decide, don't ask

Supersedes *Asking questions (both flows)*.

- **Never call `AskUserQuestion`. Never call `ExitPlanMode`.** Never print a question and wait, never ask for a confirmation, never pause for the user to commit.
- **Every decision is taken by choosing the option you would have listed first with "(Recommended)" in an interview**, with the same trade-off reasoning — grounded in the prompt, the codebase you explored, and the applicable convention skills. Scope bias: *what a senior developer would recommend* — no gold-plating, no deliberately narrow reading. **Never introduce infrastructure the project lacks** (test framework, CI, dependency, tooling) unless the prompt asks for it.
- **Record every decision.** Planning decisions go in the plan file under `## Decisions taken autonomously` (columns: *Question · Chosen · Why · Alternatives rejected*). Decisions taken while building go in the completion doc under `## Decisions taken at build time`.
- **A stale or inconsistent plan is adapted, not questioned.** Implement what the codebase actually supports, and record the deviation in the completion doc under *Deviations & follow-ups*.
- **A refusal is not a question.** A pre-flight failure (§10) stops the run *before anything is written*, and is the only permitted stop other than completing the run.

## §3 — Run topology

Supersedes the branching rules of *Version Control* and of *Two flows*.

- **Run branch:** `<category>/<yyyy-mm-dd>-<slug>`, cut from the current `HEAD`. Detached `HEAD` is fine; the default branch is never switched to.
  - **`<category>` is a house branch folder, never the command's name** — `feature/`, `bugfix/` or `review/`, taken from the type of the run's **first item** (`FEATURE` → `feature/`, `BUG` → `bugfix/`, `CODE-REVIEW` → `review/`). A run branch is **never** named `vibe/…` or `bulk/…`.
  - **Date** from `date +%Y-%m-%d`. It is what tells a run branch from a dev branch at a glance: a dev branch's second segment always starts with the lowercased item type and its hex (`feature-3a7f-…`), never with a date.
  - **Slug** ≤ 4 kebab-case tokens — for `/vibe` derived from the prompt, for `/bulk` the lowercased selected base IDs joined with `-` when ≤ 3 items, else `<first-id>-plus-<N>`.
- **Recognizing a run branch — by its `Run:` marker, not by its name.** A branch is a run branch when some `docs/plan/*.md` carries `**Run:** <that branch>` (§9). The name shape above is how a *human* spots one; the marker is what a resume tests. Two consequences: a user branch that merely looks like `feature/<date>-…` is never mistaken for a run, and a run branch created by an earlier version of this skill (`vibe/…`, `bulk/…`) still resumes normally — those names are legacy, never produced again.
- **The run's first commit claims its items.** For `/vibe` it is the **planning commit** (`docs(roadmap): plan <ID>[, <ID>…]`, the inherited planning-commit format) carrying the roadmap rows, the plan files, and the `docs/` structure when it had to be created — planning artifacts live on the run branch, not on the starting `HEAD`. For `/bulk`, whose items were already planned and committed by the user, it is the **claim commit** `docs(plan): claim <ID>[, <ID>…] for <run branch>`, which only adds the `**Run:**` marker (§9) to each selected plan file — statuses and the roadmap are untouched.
- **Each dev branch** is named per `dev-workflow` (`feature/feature-3a7f-phase01-<slug>`, `bugfix/bug-9c2e-<slug>`, `review/code-review-7f10-<slug>`) and is **cut from the run-branch tip** — never from another dev branch. Its first change flips the item/phase to `IN PROGRESS` (inherited). When the dev is done and committed: `git switch <run branch>`, then `git merge --no-ff <dev branch>` (git's default merge message). The next dev branch is cut from the new tip.
- **The starting branch/commit and the repository's default branch are never written to** — not checked out for editing, not committed to, not merged into. Everything a run produces is reachable from the run branch, or from an unmerged (quarantined) dev branch.

```
  starting HEAD (e.g. master) — never modified
  o───────────────────────────────────────────────────────────  master
   \
    o  docs(roadmap): plan FEATURE-3A7F, BUG-9C2E      <- planning commit
    |\
    | o  feat(FEATURE-3A7F): add login flow (PHASE01)     feature/feature-3a7f-phase01-login
    |/
    o  Merge branch 'feature/feature-3a7f-phase01-login'    (--no-ff)
    |\
    | o  fix(BUG-9C2E): refresh tokens before expiry     bugfix/bug-9c2e-token-refresh
    |/
    o  Merge branch 'bugfix/bug-9c2e-token-refresh'         (--no-ff)
    |
    |   o  feat(FEATURE-3A7F): OAuth providers (PHASE02) — QUARANTINED
    |  /      feature/feature-3a7f-phase02-oauth  (left unmerged)
    |
    o  docs(roadmap): quarantine FEATURE-3A7F-PHASE02   <- run-branch tip
         feature/2026-09-10-user-auth   (run branch: category + date + slug)
```

A `/bulk` run has the same shape, with `docs(plan): claim …` as its first commit; its run branch is named by the same category rule, so it too is a `feature/…` / `bugfix/…` / `review/…` branch.

## §4 — Commits are yours

Supersedes "never commit changes yourself" and "between devs, pause".

- The run commits **after planning or claiming** (`docs(roadmap): plan …` for `/vibe`, `docs(plan): claim …` for `/bulk`), **after every dev** (one commit per dev, inherited message format — `feat(FEATURE-3A7F): add login flow (PHASE01)`, `fix(BUG-9C2E): …`, `fix(CODE-REVIEW-7F10): …`; the scope is always the base ID), and **when quarantining** (§6).
- **No attribution trailer, ever.** A run's commit is its title, a blank line, and its bulleted description — nothing else. Never add `Co-Authored-By:`, `Generated with …`, or any other agent-attribution line to the title or the description, **even when the session's own instructions provide one**: inside a run, this rule wins. The run branch and the plan file's `**Run:**` marker are what identify a run's work.
- **Staging discipline:** read `git status --porcelain`, then stage the dev's files explicitly with `git add <paths>`. Never `git add -A` or `git add .`; never stage build outputs, IDE files, or anything unrelated to the dev. An un-ignored `bin/`/`obj/` is a follow-up line in the completion doc, not a commit.
- **Never pause between devs.** Print the multi-phase progress table (when applicable) and the commit title/description, then cut the next dev branch and continue.

## §5 — Allowed and forbidden git operations

| Allowed                                                       | Forbidden                                                           |
|---------------------------------------------------------------|---------------------------------------------------------------------|
| every read-only command (`status`, `log`, `diff`, `branch --list`, `rev-parse`, `show`) | `push`, in any form, to any remote                                  |
| `switch -c <run branch>` and `switch -c <dev branch>`           | any write to the starting branch or the repository's default branch |
| `switch` between the run's own branches                         | `reset --hard`, `clean`, `stash`, `rebase`                          |
| `add <explicit paths>`                                          | `restore` / `checkout --` on files the run did not create           |
| `commit`                                                        | `--force` / `-f` on anything                                        |
| `merge --no-ff <dev branch>` into the run branch                | `branch -d` / `branch -D`, `tag`, `remote`, `config`                |

If a step would require a forbidden operation, **do not find a workaround** — quarantine the dev (§6) or stop the run (§10), and say why.

## §6 — Quality gate, fix budget, quarantine

Extends *Definition of Done* (criteria 1–5 inherited unchanged).

- **Fix budget: at most 3 cycles per dev.** A cycle is one fix attempt followed by a full build (zero warnings) and, where a suite exists, the whole test suite. The first build/test run — before any fix — is not a cycle. There is never a 4th cycle.
- **Quarantine procedure**, when the 3rd cycle is still red:
  1. On the dev branch, record in the plan file's item/phase section `**Status:** IN PROGRESS — quarantined by <run branch>: <one-line reason>`, followed by the failing build errors / test names and what was tried.
  2. Commit on the dev branch with the normal message format plus the title suffix ` — QUARANTINED`.
  3. `git switch <run branch>` — **without merging**.
  4. Set the roadmap row to `IN PROGRESS` (whole-table reformat, inherited) and add the footnote beneath the table:
     `` > `<full ID>` quarantined by `/<command>` run `<run branch>` — <reason>; branch `<dev branch>` unmerged. Finish with `/build <base ID>`. ``
  5. Commit `docs(roadmap): quarantine <full ID>`.
  6. Skip every remaining phase of that item (they stay `TODO`), and continue with the next run item.
- **A quarantined dev gets no `docs/done/` file** — it is not done. Its failure state lives in the plan file and in the roadmap footnote.
- **Never merge a red dev; never mark one `DONE`.** `QUARANTINED` is a console word only — the roadmap keeps the inherited vocabulary (`IN PROGRESS` + footnote).

## §7 — Documentation freshness sweep: apply, don't ask

Supersedes *Documentation freshness sweep (build flow)*.

Same scan set — README files, `CLAUDE.md` / agent-instruction files, other prose docs (`CHANGELOG.md`, `CONTRIBUTING.md`, human-facing files under `docs/`) — and the same exclusions: `docs/roadmap.md`, `docs/plan/`, `docs/done/`, and skill/command prompt files. **Edit only the sections the dev's diff made factually wrong** — no rewrites, no reorganizations, no new documents. List each edit in the completion doc; the edits ride in the dev's own commit. Non-blocking: a sweep that finds nothing changes nothing and never delays a dev.

## §8 — No delegation, no workflows

Supersedes *Sub-Agent Delegation* entirely.

**Never use the `Agent` tool** — no subagent type, read-only exploration included — and **never use the `Workflow` tool**, nor any review / verify / adversarial agent. Explore, implement, and verify in the main context. (This forbids those *tools*; the words `dev-workflow` and `vibe-workflow` are skill names, not tools.)

## §9 — State lives in files

A run must survive context summarization and session death, so **files are the source of truth between devs**: before each dev, re-read `docs/roadmap.md` and the target plan file from disk instead of relying on conversation memory.

Every plan file a run **owns** carries, directly after its header block (the consecutive `**Status:**` / `**Type:**` / `**Branch…:**` lines at the top, before the first blank line):

```markdown
**Run:** feature/2026-09-10-user-auth
```

`/vibe` writes the line when it creates the plan file; `/bulk` adds it to the selected, already-existing plan files in its claim commit. The marker is also what makes a branch recognizable as a run branch (§3), so it names the run branch **exactly**, with no glob and no abbreviation.

**The run's items are exactly the plan files carrying its `**Run:**` marker** — never items recalled from the conversation, never plan files carrying **another** run's marker, and — for `/vibe` — never pre-existing rows planned by `/interview`, which are left for `/build` or `/bulk`. Resume logic belongs to the run command; this skill only fixes the marker format.

## §10 — Pre-flight stops

Nothing is written before pre-flight passes. Each stop prints the shape *`<command>: cannot start — <reason>. <what the user should do>.`* (the run command's name as the prefix) and ends the turn:

| Condition                                | Message                                                                                                                                                                      |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| no git repository                        | <command>: cannot start — no git repository here. Run `git init` and commit a baseline first.                                                                                |
| plan mode active                         | <command>: cannot start — plan mode is active. Switch to a permission mode that does not prompt, then re-run.                                                                |
| dirty working tree                       | <command>: cannot start — the working tree has uncommitted changes. Commit or stash them yourself, then re-run.                                                              |
| run-branch name collision                | <command>: cannot start — branch `<run branch>` already exists. Re-run with different wording, or resume it with `/<command>` (no argument) from that branch.                |
| no argument, nothing resumable (`/vibe`) | vibe: nothing to resume here — pass a spec to start a run.                                                                                                                   |
| no roadmap (`/bulk`)                     | bulk: nothing to build — no `docs/roadmap.md` here. Plan items with `/interview` first.                                                                                      |
| unknown ID (`/bulk`)                     | bulk: cannot start — `<ID>` is not in `docs/roadmap.md`. Check the ID, or plan it with `/interview` first.                                                                   |
| phase ID passed (`/bulk`)                | bulk: cannot start — `<phase ID>` is a phase. Pass the base ID `<base ID>` (its `TODO` phases build in order), or use `/build <phase ID>` for a single phase.                |
| ID not `TODO` (`/bulk`)                  | bulk: cannot start — `<ID>` is `<status>`. Only `TODO` rows are built; an `IN PROGRESS` row belongs to `/build`, a quarantine, or another run.                               |
| ID owned by another run (`/bulk`)        | bulk: cannot start — `<ID>` already carries `**Run:** <branch>`. Resume that run from its branch, or finish the item with `/build <ID>`.                                     |
| plan file missing (`/bulk`)              | bulk: cannot start — `docs/plan/<ID>.md` does not exist. Plan the item with `/interview` first.                                                                              |
| nothing selectable (`/bulk`)             | bulk: nothing to build — no unowned `TODO` row in `docs/roadmap.md`. Plan items with `/interview` first.                                                                     |
| no argument, nothing resumable (`/bulk`) | *(not a stop — no argument outside a run branch starts a new run over every unowned `TODO` row; listed here so the two commands' no-argument semantics sit side by side.)*   |

## §11 — End-of-run report

The run ends on the run branch and prints this report — its first line is `<command> run <run branch> — <tally>`, tables padded per the inherited formatting rule:

```
vibe run feature/2026-09-10-user-auth — 3 devs done, 1 quarantined
Started from: master @ edb28ad

| Dev                  | Branch                             | Status      | Commit  |
|----------------------|------------------------------------|-------------|---------|
| FEATURE-3A7F-PHASE01 | feature/feature-3a7f-phase01-login | DONE        | a1b2c3d |
| FEATURE-3A7F-PHASE02 | feature/feature-3a7f-phase02-oauth | QUARANTINED | d4e5f6a |
| FEATURE-3A7F-PHASE03 | —                                  | TODO        | —       |
| BUG-9C2E             | bugfix/bug-9c2e-token-refresh      | DONE        | b7c8d9e |

Quarantined: FEATURE-3A7F-PHASE02 — 2 tests still failing after 3 cycles (OAuthTests.Refresh_*).

Review:   git log --first-parent master..feature/2026-09-10-user-auth
          git diff master...feature/2026-09-10-user-auth
Finish:   /build FEATURE-3A7F           (continues PHASE02 on its existing branch)
Merge:    git switch master && git merge --no-ff feature/2026-09-10-user-auth
Clean up: git branch -d feature/feature-3a7f-phase01-login bugfix/bug-9c2e-token-refresh
```

A `/bulk` report has the same shape and, in no-argument mode, one extra `Skipped:` line after `Quarantined:` naming the rows it did not select and why (`IN PROGRESS`, owned by another run) — omitted when nothing was skipped.

The run never runs the *Review* / *Finish* / *Merge* / *Clean up* commands itself — they are the user's, and `push` stays forbidden (§5).

## §12 — Common mistakes

| Mistake                                                                           | Fix                                                                           |
|-----------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| Asking "shall I continue?", or any confirmation round                             | Decide with the option you would have recommended, and keep going (§2)        |
| Committing on the branch the user started from                                    | Everything lands on the run branch or on a dev branch (§3)                    |
| Cutting a dev branch from the previous dev branch                                 | `git switch <run branch>` first, then branch from its tip (§3)                |
| Leaving a dev uncommitted "for the user to review"                                | The run commits every dev itself and never pauses (§4)                        |
| Merging a red dev, or marking it `DONE`                                           | Quarantine it, leave the branch unmerged, footnote the roadmap (§6)           |
| A 4th fix cycle, or "one more quick try"                                          | The budget is 3 cycles, then quarantine (§6)                                  |
| `git add -A` sweeping `bin/`, `obj/`, `.idea/`                                    | Stage explicit paths after reading `git status --porcelain` (§4)              |
| Writing `docs/done/<ID>.md` for a quarantined dev                                 | Quarantined is not done — the plan file and the footnote carry the state (§6) |
| `/bulk` picking up an `IN PROGRESS` row, or a plan file with another run's marker | Only unowned `TODO` rows are selectable (§9, §10)                             |
| Naming the run branch `vibe/…` or `bulk/…`                                        | A run branch is `<category>/<date>-<slug>` (§3)                               |
| Adding a `Co-Authored-By` trailer because the session asks for one                | A run's commits carry no attribution trailer (§4)                             |

## §13 — Cross-references

- **dev-workflow** — everything inherited: roadmap and plan-file shapes, work-item IDs, branch naming, the Definition of Done, completion docs, the multi-phase progress table, the CRLF policy, and the commit-message formats.
- **Stack and convention skills** (the dotnet / avalonia / xunit family, `git-repo-hygiene`, …) — loaded by `/vibe`'s self-interview exactly as `/interview` loads them, and by `/bulk` for the codebase it builds in; their defaults are authoritative, applied and recorded rather than questioned.

If the target project already enforces its own conventions (roadmap, work-item IDs, branch naming, documentation layout), those take precedence — apply them and record the choice.
