---
name: dotnet-release
description: Use when releasing a new version of a .NET library/app to NuGet — bumping the version, authoring the release documentation from the bundled templates (packed README + badges, release notes, per-category guides and their index, SECURITY.md), PackageReleaseNotes, refreshing NuGet packages, printing the pack/tag/push runbook, and generating a WixSharp MSI profile when releasing an app.
---

# .NET version release

Drive a new NuGet library-version release end-to-end: make the in-repo edits (version, release notes, README, package metadata, selective dependency bumps), then **print** the out-of-repo runbook for the user to run. A release is the **final phase of a `FEATURE-HHHH` work item** — defer to **dev-workflow** for the branch, the commit, tag/publish ownership, the roadmap/plan/`done` records, and the documentation-freshness sweep; this skill does not restate them.

## When to use

- Cutting a new version of a .NET **library** that publishes to NuGet — bump the version, refresh notes and README, update dependencies, and produce the pack/tag/push runbook.
- Cutting a new version of a non-packable **app** — the version bump, release notes, and tag still apply; the `pack`/`push` steps are skipped (see *App vs library*).

**Not for:** the shape of `Directory.Packages.props` / CPM itself (see **dotnet-solution-config**) · `.gitignore` / `.gitattributes` / line-ending normalization (see **git-repo-hygiene**) · the roadmap / plan / `done` / commit / branch mechanics of the work item (see **dev-workflow**).

## Execution boundary

The skill makes **in-repo edits only**. It **prints — never runs —** the outward-facing, irreversible commands (`git tag`, `dotnet pack`, `dotnet nuget push`, and the merge/push to the default branch); the user runs them. The NuGet API key is never stored, committed, or echoed. This mirrors **git-repo-hygiene** and **dev-workflow**: the user owns commits, tags, and publishes.

**One exception:** local GUID generation for an app's MSI profile (see *MSI profiles (apps only)*). A `uuidgen`-class command is local and reversible, so the skill **runs** it rather than fabricating GUIDs by hand — unlike the outward pack/tag/push commands, which it only prints.

## In-repo edits (the skill makes these)

Given the version `X.Y.Z` being released:

- **Target frameworks** — check the **packable library**'s `<TargetFramework>` / `<TargetFrameworks>` and normalize its modern-.NET set to the current LTS pair. **This is the one in-repo edit the skill proposes and confirms before writing:** show the `old → new` TFM set and wait for the user's OK, because a TFM change moves the library's compatibility surface. Apps/CLIs are left alone (they ship a single TFM).
  - **Preserve** every `netstandard*` target (max consumer compatibility) and every **platform-specific** TFM (one with a `-` suffix — `net8.0-windows`, `net10.0-android`, …); rewriting those would strip the platform surface. If a platform-specific TFM is older than `net8`, **warn** (print a note) for manual review — don't change it.
  - **Normalize the plain-`net` targets to exactly `net8.0;net10.0`** — the two currently-supported LTS releases (net8 LTS through Nov 2026, net10 LTS from Nov 2025), so the modern-.NET set is `net8.0` + `net10.0` **for now**. Add whichever is missing, replace any `net` older than 8 (`net6.0`, `netcoreapp*`), and collapse any other `net` (e.g. `net9.0`) down to the pair. This fires **only when a plain-`net` target already exists** — a `netstandard`-only library is left untouched (never force `net` onto it):

    | before | after |
    |---|---|
    | `net8.0` | `net8.0;net10.0` |
    | `netstandard2.0;net8.0` | `netstandard2.0;net8.0;net10.0` |
    | `net6.0` | `net8.0;net10.0` |
    | `net9.0` | `net8.0;net10.0` |
    | `net10.0` | `net8.0;net10.0` |
    | `netstandard2.0` | `netstandard2.0` (unchanged) |

  - When the result carries more than one TFM, use the plural **`<TargetFrameworks>`** element (`;`-separated — `netstandard*` first, then ascending `net`, then any preserved platform TFM), converting from a singular `<TargetFramework>` if needed.
  - **Log the change:** record the `old → new` TFM set in the release's `RELEASENOTES.md` *Compatibility* sub-section and update the README **"supported target frameworks"** line (below). A **dropped** TFM (replacing a `net` older than 8) is a compatibility break — say so in the notes.
- **`<Version>`** in the packable library `.csproj` → `X.Y.Z`. (A CLI/app in the same solution keeps its own independent `<Version>`.)
- **`<PackageReleaseNotes>`** in that csproj — a short prose summary mirroring the top of `RELEASENOTES.md`, ending with `See RELEASENOTES.md for the full details.` (or the migration guide, for a breaking release).
- **`RELEASENOTES.md`** — prepend the new section (newest-first); see *Release documents* below for its shape and sub-sections.
- **`README.md`** — update the **what's-new callout**, and the **"supported target frameworks"** line if the TFM set changed this release; see *Release documents* below for the badge set, the section order, and the packed-link rule.

So the actual per-release version edits are usually just `<Version>` in the csproj and the what's-new callout — plus the target-framework normalization on the releases that move the TFM set. The NuGet badge tracks the published version on its own — leave it alone — and the supported-TFMs line changes only if the TFM set moved this release.

## Release documents

What must be *true* of the released documentation. The bundled templates carry the shape (section order, heading levels, tone, length) so SKILL.md doesn't have to reproduce whole documents — see *Bundled files*.

### `README.md`

The repository-root README is **packed into the nupkg** (`PackageReadmeFile`) and is the package's nuget.org landing page. [`templates/package-README.md`](templates/package-README.md) carries the section order: title → badges → one-paragraph intro → what's-new callout → *Features* → *Installation* → *Quick start* → *Documentation* → *License*. Keep it **summary-length** — the guides carry the detail.

**Badges** — the house set is exactly two, under the title, in this order:

```markdown
[![NuGet](https://img.shields.io/nuget/v/<PackageId>.svg)](https://www.nuget.org/packages/<PackageId>)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
```

The NuGet-version badge tracks the published version automatically — no per-release edit. A **Downloads** badge (`nuget/dt`) exists if it is ever wanted, but it is not part of the house set and is **not offered**: on a fresh package it advertises a low count, which is a negative signal.

**Link rule — a correctness constraint, not a style preference.** The README is packed, so it renders on nuget.org where the repository tree isn't present and a relative link into `docs/` is simply dead:

- **Link only to files that are packed or repo-root** — `LICENSE.md`, `RELEASENOTES.md`.
- **Point at the guides in prose** — name where they live (`docs/guides/`, indexed by `docs/guides/README.md`) and what they cover. **No clickable per-guide links.**
- **No absolute GitHub URLs** — they hard-code org/repo/branch and rot on a rename.

Note the asymmetry: `docs/guides/README.md` is **not** packed, so relative links between the guides are correct *there*. The rule applies to the packed README only.

**What's-new callout** — a single blockquote after the intro:

```markdown
> **What's new in X.Y** — <one-line highlight>. See [RELEASENOTES.md](RELEASENOTES.md).
```

**Supported target frameworks** — the `Targets **<TFMs>**; built on <primary dependency + version>.` line under *Installation*, updated only when the TFM set moved (see *In-repo edits*).

### `RELEASENOTES.md`

Repo-root, newest-first, one section per release. [`templates/RELEASENOTES.md`](templates/RELEASENOTES.md) carries both variants — **first release** (*Feature overview · Compatibility · Version*) and **subsequent release**.

- **Prepend** the new section above the previous one. If the top section is headed `(unreleased)`, **rename** it to `<Name> vX.Y.Z Release Notes` rather than adding a second block.
- **Sub-sections**, in this order and only where non-empty: *New Features · Fixes · Breaking Changes & Migration · Dependencies · Compatibility · Version*. Match the repo's existing style where it already differs.
- **Dependencies** records every `old → new` transition and any coupled set deliberately held back (see *NuGet package refresh*).
- **Compatibility** records the `old → new` TFM set when it moved; a **dropped** TFM is called out as a compatibility break.

### Guides — `docs/guides/`

One markdown guide per category the library actually has, plus an index at `docs/guides/README.md`. **The count follows the library** — one category, one guide. (Enigma.Core has 13 because it has 13 algorithm categories; that is a consequence of its surface, not a target.)

- **Shape** — [`templates/guide.md`](templates/guide.md) for a guide (intro → supported algorithms/operations table → key types table → `###`-per-scenario usage → notes), [`templates/guides-README.md`](templates/guides-README.md) for the index.
- **Delegation** — guides are independent and split cleanly, so write them **one per sub-agent**, giving each the target path and the relevant public API surface. See **dev-workflow**'s sub-agent rules; the owner integrates and re-verifies every snippet before the phase is done.

**The snippet-verification gate — required** whenever a guide or the README quick-start is touched:

- Cross-check **every API reference in every code fence** against the real public surface in `src/`: `using` namespaces, factory types and their `Create*` methods, service members and their argument shapes (including sync/async and `await`), static helpers, extension methods, enums and options types.
- **Fix any mismatch in place.**
- **Record the coverage in the completion doc as a table** — per file: *snippets · symbols · mismatches · uncertain*, with totals. (Enigma.Core's polish pass recorded 60 snippets / 209 symbols / 0 mismatches; the table is what makes the claim auditable.)

The gate exists because **there is no compile harness for doc snippets** — nothing else catches drift when the API moves. A permanent doc-sample test project is the known alternative; Enigma.Core considered and declined it. It is not required here.

### Community files

- **`SECURITY.md`** — **offer** it from [`templates/SECURITY.md`](templates/SECURITY.md) for any package published publicly; **create only if missing**.
- **No `CHANGELOG.md`.** `RELEASENOTES.md` is the single release-notes source; a second chronology guarantees divergence. Don't add one, and if the repo has both, say so.
- **`CONTRIBUTING.md`** — not part of the house set; add only on request.
- **`LICENSE.md`** — owned by **dotnet-solution-setup** (written at bootstrap from its `templates/LICENSE.md`). This skill's job is to **verify** it exists, is referenced by `<PackageLicenseFile>`, and is packed.
- **`CLAUDE.md`** — a repo-specific agent guide, not a release artifact and not a template. If the repo has one, **dev-workflow**'s documentation-freshness sweep covers it.

## NuGet package refresh

- Run `dotnet list package --outdated` to see what moved.
- Apply the **non-coupled** bumps by editing `<PackageVersion>` entries in `Directory.Packages.props` (see **dotnet-solution-config** for the CPM file's layout).
- **Hold back the version-coupled ecosystems** unless the user opts in — bump each set together, never one package at a time: `Avalonia.*`, `Carbon.Avalonia.Desktop`, `PhosphorIconsAvalonia`, `AvaloniaUI.DiagnosticsSupport`.
- **Record every `old → new` transition** in the release's `RELEASENOTES.md` section (a *Dependencies* bullet), and note any coupled set deliberately held back.

## Packable-library prerequisites

Before the first release (or when verifying an existing one), the library csproj must have:

- `<PackageId>`.
- `<PackageReadmeFile>README.md</PackageReadmeFile>` and `<PackageLicenseFile>LICENSE.md</PackageLicenseFile>`, with the files packed:
  ```xml
  <ItemGroup>
    <None Include="..\..\README.md" Pack="true" PackagePath="\" />
    <None Include="..\..\LICENSE.md" Pack="true" PackagePath="\" />
  </ItemGroup>
  ```
- `<PackageReleaseNotes>` (see above).
- **`GeneratePackageOnBuild` OFF** (absent, or `false`) — a publishable library is packed explicitly by the release step, never on every local build, consistent with the print-don't-run boundary.

## Runbook — print, never run

Print the following for the user to run (these are the `docs/RELEASE.md` steps; the bundled template is the fuller checklist). State explicitly: **the skill prints these; the user runs them.**

```bash
# 1. Pre-flight (Release configuration)
dotnet build <solution> -c Release
dotnet test  <solution> -c Release

# 2. Merge the release branch into the default (published) branch, then locally:
git switch <default-branch> && git pull

# 3. Tag — match existing tags; default bare X.Y.Z
git tag X.Y.Z
git push origin X.Y.Z

# 4. Pack (GeneratePackageOnBuild is off)
dotnet pack <lib.csproj> -c Release -o ./artifacts

# 5. Push to NuGet (API key has push rights; never commit/echo it)
dotnet nuget push ./artifacts/<PackageId>.X.Y.Z.nupkg \
  --api-key <NUGET_API_KEY> \
  --source https://api.nuget.org/v3/index.json
```

Then **post-publish verification**: the package page shows `X.Y.Z`; the README NuGet badge resolves; `dotnet add package <PackageId> --version X.Y.Z` restores; and the tag exists with notes matching `RELEASENOTES.md`.

Detect the specifics rather than assuming them:

- **Tag format** — `git tag` to see the repo's convention (bare `X.Y.Z` vs. `vX.Y.Z`) and match it; default to **bare `X.Y.Z`** for a repo with no tags.
- **Solution vs. single project** — use the solution file (`.slnx` / `.sln`) for the build/test pre-flight; if the repo has no solution (one packable project), use the library `.csproj` instead.
- **Default branch** — the published branch you merge into and pack from; the house repos use `main` or `master`. Confirm with `git remote show origin` (or the local default) if unsure.

The merge/tag/push steps assume an initialized git repo with a remote — skip them for a repo that isn't set up to publish yet.

## App vs library

For a **non-packable app** (no `PackageId`, not published to NuGet), skip the pack/push steps entirely — the version bump, `RELEASENOTES.md`, README callout, and the tag still apply. For an app you also **offer to generate an MSI profile** (see *MSI profiles (apps only)*).

## MSI profiles (apps only)

When releasing an **app** — never a library — **offer** to generate a home-made MSI profile: a JSON file WixSharp turns into a Windows installer. The offer fires in the app branch only, **after** the version bump / release notes and **before** the printed runbook. It is **opt-in** — the skill suggests, the user says yes/no. A project with a `PackageId` (a packable library) never gets a profile.

**GUID contract** — the whole point of persisting these files:

- `upgradeCode` — the app's **stable identity** GUID; the **same in every version's profile**.
- `productId` — a **new GUID for every version**.

**Location & filenames.** Profiles live in `<solution-root>/msiProfiles/` (create the dir if missing) and are **committed** to the repo — the `upgradeCode` must persist across releases. Filenames are **always version-suffixed**, including the first: `<AppName>.msiprofile.<version>.json`. Detect this app's existing profiles by glob `<AppName>.msiprofile.*.json`; an empty or absent dir counts as "first".

**First profile** (none exist for this app): generate **two** GUIDs — `upgradeCode` and `productId` — then fill the rest by auto-detecting the derivable fields and confirming/asking the others.

- **Auto-detect:** `appName` + `msiFilename` (csproj / app name); `releasePath` = `<appdir>\bin\Release\<tfm>`; the shortcut exe / `targetPath` = the app's **build-output assembly name**, `[INSTALLDIR]\<AssemblyName>.exe` (the csproj output name — often differs from the display `appName`, e.g. `Draw.App.exe` for the `Draw` app); `productIcon` = `Assets\*.ico`; `manufacturer` = csproj `<Authors>` / `<Company>`; `version` = the release `X.Y.Z`. If the `.ico` or a `bin\Release\<tfm>` build isn't present yet, leave that field blank and **warn**.
- **Confirm/ask, with defaults:** `scope` (`PerMachine`), `installPath` (`%ProgramFiles%\<AppName>`), `compression` (`High`), `outputPath`, and `shortcuts` (default a `%Desktop%` and a `%ProgramMenu%` entry, both targeting `[INSTALLDIR]\<AssemblyName>.exe`).

**Subsequent profile** (≥1 already exists): **clone the most-recent** `<AppName>.msiprofile.*.json` (highest version). Keep `upgradeCode` and all config **verbatim**; generate a **new `productId`** only; set `version` = the release version. Re-point `releasePath` **only if** this release changed the app's TFM (see *In-repo edits*). If the newest existing profile is malformed, **stop and ask** — don't guess.

**GUID generation — the skill runs it.** Use a local generator: `uuidgen`, or `cat /proc/sys/kernel/random/uuid`, or PowerShell `[guid]::NewGuid()`. This is the **one documented exception** to the print-never-run boundary (local and reversible, unlike the outward pack/tag/push). **Never fabricate a GUID** by hand.

**Scope stops at the JSON profile** — no `.msi` build, no WixSharp invocation.

### Field reference

Mirrors [`templates/msiprofile.template.json`](templates/msiprofile.template.json) (its field **order** is authoritative).

| Field | Meaning | Source |
|---|---|---|
| `appName` | Display name (drives `installPath`, shortcut names, `msiFilename`) | csproj / app name — confirm |
| `installPath` | Install directory | default `%ProgramFiles%\<AppName>` — confirm |
| `releasePath` | Build output to package | `<appdir>\bin\Release\<tfm>` — auto (blank + warn if not built) |
| `scope` | Install scope | default `PerMachine` — confirm |
| `version` | Release version | the release `X.Y.Z` — auto |
| `productId` | Per-version product GUID | **generated new every release** |
| `upgradeCode` | Stable app-identity GUID | **generated once; reused verbatim after** |
| `manufacturer` | Publisher | csproj `<Authors>` / `<Company>` — auto |
| `productIcon` | App icon (`.ico`) | `Assets\*.ico` — auto (blank + warn if absent) |
| `compression` | MSI compression | default `High` — confirm |
| `outputPath` | Where the `.msi` is written | confirm |
| `msiFilename` | `.msi` base name | csproj / app name — confirm |
| `shortcuts[]` | Desktop / start-menu shortcuts | default `%Desktop%` + `%ProgramMenu%`, target `[INSTALLDIR]\<AssemblyName>.exe` |

Each `shortcuts[]` entry, in order: `shortcutPath` (`%Desktop%` / `%ProgramMenu%`), `shortcutName`, `targetPath` (`[INSTALLDIR]\<AssemblyName>.exe`), `iconPath`, `arguments`.

**Placeholder legend** (tokens in the template): `{{APP_NAME}}`, `{{INSTALL_PATH}}`, `{{RELEASE_PATH}}`, `{{SCOPE}}`, `{{VERSION}}`, `{{PRODUCT_ID}}`, `{{UPGRADE_CODE}}`, `{{MANUFACTURER}}`, `{{PRODUCT_ICON}}`, `{{COMPRESSION}}`, `{{OUTPUT_PATH}}`, `{{MSI_FILENAME}}`, and `{{TARGET_EXE}}` (the shortcut target exe filename, e.g. `Draw.App.exe`). Write valid JSON; a non-ASCII `manufacturer` need not be `\uXXXX`-escaped (the examples' escaping is cosmetic).

## Cross-references

- **dev-workflow** — the release is the final phase of a `FEATURE-HHHH` item; it owns branch naming, the never-commit-myself rule, tag/publish ownership, the `docs/roadmap.md` + `docs/plan/` + `docs/done/` records, and the doc-freshness sweep.
- **dotnet-solution-config** — the CPM `Directory.Packages.props` file this skill edits when refreshing dependency versions, and the coupled-ecosystem rule.
- **dotnet-solution-setup** — the authority for choosing a project's target frameworks at creation time; this skill's release-time normalization keeps a multi-targeted library on the current `net8.0` + `net10.0` LTS pair.
- **git-repo-hygiene** — `.gitignore` / `.gitattributes` / line-ending normalization.

## Bundled files

- [`templates/RELEASE.md`](templates/RELEASE.md) — the human release checklist (pre-flight → merge → tag → pack → push → verify). Offer it into the target repo's `docs/RELEASE.md`, **create only if missing** (don't clobber an existing runbook — diff instead), and fill its placeholders (`{{PACKAGE_ID}}`, `{{SOLUTION}}`, `{{LIB_CSPROJ}}`, `{{LIB_DIR}}`, `{{DEFAULT_BRANCH}}`).
- [`templates/msiprofile.template.json`](templates/msiprofile.template.json) — the MSI-profile skeleton (the authoritative field set/order). **Apps only** — copy into `<solution-root>/msiProfiles/<AppName>.msiprofile.<version>.json` and fill its `{{…}}` placeholders (see *MSI profiles (apps only)*).
- [`templates/package-README.md`](templates/package-README.md) — the packed root `README.md`: badges, intro, what's-new callout, *Features*, *Installation*, *Quick start*, prose-only *Documentation* pointer, *License*.
- [`templates/RELEASENOTES.md`](templates/RELEASENOTES.md) — the root `RELEASENOTES.md`, carrying both the first-release and subsequent-release variants and the `(unreleased)` rename rule.
- [`templates/guide.md`](templates/guide.md) — one per-category guide under `docs/guides/`: supported algorithms/operations → key types → copy-pasteable usage → notes.
- [`templates/guides-README.md`](templates/guides-README.md) — the `docs/guides/README.md` index: themed groups of relative links (repo-only, never packed).
- [`templates/SECURITY.md`](templates/SECURITY.md) — the root `SECURITY.md`: supported versions, GitHub private vulnerability reporting, what to expect, scope.

Every doc template follows the same handling rule as `RELEASE.md`: **create only if missing — diff against an existing file, never clobber it.**

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Auto-pushing to NuGet, or running `git tag` / `dotnet pack` / `dotnet nuget push` for the user | The skill only prints them; the user runs the outward-facing commands. |
| Bumping `Avalonia.*` / `Carbon.Avalonia.Desktop` / `PhosphorIconsAvalonia` individually | Bump the coupled ecosystem together, or hold the whole set back. |
| Forgetting `<PackageReleaseNotes>` in the library csproj | Add it, mirroring the top of `RELEASENOTES.md`. |
| Tagging with the wrong prefix (bare vs. `v`) | Detect existing tags and match; default bare `X.Y.Z`. |
| `GeneratePackageOnBuild` left on for a publishable library | Turn it off; pack explicitly in the release step. |
| Skipping the Release-config build/test pre-flight | Always `dotnet build`/`dotnet test -c Release` before tagging. |
| Not logging `old → new` dependency transitions | Record every version change (and held-back set) in `RELEASENOTES.md`. |
| TFM set changed but the README "supported target frameworks" line / `RELEASENOTES.md` *Compatibility* note not updated | Log the `old → new` TFM set and keep the audit trail in sync; flag a dropped TFM as a breaking change. |
| Committing or echoing the NuGet API key | The key is a secret — it never appears in the repo or output. |
| Generating an MSI profile for a *library* | Profiles are apps-only; a project with a `PackageId` never gets one. |
| Regenerating `upgradeCode` on a later release | Reuse the existing `upgradeCode` verbatim — only `productId` changes per version. |
| Fabricating GUIDs by hand | Run a local generator (`uuidgen` / `[guid]::NewGuid()`); GUIDs are never invented. |
| Storing MSI profiles outside `<solution-root>/msiProfiles/` | They live there and are committed, so `upgradeCode` persists across releases. |
| A relative `docs/…` link in the packed README | Dead on nuget.org — the repo tree isn't there. Link only packed/repo-root files; point at the guides in prose. |
| Adding a `CHANGELOG.md` alongside `RELEASENOTES.md` | One release-notes source only; two chronologies diverge. `RELEASENOTES.md` wins. |
| Shipping a guide whose snippets were never verified against `src/` | Run the snippet-verification gate and record the coverage table — there is no compile harness to catch drift. |

If the target repo already has its own release conventions (tag prefix, notes layout, badge set), stay consistent with them and flag the divergence rather than silently imposing these defaults.
