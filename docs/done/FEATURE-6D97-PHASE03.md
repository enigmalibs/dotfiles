# FEATURE-6D97-PHASE03 — Packaging prerequisites, first-release path, pack-verify & release-item shapes

## Summary

The final phase of `FEATURE-6D97`: the release **mechanics** Enigma.Core (EC) needed and the skill lacked.
PHASE01 bundled the doc templates, PHASE02 wrote the content rules; this phase covers what a packable
library must actually carry, what differs on a first release, and what the skill is permitted to run.

Six changes to `dotnet-release/SKILL.md`: the 5-item prerequisite list became the full **12-property
table**; *In-repo edits* split into explicit **first-release** and **routine-release** paths (with the
license audit scoped to the first); *Execution boundary* gained **pack-verify** as its second sanctioned
exception; a **Symbols & SourceLink opt-in** subsection completes the D5 fix started in PHASE01; a new
**shape of a release work item** section bridges `dev-workflow` and this skill; and the housekeeping —
version line `dotnet-release v4`, four new *Common mistakes* rows.

SKILL.md grew 261 → 362 lines. `FEATURE-6D97` is complete.

## Files/modules touched

**Modified**

- `.claude/skills/dotnet-release/SKILL.md` — version line; *Execution boundary* rewritten with two
  exceptions + new `### Pack-verify`; *In-repo edits* split into `### First release` / `### Routine
  release` / `### Target-framework normalization`; *Packable-library prerequisites* replaced with the
  12-property table + `### Symbols & SourceLink (opt-in)`; new `## The shape of a release work item`;
  4 new *Common mistakes* rows.
- `docs/roadmap.md`, `docs/plan/FEATURE-6D97.md` — PHASE03 and the **item itself** flipped to `DONE`.

**Created** — `docs/done/FEATURE-6D97-PHASE03.md` (this file).

## Acceptance criteria

### 1 — 12-property table + the two structural requirements, cross-checked both ways ✅

The table lists all 12, followed by the packing `ItemGroup` and **`GeneratePackageOnBuild` OFF**.

**Two-way comparison against `src/Enigma.Core/Enigma.Core.csproj`** (scripted, not eyeballed):

| Direction | Result |
|---|---|
| Every property in the table appears in EC's csproj | **12 / 12** — no gaps |
| Every package-metadata property in EC's csproj appears in the table | **12 / 12** — no extras |

| # | Property | In EC csproj |
|---|---|---|
| 1 | `PackageId` | ✅ `Enigma.Core` |
| 2 | `Version` | ✅ `1.0.0` |
| 3 | `Title` | ✅ |
| 4 | `Description` | ✅ |
| 5 | `PackageTags` | ✅ |
| 6 | `PackageReadmeFile` | ✅ `README.md` |
| 7 | `PackageLicenseFile` | ✅ `LICENSE.md` |
| 8 | `RepositoryUrl` | ✅ |
| 9 | `RepositoryType` | ✅ `git` |
| 10 | `PackageProjectUrl` | ✅ |
| 11 | `PackageReleaseNotes` | ✅ |
| 12 | `GenerateDocumentationFile` | ✅ `true` |

The only csproj properties **excluded** are `OutputType` and `TargetFrameworks` — build configuration, not
package metadata, and both owned by `dotnet-solution-setup`'s `library.csproj` template. EC's csproj has
`GeneratePackageOnBuild` absent (= off) and carries the packing `ItemGroup`, matching both structural
requirements. The cross-reference to `../dotnet-solution-setup/templates/library.csproj` is present and
resolves, and states that a never-released library missing all 12 is expected, not drift.

### 2 — Two separate ordered paths; license audit scoped to the first release ✅

`### First release (no published version yet)` — 4 ordered steps: metadata → **license audit** →
author the documents → `docs/RELEASE.md`. `### Routine release (a published version exists)` — 4 ordered
steps: version + TFM normalization → `PackageReleaseNotes` / notes / callout → dependency refresh →
snippet gate *only if* guides or the quick-start moved. The "usually just `<Version>` and the callout"
note is kept.

The audit step carries the ships/doesn't-ship distinction as a table (EC's actual audit as the worked
example: `BouncyCastle.Cryptography` and `System.Buffers` runtime → audited; `PolySharp` compile-only
`PrivateAssets=all` and `xunit.v3` / `coverlet.collector` test-only → not redistributed), requires
recording findings in the completion doc, and is marked **first release only — not repeated on routine
bumps**.

### 3 — Execution boundary names exactly two run-permitted exceptions ✅

Rewritten as an explicit two-sided statement — verified by grep:

- **Runs:** local GUID generation (MSI profiles) · local pack-verify (cleans up after itself).
- **Prints only, never runs:** `git tag`, `git push`, the publish `dotnet pack` into a real artifacts
  directory, `dotnet nuget push`, the merge/push to the default branch; the API key is never stored,
  committed or echoed.

The section states "**exactly two** run-permitted exceptions" in so many words, so a future reader can't
quietly add a third.

### 4 — Pack-verify subsection ✅

`### Pack-verify (local, then deleted)` gives the command (`-o ./artifacts-verify`) and the full
inspection list: `.nupkg` version matches the release · `README.md` embedded **and non-empty** ·
`LICENSE.md` embedded · the nuspec's `<version>`, `<title>`, `<license type="file">`, `<readme>` and
`<releaseNotes>` · dependency floors per TFM. It requires **deleting the verify directory** ("never
committed") and reiterates that the publish `pack` into `./artifacts` stays print-only.

### 5 — SourceLink subsection, consistent with PHASE01's `RELEASE.md` fix ✅

States **"No symbol package by default"** and lists all four properties — `PublishRepositoryUrl`,
`IncludeSymbols`, `SymbolPackageFormat`, `EmbedUntrackedSources` — plus what it buys (real stack traces,
step-into-source) and the requirement to update `docs/RELEASE.md` when enabling it.

**No contradiction with PHASE01:** both files now say `dotnet pack` produces only the `.nupkg`, and both
name `IncludeSymbols` / `SymbolPackageFormat=snupkg` as the opt-in that changes it — checked
side-by-side. This closes the second half of defect **D5**.

### 6 — Both work-item shapes + the two ordering constraints ✅

`## The shape of a release work item` documents the **first release — 4 phases** table (metadata+audit →
guides → README/notes/community → RELEASE.md+pre-flight+pack-verify+runbook) and the **routine release —
single phase**. Both ordering constraints are stated with their reasons: *metadata before pack-verify*
(nothing valid to pack until the metadata is complete) and *guides before the README* (the README's
Documentation section points at them). The practical note about keeping the Release build green on a
doc-only phase that touches the csproj is included.

### 7 — Version line, four new mistake rows, nothing to build or test ✅

`**Version: dotnet-release v4.**` sits on line 8, matching the house placement in the other five skills
(`dev-workflow v3`, `xunit-v3 v2`, `dotnet-solution-setup v2`, `dotnet-solution-config v2`,
`git-repo-hygiene v2`). *Common mistakes* went 16 → 20 rows; the four new ones cover a package with no
`Description`/`Title`, packing without inspecting, claiming a `.snupkg` without `IncludeSymbols`, and
misscoping the license audit.

**Nothing to build or test** — a markdown skill file in a dotfiles repo; no build step and no test suite
exist. Definition-of-Done criteria 1–2 are met by inspection: 12 code fences balanced, heading tree
checked, all 8 relative links resolve, and the AC1 / AC3 / AC5 assertions above were run as scripts
rather than read by eye.

## Deviations & follow-ups

- **TFM normalization kept as its own `### Target-framework normalization` subsection.** The plan's
  routine-release path references it in one line ("TFM normalization if the set moves"), but the rules
  themselves (preserve/normalize table, plural-element rule, logging) are ~15 lines that predate this item
  (`FEATURE-009`) and belong to neither path exclusively. Promoting them to a sibling subsection keeps both
  paths short and leaves the `FEATURE-009` content verbatim rather than duplicating or truncating it. No
  rule text changed — the only edit was dedenting from sub-bullets to top-level bullets and dropping a now
  dangling "(below)".
- **First-release path does not restate the TFM check.** The plan's first-release steps don't include one,
  and a freshly bootstrapped library already gets `netstandard2.0;net8.0;net10.0` from
  `dotnet-solution-setup`. The subsection is written to apply to any release that moves the set, so nothing
  is lost — but if you want an explicit "confirm the TFM set" step on a first release, that is a small
  follow-up.
- **`{{PACKAGE_TITLE}}` still unused.** PHASE01 predicted it would land here as the csproj `<Title>`, but
  the prerequisites table describes properties rather than templating a csproj, so no placeholder was
  needed. The token from the plan's conventions list is simply not used by this item — worth dropping from
  any future template work rather than inventing a use for it.
- **Line endings (CRLF):** no line-ending inconsistency observed in any file touched across all three
  phases — nothing to recommend.
