# FEATURE-79A1-PHASE02 — `dotnet-solution-config` + `git-repo-hygiene` fixes (DONE)

## Summary

Brought the two solution-bootstrap config skills in line with what **Enigma.Core** (EC) actually ships,
closing defects **D1** and **D3** from the item's defect table.

- **D1 — CPM Tests group (`dotnet-solution-config/templates/Directory.Packages.props`).** Dropped
  `Microsoft.NET.Test.Sdk` (VSTest-era boilerplate that breaks the Microsoft Testing Platform and that
  `xunit-v3` already forbids), and moved `xunit.v3` / `coverlet.collector` to EC's versions
  (3.2.0 → **3.2.2**, 6.0.0 → **6.0.4**). The group's comment now carries EC's wording verbatim.
- **Core group.** Added EC's real `netstandard2.0`-support pair — `System.Buffers` 4.6.1 and
  `PolySharp` 1.16.0 — with a comment tying them to the *conditional* `PackageReference`s that
  PHASE01 put in `dotnet-solution-setup/templates/library.csproj`, so the two halves of that
  netstandard2.0 arrangement are discoverable from either file.
- **D3 — `templates/Directory.Build.props`.** The planned missing-final-newline fix turned out to be a
  phantom (see *Deviations*). The real gap was a missing `<ImplicitUsings>disable</ImplicitUsings>`,
  added here with your approval.
- **`global.json` guidance.** The skill previously mentioned only the SDK pin, in a parenthetical. It now
  has its own section covering both keys (`sdk` + the MTP `test.runner`), what each does, and EC's
  hard-won `dotnet test --solution <Solution>.slnx` invocation note.
- **`git-repo-hygiene/templates/gitattributes`.** Added `*.bin binary` at EC's exact position — first
  entry of the forced-binary list. This was the file's last outstanding delta against EC; it is now
  byte-identical.
- Both skills gained their version line, and `dotnet-solution-config` now cross-references PHASE01's
  bootstrap checklist from two places, so the "which skill do I call?" question is answered from either
  side of the split.

## Files/modified touched

### Modified — `dotnet-solution-config`
- `.claude/skills/dotnet-solution-config/templates/Directory.Packages.props` — Tests group rewritten
  (D1); Core group gained `System.Buffers` / `PolySharp` + explanatory comment.
- `.claude/skills/dotnet-solution-config/templates/Directory.Build.props` — added
  `<ImplicitUsings>disable</ImplicitUsings>` with a one-line comment.
- `.claude/skills/dotnet-solution-config/SKILL.md` — version line `dotnet-solution-config v2`;
  `description:` extended with `global.json`; new **global.json** section (both keys +
  `dotnet test --solution` note); `ImplicitUsings` added to the file table, the
  `Directory.Build.props` bullet list and the "repeating in every csproj" mistake row; new CPM paragraph
  on the MTP Tests group and the netstandard2.0 pair; bootstrap-checklist cross-reference added to
  *The three files* and to *Cross-references*; `global.json` added to *When to use* and as workflow
  step 4; three new **Common mistakes** rows (`Microsoft.NET.Test.Sdk` in CPM, `sdk`-only `global.json`,
  `dotnet test <Solution>.slnx`).

### Modified — `git-repo-hygiene`
- `.claude/skills/git-repo-hygiene/templates/gitattributes` — `*.bin binary` inserted as the first
  forced-binary entry.
- `.claude/skills/git-repo-hygiene/SKILL.md` — version line `git-repo-hygiene v2`; the `.gitattributes`
  row of *The three files* now names `*.bin`. `description:` unchanged (no scope change), per the plan.

### Modified — tracking
- `docs/roadmap.md`, `docs/plan/FEATURE-79A1.md` — PHASE02 `TODO` → `IN PROGRESS` → `DONE`.

### Created
- `docs/done/FEATURE-79A1-PHASE02.md` (this file).

## Deviations & follow-ups

- **D3 was a phantom defect — Step 2 as written was a no-op.** The plan recorded
  `templates/Directory.Build.props` as having no final newline. It does have one: the trailing bytes are
  `</PropertyGroup>\n\n</Project>\n`, i.e. exactly one LF, and the file has been untouched since its
  creating commit (`1b34315`, FEATURE-006) — so the interview's audit observation was simply wrong, not
  stale. Verified: `data.endswith(b'\n') and not data.endswith(b'\n\n')` → `True`.
- **`ImplicitUsings` gap found and fixed instead (approved deviation).** Step 2 said "nothing else
  changes", but acceptance criterion 3 requires the template's `PropertyGroup` to diff clean against
  EC's — and EC declares `<ImplicitUsings>disable</ImplicitUsings>` while the template did not. The
  omission was also a live self-contradiction: `dotnet-solution-setup/SKILL.md:108` and PHASE01's
  `templates/library.csproj` comment both tell readers that `ImplicitUsings` "lives once in
  `Directory.Build.props`", so a solution bootstrapped by these skills would have silently inherited the
  SDK default (`enable`) — precisely what setup's own *Common mistakes* row forbids. Raised before
  building; you chose to add the property **and** fix the skill prose. AC3 now passes.
- **AC1 vs AC1b tension, resolved in favour of AC1.** AC1 requires the Tests-group comment to match EC's
  wording, which itself reads *"No `Microsoft.NET.Test.Sdk`."*; AC1b asks for no `Microsoft.NET.Test.Sdk`
  "anywhere in the template". The single surviving occurrence is inside that prohibitive comment — there
  is no `PackageVersion` entry for it. A comment forbidding a package is not a reference to it, so both
  criteria are met as intended.
- **Line endings (CRLF):** no line-ending inconsistency observed in any file touched or inspected —
  all are LF. No recommendation needed.
- **Stale roadmap row (carried forward, not touched):** `FEATURE-003` (`git-repo-hygiene` skill) is still
  `IN PROGRESS` although that skill exists, is complete, and was just revised to v2 here. Still flagged
  for you to close or re-scope; PHASE02 deliberately did not touch it.
- **PHASE03 dependency now live.** This phase pins the contract PHASE03 must match: package set
  (`xunit.v3` + `coverlet.collector`, no `Microsoft.NET.Test.Sdk`), versions (3.2.2 / 6.0.4), and the
  `global.json` `test.runner` entry that `xunit-v3` is cross-referenced as owning. PHASE03's AC5
  three-way consistency check should compare against this file's Tests group.

## Build/test evidence

**Nothing to build or test** — these are markdown prompt files and XML/text templates under
`.claude/skills/`, symlinked live into `~/.claude/skills/`; there is no build step, no install step and
no test suite. Definition-of-Done criteria 1–2 are met by the applicable equivalent: well-formedness
checks plus the byte-diffs the acceptance criteria call for. Every criterion was verified mechanically:

| AC | Check | Result |
|---|---|---|
| 1 | Tests `ItemGroup` (uncommented, comment included) vs EC's `Directory.Packages.props` | `diff` → **identical** |
| 1b | `Microsoft.NET.Test.Sdk` as a `PackageVersion` entry | **0 occurrences** (1 hit, inside EC's prohibitive comment — see *Deviations*) |
| 2 | `templates/gitattributes` vs `/home/jo/Dev/Enigma.Core/.gitattributes` | `diff` → **zero differences** |
| 3 | `Directory.Build.props` trailing bytes | `</PropertyGroup>\n\n</Project>\n` → **exactly one final LF** |
| 3 | `PropertyGroup` (placeholders filled, comments stripped) vs EC's | **identical** — 8 properties, same order |
| 4 | `SKILL.md` `global.json` snippet parsed with `json.loads` | **valid JSON**, `sdk` ✓ and `test.runner = Microsoft.Testing.Platform` ✓ |
| 4 | `dotnet test --solution` note | present at `SKILL.md:87` + mistake row `:117` |
| 5 | Version lines | `dotnet-solution-config v2` ✓ (`:8`), `git-repo-hygiene v2` ✓ (`:8`) |
| 5 | Bootstrap-checklist cross-reference | present at `SKILL.md:32` and `:95`; "steps 3–5" claim verified against PHASE01's checklist rows 3/4/5 |
| — | XML well-formedness of both edited templates | `xml.dom.minidom.parse` → **both parse** |

Both props templates were parsed as XML after editing, and the placeholder-substituted
`Directory.Build.props` was compared property-by-property against EC's.
