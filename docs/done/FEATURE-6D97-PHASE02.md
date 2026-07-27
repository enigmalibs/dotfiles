# FEATURE-6D97-PHASE02 — SKILL.md content rules: README, notes, guides, community files

## Summary

PHASE01 bundled five doc templates but left them unreferenced from the skill body. This phase writes the
**prose rules that govern them** — what must be *true* of the released documentation, not just what it
looks like — and wires the templates into `dotnet-release/SKILL.md`.

The four rule sets (README, release notes, guides, community files) landed as `###` subsections of one new
`## Release documents` top-level section, and defect **D6** is fixed: the badge set is now closed at two
(NuGet version + License, `green`), with the Downloads offer deleted.

SKILL.md grew 198 → 261 lines. Release *mechanics* — the 12-property metadata table, the first-release
path, pack-verify, SourceLink, release-item shapes, the `v4` version line — are PHASE03's scope and were
deliberately left untouched.

## Files/modules touched

**Modified**

- `.claude/skills/dotnet-release/SKILL.md` — frontmatter `description:`; the `README.md` / `RELEASENOTES.md`
  bullets under *In-repo edits* reduced to per-release edits + pointers; new `## Release documents` section
  (4 subsections); 5 new *Bundled files* entries + the create-only-if-missing rule; 3 new *Common mistakes*
  rows.
- `docs/roadmap.md`, `docs/plan/FEATURE-6D97.md` — statuses.

**Created** — `docs/done/FEATURE-6D97-PHASE02.md` (this file).

## Acceptance criteria

### 1 — Badge section: exactly two badges, `green`, no Downloads offer ✅ (D6)

`grep -n img.shields.io SKILL.md` returns exactly two lines — `nuget/v` and `license-MIT-green.svg`.
`grep -n 'license-MIT-blue'` → no match (was line 50). The only surviving mention of Downloads is the
one-line note the plan asked for:

> A **Downloads** badge (`nuget/dt`) exists if it is ever wanted, but it is not part of the house set and
> is **not offered**: on a fresh package it advertises a low count, which is a negative signal.

The "the NuGet-version badge tracks the published version automatically — no per-release edit" note is
kept, as required.

### 2 — Packed-README link rule, all three parts + the exception ✅

Present under *Release documents → `README.md`*, framed as "a correctness constraint, not a style
preference", with the reason stated (the README is packed, so it renders where the repo tree isn't):

| Part | Text |
|---|---|
| packed/repo-root links only | "Link only to files that are packed or repo-root — `LICENSE.md`, `RELEASENOTES.md`." |
| prose pointer for guides | "Point at the guides in prose … **No clickable per-guide links.**" |
| no absolute URLs | "No absolute GitHub URLs — they hard-code org/repo/branch and rot on a rename." |
| exception | "`docs/guides/README.md` is **not** packed, so relative links between the guides are correct *there*. The rule applies to the packed README only." |

### 3 — Guides section ✅

- **Count follows the library** — "one category, one guide", with EC's 13 named as "a consequence of its
  surface, not a target".
- **Both templates** linked — `templates/guide.md` (with its shape summarised) and `templates/guides-README.md`.
- **Sub-agent delegation** — one guide per sub-agent, each given the target path and the relevant public
  API surface; cross-references **dev-workflow**'s rules rather than restating them; owner integrates and
  re-verifies.
- **Verification gate** — marked **required** whenever a guide or the README quick-start is touched, with
  the full cross-check list (usings, factory types and `Create*`, member argument shapes incl. sync/async
  and `await`, static helpers, extension methods, enums, options types), *fix in place*, and the
  **completion-doc coverage table** (*snippets · symbols · mismatches · uncertain* + totals, with EC's
  60 / 209 / 0 as the worked example). The rationale — no compile harness for doc snippets — and the
  declined doc-sample test project are both recorded, the latter explicitly "not required".

### 4 — Community files ✅

| File | Rule as written |
|---|---|
| `SECURITY.md` | Offered from `templates/SECURITY.md` for any publicly published package; create only if missing. |
| `CHANGELOG.md` | Banned — `RELEASENOTES.md` is the single source; "a second chronology guarantees divergence". |
| `CONTRIBUTING.md` | Not house set; on request only. |
| `LICENSE.md` | Owned by **dotnet-solution-setup**; this skill only **verifies** it exists, is referenced by `<PackageLicenseFile>`, and is packed. |
| `CLAUDE.md` | Not a release artifact; covered by **dev-workflow**'s freshness sweep. |

### 5 — Bundled-file links resolve · `description:` refreshed · three new mistake rows ✅

Automated check over the *Bundled files* section: **7 links, 7 resolve, 0 missing** — and every file in
`templates/` is linked (no orphans in either direction). `description:` now names the doc templates,
the packed README + badges, the guides and their index, and `SECURITY.md`. *Common mistakes* went 13 → 16
rows; the three new ones are a relative `docs/…` link in the packed README, a `CHANGELOG.md` alongside
`RELEASENOTES.md`, and shipping a guide whose snippets were never verified against `src/`.

### 6 — Nothing to build or test ✅

A markdown skill file in a dotfiles repo: **no build step and no test suite exist**. Definition-of-Done
criteria 1–2 are met by inspection — code fences balanced (8), heading tree checked, and the
bundled-link / badge / mistake-row assertions above run as greps and a link-resolution script.

## Deviations & follow-ups

- **Placement: one `## Release documents` section rather than edits spread across two levels.** The plan
  fixes the *content* of each rule set but not where it lives. The guides and community-files rules are
  new top-level sections per the plan, while the README and release-notes rules currently sit as
  sub-bullets inside *In-repo edits* — leaving them split would have put four related rule sets at two
  different heading levels. Grouping all four under `## Release documents` keeps each rule in exactly one
  place (nothing is duplicated, so nothing can diverge) and gives PHASE03's first-release path a single
  section to point at when it says "author README / notes / guides / SECURITY from the templates".
  *In-repo edits* keeps the mechanical per-release edits (`<Version>`, `<PackageReleaseNotes>`, TFMs, the
  callout, the supported-TFMs line) and forward-references the new section. No rule text was dropped.
- **PHASE03 dependency now visible in the file.** *Packable-library prerequisites* still lists only 5
  items and *Execution boundary* still names one exception — both are PHASE03 Steps 1 and 3. The `v4`
  version line is PHASE03 Step 6, so SKILL.md currently carries **no version line at all**; it arrives
  with PHASE03, not here.
- **Line endings (CRLF):** no line-ending inconsistency observed in any file touched — nothing to
  recommend.
