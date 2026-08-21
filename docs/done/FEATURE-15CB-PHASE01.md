# FEATURE-15CB-PHASE01 — `xunit-v3` skill rewritten for 4.0 (DONE)

## Summary

`.claude/skills/xunit-v3/SKILL.md` is now the house authority for **xUnit.net Core
Framework v3 `4.0.0`**. The two statements the 4.0 release made actively wrong are
corrected, and the 4.0 surface the house cares about is documented.

The two corrections:

- **"xUnit 4.x is prerelease, don't use it"** — gone. `4.0.0` is stable (NuGet
  2026-08-15) and is now the house version, with a dated *"stable as of 2026-08 —
  use the latest stable 4.x"* note.
- **`coverlet.collector` "works fine under MTP"** — reversed. It is a *VSTest data
  collector*; 4.0 defaults to **MTP v2**, which does not host VSTest data
  collectors, so the old guidance produced test projects whose coverage silently
  collected nothing. The sanctioned package is now
  `Microsoft.Testing.Extensions.CodeCoverage`, and the skill states *why* rather
  than just swapping the name.

New sections: **Running tests** (promoted to its own heading), **Test
parallelization**, **Native AOT — not the house default**, **Runner & CI changes in
4.0**, **Migrating a 3.x project to 4.0**. The v2-only stale-isms table is replaced
by a single merged table with a `From` column (`v2` / `3.x`), 11 rows. Version line
bumped **v2 → v3**; frontmatter `description` deliberately unchanged (it names no
version).

Every API spelling, switch name, package ID and property in the file was verified
against a real SDK 10.0.300 run — not copied from documentation. That mattered: the
plan's own assumed facts were wrong in three places (below).

## Files/modules touched

**Modified**
- `.claude/skills/xunit-v3/SKILL.md` — rewritten per plan Steps 2–12.
- `docs/roadmap.md` — `FEATURE-15CB` and its `PHASE01` row flipped `TODO` →
  `IN PROGRESS`. Table already aligned under the `FEATURE-2059` rule; the flip
  preserves the Status column width (`IN PROGRESS` is the widest cell), so no
  reformat was needed.
- `docs/plan/FEATURE-15CB.md` — item status and PHASE01 status → `IN PROGRESS`.

**Created**
- `docs/done/FEATURE-15CB-PHASE01.md` (this file)

**Unchanged, deliberately** — every sibling skill. Propagating the corrected facts
to `dotnet-solution-config`, `dotnet-solution-setup`, `dotnet-release` and
`enigma-icons-avalonia` is PHASE02's scope; `grep -rn "coverlet" .claude/skills/`
therefore still reports the five sibling hits until that phase runs.

## Step 1 — empirical verification (evidence)

Probe built under the session scratchpad (never in the repo): `global.json` with the
house content (`sdk` pin + `test.runner: Microsoft.Testing.Platform`), a `net10.0`
`ProbeLib` library, and a `ProbeLib.UnitTests` project shaped exactly like
`dotnet-solution-setup/templates/test.csproj` — `<OutputType>Exe</OutputType>`, no
`Microsoft.NET.Test.Sdk`, no `xunit.runner.visualstudio` — referencing `xunit.v3`
**4.0.0** and `Microsoft.Testing.Extensions.CodeCoverage` **18.10.0**. SDK in use:
**10.0.300**.

| # | Command | Exit | Result |
|---|---|---|---|
| 1 | `dotnet restore` | 0 | Clean; no `Microsoft.NET.Test.Sdk` in the graph. `xunit.v3.mtp-v2.dll` present in output → MTP v2 is the transitive default of plain `xunit.v3`. |
| 2 | `dotnet test` | 0 | 1 test discovered and passed. |
| 3 | **Run A** — `dotnet test -- --coverage --coverage-output-format cobertura --coverage-output coverage.cobertura.xml` | 0 | **`TestResults/coverage.cobertura.xml` produced, 990 bytes, non-empty**: `line-rate="1"`, `lines-covered="1"`, `ProbeLib.Calculator.Add` line 5 `hits="1"`. |
| 4 | **Run B** | — | **Not needed** — Run A succeeded. |

**Minimum working property set concluded: NONE.** Coverage works on SDK 10.0.300
with the `global.json` runner entry alone — neither
`UseMicrosoftTestingPlatformRunner` nor `TestingPlatformDotnetTestSupport` is
required. Upstream's *Code Coverage with MTP* page (dated 2025-05, SDK 8/9-era)
prescribes both; on SDK 10 both are unnecessary and the latter is wrong. **Therefore
PHASE02 Step 2 must add no new property to `templates/test.csproj`** (PHASE02
acceptance criterion 4: the "Run A succeeded" case applies).

Also confirmed while the probe existed:

- **Plain `dotnet test`** discovers and runs — yes (row 2).
- **MTP v2 filter switches** — all accepted *and* filtering correctly (verified by
  exit code, not by absence of an error string; an invalid switch yields exit **5**,
  a zero-match filter exit **8**): `--filter-class` (match → 1 test; no match → 0,
  exit 8), `--filter-method` → 1, `--filter-trait` → 0 as expected,
  `--filter-query` → 1, and **new in 4.0** `--filter-display-name` → 1,
  `--filter-not-display-name` → 0, `--filter-not-class` → 1.
- **`dotnet test --solution <Solution>.slnx`** — works. **But the existing skill
  claim that the bare positional form is *rejected* is no longer true**: on SDK
  10.0.300 `dotnet test Probe.slnx` also ran the suite (exit 0, 4 tests). See
  *Deviations* — the note was softened rather than carried forward unchanged, per
  plan Step 1.5's "unless this contradicts it".
- **`xunit.v3` 4.0.0 restores cleanly with no `Microsoft.NET.Test.Sdk`** — yes.
- **TFM floor** — a `net7.0` test project restores only via .NET Framework asset
  fallback and emits `NU1701` (which the house `TreatWarningsAsErrors` turns into a
  build failure); `net8.0` restores clean. The documented `net8.0` floor is real and
  its failure mode is now stated in the skill.
- **Companion packages on NuGet** — `xunit.v3.mtp-v2` 4.0.0, `xunit.v3.mtp-off`
  4.0.0, `xunit.v3.aot` 4.0.0, `xunit.v3.core.aot` 4.0.0, `xunit.analyzers` 2.0.0,
  and `xunit.v3.mtp-v1` topping out at 3.x with **no 4.x release** — confirming MTP
  v1 support is removed at 4.0.
- **Report switches / extensions** — old names hard-fail (exit 5):
  `--report-junit`, `--report-ctrf`, `--report-xunit` all rejected; the new
  `--report-xunit-junit` / `-ctrf` / `-nunit` / `-xml` / `-trx` all succeed. Running
  all four emitted `*.junit.xml`, `*.nunit.xml`, `*.xunit.xml`, `*.ctrf` — the
  `.xml` suffix change is real, and CTRF keeps its extension.
- **Corrected code samples compile** — a file containing the skill's
  `[assembly: Parallelization(…)]` sample, all five `DisableParallelization`
  opt-out levels, and all five new `Assert` members built with **0 warnings, 0
  errors**.

**The probe directory has been deleted** (`rm -rf`), and `git status --porcelain`
after deletion showed only the two intended status-flip edits — nothing from the
probe is in the repo.

## Deviations & follow-ups

**Three of the plan's "Upstream facts to encode" were wrong.** The plan anticipated
exactly this for the parallelization API (Step 6: *"Verify the exact property
spelling … before writing it … or the sample will not compile"*), so the verified
truth was written instead. Recorded here because the plan's fact table is otherwise
the item's reference:

1. **The `DisableParallelization` / `DisableParallelism` asymmetry does not exist.**
   The plan asserted `DisableParallelization` at collection/data-row level but
   `DisableParallelism` at class/method level. Reflection over `xunit.v3.core`
   4.0.0.0 and a compile test show the property is **`DisableParallelization` at all
   five levels** — `CollectionDefinitionAttribute`, `TestClassAttribute`,
   `FactAttribute`, `TheoryAttribute`, `InlineDataAttribute` and
   `TheoryDataRow<T>`. `DisableParallelism` does not exist anywhere; a sample using
   it fails with `CS0246`. The skill states this explicitly so the wrong spelling
   isn't reintroduced.
2. **`Assert.All`'s new parameter is `throwIfEmpty`, not `strict`.** Real signature:
   `All(IEnumerable<T>, Action<T>, bool throwIfEmpty)`. The skill names the real one
   and flags the wrong one.
3. **`CollectionBehaviorAttribute` is not removed and not `[Obsolete]` at 4.0.** It
   still compiles, so the plan's "replaces" was too strong. The skill says
   `Parallelization` **supersedes** it — accurate, and it explains the actual reason
   to migrate (`CollectionBehavior` cannot express `Mode = All`). The two
   `CollectionBehavior` stale-isms rows are kept as instructed; they remain correct
   *house guidance*, just not a compiler-enforced requirement.

Two smaller naming fixes: the generic orderer attribute is
`TestCaseOrdererAttribute<T>` (the plan wrote `TestCaseOrderAttribute<TOrderer>`),
and the renamed report switches are **MTP double-dash** options
(`--report-xunit-junit`), not the single-dash `-report-…` form the plan showed —
the native console runner has its own separate `-result-*` switches, which the skill
now mentions so the two surfaces aren't conflated.

**A namespace gotcha worth the line it costs:** `ParallelizationAttribute` lives in
`Xunit.v3` and `ParallelMode`/`ParallelAlgorithm` in `Xunit.Sdk` — a lone
`using Xunit;` does not compile. This cost the first compile attempt and is now
documented in the sample.

**Acceptance criterion 2 is met in intent, not to the letter.** It says the
`coverlet` grep should return "only the stale-isms row and the one-line
`coverlet.MTP` note", but Steps 4, 10 and 12 each *mandate* a further
`coverlet.collector` mention (the coverage rationale, migration step 3, and the
replaced Common-mistakes row). Those four mentions are all plan-required and all
deliberate; the criterion's list was an incomplete restatement of its own steps. The
`3.2.2` and `prerelease` halves of the criterion are met exactly — **zero** hits.

**Follow-ups (not actioned here):**
- **PHASE02 must soften `dotnet-solution-config`'s `--solution` note too.** Its
  *Invocation note* (`SKILL.md:84`) states the positional `.slnx` form is
  "**rejected**"; that is now false on SDK 10.0.300. PHASE02 Step 3 says "unchanged
  unless PHASE01 Step 1 contradicted them" — it did.
- `Avalonia.Headless.XUnit` compatibility with `xunit.v3` 4.0.0 remains unverified
  (out of scope per the plan); `enigma-icons-avalonia/reference/setup.md` pins them
  side by side.
- `~/.claude/skills/` holds plain copies, not junctions, and no sync script exists —
  this rewrite is not live for the user's other sessions until they refresh it.
- **Line endings:** no CRLF anomalies observed in the edited files. The repo has
  `core.autocrlf=true`, so `git diff` reported the usual "LF will be replaced by
  CRLF" advisory on `docs/roadmap.md`; per the house rule this is a recommendation
  only and nothing was changed for it.

## Build/test evidence

**There is nothing to build or test in this repo** — the deliverable is a Claude
Code skill prompt file. Definition-of-Done criteria 1–2 are met by the documentation
equivalents, plus the real dry run above:

- **Markdown well-formed** — 10 fence markers (5 balanced blocks); all three tables
  rectangular by pipe count (parallelization opt-outs 3 pipes × 7 lines, stale-isms
  4 pipes × 13 lines, common mistakes 3 pipes × 8 lines); frontmatter intact and the
  skill still loads (the harness re-advertised `xunit-v3` after the write).
- **Content verified by grep** — `grep -n "3\.2\.2\|prerelease"` → **0 hits**;
  version line reads `**Version: xunit-v3 v3.**`; 11 stale-isms rows; 8 migration
  steps; all AC3 facts present (4.x note, numbering note, MTP v2 default, MTP v1
  removed, Mono discontinued, `net8.0`/`net472` floor, SDK 8.0.400+ / Roslyn 4.11+).
- **Every code sample in the file was compiled**, not just eyeballed — the csproj
  shape restored and ran a passing test, and the parallelization + `Assert` samples
  built with 0 warnings and 0 errors against `xunit.v3` 4.0.0 on SDK 10.0.300.
- **Preserved sections confirmed present** — Naming (verbatim), TFM mirroring and
  the `netstandard2.0` paragraph (verbatim), `<OutputType>Exe</OutputType>`, the CPM
  rule, the `Directory.Build.props` rule, the `global.json` `test.runner` block, the
  no-`dotnet.config` line, the `--solution` note (softened, see *Deviations*), and
  all six existing v3 API bullets.
