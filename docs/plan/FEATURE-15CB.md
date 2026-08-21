# FEATURE-15CB — xUnit 4.0: update `xunit-v3` and propagate across the skill set

**Status:** TODO
**Type:** FEATURE (multi-phase)
**Branch (per phase, at build time):** `feature/feature-15cb-phaseNN-<slug>` — one branch per phase, cut from current `HEAD`.

## Objective

Bring the house xUnit conventions up to **xUnit.net Core Framework v3 `4.0.0`** (released 2026-08-14) and
correct the two statements the release has made actively wrong:

1. `xunit-v3/SKILL.md` says *"xUnit 4.x is prerelease, don't use it"* — 4.0.0 is stable.
2. It sanctions `coverlet.collector` as *"works fine under MTP"* — `coverlet.collector` is a **VSTest data
   collector**, and 4.0.0 defaults to **MTP v2**, which does not host VSTest data collectors. Following the
   skill today produces a test project whose coverage silently collects nothing.

Then propagate the corrected facts to every sibling skill that repeats them, so the skill set stays
internally consistent.

## Context & constraints

- **Evolution of an existing repo:** `C:\Dev\EnigmaLibs\dotfiles`; the skills live at `.claude/skills/**`
  and are Claude Code skill prompt files.
- **No build, no test suite** — Definition-of-Done criteria 1–2 are met by the documentation equivalents:
  well-formed markdown, plus the **real dry run** specified in PHASE01 Step 1.
- **`~/.claude/skills/` holds plain copies, not junctions**, and there is no sync script in the repo.
  Deploying the updated files there is **out of scope** — the user does it (decided in the interview).
- **Skill-file shape to preserve:** YAML frontmatter (`name`, `description`), `# <Title>` heading, a
  `**Version: <skill> vN.**` line, fenced XML/C#/JSON samples, a *Common mistakes* table, a
  *Cross-references* list, and a closing "if an existing solution differs, stay consistent and flag it"
  sentence.
- **Local toolchain available for verification:** .NET SDKs 8.0.421, 9.0.314, **10.0.300**.

## Upstream facts to encode (verified 2026-08-21)

| Fact | Detail |
|---|---|
| Package ID | **unchanged** — `xunit.v3`, now version `4.0.0` (NuGet 2026-08-15). "v3" is the core-framework *generation*; 4.0.0 is its *version*. This is why the skill keeps its `xunit-v3` name. |
| Companion releases | Analyzers `2.0.0`, Visual Studio adapter `4.0.0` |
| Toolchain floor | Analyzers 2.0.0 needs Roslyn 4.11+ → **SDK 8.0.400+ / VS 2022 17.11+** |
| Minimum TFMs | **net8.0** and **net472** |
| Microsoft Testing Platform | **v1 support removed from 4.0.0 onward**; **MTP v2** (2.3.3) is the default. Variants: `xunit.v3.mtp-v2` (explicit v2), `xunit.v3.mtp-off` (disable MTP). `xunit.v3.mtp-v1` is 3.x-only. |
| Mono | official support discontinued |
| Parallelization | new `parallelMode`: `none` / `collections` (**default, unchanged**) / `all`. `[assembly: CollectionBehavior(…)]` → **`[assembly: Parallelization(…)]`**. Opt-outs at collection / class / method / data-source / data-row level. |
| Coverage | `coverlet.collector` is a VSTest data collector — **not usable under MTP v2**. Replacements: `Microsoft.Testing.Extensions.CodeCoverage` (what xunit.net's own doc prescribes) or `coverlet.MTP` (third-party, needs MTP ≥ 2.0.0). |
| Runner / CI | report switches renamed (`-report-ctrf` → `-report-xunit-ctrf`, `-report-junit` → `-report-xunit-junit`, `-report-nunit` → `-report-xunit-nunit`, `-report-xunit` → `-report-xunit-xml`); report extensions `.junit` → **`.junit.xml`**, `.nunit` → `.nunit.xml`, `.xunit` → `.xunit.xml`; new `--filter-display-name` / `--filter-not-display-name`, `--xunit-list` |
| Native AOT | `xunit.v3.aot` / `xunit.v3.core.aot`; **net9.0+**, C# only; no generic test methods, no serialization, no interface-based attributes, truncated stack traces |
| Other additions | test **class** and **method** orderers; generic attribute variants (net8+); `removeAsyncSuffix` display option; `Assert.All(…, strict:)`; `Assert.OverrideMaxEnumerableLength` / `OverrideMaxObjectDepth` / `OverrideMaxObjectMemberCount` / `OverrideMaxStringLength`; `dotnet xunit-console` .NET tool (**not** documented — see *Out of scope*) |

**Sources** (recorded here, not in the skill body — the skills carry no URLs):

- <https://xunit.net/releases/v3/4.0.0>
- <https://www.nuget.org/packages/xunit.v3>
- <https://xunit.net/docs/running-tests-in-parallel>
- <https://xunit.net/docs/getting-started/v3/microsoft-testing-platform>
- <https://xunit.net/docs/getting-started/v3/code-coverage-with-mtp>
- <https://xunit.net/docs/config-xunit-runner-json>
- <https://xunit.net/docs/getting-started/v3/native-aot>
- <https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/Coverlet.MTP.Integration.md>

## Decisions settled in the interview

| # | Decision |
|---|---|
| 1 | **Full ripple**, split multi-phase — the xUnit skill plus every sibling that repeats an xUnit fact. |
| 2 | **Coverage package: `Microsoft.Testing.Extensions.CodeCoverage`** (first-party, prescribed by xunit.net's own coverage doc). Not `coverlet.MTP`, not "drop coverage". |
| 3 | **Version expression:** templates pin `Version="4.0.0"`; the skill carries a dated *"4.0.0 is stable as of 2026-08 — use the latest stable 4.x"* note, mirroring today's 3.2.2 note. |
| 4 | **Skill keeps the name `xunit-v3`** — it matches the package ID and upstream's own release title. Add a one-line numbering note so `v3` next to `4.0` isn't confusing. |
| 5 | **One compact `SKILL.md`** — no `reference/` split; new material stays terse (a paragraph + table per topic). |
| 6 | **House parallel default stays `collections`.** `all` is documented as opt-in with its opt-out levels. |
| 7 | **Native AOT gets a short "not the house default" note** naming `xunit.v3.aot` and the disqualifiers. |
| 8 | **Migration stance unchanged** ("stay consistent; migrating is its own work item"), extended to 3.x, plus a short ordered 3.x→4.0 checklist. |
| 9 | **One merged stale-isms table** with a `From` column (`v2` / `3.x`) — replaces the current v2-only table. |
| 10 | **The coverage csproj property set is verified empirically**, not copied from upstream's SDK 8/9-era doc. |
| 11 | **Brief runner/CI section** covering the switch renames and `.xml` extension change; `dotnet xunit-console` not documented. |
| 12 | **2 phases** — authority (PHASE01), then propagation (PHASE02). |
| 13 | **Carbon/Phosphor stale entries left alone** — recorded as a follow-up, not fixed here. |
| 14 | **No deployment to `~/.claude/skills/`** — repo only. |

## Versioning

`xunit-v3` gains `**Version: xunit-v3 v3.**` (currently `v2`). Derived from the roadmap: v1 = original
skill, v2 = `FEATURE-79A1-PHASE03` (bootstrap-template alignment), **v3 = this item**.

Sibling skills touched in PHASE02 are **fact corrections, not material revisions** — their version lines
are **not** bumped. State this explicitly in the PHASE02 completion doc so the omission reads as
deliberate.

---

## PHASE01 — `xunit-v3` skill rewritten for 4.0

**Status:** TODO

**Goal:** `.claude/skills/xunit-v3/SKILL.md` becomes the single authority for xUnit 4.0 house conventions,
with the coverage setup verified against a real SDK 10 run rather than inferred from docs.

### Step 1 — Empirical verification (do this first; its result feeds Steps 4 and 5)

xunit.net's *Code Coverage with MTP* page is dated **2025-05** and targets SDK 8/9: it prescribes
`<TestingPlatformDotnetTestSupport>true</TestingPlatformDotnetTestSupport>` — which this skill correctly
forbids on SDK 10 — **alongside** `<UseMicrosoftTestingPlatformRunner>true</UseMicrosoftTestingPlatformRunner>`.
Whether the latter is genuinely required on SDK 10 with the `global.json` runner entry is unknown, and the
answer decides what goes into `templates/test.csproj` in PHASE02.

Build a probe under the session scratchpad (**never** inside the repo):

1. `global.json` with the house content:
   `{"sdk": {"version": "10.0.100", "rollForward": "latestFeature"}, "test": {"runner": "Microsoft.Testing.Platform"}}`.
2. A trivial library plus a `<ProjectUnderTest>.UnitTests` project shaped exactly like
   `dotnet-solution-setup/templates/test.csproj` (`<OutputType>Exe</OutputType>`, `net10.0`, no
   `Microsoft.NET.Test.Sdk`, no `xunit.runner.visualstudio`), referencing `xunit.v3` **4.0.0** and
   `Microsoft.Testing.Extensions.CodeCoverage`. One passing `[Fact]`.
3. **Run A — no extra properties:**
   `dotnet test -- --coverage --coverage-output-format cobertura --coverage-output coverage.cobertura.xml`
4. **Run B — only if A fails or produces no/empty report:** add
   `<UseMicrosoftTestingPlatformRunner>true</UseMicrosoftTestingPlatformRunner>` and re-run.
5. **Also confirm, while the probe exists:**
   - plain `dotnet test` still discovers and runs the test;
   - the MTP filter switches still exist under MTP v2 (`--filter-class`, `--filter-method`,
     `--filter-trait`, `--filter-query`) and the new `--filter-display-name` is present — check the
     runner's `--help`;
   - the `dotnet test --solution <Solution>.slnx` form still behaves as the skill claims (the existing
     note is carried forward unchanged unless this contradicts it);
   - `xunit.v3` 4.0.0 restores cleanly with no `Microsoft.NET.Test.Sdk` present.
6. **Record in the completion doc:** each command run, its exit code, and whether
   `coverage.cobertura.xml` exists and is non-empty. Then **delete the probe directory**; nothing from it
   is committed.

The **minimum working property set** discovered here is what Steps 4/5 document and what PHASE02 puts in
`templates/test.csproj`. If Run A succeeds, the template gains **no** new property.

### Step 2 — Header, version line, numbering note

- Frontmatter `description:` — verify it still reads correctly; it names no version, so it is expected to
  stay **unchanged**. Do not edit it just to touch it.
- `**Version: xunit-v3 v2.**` → `**Version: xunit-v3 v3.**`
- House-rule paragraph: new test projects use **xUnit v3 at version 4.x** (`xunit.v3` package). Add the
  one-line numbering note: *the package is `xunit.v3` and stays that way — "v3" is the core-framework
  generation, `4.0.0` is its version; upstream titles the release "Core Framework v3 4.0.0".* Keep the
  existing "not `xunit` 2.x, not MSTest/NUnit; deviating needs a documented compatibility reason" rule and
  the `tests/` + `<ProjectUnderTest>.UnitTests` sentence verbatim.

### Step 3 — `## Naming` and `## Target frameworks`

- **Naming:** unchanged.
- **Target frameworks:** keep the mirroring rule and the `netstandard2.0`-is-not-a-test-TFM paragraph
  verbatim. Add one sentence: **4.0.0's floor is `net8.0` (or `net472`)** — a library still multi-targeting
  `net6.0`/`net7.0` cannot have those mirrored in a 4.0 test project. Note this does not move the house
  pair, which is already `net8.0;net10.0`.

### Step 4 — `## Project setup (MTP-native — the default)`

Rewrite for MTP v2:

- v3 test projects are standalone executables on MTP; **4.0.0 defaults to MTP v2** and **MTP v1 support is
  removed**. Name the variants in one line — `xunit.v3.mtp-v2` (explicit v2), `xunit.v3.mtp-off` (no MTP);
  `xunit.v3.mtp-v1` no longer exists at 4.x — and note plain `xunit.v3` is the house choice.
- **Forbidden, unchanged:** `Microsoft.NET.Test.Sdk` and `xunit.runner.visualstudio`.
- **Coverage — rewrite the sanctioned opt-in.** `Microsoft.Testing.Extensions.CodeCoverage` replaces
  `coverlet.collector`. State plainly *why*: `coverlet.collector` is a **VSTest data collector**, and MTP
  v2 does not host VSTest data collectors — so it is no longer "guilty by association", it genuinely does
  not work. Mention `coverlet.MTP` exists as the coverlet-ecosystem alternative but is not the house
  choice. Give the run command
  (`dotnet test -- --coverage --coverage-output-format cobertura --coverage-output coverage.cobertura.xml`)
  and **the property set verified in Step 1** (which may be none).
- **csproj sample** — updated: TFM comment unchanged, `<OutputType>Exe</OutputType>`, `xunit.v3`, the
  coverage package as the commented optional line, `ProjectReference`. Keep the CPM rule
  (`<PackageVersion Include="xunit.v3" Version="4.0.0" />` centrally; inline `Version="4.0.0"` only
  without CPM) and the "no `LangVersion` / `Nullable` / `ImplicitUsings` / `TreatWarningsAsErrors`" rule.
- **Version note:** *4.0.0 is stable as of 2026-08 — use the latest stable 4.x.* Delete the
  "xUnit 4.x is prerelease, don't use it" sentence.
- **Toolchain floor (new one-liner):** 4.0 ships Analyzers 2.0.0, which needs Roslyn 4.11+ → **SDK
  8.0.400+ / VS 2022 17.11+**. Note that under the house `TreatWarningsAsErrors`, new analyzer diagnostics
  fail the build rather than warn.
- **Mono (new one-liner):** official support discontinued in 4.0.
- Keep the `global.json` `test.runner` block, the "no `dotnet.config`" line, and the note that
  `TestingPlatformDotnetTestSupport` is for SDK 8/9 only.

### Step 5 — Running tests

Keep the existing paragraph (MTP filters, not VSTest's `--filter FullyQualifiedName~…`) and the
`dotnet test --solution <Solution>.slnx` note. Add the new **`--filter-display-name` /
`--filter-not-display-name`** filters (they can target an individual theory data row), reconciled with
whatever Step 1's `--help` check found.

### Step 6 — `## Test parallelization` (new section)

- **Default is `collections`, unchanged by 4.0** — one test collection per class, so different classes run
  concurrently while tests inside a class run sequentially. **This is the house default; do not change it
  per project without a reason.**
- **`all` is 4.0's headline opt-in** — every test runs against every other regardless of collection or
  shared context. State the cost plainly: any mutable instance field or shared fixture state becomes a
  flake source.
- **Assembly attribute:** `[assembly: Parallelization(Mode = ParallelMode.All)]`, plus `MaxThreads` and
  `Algorithm`. Note it **replaces** `[assembly: CollectionBehavior(…)]`.
- **Opt-out table** — collection: `[CollectionDefinition("…", DisableParallelization = true)]`; class:
  `[TestClass(DisableParallelism = true)]`; method: `[Fact(DisableParallelism = true)]` / `[Theory(…)]`;
  data row: `[InlineData(…, DisableParallelization = true)]` or
  `new TheoryDataRow<T>(…) { DisableParallelization = true }`.
  **Verify the exact property spelling against <https://xunit.net/docs/running-tests-in-parallel> before
  writing it** — the docs use `DisableParallelization` at collection/data-row level and
  `DisableParallelism` at class/method level, and that asymmetry must be reproduced correctly or the
  sample will not compile.
- One line: the equivalent `xunit.runner.json` key is `parallelMode` (`none` / `collections` / `all`).

### Step 7 — `## Writing tests — v3 API notes`

Keep every existing bullet (`ITestOutputHelper` in `Xunit`, `IAsyncLifetime` returning `ValueTask`,
`TestContext.Current.CancellationToken`, `Assert.Skip*`, no `async void`, the `xunit.runner.json` content
copy). Append the 4.0 additions, one line each:

- `Assert.All(…, strict: true)` fails on an empty collection.
- `Assert.OverrideMaxEnumerableLength` / `OverrideMaxObjectDepth` / `OverrideMaxObjectMemberCount` /
  `OverrideMaxStringLength` override assertion-message formatting per test.
- Generic attribute variants on net8+ (e.g. `TestCaseOrderAttribute<TOrderer>`,
  `AssemblyFixtureAttribute<TFixture>`).
- `methodDisplayOptions: removeAsyncSuffix` strips a trailing `Async` from displayed test names.
- Orderers now exist at class and method level too; execution order is collection → class → method → case.

### Step 8 — `## Native AOT — not the house default` (new, 3–5 lines)

`xunit.v3.aot` / `xunit.v3.core.aot` replace the reflection packages. **Disqualifiers for house
projects:** net9.0+ only (the house pair is `net8.0;net10.0`), C# only, no generic test methods, no
serialization, no interface-based attributes, significantly reduced stack traces. Conclusion: not the
default; reach for it only with a specific reason, and expect to give up generic theories.

### Step 9 — `## Runner & CI changes in 4.0` (new, brief)

- Report switches renamed: `-report-ctrf` → `-report-xunit-ctrf`, `-report-junit` →
  `-report-xunit-junit`, `-report-nunit` → `-report-xunit-nunit`, `-report-xunit` → `-report-xunit-xml`.
  These **fail loudly** — a renamed switch is an error.
- Report extensions changed: `.junit` → `.junit.xml`, `.nunit` → `.nunit.xml`, `.xunit` → `.xunit.xml`.
  These **fail silently** — a CI artifact glob on the old extension matches nothing while the build stays
  green. Call this out as the dangerous one.

### Step 10 — `## Migrating a 3.x project to 4.0` (new, ordered checklist)

1. Bump `xunit.v3` to `4.0.0`; confirm the toolchain is SDK 8.0.400+ / VS 2022 17.11+ (Analyzers 2.0.0).
2. Confirm every test TFM is `net8.0`+ (or `net472`).
3. Replace `coverlet.collector` with `Microsoft.Testing.Extensions.CodeCoverage`; update the coverage
   invocation in CI (`--collect:"XPlat Code Coverage"` / `/p:CollectCoverage` no longer apply).
4. Rename `[assembly: CollectionBehavior(…)]` → `[assembly: Parallelization(…)]`
   (`DisableTestParallelization = true` → `Mode = ParallelMode.None`; `MaxParallelThreads` → `MaxThreads`).
5. Update CI report switch names and artifact globs (`.junit.xml` etc.).
6. Drop any `xunit.v3.mtp-v1` reference — MTP v1 is gone at 4.x.
7. Note any Mono-hosted run: official support is discontinued.
8. Run the suite. Analyzers 2.0.0 diagnostics surface as warnings, which the house
   `TreatWarningsAsErrors` turns into build failures — triage them as part of the migration.

Keep this ordered and terse; it is a checklist, not a tutorial.

### Step 11 — Merged stale-isms table

Replace `## Common stale v2-isms` with `## Common stale v2 / 3.x-isms`, a single table
`| Wrong | Right (v4) | From |`:

| Wrong | Right (v4) | From |
|---|---|---|
| `<PackageReference Include="xunit" Version="2.x" />` | `xunit.v3` | v2 |
| `Microsoft.NET.Test.Sdk` + `xunit.runner.visualstudio` | `xunit.v3` alone + the `global.json` runner entry | v2 |
| Missing `<OutputType>Exe</OutputType>` or a hand-written `Program.Main` | Exe output; `Main` is generated | v2 |
| `using Xunit.Abstractions;` | `using Xunit;` | v2 |
| `Task IAsyncLifetime.InitializeAsync()` | `ValueTask` | v2 |
| `coverlet.collector` | `Microsoft.Testing.Extensions.CodeCoverage` | 3.x |
| `[assembly: CollectionBehavior(DisableTestParallelization = true)]` | `[assembly: Parallelization(Mode = ParallelMode.None)]` | 3.x |
| `[assembly: CollectionBehavior(MaxParallelThreads = n)]` | `[assembly: Parallelization(MaxThreads = n)]` | 3.x |
| `-report-junit` / `-report-ctrf` | `-report-xunit-junit` / `-report-xunit-ctrf` | 3.x |
| CI glob `**/*.junit` | `**/*.junit.xml` | 3.x |
| `xunit.v3.mtp-v1` | removed at 4.x — plain `xunit.v3` (MTP v2) | 3.x |

### Step 12 — `## Common mistakes`, cross-references, closing sentence

- **Common mistakes:** keep the naming, TFM-mirroring, CPM-version and `Directory.Build.props` rows
  (updating `Version="3.2.2"` → `Version="4.0.0"`). **Replace** the "treating `coverlet.collector` as
  VSTest boilerplate and stripping it" row — it now says the opposite — with: *keeping `coverlet.collector`
  in a 4.0 project* → *it collects nothing under MTP v2; use `Microsoft.Testing.Extensions.CodeCoverage`*.
  Add a row for *a CI artifact glob still matching `.junit`* → *`.junit.xml` since 4.0*.
- **Cross-references:** update the `dotnet-solution-config` line so the Tests group reads `xunit.v3` +
  `Microsoft.Testing.Extensions.CodeCoverage`. `dotnet-solution-setup` and `dotnet-async` lines unchanged.
- **Closing sentence:** extend to cover 3.x — *"If an existing solution is on xUnit v2, VSTest mode, or
  `xunit.v3` 3.x, stay consistent within it and flag the divergence — migrating is its own work item, not
  a drive-by (see the migration checklist above)."*

**Acceptance criteria**

1. Step 1's probe ran on SDK 10.0.300; the completion doc records each command, its exit code, whether
   `coverage.cobertura.xml` was produced non-empty, and the **minimum property set** concluded. The probe
   directory no longer exists and nothing from it is in the repo.
2. `grep -n "3\.2\.2\|prerelease\|coverlet" .claude/skills/xunit-v3/SKILL.md` returns **only** the
   deliberate mentions: the stale-isms `coverlet.collector` row and the one-line note that `coverlet.MTP`
   exists. No `3.2.2`, no "prerelease".
3. The file states: `xunit.v3` `4.0.0` with the dated "latest stable 4.x" note; the package-ID-vs-version
   numbering note; MTP v2 default and MTP v1 removed; Mono discontinued; the net8.0/net472 floor; the
   SDK 8.0.400+ / Roslyn 4.11+ toolchain floor.
4. The coverage section names `Microsoft.Testing.Extensions.CodeCoverage`, explains *why*
   `coverlet.collector` cannot work (VSTest data collector vs MTP v2), gives the run command, and states
   exactly the property set verified in Step 1 — no property that Step 1 showed to be unnecessary.
5. A `## Test parallelization` section exists with `collections` as the stated house default, `all` as
   opt-in via `[assembly: Parallelization(…)]`, and the five opt-out levels with **property names verified
   against the upstream doc**.
6. A Native AOT note exists (≤ 5 lines) naming `xunit.v3.aot` and at least the net9.0+, C#-only and
   no-generic-test-methods disqualifiers.
7. A runner/CI section documents both the switch renames and the `.xml` extension change, and identifies
   the extension change as the silent one.
8. An ordered 3.x→4.0 migration checklist exists with all 8 steps.
9. The stale-isms table is a **single** table with a `From` column and carries all 11 rows above; the old
   v2-only table is gone.
10. Version line reads `**Version: xunit-v3 v3.**`; frontmatter `description` unchanged; every preserved
    section (Naming, TFM mirroring, `Exe`, CPM, `Directory.Build.props`, `global.json`, `--solution`, the
    existing v3 API bullets) is still present.
11. Markdown is well-formed: all fences closed, all tables rectangular. Nothing to build or test beyond
    Step 1's probe — state so in the completion doc.

---

## PHASE02 — Propagate the 4.0 facts to sibling skills

**Status:** TODO

**Goal:** no file under `.claude/skills/**` contradicts PHASE01's skill. Mechanical application of
decisions already made — no new decisions in this phase.

### Step 1 — `dotnet-solution-config/templates/Directory.Packages.props`

Tests group (currently a commented-out example, lines ~68–74):

- `<PackageVersion Include="xunit.v3" Version="3.2.2" />` → `Version="4.0.0"`.
- `<PackageVersion Include="coverlet.collector" Version="6.0.4" />` →
  `<PackageVersion Include="Microsoft.Testing.Extensions.CodeCoverage" Version="<latest stable>" />` —
  **look the version up at build time** and record it in the completion doc.
- Group comment
  `<!-- Tests (MTP-native: xunit.v3 only; coverlet.collector for coverage). No Microsoft.NET.Test.Sdk. -->`
  → names the CodeCoverage package instead.

### Step 2 — `dotnet-solution-setup/templates/test.csproj`

- `<PackageReference Include="coverlet.collector" PrivateAssets="all" />` →
  `<PackageReference Include="Microsoft.Testing.Extensions.CodeCoverage" />`. Decide `PrivateAssets` by
  what the package actually needs (it is a test-host extension, not a compile-time asset) and note the
  reasoning in the completion doc.
- Add `<UseMicrosoftTestingPlatformRunner>true</UseMicrosoftTestingPlatformRunner>` **only if PHASE01
  Step 1 proved it necessary**. If Run A succeeded, add nothing.
- The `<!-- v3 test projects are executables; Main is generated by xunit.v3.core. -->` comment stays
  accurate — leave it.
- Everything else (TFM comment, `OutputType`, `ProjectReference`, fixture copy-glob) unchanged.

### Step 3 — `dotnet-solution-config/SKILL.md`

- Line ~68 Tests-group paragraph: `xunit.v3` plus, optionally,
  `Microsoft.Testing.Extensions.CodeCoverage`; keep the "no `Microsoft.NET.Test.Sdk`" rule and the
  `(see xunit-v3)` pointer.
- Common-mistakes row
  `| Microsoft.NET.Test.Sdk in the CPM Tests group | … (+ optional coverlet.collector) only. |`
  → name the CodeCoverage package.
- Add one row: *`coverlet.collector` in the CPM Tests group* → *VSTest data collector; collects nothing
  under MTP v2 (xunit.v3 4.0) — use `Microsoft.Testing.Extensions.CodeCoverage`.*
- Cross-references line for **xunit-v3** — verify it still reads correctly.
- `global.json` section and the `--solution` invocation note: unchanged unless PHASE01 Step 1 contradicted
  them.

### Step 4 — `dotnet-solution-setup/SKILL.md`

- Line ~37 ``tests/` — test projects (xUnit v3 — see xunit-v3)`` → keep, optionally "(xUnit v3, 4.x)".
- Line ~107 mistakes row `| Tests scaffolded with dotnet new xunit (v2) | xUnit v3 per the xunit-v3 skill |`
  — keep; sharpen to "xUnit v3 (4.x)" if it reads better.
- Line ~117 bundled-files line for `templates/test.csproj` — keep "MTP-native xUnit v3 test project"; no
  version claim needed.
- Line ~25 bootstrap-checklist row and line ~20 `global.json` row: unchanged.
- **No version bump** to this skill's version line.

### Step 5 — `dotnet-release/SKILL.md`

Line ~61 license-audit table row `| xunit.v3, coverlet.collector | test-only | no — never in the package |`
→ `| xunit.v3, Microsoft.Testing.Extensions.CodeCoverage | test-only | no — never in the package |`.
The row's meaning is unchanged: still test-only, still never shipped, still out of audit scope.

### Step 6 — `enigma-icons-avalonia/reference/setup.md`

Line ~130 `<PackageReference Include="xunit.v3" Version="3.2.2" />` → `Version="4.0.0"`.
Leave the adjacent `Avalonia.Headless.XUnit` line alone — its compatibility with xunit.v3 4.0 is **not**
in scope for this item; if a quick check suggests a problem, record it as a follow-up recommendation
rather than changing it.

### Step 7 — Repo-wide consistency check

`grep -rn "3\.2\.2\|coverlet" .claude/skills/` must return only the deliberate mentions listed in PHASE01
acceptance criterion 2. Investigate and fix anything else it finds.

**Acceptance criteria**

1. `grep -rn "coverlet\.collector" .claude/skills/` returns only the stale-isms row in
   `xunit-v3/SKILL.md`.
2. `grep -rn "3\.2\.2" .claude/skills/` returns nothing.
3. All six files above are edited; the CodeCoverage package version used in `Directory.Packages.props` is
   recorded in the completion doc.
4. `templates/test.csproj` contains a `UseMicrosoftTestingPlatformRunner` property **if and only if**
   PHASE01 Step 1 showed it necessary; the completion doc states which case applied.
5. Every prose claim about xUnit in the six files matches `xunit-v3/SKILL.md` — no sibling skill
   contradicts the authority.
6. Sibling skills' `**Version: … vN.**` lines are **unchanged**, and the completion doc says so
   deliberately.
7. All templates remain well-formed XML; all edited tables remain rectangular.
8. Nothing to build or test — state so in the completion doc.

---

## Out of scope / recorded, not planned here

- **`~/.claude/skills/` deployment** — the copies there are the user's to refresh. Recorded follow-up:
  they are plain copies, not junctions, and no sync script exists; junctions or a sync script would remove
  a recurring drift risk.
- **`Carbon.Avalonia.Desktop` / `PhosphorIconsAvalonia` in `Directory.Packages.props`** — dropped in commit
  `22f3ca4` and replaced by the Enigma.* skills, but still listed in the CPM Desktop group and in
  `dotnet-solution-config`'s ecosystem-coupling bullet. Deliberately left alone: the Enigma replacements
  need their own version decisions. Worth its own work item.
- **`dotnet xunit-console`** (`dotnet tool install -g xunit-console-tool`, SDK 10+) — real, but the house
  runs tests through `dotnet test`; documenting a second runner adds churn for no current need.
- **`coverlet.MTP`** — named in one line as the alternative, not adopted.
- **Renaming the skill** — considered and declined; `xunit-v3` matches the package ID.
- **`Avalonia.Headless.XUnit` compatibility with xunit.v3 4.0** — not verified here; flag it if noticed.
- **Migrating any real solution to 4.0** — this item updates conventions only; no consuming repo is
  touched.
- **Line endings (CRLF):** no line-ending anomalies observed in any of the seven target files.
