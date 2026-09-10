# FEATURE-608E — `/vibe` autonomous coding workflow

**Status:** DONE
**Branch:** `feature/feature-608e-vibe-workflow` (cut from `master` @ `bdaad3a`)

## Summary

Added the autonomous "vibe coding" workflow to this repo's Claude Code toolkit: from a single spec prompt,
`/vibe` self-answers the `/interview` question set with the options it would have recommended, writes the
roadmap rows and plan files, then builds every planned dev end to end — branch, implement, Definition of
Done, completion doc, commit, merge — without asking a question or pausing for a confirmation. Everything a
run produces lives on a `vibe/<yyyy-mm-dd>-<slug>` run branch and its dev branches; the branch the user
started from is never modified and nothing is ever pushed.

Two prompt files deliver it:

- **`.claude/skills/vibe-workflow/SKILL.md` (v1, 185 lines)** — an *override skill* layered on an unchanged
  `dev-workflow`. §1 names what is inherited and what is superseded (by `dev-workflow`'s exact heading
  names); §2 decide-don't-ask; §3 run topology (with an ASCII branch diagram); §4 the run commits its own
  devs; §5 the allowed/forbidden git table; §6 the 3-cycle fix budget and the six-step quarantine
  procedure; §7 the auto-applying doc sweep; §8 no `Agent`/`Workflow` tools; §9 files as the source of
  truth + the `**Run:**` marker; §10 the five pre-flight stops with their exact messages; §11 the
  end-of-run report template; §12 common mistakes; §13 cross-references.
- **`.claude/commands/vibe.md` (v1, 95 lines)** — Phase 0 announce (`Using vibe v1 by Josué Clément`),
  Phase 1 load `dev-workflow` then `vibe-workflow` (precedence stated) then stack skills, Phase 2
  pre-flight + NEW RUN/RESUME resolution, Phase 3 self-interview (code-review detection, codebase
  exploration, the 13 beyond-the-draft dimensions, recommended-option answers, item breakdown with the
  one-dev-per-reviewable-commit heuristic), Phase 4 plan + planning commit, Phase 5 the build loop with the
  five-row resume state machine, Phase 6 end-of-run report, plus `# Rules`.

## Files/modules touched

**Created**

- `.claude/skills/vibe-workflow/SKILL.md`
- `.claude/commands/vibe.md`
- `docs/done/FEATURE-608E.md` (this file)

**Modified**

- `docs/roadmap.md` — `FEATURE-608E` row `TODO` → `IN PROGRESS` → `DONE` (whole-table pipe layout unchanged).
- `docs/plan/FEATURE-608E.md` — `**Status:**` `TODO` → `IN PROGRESS` → `DONE`.

**Deliberately untouched** — `.claude/commands/interview.md` (v9), `.claude/commands/build.md` (v6),
`.claude/skills/dev-workflow/SKILL.md` (v5) and every other skill:
`git diff HEAD --stat -- <those three>` prints nothing (acceptance criterion 7).

## Deviations & follow-ups

- **The end-of-run report template is defined once, in the skill (§11), and referenced — not reproduced —
  by the command's Phase 6.** Design B's Phase 6 illustrates the template inline while Design A §11 states
  "the skill owns the format, the command prints it", and build step 3 requires each shared rule to live in
  "exactly one of the two files". Single definition wins: duplicating a 20-line template across two prompt
  files is how the two drift apart. The command's Phase 6 still enumerates every field the report carries.
  The same single-definition rule was applied to the quarantine procedure, the fix budget, the pre-flight
  messages and the git allowed/forbidden table (all skill-side, referenced from the command) — acceptance
  criterion 6 explicitly permits "a reference to skill §6" for the quarantine procedure.
- **Line endings (recommendation only, no action taken):** the whole repo is CRLF and internally
  consistent, so both new files were authored CRLF to match their siblings. A `.gitattributes` carrying
  `* text=auto eol=lf` would remove the churn risk repo-wide — the user owns that decision.
- **Deployment is out of scope and still pending:** the copies in `~/.claude/commands` and `~/.claude/skills`
  are plain files, not junctions (FEATURE-15CB precedent), so `/vibe` is picked up from this repo only until
  the two files are copied over. See the dry run recipe below.
- **Follow-ups recorded, not built:** build-by-ID mode (`/vibe FEATURE-003` on an already-planned item), a
  project `.claude/settings.json` allowlist so a run needs no permission prompts in default mode, and
  back-filling roadmap rows for untracked skill work.

## Build/test evidence

**There was nothing to build and no test suite to run** — this repo contains only Claude Code prompt files
(markdown), no project, no build step, no test project. Per the Definition of Done's no-build clause,
criteria 1–2 were satisfied by verifying the artifacts are well-formed and by checking every acceptance
criterion by inspection and by grep:

| # | Criterion | Evidence |
|---|-----------------------------|-----------------------------------------------------------------------------------------------|
| 1 | House shapes                | Skill: `name: vibe-workflow` + `description` frontmatter, `# ` title, `**Version: vibe-workflow v1.**` at line 8. Command: `description` + `argument-hint` + `disable-model-invocation: true`, `Using vibe v1 by Josué Clément` at line 22 (Phase 0). |
| 2 | No question path            | `grep -n "AskUserQuestion\|ExitPlanMode"` → 2 hits, both inside "**Never call …**" / "**Never ask, never pause.** No …" sentences. |
| 3 | No delegation path          | Every `Agent`/`Workflow` **tool** mention is a prohibition (skill §8, command Rules); the only other hits are the superseded-section name *Sub-Agent Delegation*. |
| 4 | Precedence explicit         | "**where the two disagree, this skill wins**" (skill line 10); the §1 table names *Asking questions (both flows)*, *Two flows: planning vs building*, *Version Control*, *Documentation freshness sweep (build flow)*, *Sub-Agent Delegation* by their exact `dev-workflow` headings. |
| 5 | Safety rails enumerated     | §5 forbids `push`, writes to the starting/default branch, `reset --hard`, `clean`, `stash`, `rebase`, `restore`/`checkout --`, `--force`/`-f`, `branch -d`/`-D`, `tag`, `remote`, `config`. Command `# Context` states the non-prompting permission mode and no-plan-mode prerequisite. |
| 6 | Loop complete               | Phases 0–6 present (lines 19/26/29/37/47/53/77); five pre-flight stops (skill §10 table); resume state machine with 5 rows; quarantine referenced to §6; literal 3-cycle budget; `--no-ff`; `**Run:**` marker; report template (skill §11). |
| 7 | Nothing else changed        | `git diff HEAD --stat -- .claude/commands/interview.md .claude/commands/build.md .claude/skills/dev-workflow/SKILL.md` → empty. |
| 8 | Roadmap/plan/done           | `FEATURE-608E` reads `DONE` in both; this file exists; the pipe-offset check over `docs/roadmap.md` reports **1 distinct pipe layout** across all 33 table rows — `(0, 15, 52, 66, 94)`. |
| 9 | Well-formed markdown        | Fences balanced (skill 6, command 0), frontmatter parses, every markdown table rectangular (automated cell-count check over both files → no ragged tables). |
| 10 | Nothing to build/test      | Stated above; the dry run recipe is reproduced below. |

## Dry run recipe (for the user)

1. Copy `vibe.md` to `~/.claude/commands/` and the `vibe-workflow/` folder to `~/.claude/skills/` — or run
   from this repo, where both are picked up locally.
2. Create a throwaway repo: `git init` a folder with a small .NET class library plus an xUnit test project
   (or a markdown-only repo, to exercise the no-build path), and commit once.
3. Start Claude Code in a **non-prompting permission mode** — not plan mode — and run, for example:
   `/vibe Add a Stack<T> with Push/Pop/Peek and full unit tests`.
4. Expect: the announce line · the printed self-interview summary · a `vibe/<date>-<slug>` branch whose
   first commit is `docs(roadmap): plan …` · one merged dev branch per planned dev · **no change on the
   starting branch** (`git log <start> -1` unchanged, `git status` clean there) · no push · the
   end-of-run report.
5. Kill the session mid-dev on a second, larger prompt, then re-run `/vibe` with no argument to exercise
   the resume state machine.
