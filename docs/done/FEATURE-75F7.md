# FEATURE-75F7 — `/bulk`: build already-planned items unattended

**Status:** DONE
**Branch:** `feature/feature-75f7-bulk-command` (cut from `feature/feature-3bf6-interview-no-confirm` @ `42f15d2`)

## Summary

Added **`/bulk`**, the unattended executor for plans written by `/interview`. `/vibe` self-interviews, plans
and builds from a spec prompt; `/bulk` skips the planning entirely and builds **already-planned roadmap
items** — every unowned `TODO` row, or the base IDs passed as arguments — under exactly `/vibe`'s
autonomy rules: no questions, its own `bulk/<yyyy-mm-dd>-<slug>` run branch, one dev branch per dev merged
`--no-ff`, its own commits, the 3-cycle fix budget, quarantine-and-continue, no `Agent`/`Workflow` tools,
resume after a dead session, never a push, never a write to the branch the user started from.

The run's first commit is the **claim commit** `docs(plan): claim <ID>[, <ID>…] for <run branch>`, which
stamps `**Run:** <run branch>` into each selected plan file and nothing else — statuses stay `TODO`, the
roadmap is untouched. That single mechanism makes the inherited ownership rule (skill §9: "the run's items
are exactly the plan files carrying its marker") and the resume state machine work for `/bulk` unchanged.

Typical flow: `/interview <spec>` → the user commits `docs(roadmap): plan …` → `/bulk` → review the
run branch → merge.

Delivered by two prompt files:

- **`.claude/skills/vibe-workflow/SKILL.md` — v1 → v2.** A pure generalization: the places that named
  `/vibe`, the `vibe/` branch prefix, the `vibe:` message prefix, the planning commit and the report header
  now speak of *the run command* (`<command>` = `vibe` or `bulk`), and §10 gained `/bulk`'s pre-flight
  stops. **No rule changed** — §2, §5, §6, §7 and §8 are byte-identical apart from the
  `/vibe` → `/<command>` substitution in §6's quarantine footnote. `/vibe` v1 keeps working unmodified
  because every generalized sentence still reads correctly with `<command>` = `vibe`.
- **`.claude/commands/bulk.md` — v1, new.** 94 lines: frontmatter, `# Role`, `# Context`, Phases 0–6
  (announce · load standards · pre-flight & mode resolution · select and claim · build loop · resume
  state machine · end of run), `# Rules`, and the `$ARGUMENTS` footer. Rules stay skill-side and are
  referenced by § number; the build loop is restated (adapted for claiming instead of planning) so
  `vibe.md` could stay byte-identical (decision A9).

## Files/modules touched

**Created**

| File                        | What                                                          |
|-----------------------------|---------------------------------------------------------------|
| `.claude/commands/bulk.md`  | `/bulk` v1 — 94 lines, CRLF, `disable-model-invocation: true` |
| `docs/done/FEATURE-75F7.md` | this record                                                   |

**Modified**

| File                                    | What                                                              |
|-----------------------------------------|-------------------------------------------------------------------|
| `.claude/skills/vibe-workflow/SKILL.md` | v1 → v2, the 12 planned edits (16 diff hunks, +47/-32 lines)      |
| `docs/roadmap.md`                       | `FEATURE-75F7` → `IN PROGRESS` → `DONE` (column widths unchanged) |
| `docs/plan/FEATURE-75F7.md`             | `**Status:**` → `IN PROGRESS` → `DONE`                            |

**Untouched, as the plan required:** `.claude/commands/interview.md` (v10), `.claude/commands/build.md`
(v6), `.claude/commands/vibe.md` (v1), `.claude/skills/dev-workflow/SKILL.md` (v5) —
`git diff HEAD --stat` over those four paths prints nothing.

## Deviations & follow-ups

**Deviations from the plan**

1. **`argument-hint` had to be quoted.** Design B specified the frontmatter line verbatim as
   `argument-hint: [<ID> [<ID>…]] | (nothing = every TODO row, or resume the current bulk run)`. That
   value is **invalid YAML**: `[` opens a flow sequence, `[<ID>…]]` closes it, and the trailing
   `| (nothing = …)` is then a parse error — which takes the *whole* frontmatter block down with it.
   Written that way, the harness ignored the frontmatter and registered the file as a model-invocable skill
   named `bulk` described `Role` (the first heading), i.e. `disable-model-invocation: true` was silently
   lost. Fixed by wrapping the value in double quotes, which keeps the planned hint text byte-for-byte and
   makes the block parse. (`vibe.md`'s hint happens to be valid unquoted — its brackets enclose the whole
   value — so it never hit this.)
2. **`bulk.md` came out at 94 lines**, just under the plan's ≈ 100–130 size guidance, with every
   designed element present. The gap is `/vibe` wording reused verbatim rather than restated.
3. **Phase 5's dirty-run-branch row quotes §10's message in full** (`bulk: cannot start — the working
   tree has uncommitted changes. Commit or stash them yourself, then re-run.`) where the plan abbreviated it
   with an ellipsis. Note `vibe.md`'s equivalent row says "the run branch has uncommitted changes", which
   diverges from its own §10 row; `bulk.md` follows §10.

**Follow-ups (not acted on)**

- **`vibe.md`'s Phase 5 dirty-tree message** does not match skill §10's wording (above). One-line fix,
  belongs to a `/vibe` v2 — out of scope here, where `vibe.md` had to stay byte-identical.
- **Two loop skeletons now exist** (`vibe.md` Phase 5, `bulk.md` Phase 4). They are identical step for step
  apart from step 4 (`bulk` adds the sanity-check-and-adapt sentence); verified by diff. If they drift,
  reconsider moving the loop into the skill (plan decision A9).
- **`§1` and `§5` tables in `SKILL.md` are padded to equal *byte* width, not character width** — a
  pre-existing v1 artifact (`dev-workflow` says to count characters, so rows containing `—` come out 2
  characters short). Left alone: touching them would add diff hunks that map to none of the planned edits.
  The tables this dev rebuilt (§10, §12) and authored (`bulk.md` Phase 5) are character-padded and
  exactly rectangular.
- **Deployment is the user's step:** `bulk.md`, `vibe.md` and `vibe-workflow/` are not copied to
  `~/.claude/commands` / `~/.claude/skills` (those copies are plain files, not junctions). Deploy skill v2
  together with both commands, or run from this repo.
- **Line endings (recommendation only):** every touched file is CRLF and internally consistent. A
  `.gitattributes` with `* text=auto eol=lf` would remove the churn risk repo-wide. No action taken.

## Build/test evidence

**There was nothing to build and no test suite to run** — this repo contains only Claude Code prompt files
(markdown): no project, no build step, no test project. Per the Definition of Done's no-build clause,
criteria 1–2 were satisfied by verifying the artifacts are well-formed and by checking every acceptance
criterion by inspection and by grep.

| #  | Criterion                | Evidence |
|----|--------------------------|----------|
| 1  | Files exist, house shapes | `bulk.md` lines 1–5 are the frontmatter (`description`, quoted `argument-hint`, `disable-model-invocation: true`); line 24 is exactly `Using bulk v1 by Josué Clément`. `SKILL.md:8` reads `**Version: vibe-workflow v2.**`; its `description` names `/vibe` and `/bulk`; `grep -rn "vibe-workflow v1" .claude/` → no matches (exit 1). |
| 2  | No question path          | `grep -n "AskUserQuestion\|ExitPlanMode"` over both files → 2 hits, both prohibitions (`bulk.md:79` "Never ask, never pause. No `AskUserQuestion`, no `ExitPlanMode`…"; `SKILL.md:30` "**Never call `AskUserQuestion`. Never call `ExitPlanMode`.**"). |
| 3  | No delegation path        | The only `Agent`/`Workflow` **tool** mention in `bulk.md` is line 82: "**Never use the `Agent` or `Workflow` tools**, or any review/verify/adversarial agent." |
| 4  | Selection rules complete  | `bulk.md` Phase 3 step 2 (lines 41–44) states explicit base IDs vs. all `TODO` rows, the phase-ID stop, and the exclusions (`IN PROGRESS` / `DONE` / `ABANDONED`, missing plan file, `**Run:**`-owned), plus the `Skipped:` bookkeeping; step 3 prints the selection table. Skill §10 carries 8 rows tagged `` (`/bulk`) `` — the seven stops plus the no-argument note. |
| 5  | Claim mechanics           | §3 defines `<command>/<yyyy-mm-dd>-<slug>` with the `bulk/…` prefix and the ≤ 3-items slug rule, and the claim commit `docs(plan): claim <ID>[, <ID>…] for <run branch>`; §9 defines marker placement ("directly after its header block") and who writes it; `bulk.md` Phase 3 runs claim (step 5) → explicit staging → commit (step 6) in that order. |
| 6  | Loop complete             | `bulk.md` has `## Phase 0–6` (lines 21, 28, 31, 39, 50, 63, 75); the literal **3**-cycle budget and "3rd cycle" in Phase 4 step 5 plus "never a 4th fix cycle" in the rules; quarantine by reference to §6; `--no-ff` in step 8; the six-row resume table including the finished-run row; §11 referenced with the `bulk run <run branch>` header and the `Skipped:` line. |
| 7  | Nothing else changed      | `git diff HEAD --stat -- .claude/commands/interview.md .claude/commands/build.md .claude/commands/vibe.md .claude/skills/dev-workflow/SKILL.md` → empty output. |
| 8  | Skill rules unchanged      | `git diff -U0` over `SKILL.md` → **16 hunks**, each mapping to one of Design A's edits 1–11 (edit 12 was a no-op by design): lines 3, 8, 10, 40–41, 66, 72, 100, 122, 128–132, 134–150, 157, 176, 182–192, 197. No hunk falls inside §2 (28–39), §5 (76–85), §7 or §8 (107–117); §6's only change is the edit-6 footnote substitution at line 100 — the 3-cycle budget and the six quarantine steps are untouched. |
| 9  | Roadmap/plan/done         | `FEATURE-75F7` reads `DONE` in `docs/roadmap.md` and in `docs/plan/FEATURE-75F7.md`; this file exists; the pipe-offset check over the roadmap reports **a single pipe layout** `(0, 15, 57, 71, 99)` across all 35 table rows. |
| 10 | Well-formed markdown      | Both files decode as UTF-8; `bulk.md` has 0 code fences (nothing to balance), `SKILL.md` 6 (3 balanced pairs); every table this dev wrote is rectangular (`bulk.md` Phase 5: 8 rows × 212 chars × 5 pipes; §10: 15 × 219 × 3; §12: 11 × 165 × 3); line endings **`bulk.md` 93 CRLF / 0 lone LF / 0 lone CR**, **`SKILL.md` 199 CRLF / 0 lone LF / 0 lone CR**. |
| 11 | Nothing to build or test  | Stated above; the dry run recipe is reproduced below. |

**Cross-checks beyond the criteria**

- Every `§` reference in `bulk.md` (§2, §3, §5, §6, §7, §9, §10, §11) resolves to a
  section that exists in skill v2 (§1–§13).
- The `bulk:` message stems `bulk.md` cites (`bulk: cannot start —`, `bulk: nothing to build —`) are
  exactly the stems §10 defines.
- `vibe.md` Phase 5 vs. `bulk.md` Phase 4, numbered steps diffed: identical except step 4 (the designed
  sanity-check/adapt difference).

## Dry run recipe (for the user)

`bulk.md` carries `disable-model-invocation: true`, so the builder cannot invoke it — the first real run
is yours.

1. Copy `bulk.md` (and `vibe.md`) to `~/.claude/commands/` and `vibe-workflow/` to `~/.claude/skills/` —
   or run from this repo, where they are picked up locally.
2. Create a throwaway repo with a small .NET class library + xUnit test project (or a markdown-only repo for
   the no-build path); commit once. Run `/interview` on a two-item spec (e.g. "add `Stack<T>` with tests"
   and "add `Queue<T>` with tests"); commit the printed `docs(roadmap): plan …`.
3. Start Claude Code in a **non-prompting permission mode** — not plan mode — and run `/bulk`. Expect:
   the announce line · the selection table · a `bulk/<date>-<slug>` branch whose first commit is
   `docs(plan): claim …` · one merged dev branch per dev · **no change on the starting branch**
   (`git log <start> -1` unchanged, `git status` clean there) · no push · the end-of-run report.
4. Explicit mode: plan a third item, then `/bulk <that ID>` → only that item is built.
5. Kill the session mid-dev on a larger batch, then `/bulk` with no argument from the `bulk/*` branch →
   the resume state machine picks up where it stopped.
6. Negative paths: `/bulk FEATURE-DEAD` (unknown ID), `/bulk <a DONE ID>` (not `TODO`),
   `/bulk <ID>-PHASE01` (phase ID) → each prints its §10 stop and writes nothing.
7. Worth a glance on the first run: that `/bulk` shows up as a slash command **and not** in the
   model-invocable skill list (the frontmatter fix under *Deviations*), and that `/vibe` still works
   unchanged against skill v2.
