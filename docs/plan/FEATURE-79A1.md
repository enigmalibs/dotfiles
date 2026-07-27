# FEATURE-79A1 — Solution-bootstrap skills: EC-derived templates & bootstrap checklist

**Status:** DONE
**Type:** FEATURE (multi-phase)
**Branch (per phase, at build time):** `feature/feature-79a1-phaseNN-<slug>` — one branch per phase, cut from current `HEAD`.

## Objective

Feed the lessons of the **Enigma.Core** (EC) bootstrap back into the solution-bootstrap skill family, so
the next .NET solution is scaffolded correctly on the first try. Three outcomes:

1. **Bundle the reusable project files** EC proved out — `.slnx`, a multi-targeted library `.csproj`, an
   MTP-native test `.csproj`, and the MIT `LICENSE.md` — as templates in `dotnet-solution-setup`.
2. **Add one ordered "New solution bootstrap" checklist** to `dotnet-solution-setup` that names every
   root file, its owning skill, and the creation order. This is the fix for the reported confusion about
   what `dotnet-solution-setup` vs `dotnet-solution-config` actually do — the three-skill split stays, it
   just gains a single entry point.
3. **Resolve three real defects/contradictions** the EC audit surfaced (below).

## Context & constraints

- **Evolution of an existing codebase:** `/home/jo/dotfiles2`, skills at `.claude/skills/`, symlinked
  live into `~/.claude/skills/`. Edits take effect immediately — no build, no install step, no tests.
- **Reference project:** `/home/jo/Dev/Enigma.Core` @ `fa78784`. The bootstrap to reproduce is commit
  `8bf9fa7` (`chore(FEATURE-56AA): bootstrap repository & solution`); the release work that added
  `docs/guides/` is `FEATURE-4620`, polished by `FEATURE-28C7`.
- **EC was built *by* these skills**, so most templates already match. Verified during the interview:
  - `.gitignore` — **byte-identical** to `git-repo-hygiene/templates/gitignore`. **No work.**
  - `.editorconfig` — **byte-identical** to `dotnet-solution-config/templates/editorconfig`. **No work.**
  - `Directory.Build.props` — the template with `{{AUTHORS}}`/`{{YEAR}}` filled. **Structurally correct.**
  - `Directory.Packages.props` — the template's shape (one commented `ItemGroup` per concern).
    **Structurally correct**; only its Tests group contents are wrong (see PHASE02).
  - `.gitattributes` — differs by exactly one line: `*.bin binary`.
- **`docs/guides/` and `msiProfiles/` are NOT bootstrap artifacts.** They appear later, at release time
  (`dotnet-release`). The checklist mentions them only as a forward pointer.
- Skills are markdown prompt files: the Definition of Done's criteria 1–2 are met by inspection and by
  the byte-diffs in the acceptance criteria (state explicitly that there was nothing to build or test).

## Defects & contradictions this item fixes

| # | Defect | Fix | Phase |
|---|--------|-----|-------|
| D1 | `dotnet-solution-config/templates/Directory.Packages.props` Tests group lists `Microsoft.NET.Test.Sdk`, which the `xunit-v3` skill explicitly forbids and EC omits (it breaks MTP). | Tests group → `xunit.v3` + `coverlet.collector` only. | PHASE02 |
| D2 | `xunit-v3` forbids `coverlet.collector`, but EC uses it (with `PrivateAssets="all"`) for coverage — the skill bans a package the reference project depends on. | Narrow the ban to the VSTest boilerplate; sanction coverlet as the coverage opt-in. | PHASE03 |
| D3 | `dotnet-solution-config/templates/Directory.Build.props` has no final newline, while the `.editorconfig` it ships alongside mandates `insert_final_newline = true`. | Add the trailing newline. | PHASE02 |
| D4 | `xunit-v3`'s csproj example carries `Version="3.2.2"` inline on the `PackageReference`, which is invalid under the Central Package Management that `dotnet-solution-config` sets up. | Show the CPM form (no `Version`) and note where the version lives. | PHASE03 |

## Versioning

Every skill touched gains a `**Version: <skill> v<N>.**` line under its `#` heading, matching the
`dev-workflow v3` precedent. Numbers are derived by counting material revisions from the roadmap, so the
line is traceable rather than arbitrary:

| Skill | History | New line |
|---|---|---|
| `dotnet-solution-setup` | v1 = pre-tracking origin | `**Version: dotnet-solution-setup v2.**` |
| `dotnet-solution-config` | v1 = FEATURE-006 (creation) | `**Version: dotnet-solution-config v2.**` |
| `git-repo-hygiene` | v1 = FEATURE-003 (creation) | `**Version: git-repo-hygiene v2.**` |
| `xunit-v3` | v1 = pre-tracking origin | `**Version: xunit-v3 v2.**` |

## Conventions for all new bundled templates

- **Placeholder style** `{{UPPER_SNAKE}}`, matching `dotnet-release/templates/RELEASE.md` and
  `msiprofile.template.json`.
- **Create only if missing; diff, never clobber** — the rule already stated in both
  `dotnet-solution-config` and `git-repo-hygiene` extends to every template added here.
- **Un-dotted / non-colliding bundled filenames**, per the existing rationale (a bundled file must not
  act as a real config or shadow the skill's own docs).
- Each new template is listed in its skill's **Bundled files** section with a one-line purpose.

---

## PHASE01 — `dotnet-solution-setup`: bundled templates + bootstrap checklist

**Status:** DONE

**Goal:** four new bundled templates plus the ordered bootstrap checklist, so a new solution's project
files and root license come from a template instead of being retyped.

### Step 1 — `templates/Solution.slnx`

EC's `.slnx` shape: solution folders `/src/` and `/tests/`, one project each.

```xml
<Solution>
  <Folder Name="/src/">
    <Project Path="src/{{PROJECT}}/{{PROJECT}}.csproj" />
  </Folder>
  <Folder Name="/tests/">
    <Project Path="tests/{{PROJECT}}.UnitTests/{{PROJECT}}.UnitTests.csproj" />
  </Folder>
</Solution>
```

### Step 2 — `templates/library.csproj`

EC's `src/Enigma.Core/Enigma.Core.csproj` **minus its NuGet packaging metadata** (that block is
`dotnet-release`'s responsibility and is added at release time — leave a comment saying so) and minus its
crypto-specific `BouncyCastle` reference. It must carry, with EC's explanatory comments intact:

- `<OutputType>Library</OutputType>`, `<TargetFrameworks>netstandard2.0;net8.0;net10.0</TargetFrameworks>`,
  `<GenerateDocumentationFile>true</GenerateDocumentationFile>`.
- **No** `LangVersion` / `Nullable` / `ImplicitUsings` / `TreatWarningsAsErrors` — those come from
  `Directory.Build.props` and must never be repeated per-project.
- The **`System.Buffers` conditional `ItemGroup`** guarded by
  `Condition="'$(TargetFramework)' == 'netstandard2.0'"`, carrying EC's comment: `System.Buffers` is
  framework-provided on net8.0+, so referencing it there raises **NU1510** and fails a
  `TreatWarningsAsErrors` build.
- The **`PolySharp` conditional `ItemGroup`** (same condition) with `PrivateAssets="all"` and EC's
  comment that it is compile-only (polyfills modern C# on `netstandard2.0`).
- No `Version` attributes anywhere (CPM).

### Step 3 — `templates/test.csproj`

EC's `tests/Enigma.Core.UnitTests/Enigma.Core.UnitTests.csproj`, minus its crypto-specific test-only
`BouncyCastle` reference:

- `<TargetFrameworks>net8.0;net10.0</TargetFrameworks>` with EC's comment explaining **why** it
  multi-targets (exercise the library's `net8.0` code paths and the `netstandard2.0` polyfill surface
  reachable through them) — plus a note that a single-TFM library or an app gets `net10.0` alone.
- `<OutputType>Exe</OutputType>` with the "Main is generated by xunit.v3.core" comment.
- `PackageReference` to `xunit.v3` and to `coverlet.collector` with `PrivateAssets="all"`, both without
  `Version` (CPM).
- `ProjectReference` to `../../src/{{PROJECT}}/{{PROJECT}}.csproj`.
- The **fixture copy-glob `ItemGroup`** (`None Update` + `CopyToOutputDirectory=PreserveNewest`) that EC
  uses for `*.csv`, `*.pem`, `*.key`, `*.bin`, `*.txt`, generalized with a comment saying to keep only
  the extensions the suite actually loads by relative path.

### Step 4 — `templates/LICENSE.md`

EC's reworded MIT text verbatim, with `{{YEAR}}` and `{{AUTHORS}}` substituted into the copyright line
and the warranty paragraph left bold exactly as EC has it. (No skill currently owns `LICENSE.md`, yet
`dotnet-release` requires it to exist and be packed — this closes that hole at bootstrap time.)

### Step 5 — the "New solution bootstrap" checklist in `SKILL.md`

One ordered section reproducing EC's `8bf9fa7`, each entry naming the **owning skill**:

| Order | Artifact | Owner |
|---|---|---|
| 1 | `git init -b <branch>` (or an existing repo) | user / `dev-workflow` |
| 2 | `.gitignore`, `.gitattributes` | `git-repo-hygiene` |
| 3 | `.editorconfig` (the full C# one, not the minimal hygiene one) | `dotnet-solution-config` |
| 4 | `Directory.Build.props`, `Directory.Packages.props` | `dotnet-solution-config` |
| 5 | `global.json` — SDK pin **and** the MTP `test.runner` entry | `dotnet-solution-config` |
| 6 | `LICENSE.md` | `dotnet-solution-setup` (`templates/LICENSE.md`) |
| 7 | `README.md`, `RELEASENOTES.md` — created **empty**; filled at release time | `dotnet-release` fills them |
| 8 | `<Solution>.slnx` | `dotnet-solution-setup` |
| 9 | `src/<Project>/<Project>.csproj` | `dotnet-solution-setup` |
| 10 | `tests/<Project>.UnitTests/<Project>.UnitTests.csproj` + one smoke test | `dotnet-solution-setup` / `xunit-v3` |
| 11 | `docs/roadmap.md`, `docs/plan/`, `docs/done/` | `dev-workflow` |

Followed by a short **"appears later, not at bootstrap"** note: `docs/guides/` and `msiProfiles/` are
created by `dotnet-release`, and the library's NuGet packaging metadata is added at release time.

EC's empty-`README.md`/`RELEASENOTES.md` convention is worth stating explicitly: they exist from the
first commit as 0-byte placeholders so the release phase has something to fill rather than something to
invent.

### Step 6 — housekeeping

- Add the four templates to a **Bundled files** section (the skill currently has none).
- Refresh the frontmatter `description:` to mention the bootstrap checklist and the bundled templates.
- Add the version line (`dotnet-solution-setup v2`).
- Keep the existing "Decisions to surface when scaffolding" and "Common mistakes" sections; add mistake
  rows for repeating `Directory.Build.props` values in a csproj, and for referencing `System.Buffers`
  unconditionally (NU1510).

**Acceptance criteria**

1. `templates/Solution.slnx`, `templates/library.csproj`, `templates/test.csproj`, `templates/LICENSE.md`
   exist and are well-formed.
2. **Byte-diff:** with `{{PROJECT}}` = `Enigma.Core`, `templates/Solution.slnx` diffs clean against
   `/home/jo/Dev/Enigma.Core/Enigma.Core.slnx`. With `{{YEAR}}`/`{{AUTHORS}}` filled as EC filled them,
   `templates/LICENSE.md` diffs clean against EC's `LICENSE.md`.
3. **Structural diff:** `templates/library.csproj` and `templates/test.csproj` diff against EC's two
   csprojs with **only** these differences — the packaging-metadata `PropertyGroup` entries and the
   README/LICENSE packing `ItemGroup` (library), and the BouncyCastle references (both). Every other
   element, condition, comment and ordering matches. Record the diff in the completion doc.
4. The bootstrap checklist lists all 11 artifacts in order with an owning skill each, and states that
   `docs/guides/`, `msiProfiles/` and packaging metadata are release-time.
5. No `LangVersion` / `Nullable` / `ImplicitUsings` / `TreatWarningsAsErrors` in either csproj template,
   and no `Version=` attribute on any `PackageReference`.
6. Bundled-files section lists all four templates; `description:` refreshed; version line present.

---

## PHASE02 — `dotnet-solution-config` + `git-repo-hygiene` fixes

**Status:** DONE

**Goal:** correct the three template defects and bring the CPM skeleton in line with what EC actually
ships.

### Step 1 — `templates/Directory.Packages.props`

- **Tests group (D1):** replace `Microsoft.NET.Test.Sdk` + `xunit.v3` + `coverlet.collector` with
  **`xunit.v3` + `coverlet.collector` only**, at EC's versions (`xunit.v3` 3.2.2,
  `coverlet.collector` 6.0.4). Retitle the comment to EC's wording: *MTP-native: `xunit.v3` only;
  `coverlet.collector` for coverage. No `Microsoft.NET.Test.Sdk`.*
- **Core group:** add EC's real netstandard2.0-support entries as the commented example —
  `PolySharp` 1.16.0 and `System.Buffers` 4.6.1 — with a comment noting they pair with the conditional
  `PackageReference`s in `dotnet-solution-setup/templates/library.csproj`.
- Leave the CLI and Desktop groups (including the coupled-ecosystem comment) as they are.

### Step 2 — `templates/Directory.Build.props` (D3)

Add the missing final newline. Nothing else changes — the file's structure is already what EC ships.

### Step 3 — `global.json` guidance in `SKILL.md`

The skill currently shows only the SDK pin. Extend it to EC's actual file:

```json
{
  "sdk": { "version": "10.0.100", "rollForward": "latestFeature" },
  "test": { "runner": "Microsoft.Testing.Platform" }
}
```

Add EC's hard-won invocation note (from `docs/done/FEATURE-56AA.md`): on the .NET 10 SDK in MTP mode,
`dotnet test <solution>` is **rejected** — the solution must be passed as
`dotnet test --solution <Solution>.slnx`. Cross-reference `xunit-v3` for the runner entry itself.

### Step 4 — `git-repo-hygiene/templates/gitattributes`

Add `*.bin binary` as the **first** entry of the forced-binary list, immediately after the
"Belt-and-suspenders" comment and before `*.png binary` — the position EC has it (line 20).

### Step 5 — housekeeping

- Both skills: version line (`dotnet-solution-config v2`, `git-repo-hygiene v2`).
- `dotnet-solution-config`: cross-reference the new bootstrap checklist in `dotnet-solution-setup` so the
  "which skill do I call?" question is answered from either side.
- `git-repo-hygiene`: no scope change, so its `description:` stays; `dotnet-solution-config`'s gains the
  `global.json` mention.

**Acceptance criteria**

1. **Byte-diff:** the Tests `ItemGroup` of `templates/Directory.Packages.props`, uncommented, diffs clean
   against the Tests `ItemGroup` of `/home/jo/Dev/Enigma.Core/Directory.Packages.props` (comment wording
   included). No `Microsoft.NET.Test.Sdk` remains anywhere in the template.
2. **Byte-diff:** `templates/gitattributes` diffs clean against EC's `.gitattributes` (zero differences —
   this is the file's only outstanding delta).
3. `templates/Directory.Build.props` ends with exactly one newline; with `{{AUTHORS}}`/`{{YEAR}}` filled,
   its `PropertyGroup` diffs clean against EC's (comments excepted).
4. The `SKILL.md` `global.json` snippet is valid JSON containing both the `sdk` and `test` keys, and the
   `dotnet test --solution` note is present.
5. Both skills carry a version line; `dotnet-solution-config` cross-references the bootstrap checklist.
6. Nothing to build or test — state so in the completion doc.

---

## PHASE03 — `xunit-v3` alignment

**Status:** DONE

**Goal:** make `xunit-v3` agree with EC and with the two templates the earlier phases produce, so all
three sources describe the same test project.

### Step 1 — narrow the package ban (D2)

Current text forbids `Microsoft.NET.Test.Sdk`, `xunit.runner.visualstudio` **and**
`coverlet.collector` in one breath. Split them:

- **Forbidden (VSTest-era, actively breaks MTP):** `Microsoft.NET.Test.Sdk`,
  `xunit.runner.visualstudio`.
- **Sanctioned opt-in:** `coverlet.collector` with `PrivateAssets="all"`, when coverage is wanted. It
  works under MTP; it is `Microsoft.NET.Test.Sdk` that conflicts. Note that the house CPM skeleton lists
  it in the Tests group.

Update the corresponding row of the **Common stale v2-isms** table so it names only the VSTest
boilerplate.

### Step 2 — TFM mirroring rule

Replace the flat "test projects target `net10.0`" rule with:

> A test project **mirrors the TFMs of the library under test**. A multi-targeted library
> (`netstandard2.0;net8.0;net10.0`) gets a `net8.0;net10.0` test project, so its `net8.0` code paths —
> and the `netstandard2.0` polyfill surface reachable through them — are actually exercised rather than
> shipped untested. A single-TFM library or an app gets `net10.0` alone.

Note that `netstandard2.0` itself is never a *test* TFM (it isn't a runtime); `net8.0` is what exercises
the polyfilled surface.

### Step 3 — naming convention

`<ProjectUnderTest>.Tests` → **`<ProjectUnderTest>.UnitTests`** (EC's `Enigma.Core.UnitTests`), leaving
room for a sibling `<ProjectUnderTest>.IntegrationTests`. Update every occurrence, including the
`ProjectReference` path in the csproj example and any prose reference.

### Step 4 — CPM-correct csproj example (D4)

- Drop the inline `Version="3.2.2"` from the `PackageReference` and note that under Central Package
  Management (`dotnet-solution-config`) the version lives in `Directory.Packages.props`; show the inline
  form only as the non-CPM fallback.
- Drop `LangVersion` / `Nullable` / `ImplicitUsings` / `TreatWarningsAsErrors` from the example — they
  come from `Directory.Build.props` — and point at `dotnet-solution-setup/templates/test.csproj` as the
  full bundled version.
- Keep the "3.2.2 is stable as of 2026-07; xUnit 4.x is prerelease" version note.

### Step 5 — housekeeping

Version line (`xunit-v3 v2`); refresh `description:` if the naming/TFM change makes it inaccurate; add
cross-references to `dotnet-solution-setup` (the bundled `test.csproj`) and `dotnet-solution-config` (the
CPM Tests group and the `global.json` runner entry).

**Acceptance criteria**

1. `coverlet.collector` appears as a sanctioned opt-in with `PrivateAssets="all"`, and no longer appears
   in any forbidden list. `Microsoft.NET.Test.Sdk` and `xunit.runner.visualstudio` remain forbidden.
2. The TFM rule states the mirroring behaviour with both branches (multi-targeted library → matching
   multi-TFM test project; single-TFM library or app → `net10.0`).
3. `grep -n "\.Tests" .claude/skills/xunit-v3/SKILL.md` returns no naming-convention occurrence —
   all are `.UnitTests`.
4. The csproj example carries no `Version=` attribute in its CPM form and none of the four
   `Directory.Build.props`-owned properties.
5. **Consistency check (cross-phase):** `xunit-v3`, `dotnet-solution-config/templates/Directory.Packages.props`
   and `dotnet-solution-setup/templates/test.csproj` agree on the package set, the TFMs and the project
   name. Record the three-way comparison in the completion doc.
6. Version line present; cross-references resolve. Nothing to build or test.

---

## Out of scope / recorded, not planned here

- **`dotnet-release`** — all of it, including the packaging metadata the library csproj template defers
  to: that is `FEATURE-6D97`, planned alongside this item and built after it.
- **Merging or re-splitting the skills** — the three-skill boundary is deliberately kept; only an entry
  point is added.
- **CI / GitHub Actions** — declined for EC, not introduced here.
- **`docs/guides/` and `msiProfiles/` at bootstrap** — release-time artifacts; the checklist only points
  forward to them.
- **Stale roadmap row (observation only):** `FEATURE-003` (`git-repo-hygiene` skill) is still
  `IN PROGRESS` although the skill exists and is complete. Not touched here — flagged for the user to
  close or re-scope.
- **Line endings (CRLF):** no churn observed in any file inspected. The missing final newline in
  `Directory.Build.props` is a content fix (D3), not a normalization.
