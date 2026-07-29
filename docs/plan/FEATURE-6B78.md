# FEATURE-6B78 — Always offer a free-text escape option in questions

**Status:** DONE
**Type:** FEATURE (single-phase)
**Branch:** `feature/feature-6b78-question-escape-hatch`

## Objective

Guarantee that every question put to the user leaves a **visible** way to type
their own answer, so they are never cornered into picking an ill-fitting option
and correcting it a round later.

**Root cause — not a missing capability.** `AskUserQuestion` always appends an
"Other" free-text choice, and the tool's own spec says not to author one
("There should be no 'Other' option, that will be provided automatically").
`interview.md:38` currently cites that fact — which is precisely what licenses
treating a 4-option set as exhaustive. The fix is therefore a written rule about
**question construction**, not a new mechanism.

## Scope

### Files changed
1. **`.claude/skills/dev-workflow/SKILL.md`** — home of the new canonical
   "Asking questions (both flows)" section; retro-fit the doc-freshness sweep
   question; bump the version line.
2. **`.claude/commands/interview.md`** — Phase 2 "How to ask": replace the
   automatic-"Other" sentence with a deferral to the skill's rule + the
   escape-option requirement; reconcile with the existing recommend-first rule;
   bump the announce line.
3. **`.claude/commands/build.md`** — Phase 4.4's restatement of the sweep gains
   the skip **and** name-a-doc-I-missed options; bump the announce line.
4. **`~/.claude/CLAUDE.md` §2** — *out of repo, untracked, mode `555`*: one
   clause appended to the multiple-choice bullet so the rule also governs
   ordinary sessions (see *Out-of-repo step*).

### Explicitly out of scope
- **`interview.md:55`** (mandatory final round) — closed set, and its
  "Yes — I'll describe it" option already is the free-text invitation. Unchanged
  (user declined this retro-fit).
- **`interview.md:28`** (code-review classification confirm) — closed set; the
  automatic "Other" covers "it's a mix". Unchanged (user declined).
- **`build.md:27`** (the no-ID roadmap print) — deliberately does *not* call
  `AskUserQuestion`; it asks the user to reply with an ID, which is already free
  text. Unchanged.
- No change to any other skill, and no change to historical
  `docs/roadmap.md` / `docs/plan/*` / `docs/done/*` content.

## Design — the rule

New top-level section in `SKILL.md`, titled **"Asking questions (both flows)"**,
placed immediately after *"Two flows: planning vs building"* so it is read before
any flow-specific instruction. Content (~6 bullets, one place, no duplication):

1. **Every question goes through `AskUserQuestion`** — including questions whose
   answer is a free value (a name, a path, a number, a prose description): offer
   2–3 plausible sample values plus the escape option rather than asking in
   prose. (Preserves `interview.md`'s "never as free-text question lists" rule.)
2. **Assume the answer space is open.** Author an explicit final option — a
   consistent stem, `None of these — I'll describe it`, with a
   **question-specific description** naming what to type. Omit it *only* when the
   options **provably** enumerate every possible answer (a yes/no; a genuine
   pick-one-of-N such as `FEATURE` vs `BUG` vs `CODE-REVIEW`), where the tool's
   automatic "Other" is enough. Anything about approach, design, scope, naming,
   priorities, or preference is **open by default** — the burden of proof is on
   the claim that a set is closed.
3. **Budget the 4-option cap:** an open question carries **at most 3 concrete
   options** + the escape option.
4. **The escape option is always last and never carries `(Recommended)`** — the
   recommendation stays a concrete, actionable default listed first (this is what
   keeps rule 2 from colliding with the existing recommend-first rule).
5. **A typed answer is a decision.** Adopt it, restate the reading in one line,
   and continue — no confirmation round. It is recorded in an interview's Phase 3
   summary under the existing *"Decisions you made"* bucket (no new bucket).

### Retro-fit — doc-freshness sweep (`SKILL.md`, *Documentation freshness sweep*)
The "Always ask, with concrete candidates" bullet currently offers the found
candidates plus a **"none / skip"** option. Add a third kind of option so the
user can name a doc the sweep missed (e.g. `A different doc — I'll name it`),
and note the interaction with the 4-option cap: when the sweep found more
candidates than fit, group them or name the extras in the question text rather
than silently dropping them.

### `interview.md` — Phase 2 "How to ask"
- The bullet reading *"Give each question a short header and 2–4 concrete
  options; the tool adds an "Other" free-text choice automatically."* must no
  longer present the automatic "Other" as making an authored escape option
  unnecessary. Rewrite it to cite the skill's *Asking questions* rule and state
  the escape-option requirement (open by default; at most 3 concrete options
  + escape last, unrecommended).
- Keep the existing **Always recommend** and **self-explanatory options** rules
  intact, adding the one carve-out that the escape option is exempt from
  `(Recommended)` and always sits last.
- The "genuinely open-ended questions" bullet keeps its "still state a default"
  requirement, and now routes such questions through the tool (sample values +
  escape option) rather than prose.

### `build.md` — Phase 4.4
Extend the sweep clause so it names the skip option **and** the
name-a-doc-I-missed option, citing the skill's rule — so no file restates the
sweep in pre-rule wording.

## Out-of-repo step (`~/.claude/CLAUDE.md`)

§2's multiple-choice bullet ("Give me 2–4 labeled options (a / b / c …)…") gains
one clause: never present a closed option set for an open question — always
leave a free-text way out. This is what makes the rule apply **outside**
`/interview` too, since §2 is what drives multiple-choice questions in every
session.

Mechanics: the file is mode `555` → `chmod u+w`, edit, **restore `555`**. It is
untracked by this repo, so the edit rides in **no** commit; record it as an
explicit out-of-repo step under *Deviations & follow-ups* in the completion doc
(precedent: FEATURE-0EF9's out-of-repo follow-up).

## Versioning (house convention — material prompt revision)
- `dev-workflow` skill: **v3 → v4** (`**Version: dev-workflow v4.**`).
- `/interview`: announce line **v8 → v9** (`Using interview v9 by Josué Clément`).
- `/build`: announce line **v5 → v6** (`Using build v6 by Josué Clément`).

## Acceptance criteria
1. `SKILL.md` contains the new "Asking questions (both flows)" section with all
   five rules of *Design — the rule*, and its version line reads
   `**Version: dev-workflow v4.**`.
2. The `SKILL.md` doc-freshness sweep question offers: concrete candidates + a
   skip option + a way to name a doc the sweep missed.
3. `interview.md` no longer presents the tool's automatic "Other" as making an
   authored escape option unnecessary, cites the skill's *Asking questions*
   rule, and its announce line reads `Using interview v9 by Josué Clément`.
4. `build.md`'s Phase 4.4 sweep clause names both the skip and the
   name-a-doc-I-missed options, and its announce line reads
   `Using build v6 by Josué Clément`.
5. `grep -rn "interview v8\|build v5\|dev-workflow v3" .claude/` returns nothing.
6. `~/.claude/CLAUDE.md` §2 carries the escape-hatch clause, and the file's mode
   is back to `555`.
7. `interview.md:55` (final round), `interview.md:28` (code-review confirm) and
   `build.md:27` (no-ID roadmap print) are unchanged; no historical
   roadmap/plan/done content is modified.
8. All three changed repo files remain well-formed markdown (frontmatter intact,
   tables valid).

## Verification (no build/test — prompt/doc changes)
Nothing to compile and no test suite exists, so Definition-of-Done criteria 1–2
are satisfied by the no-build/no-test equivalent, verified by:
- the `grep` in AC5, plus a `grep -rn "Asking questions"` / `grep -n "None of
  these"` spot-check for AC1–AC2;
- `stat -c '%a' ~/.claude/CLAUDE.md` → `555` and a `grep` of the new clause for AC6;
- `git diff` review confirming AC7 (no unintended lines touched);
- visual inspection of the rendered markdown for AC8.
