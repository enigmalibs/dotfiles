# FEATURE-79A1-PHASE03 — `xunit-v3` alignment (DONE)

Final phase of FEATURE-79A1. Makes `xunit-v3` agree with Enigma.Core (EC) and with the two templates
PHASE01/PHASE02 produced, so all three sources describe the same test project.

## Summary

- **D2 — narrowed the package ban.** The skill previously forbade `Microsoft.NET.Test.Sdk`,
  `xunit.runner.visualstudio` **and** `coverlet.collector` in one breath — banning a package EC actually
  depends on for coverage. Split into two explicit bullets: **forbidden** (the two VSTest-era packages
  that really do break MTP) and **sanctioned opt-in** (`coverlet.collector` with `PrivateAssets="all"`).
  The *Common stale v2-isms* row now names only the VSTest boilerplate.
- **TFM mirroring rule.** Replaced the flat "test projects target `net10.0`" with a new **Target
  frameworks** section: a test project mirrors the TFMs of the library under test — a multi-targeted
  library gets `net8.0;net10.0`, a single-TFM library or an app gets `net10.0` alone — plus the note that
  `netstandard2.0` is never itself a test TFM.
- **Naming convention.** `<ProjectUnderTest>.Tests` → **`<ProjectUnderTest>.UnitTests`** (EC's
  `Enigma.Core.UnitTests`), with a new **Naming** section explaining that it leaves room for a sibling
  `.IntegrationTests`. Every occurrence updated, including the test example's namespace.
- **D4 — CPM-correct csproj example.** Dropped the inline `Version="3.2.2"` and the four
  `Directory.Build.props`-owned properties from the example, and added three bullets saying where each
  now lives (CPM central version, with the non-CPM inline form shown as the explicit fallback;
  `Directory.Build.props`; and the fuller bundled `templates/test.csproj`). Kept the "3.2.2 is stable as
  of 2026-07; xUnit 4.x is prerelease" note.
- **Housekeeping.** Version line `xunit-v3 v2`; new **Cross-references** section; a pointer that
  `dotnet-solution-config` owns `global.json` as a whole; and PHASE02's
  `dotnet test --solution <Solution>.slnx` note carried into the run section, where this skill's readers
  will actually hit it.

## Files/modules touched

### Modified
- `.claude/skills/xunit-v3/SKILL.md` — the whole of the above. New sections: **Naming**,
  **Target frameworks**, **Common mistakes**, **Cross-references**. Rewritten: the house-rule lead
  paragraph, the *Project setup* package guidance, the csproj example + its explanatory bullets, the
  `global.json`/run notes, the *Common stale v2-isms* boilerplate row, and the test example's namespace.

### Modified — tracking
- `docs/roadmap.md` — PHASE03 `TODO` → `IN PROGRESS` → `DONE`; **FEATURE-79A1** itself
  `IN PROGRESS` → `DONE` (final phase).
- `docs/plan/FEATURE-79A1.md` — same, for the item header and the PHASE03 section.

### Created
- `docs/done/FEATURE-79A1-PHASE03.md` (this file).

## Deviations & follow-ups

- **Table split (beyond the plan's letter, in its spirit).** Step 1 only asked me to fix the
  boilerplate row of *Common stale v2-isms*. Three of the rules this phase introduces — the
  `.UnitTests` name, TFM mirroring, and no-inline-`Version`-under-CPM — are **not** v2 habits at all, so
  putting them in a "stale v2-isms" table would have been miscategorised. They went into a new
  **Common mistakes** table instead, matching the house shape used by `dotnet-solution-setup` and
  `dotnet-solution-config`. The v2-isms table keeps only genuine v2→v3 migration traps.
- **AC3 satisfied literally, which required one rewording.** The plan's AC3 is a mechanical check:
  `grep -n "\.Tests" .claude/skills/xunit-v3/SKILL.md` must return nothing. Two of my first-pass lines
  cited `.Tests` only to *forbid* it — arguably fine under the criterion's intent, but a criterion that
  verifies literally is worth more than one needing a footnote, so both were reworded to "a bare `Tests`
  suffix". The grep now returns **zero** hits. (Contrast PHASE02's AC1b, where EC's mandated comment
  wording made the literal reading impossible; that one is documented as an intent-based pass.)
- **`description:` deliberately left unchanged.** Step 5 says refresh it "if the naming/TFM change makes
  it inaccurate". It doesn't — "creating a test project, choosing test packages, running dotnet test…"
  covers all of this phase's content and remains an accurate routing signal. No edit made.
- **Example TFM kept single (`net10.0`) with the multi form in a comment.** The bundled
  `templates/test.csproj` shows `net8.0;net10.0` because it accompanies the multi-targeted
  `templates/library.csproj`. The skill's inline example keeps the simpler single-TFM default and names
  the multi-target alternative in a comment, so both agree with the mirroring rule rather than hard-coding
  one branch of it.
- **Line endings (CRLF):** none observed — the file is LF throughout. No recommendation needed.
- **`FEATURE-003` still open (third and final mention).** `git-repo-hygiene`'s roadmap row remains
  `IN PROGRESS` though the skill is complete and is now at v2. Untouched by all three phases; it needs a
  decision from you (close as `DONE`, or re-scope), not a build.
- **Successor item:** `FEATURE-6D97` (`dotnet-release`: EC doc templates) is the planned follow-on and
  owns everything this item deferred — the library csproj's NuGet packaging metadata, `docs/guides/`,
  and `msiProfiles/`.

## Build/test evidence

**Nothing to build or test** — `.claude/skills/xunit-v3/SKILL.md` is a markdown prompt file, symlinked
live into `~/.claude/skills/`; no build step, no install step, no test suite. Definition-of-Done criteria
1–2 are met by the applicable equivalent — mechanical verification of each criterion:

| AC | Check | Result |
|---|---|---|
| 1 | `coverlet.collector` present as a sanctioned opt-in with `PrivateAssets="all"` | `:27` (prose), `:41` (example), `:116` (mistake row) ✓ |
| 1 | `coverlet.collector` absent from every forbidden list | forbidden bullet `:26` names only the two VSTest packages ✓ |
| 1 | `Microsoft.NET.Test.Sdk` + `xunit.runner.visualstudio` still forbidden | `:26`, `:101` ✓ |
| 2 | TFM rule states **both** branches | `:18` — multi-targeted → `net8.0;net10.0`; single-TFM/app → `net10.0` alone; plus `:20` on `netstandard2.0` ✓ |
| 3 | `grep -n "\.Tests" .claude/skills/xunit-v3/SKILL.md` | **zero occurrences** ✓ (exit 1) |
| 4 | `Version=` inside the csproj example block | **absent** (parsed the fenced block, `'Version=' in block` → `False`) ✓ |
| 4 | the four `Directory.Build.props` properties inside the example | **absent** (asserted each of `LangVersion`, `Nullable`, `ImplicitUsings`, `TreatWarningsAsErrors`) ✓ |
| 5 | three-way consistency | see table below ✓ |
| 6 | version line `xunit-v3 v2` | `:8` ✓ |
| 6 | cross-references resolve | `dotnet-solution-setup`, `dotnet-solution-config`, `dotnet-async` all exist on disk ✓ |

### AC5 — three-way consistency check

| Dimension | `xunit-v3/SKILL.md` | `dotnet-solution-config/templates/Directory.Packages.props` | `dotnet-solution-setup/templates/test.csproj` | Agree? |
|---|---|---|---|---|
| Package set | `xunit.v3` + `coverlet.collector` (`PrivateAssets="all"`) | `xunit.v3` + `coverlet.collector` | `xunit.v3` + `coverlet.collector` (`PrivateAssets="all"`) | **yes** |
| `Microsoft.NET.Test.Sdk` | forbidden (`:26`) | absent — only named in the prohibitive comment | absent | **yes** |
| Versions | none inline; points at CPM, cites 3.2.2 | `xunit.v3` 3.2.2, `coverlet.collector` 6.0.4 | none inline (CPM) | **yes** |
| TFMs | mirror rule: multi → `net8.0;net10.0`, single/app → `net10.0` | n/a | `net8.0;net10.0` (multi-targeted library case, per its comment) | **yes** |
| Project name | `<ProjectUnderTest>.UnitTests` | n/a | `tests/<Project>.UnitTests/…` (checklist row 10) | **yes** |
| `Directory.Build.props` properties | omitted, with reason | n/a (owns them) | omitted, with reason | **yes** |

All three sources now describe one test project. EC is the fourth witness: `Enigma.Core.UnitTests`,
`net8.0;net10.0`, `xunit.v3` + `coverlet.collector PrivateAssets="all"`, no inline versions, no
`Directory.Build.props` properties — matched element for element.

## FEATURE-79A1 closure

All three phases are `DONE`, so the item is complete:

| Phase | Deliverable | Status |
|---|---|---|
| PHASE01 | `dotnet-solution-setup`: 4 bundled templates + the 11-step bootstrap checklist | DONE |
| PHASE02 | `dotnet-solution-config` + `git-repo-hygiene`: D1, D3 (+ the `ImplicitUsings` gap) | DONE |
| PHASE03 | `xunit-v3`: D2, D4, TFM mirroring, `.UnitTests` naming | DONE |

All four defects from the item's defect table (D1–D4) are closed, and four skills carry a version line:
`dotnet-solution-setup v2`, `dotnet-solution-config v2`, `git-repo-hygiene v2`, `xunit-v3 v2`.
