# FEATURE-0E86 — Run branch prefix + no commit trailer

**Status:** TODO
**Type:** FEATURE (single-phase)
**Branch (at build time):** `feature/feature-0e86-run-branch-trailer`, cut from the run-branch tip.
**Run:** feature/2026-09-11-run-branch-trailer

_Planned and built by `/vibe` in the same run. Prompt-file change — no build/test step._

## Objective

Two convention fixes to the autonomous run commands, requested verbatim:

1. **No `vibe/` (or `bulk/`) prefix on the run branch.** A run's branch joins the house category
   namespace — `feature/`, `bugfix/`, `review/` — like every other branch in the repo.
2. **A run's own commits carry no `Co-Authored-By` trailer**, in the title or the description, even when
   the session's own instructions provide one.

Three prompt files deliver it:

- `.claude/skills/vibe-workflow/SKILL.md` — **v2 → v3**: §3 (run topology) and §4 (commits) change; §9,
  §10, §11, §12 and the frontmatter follow the new names.
- `.claude/commands/vibe.md` — **v1 → v2**.
- `.claude/commands/bulk.md` — **v1 → v2**.

`dev-workflow`, `/interview` and `/build` are **untouched**: neither commits, neither creates a run
branch, and the `feature/` / `bugfix/` / `review/` dev-branch naming they own is unchanged.

## Context & constraints

- **Repo:** `C:\Dev\EnigmaLibs\dotfiles`, a dotfiles mirror. `.claude/` here is a plain directory, **not a
  junction** to `C:\Users\Jo\.claude` (verified with `Get-Item … LinkType` — empty). The user's live
  `~/.claude` is **out of scope by explicit instruction**; syncing is theirs to do.
- **No build, no test suite.** Definition of Done criteria 1–2 are satisfied by inspection: the markdown
  stays well-formed, and grep proves no stale rule survives.
- **Backward compatibility matters.** A run branch created by v1/v2 (`vibe/…`, `bulk/…`) must still be
  resumable after this change.
- **The run branch now shares a namespace with dev branches.** `feature/2026-09-11-slug` (run) and
  `feature/feature-0e86-slug` (dev) must stay distinguishable — by shape for a human, by the `**Run:**`
  marker for the machine.

## Design

### 1. Run-branch naming (`vibe-workflow` §3, both commands)

New rule, replacing `<command>/<yyyy-mm-dd>-<slug>`:

> **Run branch:** `<category>/<yyyy-mm-dd>-<slug>` — `<category>` is the dev-branch folder of the run's
> **first item**: `feature/` for a FEATURE, `bugfix/` for a BUG, `review/` for a CODE-REVIEW. Date from
> `date +%Y-%m-%d`; slug ≤ 4 kebab-case tokens (unchanged per command). Never `vibe/…` or `bulk/…`.

The date segment is what tells a run branch from a dev branch by eye: a dev branch's second segment always
begins with the lowercased item type and its hex (`feature-0e86-…`), never with a date.

### 2. Recognizing a run branch (`vibe-workflow` §3, both commands' Phase 2 / resume)

The name is documentation; the **marker is the test**:

> The current branch is a run branch when some `docs/plan/*.md` carries `**Run:** <that branch>`.

This keeps resume immune to a user branch that merely looks like a date, and keeps `vibe/…` / `bulk/…` run
branches from older versions resumable.

### 3. No attribution trailer (`vibe-workflow` §4, both commands)

The §4 bullet "Append the session's `Co-Authored-By` trailer when the session provides one" is replaced by
its opposite: a run's commits are title + bulleted description only — no `Co-Authored-By:`, no other
agent-attribution trailer, **even when the session's own instructions ask for one**. Mirrored as a `# Rules`
bullet in both commands and as a §12 common-mistakes row.

### 4. Follow-through edits

| File | Sites |
|------|-------------------------------------------------------------------------------------------------|
| `SKILL.md` | frontmatter `description`; version line v2 → v3; §3 run-branch bullet + new recognition bullet; §3 ASCII topology diagram; §3 closing `/bulk` sentence; §4 trailer bullet; §9 marker example; §10 `/bulk` no-argument row; §11 report example; §12 two new rows |
| `vibe.md` | frontmatter `description`; Context bullet 1; Phase 0 announce line v1 → v2; Phase 2 both mode bullets; Phase 4 step 1 (`git switch -c`); Phase 4 step 4 (trailer); `# Rules` new bullet |
| `bulk.md` | frontmatter `description`; Context bullet 2; Phase 0 announce line v1 → v2; Phase 2 both mode bullets; Phase 3 step 4 (`git switch -c`); Phase 3 step 6 (trailer); `# Rules` new bullet; draft footer |

## Acceptance criteria

1. No run-branch **rule** in `.claude/` still names a `vibe/` or `bulk/` prefix; the only surviving
   mentions of those names are the explicit backward-compatibility notes.
2. `grep -rn 'Co-Authored-By' .claude/` returns only **prohibitions** — no instruction to append one.
3. `vibe-workflow/SKILL.md` announces **v3**; `vibe.md` Phase 0 announces **v2**; `bulk.md` Phase 0
   announces **v2**.
4. §3 states both the new run-branch name shape (with the category-selection rule) and the marker-based
   recognition rule, and §11's report example uses a category-prefixed run branch.
5. Both commands' Phase 2 mode resolution keys resume on the `**Run:**` marker, not on a branch-name glob.
6. `.claude/skills/dev-workflow/SKILL.md`, `.claude/commands/build.md` and `.claude/commands/interview.md`
   are byte-identical to `HEAD` (`git diff HEAD --stat` prints nothing for them).
7. Nothing under `C:\Users\Jo\.claude` is written.

## Out of scope

- Renaming the dev-branch folders `bugfix/` → `bug/` or `review/` → `code-review/`.
- Any change to `dev-workflow`, `/interview`, `/build`.
- Copying the result into the user's live `~/.claude`.
- Line-ending normalization (recommendation-only, per the inherited CRLF policy).

## Decisions taken autonomously

| Question | Chosen | Why | Alternatives rejected |
|----------|--------|-----|-----------------------|
| What replaces the `vibe/` prefix? | `<category>/<yyyy-mm-dd>-<slug>` | Puts the run branch in the house namespace, which is the ask; the date keeps it distinct from a dev branch | Drop the run branch entirely (devs would have no merge target — the starting branch is write-forbidden); a neutral `run/` prefix (still not a house folder) |
| Which category for a multi-item run? | The first item's | Deterministic and one line to state; item 1 is the run's headline | "Dominant type, ties broken by the first item" — more rule, no practical gain |
| Rename `bugfix/` → `bug/`, `review/` → `code-review/` to match the words in the draft? | No | The draft names the categories loosely; the folder names are established `dev-workflow` convention and renaming would ripple into `/build`, `/interview` and every existing branch | Renaming the folders |
| How is a run branch recognized once its name is no longer distinctive? | By a `docs/plan/*.md` `**Run:**` marker naming it | Immune to look-alike user branches, and keeps older `vibe/…` / `bulk/…` runs resumable | A regex on the branch name alone |
| Apply the branch change to `/bulk` as well as `/vibe`? | Both | The rule lives in one shared skill section; leaving `bulk/` behind turns one rule into an exception pair, and the draft's second bullet treats the commands as a pair | `/vibe` only |
| Does this run obey the new rules or the old ones? | The new ones | The draft is an instruction about branches and commits *now*; emitting a `vibe/…` branch with a trailer in the run that removes them would be perverse | Old rules for this run, new ones from the next |
| One dev or two phases (branch naming / trailer)? | One single-phase dev | ~30 lines over 3 files sharing one version bump; splitting leaves an intermediate commit whose announced version contradicts its content, for more roadmap churn than content | Two phases |
| Version bumps | skill v2 → v3, both commands v1 → v2 | House convention: a behavioural prompt change bumps the announce line | Leaving versions untouched |
