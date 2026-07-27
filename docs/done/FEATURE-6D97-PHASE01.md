# FEATURE-6D97-PHASE01 — Bundled doc templates + `RELEASE.md` symbols fix

## Summary

`dotnet-release` prescribed release documentation in prose but bundled no document template at all —
every release had to re-derive the README, release notes, guides and security policy from scratch.
This phase captures the Enigma.Core (EC) v1.0.0 release as **five new bundled templates**, and fixes
defect **D5** in the existing `templates/RELEASE.md`.

The templates carry EC's *section order, heading levels, tone and length*; EC's crypto-specific prose is
genericized to neutral placeholder text, so a library in any domain can fill them. Each one leads with an
HTML comment stating its placeholders, where it is copied to, and the rule that makes it non-obvious
(packed vs repo-only, snippet verification, no email address).

Only PHASE01's own scope was touched. Wiring the templates into SKILL.md — the *Bundled files* entries,
the badge/link/guide content rules, the version line — is PHASE02/PHASE03 work and was deliberately left
undone here.

## Files/modules touched

**Created**

| File | Purpose |
|---|---|
| `.claude/skills/dotnet-release/templates/package-README.md` | Packed root README — badges, intro, what's-new callout, Features, Installation, Quick start, prose-only Documentation pointer, License. |
| `.claude/skills/dotnet-release/templates/RELEASENOTES.md` | Both release-notes variants (first release / subsequent release) with the sub-section vocabulary and the `(unreleased)` rename rule. |
| `.claude/skills/dotnet-release/templates/guide.md` | Per-category guide anatomy — intro, supported-algorithms table, key-types table, `###`-per-scenario usage, notes. |
| `.claude/skills/dotnet-release/templates/guides-README.md` | The `docs/guides/` index — themed groups of relative links, stands alone. |
| `.claude/skills/dotnet-release/templates/SECURITY.md` | Security policy — supported versions, GitHub private vulnerability reporting, what to expect, scope. |

**Modified**

- `.claude/skills/dotnet-release/templates/RELEASE.md` — step 5 symbols paragraph (D5).
- `docs/roadmap.md`, `docs/plan/FEATURE-6D97.md` — statuses.

## Acceptance criteria

### 1 — Five templates exist, well-formed, each with a leading placeholder comment ✅

All five created. Automated well-formedness check (fences balanced, HTML comments balanced, trailing
newline):

| File | Code fences | `<!--` / `-->` | Trailing NL |
|---|---|---|---|
| `package-README.md` | 4 (balanced) | 6 / 6 | yes |
| `RELEASENOTES.md` | 0 | 4 / 4 | yes |
| `guide.md` | 8 (balanced) | 5 / 5 | yes |
| `guides-README.md` | 0 | 1 / 1 | yes |
| `SECURITY.md` | 0 | 1 / 1 | yes |

`guide.md`'s leading comment states **"Placeholders: none"** explicitly (a guide is written for its own
category; `<angle-bracket>` text marks what to replace) rather than listing tokens it does not use.

### 2 — Structural diff: `package-README.md` vs EC `README.md` ✅

Heading sequence compared with comments stripped; the only differences are the title placeholder and the
optional cross-cutting subsection, which the plan (Step 1, item 6) requires to ship *commented out*.

| # | EC `README.md` | Template | Match |
|---|---|---|---|
| 1 | `# Enigma.Core` | `# {{PACKAGE_ID}}` | ✅ placeholder |
| 2 | NuGet + License badges, blank-line-separated from title | identical form, `{{PACKAGE_ID}}` substituted | ✅ |
| 3 | one-paragraph intro, no bullets | one-paragraph intro, no bullets | ✅ |
| 4 | `>` what's-new blockquote → `RELEASENOTES.md` | `> **What's new in {{VERSION_MINOR}}** …` | ✅ |
| 5 | `## Features` — bold-category bullets | `## Features` — bold-category bullets | ✅ |
| 6 | `### Asynchronous, cancellable, observable` | same level, shipped as an **optional commented block** | ✅ by design |
| 7 | `## Installation` — bash fence + TFM line | `## Installation` — bash fence + `{{TFM_LIST}}` line | ✅ |
| 8 | `## Quick start` — one ~10-line snippet | `## Quick start` — one snippet, "not a tour" | ✅ |
| 9 | `## Documentation` — prose-only, no links | `## Documentation` — prose-only, no links | ✅ |
| 10 | `## License` — links `LICENSE.md` | `## License` — links `LICENSE.md` | ✅ |

Differences confined to EC's crypto prose and feature bullets, as the plan requires.

### 3 — Structural diff: `guide.md` vs EC `docs/guides/hashing.md`; `guides-README.md` vs EC `docs/guides/README.md` ✅

`guide.md` — heading sequence identical (`#` → `## Supported …` → `## Key types` → `## Usage` → three
`###` scenarios → `## Notes`); only the titles are placeholders. Table column sets identical:

| Table | EC | Template |
|---|---|---|
| algorithms | `Algorithm · Factory method · Notes` | `<Algorithm> · <Factory method> · Notes` |
| key types | `Type · Namespace · Role` | `Type · Namespace · Role` |

`guides-README.md` — same `# <Package> — Guides & Samples` H1, same intro-then-themed-`##`-sections shape,
same `- [Title](file.md) — scope` relative-link entry form. EC has 7 theme sections because it has 13
guides; the template shows 3 slots and states in its comment that the count follows the library.

### 4 — Structural diff: `SECURITY.md` vs EC's ✅

Heading sequence **byte-identical** after comment stripping: `# Security Policy` → `## Supported versions`
→ `## Reporting a vulnerability` → `## What to expect` → `## Scope`. The `Version · Supported` table, the
bold do-not-use-public-issues warning and the 3-step numbered GitHub flow are preserved.
`grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+' SECURITY.md` → **no match**; the leading comment records
*why* no address is published.

### 5 — `RELEASENOTES.md` carries both variants ✅

Variant A (first release, live): `# …v{{VERSION}} Release Notes` → `## Feature overview` →
`## Compatibility` → `## Version` — heading sequence identical to EC's, title placeholder aside.
Variant B (subsequent, commented): `## New Features` → `## Fixes` → `## Breaking Changes & Migration` →
`## Dependencies` → `## Compatibility` → `## Version`, in that order, "only where non-empty". The header
comment carries the newest-first prepend rule and the `(unreleased)` rename rule.

### 6 — No unprompted `.snupkg` claim in `RELEASE.md` ✅

`grep -n snupkg templates/RELEASE.md` now returns only the corrected paragraph (lines 84–87): `dotnet pack`
produces **only** the `.nupkg`; a `.snupkg` appears **only** on opt-in (`IncludeSymbols` /
`SymbolPackageFormat=snupkg`). The "API key is a secret — never commit or echo it" sentence is kept; the
rest of the template is untouched. This is consistent in advance with PHASE03 Step 4 (AC5 there).

### 7 — Badge set ✅

`grep -rn img.shields.io templates/` → exactly two badge lines, both in `package-README.md`: NuGet version
and `license-MIT-green.svg`. `grep -rn 'nuget/dt' templates/` → **no match**.

### 8 — Nothing to build or test ✅

Markdown templates in a dotfiles repo: **no build step and no test suite exist**. Definition-of-Done
criteria 1–2 are met by inspection — the automated well-formedness check in AC1 and the heading-sequence
diffs in AC2–AC5, run against the EC originals at `/home/jo/Dev/Enigma.Core/`.

## Deviations & follow-ups

- **`{{PACKAGE_TITLE}}`, `{{ORG}}`, `{{REPO}}` are not used by any PHASE01 template.** The plan's
  conventions section lists them among the tokens "introduced here", but no template needs them: EC's
  README and guides index are both titled with the bare package id, and `{{ORG}}`/`{{REPO}}` would only
  appear in absolute GitHub URLs — which PHASE02's packed-README link rule bans outright. `{{PACKAGE_TITLE}}`
  is the natural token for the csproj `<Title>` property in **PHASE03**'s metadata table; leave it for there.
- **`{{VERSION}}` in `SECURITY.md` is filled as `X.Y.x`,** not the literal release `X.Y.Z` (EC's row reads
  `1.0.x` — a supported *line*, not a single build). Recorded in the template's leading comment.
- **Bundled-files entries deferred.** The five templates are not yet listed in SKILL.md's *Bundled files*
  section — PHASE02 Step 5 owns that, and PHASE02 AC5 verifies every link resolves. Until PHASE02 lands,
  the templates exist but are unreferenced from the skill body.
- **Line endings (CRLF):** no line-ending inconsistency observed in any file touched or inspected — nothing
  to recommend.
