# FEATURE-79A1-PHASE01 — `dotnet-solution-setup`: bundled templates + bootstrap checklist — DONE

## Summary
Fed the Enigma.Core (EC) bootstrap back into `dotnet-solution-setup`. The skill gained
**four bundled templates** (`Solution.slnx`, `library.csproj`, `test.csproj`, `LICENSE.md`)
derived from EC's real project files, and an **ordered "New solution bootstrap" checklist**
naming all 11 root artifacts, their creation order, and the owning skill for each.

The checklist is the fix for the reported confusion about what `dotnet-solution-setup` vs
`dotnet-solution-config` vs `git-repo-hygiene` actually do: the three-skill split is unchanged,
it just gained a single entry point that answers "which skill do I call, and when?".

`library.csproj` deliberately omits NuGet packaging metadata (that block belongs to
`dotnet-release`, added at release time) and omits the four `Directory.Build.props`-owned
properties. Both csproj templates are CPM-clean — no `Version=` on any `PackageReference`.
`LICENSE.md` closes a real hole: no skill owned it, yet `dotnet-release` requires it to exist
and be packed.

## Files/modules touched
**Created**
- `.claude/skills/dotnet-solution-setup/templates/Solution.slnx` — `/src/` + `/tests/` solution
  folders, `{{PROJECT}}` placeholder.
- `.claude/skills/dotnet-solution-setup/templates/library.csproj` — multi-targeted
  (`netstandard2.0;net8.0;net10.0`) library with the conditional `System.Buffers` (NU1510) and
  `PolySharp` groups, EC's explanatory comments intact.
- `.claude/skills/dotnet-solution-setup/templates/test.csproj` — MTP-native xUnit v3 test project
  (`net8.0;net10.0`, `OutputType=Exe`, `xunit.v3` + `coverlet.collector`), fixture copy-glob.
- `.claude/skills/dotnet-solution-setup/templates/LICENSE.md` — MIT text, `{{YEAR}}`/`{{AUTHORS}}`.
- `docs/done/FEATURE-79A1-PHASE01.md` — this record.

**Modified**
- `.claude/skills/dotnet-solution-setup/SKILL.md` — added the version line
  (`dotnet-solution-setup v2`), the "New solution bootstrap" checklist section (11 rows +
  the empty-placeholder convention + the release-time forward pointer), a "Bundled files"
  section (the skill had none) carrying the create-only-if-missing / diff-never-clobber rule,
  and two "Common mistakes" rows (repeating `Directory.Build.props` values in a csproj;
  unconditional `System.Buffers` → NU1510). Refreshed the frontmatter `description:`.
- `docs/roadmap.md` — `FEATURE-79A1` and its `PHASE01` row → `IN PROGRESS`, then `PHASE01` → `DONE`.
- `docs/plan/FEATURE-79A1.md` — item and PHASE01 status transitions.

## Deviations & follow-ups
- **`templates/LICENSE.md` ends with a final newline; EC's does not** (its last byte is `*`).
  AC2 asked for a byte-clean diff, but EC's own `LICENSE.md` violates the `insert_final_newline = true`
  rule of the `.editorconfig` shipped alongside it — the same defect class D3 fixes for
  `Directory.Build.props`. Shipping it byte-perfect would propagate that defect into every solution
  bootstrapped from the template. **User decision: add the newline.** The rendered diff against EC is
  therefore exactly one byte; content is otherwise verified identical (`cmp` clean with the newline
  stripped).
- **`test.csproj` comments are generalized, not EC-verbatim.** AC3 says "every other comment matches",
  but PHASE01 Step 3 explicitly directs generalizing the fixture-glob comment ("keep only the
  extensions the suite actually loads") and adding the single-TFM/app note to the TFM comment. Step 3
  wins over AC3's blanket comment clause; the two affected comment blocks are the only ones that
  differ, and no element, condition, attribute or ordering differs.
- **`library.csproj` replaces the stripped packaging block with two explanatory comments** stating
  *why* the packaging metadata and the four `Directory.Build.props` properties are absent — so a
  reader doesn't "helpfully" add them back. Within AC3's permitted packaging-metadata delta.
- **Bundled filenames keep real extensions** (`library.csproj`, not `library.csproj.template`),
  following the `dotnet-solution-config/templates/Directory.Build.props` precedent — the un-dotted
  rule exists so bundled files don't act as live *dotfile* configs; `dotfiles2` is not a .NET repo,
  so no MSBuild discovery risk. `Solution.slnx` keeps a generic stem rather than a project name.
- **Line endings (CRLF):** none observed — all touched files are LF. No action (recommendation-only
  per the workflow).
- **Follow-up, not touched here (plan records it as observation only):** `docs/roadmap.md` still shows
  `FEATURE-003` (`git-repo-hygiene` skill) as `IN PROGRESS` although the skill exists and is complete.
  Worth closing or re-scoping.
- **Downstream phases depend on this one:** `test.csproj` here already assumes PHASE02's CPM Tests
  group (`xunit.v3` + `coverlet.collector`, no `Microsoft.NET.Test.Sdk`) and PHASE03's sanctioning of
  `coverlet.collector`. Until those land, `dotnet-solution-config` and `xunit-v3` disagree with this
  template — expected and resolved by the remaining phases.

## Build/test evidence
Prompt/template-only change to markdown and template files — **nothing to compile and no test suite**
(DoD criteria 1–2 satisfied by the no-build/no-test equivalent: well-formedness + verified diffs).

- **AC1** — all four templates exist. `xml.dom.minidom.parse` → *well-formed* for `Solution.slnx`,
  `library.csproj`, `test.csproj`; `LICENSE.md` non-empty (14 lines). All four end in exactly one `0a`.
- **AC2** — `Solution.slnx` with `{{PROJECT}}=Enigma.Core` → `diff` against
  `/home/jo/Dev/Enigma.Core/Enigma.Core.slnx` is **clean, 0 differences**. `LICENSE.md` with
  `{{YEAR}}=2026` / `{{AUTHORS}}=Josué Clément` → differs from EC's only by the deliberate final
  newline (above); `cmp` of the newline-stripped render against EC's file is clean.
- **AC3** — structural diffs recorded, both containing **only** the permitted deltas:
  - `library.csproj` vs EC's: the 10 packaging-metadata `PropertyGroup` entries (`PackageId`,
    `Version`, `Title`, `Description`, `PackageTags`, `PackageReadmeFile`, `PackageLicenseFile`,
    `RepositoryUrl`, `RepositoryType`, `PackageProjectUrl`, `PackageReleaseNotes`), the README/LICENSE
    packing `ItemGroup`, and the `BouncyCastle.Cryptography` `ItemGroup` — each replaced by the
    explanatory comments noted above. `OutputType`, `TargetFrameworks`, `GenerateDocumentationFile`,
    both conditional `ItemGroup`s, their `Condition` attributes, `PrivateAssets="all"`, the NU1510 and
    PolySharp comments, and all ordering match exactly.
  - `test.csproj` vs EC's: the test-only `BouncyCastle.Cryptography` reference (plus its comment), and
    the two generalized comment blocks. `TargetFrameworks`, `OutputType`, `xunit.v3`,
    `coverlet.collector PrivateAssets="all"`, the `ProjectReference` path, all five `None Update` globs
    with `PreserveNewest`, and all ordering match exactly.
- **AC4** — the checklist table has exactly **11** numbered rows, in order, each naming an owning
  skill; followed by the empty-`README.md`/`RELEASENOTES.md` convention and the "Appears later, not at
  bootstrap" note covering `docs/guides/`, `msiProfiles/` and release-time packaging metadata.
- **AC5** — `grep -E '<(LangVersion|Nullable|ImplicitUsings|TreatWarningsAsErrors)>'` over both csproj
  templates → **no matches**. `grep 'PackageReference[^>]*Version='` over both → **no matches**.
- **AC6** — "Bundled files" section lists all four templates with a one-line purpose each;
  frontmatter `description:` refreshed to mention the checklist and the templates; version line
  `**Version: dotnet-solution-setup v2.**` present under the `#` heading.
