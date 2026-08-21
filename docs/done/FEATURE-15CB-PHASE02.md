# FEATURE-15CB-PHASE02 — Propagate the 4.0 facts to sibling skills (DONE)

## Summary

PHASE01 made `.claude/skills/xunit-v3/SKILL.md` the house authority for **xUnit.net
Core Framework v3 `4.0.0`**. This phase brings every sibling skill that repeats an
xUnit fact into line with it, so nothing under `.claude/skills/**` contradicts the
authority.

Six files edited, all mechanical applications of decisions already settled — no new
decisions were taken in this phase:

- **`coverlet.collector` is gone from every template and every recommendation.**
  Replaced by `Microsoft.Testing.Extensions.CodeCoverage` in the CPM Tests group,
  the bundled `test.csproj`, `dotnet-solution-config`'s prose and mistakes table,
  and `dotnet-release`'s license-audit row. The reason is the substantive one:
  `coverlet.collector` is a *VSTest data collector*, and xunit.v3 4.0 defaults to
  MTP v2, which does not host VSTest data collectors — so the previous guidance
  produced test projects whose coverage silently collected nothing.
- **Every pinned `xunit.v3` version moved `3.2.2` → `4.0.0`** (CPM template,
  `enigma-icons-avalonia/reference/setup.md`). `grep -rn "3\.2\.2" .claude/skills/`
  now returns nothing.
- **`templates/test.csproj` gained no new property**, per PHASE01's empirical
  result (below).
- **`dotnet-solution-config`'s `--solution` claim was softened**, because PHASE01
  Step 1 disproved it — see *The one non-mechanical edit*.

**Sibling skills' `**Version: … vN.**` lines are deliberately unchanged** —
`dotnet-solution-config v2`, `dotnet-solution-setup v2`, `dotnet-release v4`,
`enigma-icons-avalonia` (its edited `reference/setup.md` carries no version line).
Per the plan's *Versioning* section these are **fact corrections, not material
revisions**: no rule, workflow, or template shape changed, only the package names
and versions the rules already pointed at. The omission is intentional, not an
oversight.

## Files/modules touched

**Modified**

| File | Change |
|---|---|
| `.claude/skills/dotnet-solution-config/templates/Directory.Packages.props` | Tests group: `xunit.v3` `3.2.2` → `4.0.0`; `coverlet.collector` `6.0.4` → `Microsoft.Testing.Extensions.CodeCoverage` `18.10.0`; group comment renamed to the new package. |
| `.claude/skills/dotnet-solution-setup/templates/test.csproj` | `<PackageReference Include="coverlet.collector" PrivateAssets="all" />` → `<PackageReference Include="Microsoft.Testing.Extensions.CodeCoverage" />`. No new property. |
| `.claude/skills/dotnet-solution-config/SKILL.md` | Tests-group paragraph and the `Microsoft.NET.Test.Sdk` mistakes row now name the CodeCoverage package; **new** mistakes row for `coverlet.collector`; `--solution` invocation note and its mistakes row softened. |
| `.claude/skills/dotnet-solution-setup/SKILL.md` | `tests/` layout line and the `dotnet new xunit` mistakes row sharpened to name `xunit.v3` 4.x. |
| `.claude/skills/dotnet-release/SKILL.md` | License-audit table row: `xunit.v3`, `coverlet.collector` → `xunit.v3`, `Microsoft.Testing.Extensions.CodeCoverage`. Row meaning unchanged (still test-only, still never shipped). |
| `.claude/skills/enigma-icons-avalonia/reference/setup.md` | Headless-test snippet: `xunit.v3` `3.2.2` → `4.0.0`. `Avalonia.Headless.XUnit` left alone per plan. |
| `docs/roadmap.md` | `PHASE02` `TODO` → `IN PROGRESS` → `DONE`; item `FEATURE-15CB` → `DONE` (final phase). Column widths unchanged — `IN PROGRESS` survives on the `FEATURE-003` row, so the Status column stays 11 wide and every row stays 95 characters. No reformat needed. |
| `docs/plan/FEATURE-15CB.md` | Item status and PHASE02 status → `DONE`. |

**Created** — `docs/done/FEATURE-15CB-PHASE02.md` (this file).

**Deliberately not touched** — `.claude/skills/xunit-v3/SKILL.md` (PHASE01's
deliverable; this phase aligns *to* it, never edits it) and every skill the sweep
cleared (below).

## Decisions the plan left to build time

**`Microsoft.Testing.Extensions.CodeCoverage` version: `18.10.0`.** Looked up at
build time against the NuGet flat-container index — `18.10.0` is the latest stable
(the tail reads `18.6.2, 18.7.0, 18.8.0, 18.9.0, 18.10.0`). It is also the version
PHASE01's probe actually produced a non-empty coverage report with, so the pin is
verified, not merely current. `xunit.v3` latest stable re-confirmed as `4.0.0` in
the same check.

**`PrivateAssets` on the coverage `PackageReference`: dropped.** `coverlet.collector`
carried `PrivateAssets="all"`; the CodeCoverage reference carries none. Two reasons,
and they agree: (1) it is a **test-host extension that must flow at runtime**, not a
compile-time-only asset like `PolySharp` — `PrivateAssets="all"` is the wrong
category of declaration for it; (2) it matches the authority verbatim —
`xunit-v3/SKILL.md`'s csproj sample writes
`<PackageReference Include="Microsoft.Testing.Extensions.CodeCoverage" />` bare, and
a bundled template that diverged from the sample it is the "full version" of would
reintroduce exactly the drift this phase exists to remove. The suppression also had
nothing to suppress here: a test project is never packed, so there are no consumers
for assets to flow to.

**`UseMicrosoftTestingPlatformRunner`: not added — the "Run A succeeded" case
applies.** PHASE01 Step 1's probe produced a non-empty `coverage.cobertura.xml`
(990 bytes, `line-rate="1"`) on SDK **10.0.300** with the `global.json` runner entry
alone, needing neither `UseMicrosoftTestingPlatformRunner` nor
`TestingPlatformDotnetTestSupport`. Its concluded minimum property set was
**NONE**, so per plan Step 2 (*"add nothing"*) and acceptance criterion 4,
`templates/test.csproj` gained no property. Verified absent:
`grep -c UseMicrosoftTestingPlatformRunner` → 0.

## The one non-mechanical edit

PHASE01 recorded a follow-up that this phase was required to act on, and the plan's
Step 3 authorized it in advance (*"`global.json` section and the `--solution`
invocation note: unchanged **unless PHASE01 Step 1 contradicted them**"*). It did:
`dotnet test <Solution>.slnx` positionally **ran the suite** on SDK 10.0.300
(exit 0, 4 tests), so `dotnet-solution-config`'s flat claim that the form is
"**rejected**" was false in two places:

- the *Invocation note* (`SKILL.md:84`, `:90`) — now presents `--solution` as the
  portable, always-correct form and states that the positional form is *also*
  accepted on SDK 10.0.300 though it was rejected on earlier 10.0 SDKs;
- the matching Common-mistakes row — reframed from "the positional form is
  rejected" to "the positional form is not portable", which is the claim that is
  actually true and still steers the reader to `--solution`.

The wording deliberately mirrors `xunit-v3/SKILL.md:89` so the two skills read as
one voice rather than two independent descriptions of the same behaviour.

## Deviations & follow-ups

**Acceptance criterion 1 is met in intent, not to the letter — the same way
PHASE01's criterion 2 was.** It says
`grep -rn "coverlet\.collector" .claude/skills/` should return "only the stale-isms
row in `xunit-v3/SKILL.md`". It returns **five** rows: four in `xunit-v3/SKILL.md`
(the coverage rationale, migration step 3, the stale-isms row, the Common-mistakes
row — each *mandated* by PHASE01 Steps 4, 10, 11 and 12) and one in
`dotnet-solution-config/SKILL.md` — which **this phase's own Step 3 explicitly
required me to add** (*"Add one row: `coverlet.collector` in the CPM Tests group →
VSTest data collector; collects nothing under MTP v2"*). The criterion contradicts
its own step list; it was written as shorthand for "no file still *recommends*
`coverlet.collector`", and that is satisfied — all five mentions tell the reader not
to use it and name the replacement. Criterion 2 (`3.2.2`) is met exactly: **zero**
hits.

**Follow-up: `dotnet-release`'s runbook uses the positional solution form.**
`SKILL.md:218` and `templates/RELEASE.md:36` print `dotnet test <solution> -c Release`.
This does **not** contradict the softened authority — the positional form is
accepted on SDK 10.0.300 — but it is not the portable form the authority tells you
to use "in scripts, docs, and CI", and a release runbook is precisely that. Two
one-token edits (`--solution <solution>` / `--solution {{SOLUTION}}`) would make it
strictly safer on earlier 10.0 SDKs. **Not done here:** the plan scoped
`dotnet-release` to line 61 alone and this phase is explicitly "no new decisions",
so it is surfaced for the user rather than folded in silently. Worth a small
follow-up item.

**Carried forward from PHASE01, still open:**

- `Avalonia.Headless.XUnit` `12.1.0` compatibility with `xunit.v3` `4.0.0` remains
  **unverified** — out of scope per the plan, and `enigma-icons-avalonia/reference/setup.md`
  now pins `4.0.0` beside it. Nothing observed to suggest a problem, but nothing
  proves one absent either; worth a probe before that snippet is relied on.
- `~/.claude/skills/` holds **plain copies, not junctions**, and no sync script
  exists. Neither phase's edits are live for the user's other sessions until they
  refresh those copies by hand.
- `Carbon.Avalonia.Desktop` / `PhosphorIconsAvalonia` remain in the CPM Desktop
  group and in `dotnet-solution-config`'s ecosystem-coupling bullet despite being
  replaced by the Enigma.* skills — deliberately left alone (plan decision 13);
  worth its own work item.

**Line endings (CRLF):** the repo has `core.autocrlf=true`, so `git diff --stat`
emitted the usual "LF will be replaced by CRLF" advisory on all eight touched
files. Per the house rule this is a **recommendation only** — nothing was changed
for it. A `.gitattributes` `* text=auto eol=lf` rule would silence it permanently;
that decision is the user's.

## Build/test evidence

**There is nothing to build or test in this repo** — the deliverables are Claude
Code skill prompt files and two MSBuild templates that are never built here (they
are copied into consuming solutions). Definition-of-Done criteria 1–2 are met by
the documentation equivalents. PHASE01 already executed the item's one real dry run
(the SDK 10.0.300 probe); this phase consumes its recorded result rather than
re-running it, which is exactly what the two-phase split was for.

**Well-formedness**

- **Both edited templates parse as XML** — validated with `[xml](Get-Content -Raw …)`:
  `Directory.Packages.props` **OK**, `test.csproj` **OK**.
- **All four edited markdown files have balanced code fences** — 4, 4, 8 and 20
  fence markers respectively (all even).
- **Every edited table is rectangular by pipe count** — `dotnet-solution-config`
  mistakes table 3 pipes × 12 lines (including the new row), `dotnet-release`
  license-audit table 4 pipes × 6 lines, `dotnet-solution-setup` mistakes table
  3 pipes × 9 lines.
- **`docs/roadmap.md` stays aligned** — all 32 table lines are 95 characters.

**Content verified by grep**

| Check | Result |
|---|---|
| `grep -rn "3\.2\.2" .claude/skills/` | **0 hits** (AC2) |
| `grep -rn "coverlet\.collector" .claude/skills/` | 5 hits, all plan-mandated and all advising *against* it (AC1 — see *Deviations*) |
| `grep -rn "coverlet" …` minus `coverlet.collector` | **0** — no stray `coverlet.MTP` or other mention outside the authority |
| `grep -c "UseMicrosoftTestingPlatformRunner" templates/test.csproj` | **0** (AC4 — the "Run A succeeded" case) |
| `grep -c "coverlet" templates/test.csproj` | **0** |
| Sibling `**Version:**` lines | unchanged: `dotnet-solution-config v2`, `dotnet-solution-setup v2`, `dotnet-release v4` (AC6) |

**Cross-skill consistency sweep (AC5).** Every file under `.claude/skills/`
mentioning `xunit`, `Microsoft.NET.Test.Sdk`, `MTP`, `Testing.Platform` or
`dotnet test` was listed and read — nine files. Six are this phase's targets;
`xunit-v3/SKILL.md` is the authority. The remaining two were **cleared, not
skipped**: `dotnet-di-design/SKILL.md`'s hits are `Smtp`/`SmtpOptions` matching on
"mtp" — false positives, no xUnit content at all — and
`dotnet-release/templates/RELEASE.md`'s single hit is the `dotnet test` pre-flight
noted as a follow-up above. **No sibling skill contradicts the authority.**

**Diff scope** — `git status --porcelain` shows exactly the eight intended files,
`git diff --stat` 16 insertions / 15 deletions. No stray edits, no unrelated files.
