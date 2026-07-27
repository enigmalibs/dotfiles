# FEATURE-6D97 — `dotnet-release`: EC-derived doc templates, first-release path & policy fixes

**Status:** IN PROGRESS
**Type:** FEATURE (multi-phase)
**Branch (per phase, at build time):** `feature/feature-6d97-phaseNN-<slug>` — one branch per phase, cut from current `HEAD`.

## Objective

Capture the **Enigma.Core** (EC) v1.0.0 release in `dotnet-release`, so the next release produces the same
quality of user-facing documentation without re-deriving it. Three outcomes:

1. **Bundle the doc templates the skill is missing entirely** — the package `README.md`, `RELEASENOTES.md`,
   the per-category guide shape, the guides index, and `SECURITY.md`. Today the skill prescribes only
   badges and a what's-new callout in prose; it bundles no document template at all.
2. **Document the release *mechanics* EC needed and the skill lacks** — the full package-metadata set, an
   explicit first-release path (with a license audit), a sanctioned local pack-verify, the SourceLink
   opt-in, and the shape of a release work item.
3. **Fix two policy defects** the EC audit surfaced (below).

## Context & constraints

- **Evolution of an existing codebase:** `/home/jo/dotfiles2`, skills at `.claude/skills/`, symlinked live
  into `~/.claude/skills/`. No build, no tests — Definition-of-Done criteria 1–2 are met by inspection and
  the byte-diffs in the acceptance criteria.
- **Reference release:** EC `FEATURE-4620` (4 phases: metadata+license → guides → README/notes/community →
  runbook), polished by `FEATURE-28C7` (dropped the Downloads badge; verified every doc snippet).
- **`docs/RELEASE.md` is already embedded** — EC's file *is*
  `dotnet-release/templates/RELEASE.md` with its placeholders filled. The only content delta is the
  symbols paragraph (D5 below). No other work on that template.
- **Depends on `FEATURE-79A1`**, which settles the library/test csproj templates this item's
  metadata section references. Build `FEATURE-79A1` first.
- **The number of guides is not fixed.** EC has 13 because it has 13 algorithm categories. What this item
  captures is the **shape and writing style** of a guide and its index — a library with one category gets
  one guide.

## Defects this item fixes

| # | Defect | Fix | Phase |
|---|--------|-----|-------|
| D5 | `templates/RELEASE.md` states that `dotnet pack` "also emits a `.snupkg` symbols package alongside the `.nupkg`". It does not, unless `IncludeSymbols` is set. EC had to correct this line by hand when filling the template. | State that only the `.nupkg` is produced unless symbols are configured; add SourceLink/`snupkg` as a documented opt-in. | PHASE01 + PHASE03 |
| D6 | The badge section offers a Downloads badge as "optional (offer it)", but it was deliberately removed from EC in `FEATURE-28C7` — so the skill still prompts for something already decided against. | Fix the set at NuGet version + License; delete the offer, keep a one-line note that Downloads exists. | PHASE02 |

## Versioning

`dotnet-release` gains `**Version: dotnet-release v4.**` under its `#` heading. Derived by counting
material revisions from the roadmap: v1 = FEATURE-007 (creation), v2 = FEATURE-009 (TFM normalization),
v3 = FEATURE-010 (MSI profiles), **v4 = this item**. (FEATURE-0EF9 touched two placeholder references
only — not a material revision.)

## Conventions for all new bundled templates

- **Placeholder style** `{{UPPER_SNAKE}}`, matching the existing `RELEASE.md` and
  `msiprofile.template.json`. Tokens introduced here: `{{PACKAGE_ID}}`, `{{PACKAGE_TITLE}}`,
  `{{VERSION}}`, `{{VERSION_MINOR}}` (the `X.Y` used in the what's-new callout), `{{TFM_LIST}}`,
  `{{ORG}}`, `{{REPO}}`.
- **Bundled filenames** stay non-colliding, so a template can't be mistaken for the skill's own docs:
  `templates/package-README.md`, `templates/RELEASENOTES.md`, `templates/guide.md`,
  `templates/guides-README.md`, `templates/SECURITY.md`. (**Not** a bare `templates/README.md`.)
- **Create only if missing; diff, never clobber** — the rule already applied to `RELEASE.md` extends to
  every template added here. A target repo with its own README gets a diff, not an overwrite.
- **EC's domain prose is genericized.** EC's crypto feature lists become neutral placeholder text; the
  *section order, heading levels, tone and length* are what the template carries. Those templates are
  therefore verified by a **structural** diff, not a literal one.
- Every new template is listed in the skill's **Bundled files** section with a one-line purpose.

---

## PHASE01 — Bundled doc templates + `RELEASE.md` symbols fix

**Status:** DONE

**Goal:** the five missing document templates, plus the one-paragraph correction to `RELEASE.md`.

### Step 1 — `templates/package-README.md`

EC's `README.md` (3.7 KB — deliberately short; it is packed into the nupkg and is the nuget.org landing
page). Reproduce its section order exactly:

1. `# {{PACKAGE_ID}}`
2. **Badges** — NuGet version + License, in that order, blank-line-separated from the title:
   ```markdown
   [![NuGet](https://img.shields.io/nuget/v/{{PACKAGE_ID}}.svg)](https://www.nuget.org/packages/{{PACKAGE_ID}})
   [![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
   ```
   (EC uses `green`; the skill's prose currently says `blue` — the template follows EC.)
3. **One-paragraph intro** — what the library is and the single idea a consumer needs to hold (EC: "create
   a factory, ask it for the service you need, call the operation"). No bullet list here.
4. **What's-new callout** — one blockquote, `> **What's new in {{VERSION_MINOR}}** — <one-line highlight>.
   See [RELEASENOTES.md](RELEASENOTES.md).`
5. `## Features` — bulleted summary, one bullet per category, each opening with a bold category name and
   naming the concrete capabilities (`- **Block ciphers** — AES, DES, …`). This is a summary, not a manual.
6. **Optional `### <cross-cutting capability>`** subsection for a property that spans categories — EC's is
   `### Asynchronous, cancellable, observable`. Include it in the template as an optional, commented block.
7. `## Installation` — `dotnet add package {{PACKAGE_ID}}` in a `bash` fence, then the **supported target
   frameworks** line (`Targets **{{TFM_LIST}}**; built on <primary dependency + version>.`) — the line
   `dotnet-release` already requires updating when the TFM set moves.
8. `## Quick start` — **one** short, real, compiling snippet showing the library's core idiom end to end
   (EC: factory → service → operation, ~10 lines). Not a tour.
9. `## Documentation` — **prose-only** pointer (see the packed-link rule in PHASE02): the guides live
   under `docs/guides/` in the repository, indexed by `docs/guides/README.md`, and a sentence naming what
   they cover. **No clickable links, no absolute URLs.**
10. `## License` — one line linking `LICENSE.md`.

Add a short leading HTML comment listing the placeholders and the "keep it summary-length; the guides
carry the detail" rule, mirroring how `RELEASE.md` documents itself.

### Step 2 — `templates/RELEASENOTES.md`

One file carrying **two variants**, clearly separated by comments:

**First release** (EC's actual shape):
- `# {{PACKAGE_ID}} v{{VERSION}} Release Notes`
- Intro paragraph — the first public release, one-sentence positioning.
- `## Feature overview` — the same category bullets as the README's Features, at slightly more depth, plus
  a final bullet for any cross-cutting property.
- `## Compatibility` — the TFM set and the primary dependency versions.
- `## Version` — `Initial release: **{{VERSION}}**.`

**Subsequent release** — same title form, prepended above the previous section (newest-first), with the
sub-sections the skill already names, in this order and only where non-empty:
- `## New Features`
- `## Fixes`
- `## Breaking Changes & Migration`
- `## Dependencies` — every `old → new` transition, and any coupled set deliberately held back.
- `## Compatibility` — the `old → new` TFM set when it moved; a **dropped** TFM is called out as a
  compatibility break.
- `## Version`

Include the skill's existing `(unreleased)` rule: if the top section is headed `(unreleased)`, rename it
rather than adding a second block.

### Step 3 — `templates/guide.md`

EC's per-category guide anatomy (`docs/guides/hashing.md` is the cleanest example at 132 lines; the shape
scales to 96–307 lines):

1. `# <Category>`
2. **Intro** — 2–3 short paragraphs: what this category does, the idiom for reaching it, and the one
   cross-cutting property that matters (EC hashing: "all hashing is stream-based and asynchronous, so
   hashing a multi-gigabyte file uses the same constant memory as hashing a short string").
3. `## Supported algorithms` — a table: *Algorithm · Factory method · Notes*, where **Notes carries the
   guidance a caller needs** ("Legacy / broken. Interop only — never for security.", "Recommended
   general-purpose digest."). Then a paragraph on shared optional parameters and their defaults, naming
   the exceptions each throws.
4. `## Key types` — a table: *Type · Namespace · Role*, covering the concrete type, its interface, the
   service, and any shared defaults type. Then the primary method signature in a `csharp` fence, and one
   short paragraph on how the type is obtained (`new` vs DI).
5. `## Usage` — one `###` sub-section per scenario, each a **complete, copy-pasteable** snippet with its
   full `using` block (EC includes every `using`, even `System`), ordered simplest → most involved. Final
   sub-section covers the cross-cutting concern (progress/cancellation) where applicable.
6. `## Notes` — bullets for caveats that don't belong in a table: deprecated algorithms, stream-position
   requirements, parameters that affect performance but not results.

Add a leading comment stating the two non-negotiables: **every snippet must compile against the real
public API** (see the verification gate in PHASE02), and **snippets include their full `using` block** so
they are genuinely copy-pasteable.

### Step 4 — `templates/guides-README.md`

EC's `docs/guides/README.md` (50 lines) — the index:

- `# {{PACKAGE_ID}} — Guides & Samples`
- Short intro repeating the core idiom (so the index stands alone), plus one sentence stating that every
  guide follows the same shape.
- `## <Theme>` sections grouping the guides by theme (EC: *Symmetric encryption · Hashing & message
  authentication · Key derivation · Asymmetric cryptography · Certificates · One-time passwords · Data &
  helpers*), each entry `- [Title](file.md) — <one-line scope>` using **relative** links so they resolve
  when browsing on GitHub.

Note in the template comment: the index is a repo-only file — relative links are correct **here** because
this file is never packed (unlike the root README).

### Step 5 — `templates/SECURITY.md`

EC's `SECURITY.md`, genericized:

- `# Security Policy`
- Intro naming why this package's security matters to consumers.
- `## Supported versions` — SemVer statement + a small version/supported table.
- `## Reporting a vulnerability` — a **bold do-not-use-public-issues** warning, then the numbered
  GitHub private-vulnerability-reporting steps (Security tab → Report a vulnerability → what to include).
  **No email address** — EC deliberately exposes none.
- `## What to expect` — acknowledge/triage, fix, coordinated disclosure, credit unless anonymity is asked.
- `## Scope` — what is in scope, and where to report issues rooted in an upstream dependency.

### Step 6 — fix `templates/RELEASE.md` (D5)

Replace the paragraph in step 5 that claims `dotnet pack` emits a `.snupkg` with the accurate statement:
`dotnet pack` emits **only** the `.nupkg` unless symbols are configured — that single file is what gets
pushed. Keep the "the API key is a secret — never commit or echo it" sentence. Everything else in the
template stays as-is.

**Acceptance criteria**

1. All five new templates exist, are well-formed markdown, and each carries a leading comment listing its
   placeholders.
2. **Structural diff — `package-README.md` vs EC's `README.md`:** identical heading sequence, heading
   levels, badge block and callout form; differences confined to EC's crypto-specific prose and feature
   bullets. Record the section-by-section comparison in the completion doc.
3. **Structural diff — `guide.md` vs EC's `docs/guides/hashing.md`** and **`guides-README.md` vs EC's
   `docs/guides/README.md`:** same heading sequence and table column sets.
4. **Structural diff — `SECURITY.md` vs EC's:** all five sections present in order; no email address
   anywhere in the template.
5. `templates/RELEASENOTES.md` contains both variants, each with its sub-sections in the specified order,
   and the `(unreleased)` rule.
6. `grep -n "snupkg" templates/RELEASE.md` shows no claim that `dotnet pack` emits one unprompted.
7. Badge block uses `license-MIT-green.svg` and contains **no** `nuget/dt` Downloads badge.
8. Nothing to build or test — state so in the completion doc.

---

## PHASE02 — SKILL.md content rules: README, notes, guides, community files

**Status:** DONE

**Goal:** the prose rules that govern the PHASE01 templates — what must be true of the documents, not just
what they look like.

### Step 1 — README rules & badge convention (D6)

- Replace the badge sub-section with the fixed house set: **NuGet version + License**, with `green` as the
  license badge colour. **Delete the Downloads offer**; keep one line noting the Downloads badge
  (`nuget/dt`) exists if ever wanted, and that a low count on a fresh package is a negative signal. Keep
  the existing "the NuGet-version badge tracks the published version automatically — no per-release edit"
  note.
- Add the **packed-README link rule**, called out as a correctness constraint rather than a style
  preference: the root README is packed into the nupkg (`PackageReadmeFile`), so a relative link to
  `docs/guides/…` renders as a dead link on nuget.org.
  - **Link only to files that are packed or repo-root** — `LICENSE.md`, `RELEASENOTES.md`.
  - **Point at the guides in prose** — no clickable per-guide links.
  - **No absolute GitHub URLs** (they hard-code org/repo/branch and rot on a rename).
  - Note the asymmetry explicitly: `docs/guides/README.md` is *not* packed, so relative links there are
    correct — the rule applies to the packed README only.
- Point at `templates/package-README.md` for the section order, keeping SKILL.md free of the full document.

### Step 2 — RELEASENOTES rules

Keep the existing prepend/`(unreleased)` behaviour; add the sub-section vocabulary and order from
PHASE01, and point at `templates/RELEASENOTES.md` for the two variants. Keep the existing requirement to
record TFM changes under *Compatibility* and dependency transitions under *Dependencies*.

### Step 3 — the guides section (new)

- **What it is:** one markdown guide per category the library actually has, under `docs/guides/`, plus an
  index at `docs/guides/README.md`. State plainly that **the count follows the library** — one category,
  one guide; EC's 13 is a consequence of EC's surface, not a target.
- **Shape:** point at `templates/guide.md` and `templates/guides-README.md`.
- **Sub-agent delegation** (the recipe that made EC's PHASE02 fast): guides are independent and split
  cleanly, so delegate one per sub-agent, giving each the target path plus the relevant public API
  surface; the owner then re-verifies every snippet before declaring the phase done. Cross-reference
  `dev-workflow`'s delegation rules rather than restating them.
- **The snippet-verification gate — required** whenever a guide or the README quick-start is touched:
  - Cross-check every API reference in every code fence against the real public surface in `src/`:
    `using` namespaces, factory types and their `Create*` methods, service members and their argument
    shapes (including sync/async and `await`), static helpers, extension methods, enums and options types.
  - **Fix any mismatch in place.**
  - **Record the coverage in the completion doc as a table** — per file: snippets · symbols · mismatches ·
    uncertain — with the totals. EC's `FEATURE-28C7` recorded 60 snippets / 209 symbols / 0 mismatches;
    the table is what makes the claim auditable.
  - Note why this gate exists: there is no compile harness for doc snippets, so nothing else catches
    drift. (EC considered a permanent doc-sample test project and declined it — record that as the known
    alternative, not as a requirement.)

### Step 4 — community files (new)

- **`SECURITY.md`** — offer it from `templates/SECURITY.md` (create only if missing) for any package
  published publicly.
- **No `CHANGELOG.md`.** State it as a rule with its reason: `RELEASENOTES.md` is the single
  release-notes source, and a second chronology guarantees divergence.
- **`CONTRIBUTING.md`** — not part of the house set; add only on request.
- **`LICENSE.md`** — owned by `dotnet-solution-setup` (bootstrap time, `templates/LICENSE.md`).
  `dotnet-release`'s job is to **verify** it exists, is referenced by `PackageLicenseFile`, and is packed.
- **`CLAUDE.md`** — EC has one, but it is a repo-specific agent guide, not a release artifact and not a
  template. One line: if the repo has a `CLAUDE.md`, the `dev-workflow` doc-freshness sweep covers it.

### Step 5 — housekeeping

Update the frontmatter `description:` to mention the doc templates and the guides; add the new templates
to **Bundled files**; extend **Common mistakes** with rows for: a relative `docs/` link in the packed
README; a `CHANGELOG.md` alongside `RELEASENOTES.md`; shipping a guide whose snippets were never verified
against `src/`.

**Acceptance criteria**

1. The badge section names exactly two badges, uses `green`, and contains no offer to add Downloads.
2. The packed-README link rule is present and states all three parts (packed/repo-root links only, prose
   pointer for guides, no absolute URLs) plus the `docs/guides/README.md` exception.
3. The guides section states that the guide count follows the library's categories, points at both guide
   templates, documents per-guide sub-agent delegation, and specifies the verification gate **including
   the completion-doc coverage table**.
4. The community-files section covers `SECURITY.md` (offered), `CHANGELOG.md` (banned, with reason),
   `CONTRIBUTING.md` (on request), `LICENSE.md` (verify only — owned by `dotnet-solution-setup`), and
   `CLAUDE.md` (freshness-sweep only).
5. Every bundled-file link resolves to a file that exists; `description:` refreshed; three new
   common-mistake rows present.
6. Nothing to build or test — state so in the completion doc.

---

## PHASE03 — Packaging prerequisites, first-release path, pack-verify & release-item shapes

**Status:** TODO

**Goal:** the release mechanics — what a packable library must carry, what differs on a first release, and
what the skill is allowed to run.

### Step 1 — the full packable-library prerequisite set

Replace the current 5-item list with EC's actual 12, as a table (*Property · Purpose · Source*):

| | Property | Note |
|---|---|---|
| 1 | `PackageId` | |
| 2 | `Version` | the release `X.Y.Z` (also covered under *In-repo edits*) |
| 3 | `Title` | short display name — nuget.org heading |
| 4 | `Description` | one-paragraph feature summary; nuget.org renders a package badly without it |
| 5 | `PackageTags` | space-separated search terms |
| 6 | `PackageReadmeFile` | `README.md` + the packing `ItemGroup` |
| 7 | `PackageLicenseFile` | `LICENSE.md` + the packing `ItemGroup` |
| 8 | `RepositoryUrl` | |
| 9 | `RepositoryType` | `git` |
| 10 | `PackageProjectUrl` | |
| 11 | `PackageReleaseNotes` | prose mirroring the top of `RELEASENOTES.md`, ending `See RELEASENOTES.md for the full details.` |
| 12 | `GenerateDocumentationFile` | `true` — ships the XML doc file consumers get IntelliSense from |

Plus the two existing negative/structural requirements: **`GeneratePackageOnBuild` off** (absent or
`false`), and the `<None Include="..\..\README.md" … />` / `LICENSE.md` packing `ItemGroup`.

Cross-reference `dotnet-solution-setup/templates/library.csproj` (from `FEATURE-79A1`), which deliberately
omits this block — the metadata is added here, at release time.

### Step 2 — first-release vs routine-release paths

Split the *In-repo edits* section into two explicit paths:

**First release** (no prior published version):
1. Fill all 12 metadata properties + the packing `ItemGroup`; confirm `GeneratePackageOnBuild` is off.
2. **Third-party license audit** — confirm every **runtime** dependency's license permits redistribution,
   and that the package's own `LICENSE.md` is present, correct and packed. Note that **test-only and
   compile-only packages don't ship** (EC: `BouncyCastle.Cryptography` MIT — runtime;
   `System.Buffers` MIT — netstandard2.0 runtime only; `PolySharp` MIT — compile-only,
   `PrivateAssets=all`, not redistributed; `xunit.v3` / `coverlet.collector` — test-only, not shipped).
   Record the findings in the completion doc. **First release only** — not repeated on routine bumps.
3. Author `README.md`, `RELEASENOTES.md` (first-release variant), the guides + index, and `SECURITY.md`
   from the templates.
4. `docs/RELEASE.md` from `templates/RELEASE.md`.

**Routine release** (a published version exists):
1. `<Version>` → `X.Y.Z`; TFM normalization if the set moves (propose → confirm → log).
2. `PackageReleaseNotes`; prepend the `RELEASENOTES.md` section; update the what's-new callout, and the
   supported-TFMs line only if the TFM set moved.
3. Dependency refresh (`dotnet list package --outdated`), coupled ecosystems held back or bumped as a set,
   every `old → new` logged.
4. Re-run the snippet-verification gate **only if** guides or the README quick-start were touched.

Keep the existing note that a routine release's actual edits are usually just `<Version>` and the callout.

### Step 3 — pack-verify: the second sanctioned exception

Extend the *Execution boundary* section. It currently names exactly one exception (local GUID generation
for MSI profiles); add local pack-verification with the same reasoning — local and reversible, unlike the
outward-facing commands:

```bash
dotnet pack <lib.csproj> -c Release -o ./artifacts-verify   # then inspect, then delete
```

Inspect and confirm: the `.nupkg` version matches the release; `README.md` is embedded **and non-empty**;
`LICENSE.md` is embedded; the nuspec's `<version>`, `<title>`, `<license type="file">`, `<readme>` and
`<releaseNotes>` are all correct; dependency floors are as expected. Then **delete the verify directory**
(EC used `./artifacts-verify` and removed it; it is never committed).

State the boundary precisely, since it now has two exceptions:
- **Runs:** local GUID generation; local pack-verify (then cleans up).
- **Prints only, never runs:** `git tag`, `git push`, `dotnet pack` to a real artifacts dir as part of the
  publish, `dotnet nuget push`, and the merge/push to the default branch. The API key is never stored,
  committed or echoed.

### Step 4 — SourceLink / symbol package opt-in (D5, second half)

New short sub-section: **no symbol package by default** (EC shipped without one). When symbols are wanted,
opt in with the exact properties, and only then does a `.snupkg` appear and pushing the `.nupkg` upload
the symbols automatically:

```xml
<PublishRepositoryUrl>true</PublishRepositoryUrl>
<IncludeSymbols>true</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
<EmbedUntrackedSources>true</EmbedUntrackedSources>
```

Note what it buys (consumers get real stack traces and can step into library source) and that it must be
reflected in `docs/RELEASE.md` when enabled — the template's default wording assumes no symbols.

### Step 5 — the shape of a release work item

New section bridging `dev-workflow` (which owns phases and plan files) and this skill (which owns release
content). Document both shapes and the ordering constraints:

**First release — 4 phases** (EC's `FEATURE-4620`):
| Phase | Content |
|---|---|
| PHASE01 | Package metadata & build config + license check |
| PHASE02 | Per-category guides + index |
| PHASE03 | Summary README + release notes + `PackageReleaseNotes` + community files |
| PHASE04 | `docs/RELEASE.md` + pre-flight + pack-verify + printed runbook |

**Routine release — single phase:** version, notes, callout, dependency refresh, runbook.

State the two ordering constraints that make the phase split non-arbitrary: **metadata before
pack-verify** (there is nothing valid to pack until the metadata is complete), and **guides before the
README** (the README's Documentation section points at them). Add the practical note that a doc-only phase
still keeps the Release build green whenever it edits the csproj.

### Step 6 — housekeeping

Version line (`dotnet-release v4`); extend **Common mistakes** with rows for: shipping a package with no
`Description`/`Title`; skipping the pack-verify inspection; claiming a `.snupkg` exists without
`IncludeSymbols`; running a license audit on test-only packages (or skipping it on runtime ones).

**Acceptance criteria**

1. The prerequisites table lists all 12 properties plus `GeneratePackageOnBuild` off and the packing
   `ItemGroup`. **Cross-check:** every property in the table appears in EC's
   `src/Enigma.Core/Enigma.Core.csproj`, and every package-metadata property in that csproj appears in the
   table — record the two-way comparison in the completion doc.
2. The first-release and routine-release paths are separate, ordered, and the license audit is scoped to
   the first release only (with the runtime vs compile-only vs test-only distinction stated).
3. The *Execution boundary* section names **exactly two** run-permitted exceptions (GUID generation,
   pack-verify) and keeps `git tag` / `nuget push` / the publish `pack` print-only.
4. The pack-verify sub-section lists what to inspect (version, non-empty README, LICENSE, the five nuspec
   fields, dependency floors) and requires deleting the verify directory.
5. The SourceLink sub-section states "no symbols by default" and lists all four csproj properties;
   consistent with the PHASE01 fix to `templates/RELEASE.md` (no contradiction between them).
6. Both release work-item shapes are documented with the two ordering constraints.
7. Version line present; four new common-mistake rows; nothing to build or test — state so.

---

## Out of scope / recorded, not planned here

- **The solution-bootstrap skill family** — `FEATURE-79A1`, planned alongside this item and built first.
- **CI / GitHub Actions workflow and a CI status badge** — declined for EC; a badge would render broken
  without a workflow.
- **`PackageIcon` / nuget.org logo** — declined for EC; not introduced.
- **An automated doc-sample compile harness** — declined for EC; recorded in PHASE02 as the known
  alternative to the manual verification gate, not required.
- **`CONTRIBUTING.md` template** — declined; on request only.
- **MSI profiles** — unchanged; `FEATURE-010` already covers them and no EC evidence contradicts it (EC is
  a library, so it never generated one).
- **TFM normalization rules** — unchanged; `FEATURE-009` covers them and EC's
  `netstandard2.0;net8.0;net10.0` already matched the policy, so the release logged no TFM change.
- **Line endings (CRLF):** no churn observed in any file inspected.
