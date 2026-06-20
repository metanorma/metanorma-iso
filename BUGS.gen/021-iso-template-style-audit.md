# ISO Reference DOCX Style Audit — 8 Files

Source: `mn-samples-iso-private/word/*.docx` (8 production ISO Word outputs).
Method: extract `word/styles.xml` and `word/numbering.xml` from each, parse
styleIds + numbering definitions, cross-tabulate.

## Files analyzed

| # | File | Size | Era |
|---|------|------|-----|
| 1 | `ISO 8601-1;2019_Amd 1 ed.1 - id.81801 Enquiry Word (en).docx` | 40 KB | 2022 (pre-Typefi) |
| 2 | `ISO 8601-1;2019_Amd 1 ed.1 - id.81801 Enquiry Trackchange Word (en).docx` | 54 KB | 2022 (pre-Typefi) |
| 3 | `ISO 8601-1;2019_Amd 1 ed.1 - id.81801 Publication Word (en).docx` | 55 KB | 2022 (pre-Typefi, polluted) |
| 4 | `ISO_DIS_15926-100.docx` | 195 KB | 2025 (late Typefi) |
| 5 | `ISO_DIS 19123-2 ed.2 - id.89116_pb_ACCEPTED.docx` | 860 KB | 2025 (early Typefi + OGC + German Word) |
| 6 | `ISO-IEC JTC 1-SC 24-WG 10_ISO_IEC DIS 24931-1 ed.1 - id.88529 Clean_Version_260226.docx` | 3.5 MB | 2026 (early Typefi) |
| 7 | `ISO_FDIS_19157-3ed.1_080126.docx` | 1 MB | 2026 (late Typefi) |
| 8 | `C087753e_trackchanges.docx` | 10 MB | 2026 (late Typefi, track changes) |

## Three distinct template eras

### Era A — Pre-Typefi / 8601 (2022)
- 311–463 styles (publication version heavily polluted)
- **Lowercase style IDs** for content: `note`, `example`, `figuretitle`,
  `tabletitle`, `sourcecode`, `stem`, `stem1`, `normref`, `pseudocode`,
  `sourcetitle`, `sourcecode1`, `zzwarning`, `zzwarninghdr`
- **Prefixed semantic families** (lowercase, hyphenated):
  - `bib*` (~50 styles: `bibyear`, `bibarticle`, `bibbook`, `bibdoi`, …)
  - `au*` (~12 styles: `aufname`, `ausurname`, `aurole`, …)
  - `cite*` (~14: `citefig`, `citetbl`, `citeapp`, `citesec`, …)
  - `std*` (~10: `stdpublisher`, `stdyear`, `stddocNumber`, …)
  - `coverpage-*` (~10: `coverpage-title`, `coverpage-logo`, …)
  - `boilerplate-*` (2)
- Unique extras: `h2annex`, `h3annex`, `h4annex`, `h5annex`, `title-second`,
  `partlabel`, `pseudocode`, `recommendationtitle`, `NormalIndent`,
  `NormalWeb`, `TableGrid`, `TableISO`, `BlockText`

### Era B — Early Typefi (DIS 19123-2, IEC DIS 24931, 2025–2026)
- 250–388 styles
- **CamelCase style IDs**: `Note`/`Example` are gone, but `note`/`example`
  lowercase variants also gone. The transition is messy in this era.
- NO `Warningtext`/`Warningtitle` styles (no dedicated warning rendering)
- NO `InlineCode` character style
- NO `zzCoverlarge` / `zzCopyrightaddress`
- Adds OGC template styles when authored from OGC pipeline (DIS 19123-2):
  `OGCClause`, `MethodDesc`, `MethodDescCont`, `List2OGCbullets`, `ISOMB`,
  `ISOSecretObservations`, `ISOforeword`
- DIS 19123-2 was edited in **German-locale Word** → pollutes styles.xml
  with German auto-generated names (`Code-einrck`, `HTMLSchreibmaschine1`,
  `HTMLZitat`, `Listennummer1`, `StdAbsatz-links`)

### Era C — Late Typefi (DIS 15926-100, FDIS 19157-3, C087753e, 2025–2026)
- 250–254 styles (the cleanest, most modern)
- Adds **content styles** that did not exist in Era B:
  - `Warningtext`, `Warningtitle` — dedicated warning admonition styles
  - `InlineCode`, `InlineCodeBold` — character style for inline code
  - `zzCoverlarge`, `zzCopyrightaddress` — additional cover/copyright zones
  - `TermsAdmitted` — replaces the older `AdmittedTerm`/`AltTerms`/`DeprecatedTerms` trio
  - `zzCoverlargeChar` (in FDIS 19157-3 only)
- This is the canonical "modern ISO template" our generator should target.

## Universal styles — present in all 8 docs (134 styles)

The truly canonical ISO set. Always safe to reference.

### Document headings (10)
`BaseHeading`, `BaseText`, `Heading1`, `Heading2`, `Heading3`, `Heading4`,
`Heading5`, `Heading6`, `TermNum`, `Terms`

### Annex (7)
`ANNEX`, `a2`, `a3`, `a4`, `a5`, `a6`, `AMENDTermsHeading`

### Title and cover (8)
`zzSTDTitle`, `zzCover`, `zzCopyright`, `CoverTitleA1`, `CoverTitleA2`,
`CoverTitleA3`, `CoverTitleB`, `MainTitle1`, `MainTitle2`, `MainTitle3`

### Body text (6)
`Normal`, `BodyText`, `BodyText-`, `BodyTextCenter`, `BodyTextChar`,
`BodyTextindent1`, `BodyTextindent1-`

### Front matter (4)
`ForewordTitle`, `ForewordText`, `IntroTitle`, `FrontHead`

### Bibliography (4)
`BiblioTitle`, `BiblioEntry`, `BiblioText`, `BiblioDescription`

### TOC (4)
`TOC1`, `TOC2`, `TOC3`, `zzContents`

### Terms and definitions (2)
`Definition`, `RefNorm`

### Content blocks — boxes, formulas, keys (10)
`Box-begin`, `Box-end`, `Box-title`, `Formula`, `Formuladescription`,
`KeyText`, `KeyTitle`, `Source`, `Notice`, `IndexHead`

### Figure (6)
`FigureGraphic`, `FigureImage`, `Figuredescription`, `Figureexample`,
`Figurenote`, `Figuresubtitle`

### Code (5)
`Code`, `Code-`, `Code--`, `Courier`, `Chinese`

### Dimension (3)
`Dimension50`, `Dimension75`, `Dimension100`

### Notes/examples (8)
`Examplecontinued`, `Exampleindent`, `Exampleindent2`,
`Exampleindent2continued`, `Exampleindentcontinued`, `Notecontinued`,
`Noteindent`, `Noteindent2`, `Noteindent2continued`, `Noteindentcontinued`

### Lists (15)
`ListContinue`, `ListContinue1`, `ListContinue1-`, `ListContinue2`,
`ListContinue2-`, `ListContinue3`, `ListContinue3-`, `ListContinue4`,
`ListContinue4-`, `ListContinue5-`, `ListNumber1`, `ListNumber1-`,
`ListNumber2`, `ListNumber2-`, `ListNumber3`, `ListNumber3-`, `ListNumber4`,
`ListNumber4-`, `ListNumber5-`, `NoList`

### Tables (10)
`TableGraphic`, `Tablebody`, `Tablebody-`, `Tablebody--`, `Tablebody0`,
`Tabledescription`, `Tablefooter`, `Tableheader`, `Tableheader-`,
`Tableheader--`, `Tableheader0`, `TableNormal`

### Footnotes (4)
`FootnoteText`, `FootnoteTextChar`, `FootnoteReference`

### Header/footer (4)
`Header`, `HeaderChar`, `Footer`, `FooterChar`

### Misc (3)
`Hyperlink`, `DefaultParagraphFont`, `dl`, `p2`, `p3`, `p4`, `p5`, `p6`

## Late-Typefi additions (Era C only, not in Era B)

These styles exist in DIS 15926-100 / FDIS 19157-3 / C087753e but NOT in
DIS 19123-2 / IEC DIS 24931. Our `data/iso-dis/styles.yml` is extracted
from ISO 6709 ed.3 (Era B), so it is MISSING these styles even though
`style_mapping.yml` references them:

| Style | What it's for | Present in |
|-------|---------------|------------|
| `Warningtext` | Admonition body (warning paragraph) | DIS-15926, FDIS-19157, C087753e |
| `Warningtitle` | Admonition title | DIS-15926, FDIS-19157, C087753e |
| `InlineCode` | Character style for inline code spans | DIS-15926, FDIS-19157, C087753e |
| `InlineCodeBold` | Bold variant of inline code | DIS-15926, FDIS-19157, C087753e |
| `zzCoverlarge` | Large cover-page zone | DIS-15926, FDIS-19157, C087753e |
| `zzCopyrightaddress` | Copyright address block | DIS-15926, FDIS-19157, C087753e |
| `TermsAdmitted` | Modern admitted/deprecated terms | DIS-15926, FDIS-19157, C087753e |
| `HeaderCentered` | Centered header variant | DIS-15926, IEC-24931, FDIS-19157, C087753e |
| `FooterCentered` | Centered footer variant | DIS-15926, IEC-24931, FDIS-19157, C087753e |
| `FooterPageNumber` | Page number footer | DIS-15926, FDIS-19157, C087753e |
| `FooterPageRomanNumber` | Roman-numeral page footer | DIS-15926, IEC-24931, FDIS-19157, C087753e |
| `FooterCenteredContinued` | "Continued" footer for tables spanning pages | DIS-15926, FDIS-19157, C087753e |
| `Disp-quotep` | Block quote paragraph | DIS-15926, FDIS-19157, C087753e |
| `CommentReference` | Comment reference character style | all docs except DIS-15926 and C087753e |
| `Heading7/8/9` | Extended heading levels | DIS-15926 + Era C only |
| `TOC4..TOC9` | Extended TOC levels | DIS-15926 + Era C only |
| `TOCHeading` | TOC section heading | DIS-15926 + Era C only |

## 8601-era pollution — DO NOT emit (154 styles)

All lowercase prefixed names from pre-Typefi. Listed in full so they can be
explicitly excluded from any future YAML or denormalized rendering.

`admonition`, `addition`, `aubase`, `aucollab`, `audeg`, `aufname`,
`aumember`, `auprefix`, `aurole`, `ausuffix`, `ausurname`, `bibalt-year`,
`bibarticle`, `bibbase`, `bibbook`, `bibchapterno`, `bibchaptertitle`,
`bibcomment`, `bibdeg`, `bibdoi`, `bibed-etal`, `bibed-fname`,
`bibed-organization`, `bibed-suffix`, `bibed-surname`, `bibeditionno`,
`bibetal`, `bibextlink`, `bibfname`, `bibfpage`, `bibinstitution`,
`bibisbn`, `bibissue`, `bibjournal`, `biblio`, `biblocation`, `biblpage`,
`bibmedline`, `bibnumber`, `biborganization`, `bibpagecount`, `bibpatent`,
`bibpublisher`, `bibreportnum`, `bibschool`, `bibseries`, `bibseriesno`,
`bibsuffix`, `bibsuppl`, `bibsurname`, `bibtrans`, `bibunpubl`, `biburl`,
`bibvolume`, `bibyear`, `boilerplate-address1`, `boilerplate-name1`,
`citeapp`, `citebase`, `citebib`, `citebox`, `citeen`, `citeeq`, `citefig`,
`citefn`, `citesec`, `citesection`, `citetbl`, `citetfn`, `content`,
`content1`, `coverpage`, `coverpage-doc-identity`, `coverpage-logo`,
`coverpage-stage-block`, `coverpage-tc-name`, `coverpage-title`,
`coverpage-warning`, `coverpagedocnumber`, `coverpagedocstage`,
`coverpagetechcommittee`, `coverpagewarning`, `deletion`, `dlnoindent`,
`figure`, `h2annex`, `h3annex`, `h4annex`, `h5annex`, `msofooterlandscape`,
`msoheaderlandscape`, `msonormal0`, `msotoctextspan`, `normref`, `part`,
`partlabel`, `pseudocode`, `quoteattribution`, `recommendationtitle`,
`sourcecode1`, `sourcetitle`, `stdbase`, `stddocNumber`,
`stddocPartNumber`, `stddocTitle`, `stddocumentType`, `stdfootnote`,
`stdpublisher`, `stdsection`, `stdsuppl`, `stdyear`, `stem`, `stem1`,
`tablefootnote`, `tablefootnoteref`, `title-second`, `title-second1`,
`title1`, `title2`, `zzCoverChar`, `zzcopyrighthdr`, `zzwarning`,
`zzwarninghdr`.

Also **8601-only CamelCase extras** (not lowercase prefixed, still 8601
only): `AdmittedTerm`, `AltTerms`, `AMENDHeading1Unnumbered`,
`BalloonText`, `BalloonTextChar`, `BlockText`, `BodyTextIndent21`,
`BodyTextIndent22`, `BodyTextIndent31`, `BodyTextIndent32`,
`CommentReference`, `CommentSubject`, `CommentSubjectChar`, `CommentText`,
`CommentTextChar`, `DeprecatedTerms`, `Figuretitle0`, `FollowedHyperlink`,
`HTMLPreformatted`, `HTMLPreformattedChar`, `Heading6Char`,
`ListContinue5`, `ListParagraph`, `MultiPar202106010710`,
`MultiPar202106010710Char`, `NormalIndent`, `NormalWeb`, `PlaceholderText`,
`TableGrid`, `TableISO`, `UnresolvedMention`.

## Inadvertent insertions — single-doc-only styles (500 total)

These are noise: inserted by Word's auto-mechanisms, third-party tools,
or authoring errors. None of them should ever appear in our output.

### DIS-19123-2 — 433 pollution styles (worst case)

**Sources of pollution:**
1. **Word built-in table styles** (~250): every Quick Table style auto-injected
   - `ColorfulGrid-Accent1..6`, `ColorfulGrid1`
   - `ColorfulList-Accent1..6`, `ColorfulList1`
   - `ColorfulShading-Accent1..6`, `ColorfulShading1`
   - `DarkList-Accent1..6`, `DarkList1`
   - `GridTable1Light-Accent1..6`, `GridTable1Light1`, `GridTable1Light2`
   - `GridTable2..7-Accent1..6`, `GridTable2..7` (4 variants each)
   - `LightGrid-Accent1..6`, `LightGrid1`
   - `LightList-Accent1..6`, `LightList1`
   - `LightShading-Accent1..6`, `LightShading1`
   - `ListTable1Light..7Colorful` (full series)
   - `MediumGrid1..3-Accent1..6`
   - `MediumList1..2-Accent1..6`
   - `MediumShading1..2-Accent1..6`
   - `PlainTable1..5` (variants 1 and 2)
   - `Table3Deffects1..3`, `TableClassic1..4`, `TableColorful1..3`
   - `TableColumns1..5`, `TableGrid1..8`, `TableGridLight1..2`
   - `TableList1..8`, `TableSimple1..3`, `TableSubtle1..2`, `TableWeb1..3`
   - `TableContemporary`, `TableElegant`, `TableProfessional`, `TableTheme`,
     `TableContents`, `TableFormula`, `TableClassic1..4`
2. **OGC template styles** (authoring pipeline leak):
   `OGCClause`, `MethodDesc`, `MethodDescCont`, `List2OGCbullets`, `ISOMB`,
   `ISOSecretObservations`, `ISOforeword`, `introelements`,
   `List2OGCbullets`, `HeadingCover`
3. **German-locale Word auto-styles** (German Word inserts localized names):
   `Code-einrck` (German "eingerückt" = indented), `HTMLSchreibmaschine1`
   (German "Schreibmaschine" = typewriter = monospace), `HTMLZitat`
   (German "Zitat" = quote), `Listennummer1` (German "Listennummer" =
   list number), `StdAbsatz-links` (German "links" = left)
4. **Garbage auto-generated names** (Word's "rename based on formatting"
   feature gone wrong): `FiguretitleCharCharCharChar`, `a3CharCharChar`,
   `StyleHeading3h3sub-clause3H3hd3105pt`,
   `StyleHeading4h4sub-clause4H4hd4105pt`,
   `StyleHeading4h4sub-clause4H4hd4105ptChar`,
   `StyleTableFootNoteXref105pt`, `ANNEXChar`, `AnnexLevel2`,
   `AnnexNumbered`, `AnnexNumberedChar`, `Annexlevel3`, `a2Char`, `a3Char`
5. **Author-created one-offs** (typo or local use):
   `Author`, `Bibliography1`, `Commands`, `Default`, `Defterms`, `Figure`,
   `FigureTitle0`, `FootnoteCharacters`, `Foreword`, `Index`,
   `Introduction`, `Heading`, `MainTitle`, `ML`, `MSDNFR`,
   `MTConvertedEquation`, `MethodDesc`, `MethodDescCont`, `PlainTextBlack`,
   `Quote1`, `Sourcecode`, `Table`, `Tablelineafter`, `Tablefootnote`,
   `XML`, `XMLSchema`, `xmlCode`, `Hangingindent`, `TableFormula`,
   `graysmall`, `hit`, `nowrap`, `a1`, `b2`, `b3`, `b4`, `m1`, `t1`,
   `List1`, `ListItem`, `ListItem0`, `ListIte`, `ListBulletLast`,
   `ListLabel98`, `List2Char`
6. **Requirement-related** (likely from a requirements-template parent):
   `Requirement`, `RequirementBold`, `RequirementBold1`,
   `RequirementBold1BoldItalic`

### 8601-publication — 44 pollution styles

**Chinese-Word auto-inserted numeric IDs** (Chinese Word creates these
when localized style names collide): `21103`, `24341`, `26631`

**Chinese-Word duplicate indent families** (creates many `BodyTextIndentNN`):
`BodyTextIndent20`, `BodyTextIndent23`, `BodyTextIndent24`,
`BodyTextIndent25`, `BodyTextIndent30`, `BodyTextIndent33`,
`BodyTextIndent34`, `BodyTextIndent35`, `BodyTextIndent36`,
`BodyTextindent2`, `BodyTextindent3`

**Chinese-Word duplicate headings** (suffixes with `1` on collision):
`Heading11`, `Heading1Char1`, `Heading21`, `Heading2Char1`, `Heading31`,
`Heading3Char1`, `Heading41`, `Heading4Char1`, `Heading51`,
`Heading5Char1`, `Heading61`, `Heading6Char1`, `h2annex1`, `h2annexChar`,
`h3annex1`, `h3annexChar`, `h4annex1`, `h4annexChar`, `h5annex1`,
`h5annexChar`

**HTML paste artifacts**: `PreformattedHTML`, `PreformattedHTMLChar`,
`msotoctextspan1`

**Misc author one-offs**: `Quote1`, `TOCTitle`, `Sourcecode`, `zzAddress`,
`CommentTextChar1`, `msofooterlandscapeChar`, `msoheaderlandscapeChar`

### IEC-DIS-24931 — 14 unique styles

**EndNote feature**: `EndNoteBibliography`, `EndNoteBibliographyChar`,
`EndNoteBibliographyTitle`, `EndNoteBibliographyTitleChar` (Word's endnote
auto-creates these when the feature is used)

**STS TBX terminology markup** (legitimate editorial usage, but only in
this document): `sts-tbx-entailedterm`, `sts-tbx-entailedterm-num`,
`sts-tbx-note-label`

**Author one-offs**: `Admittedterm0`, `cs1-format`, `hgkelc`, `hit`,
`nowrap`, `reference-accessdate`, `v-button-caption`

### FDIS-19157 — 7 unique styles

**Word co-authoring noise**: `Hashtag1`, `Mention1`, `SmartHyperlink1`,
`UnresolvedMention2` (auto-injected by Yammer/Teams integration)

**Auto-linked character styles** (Word creates `*Char` when a paragraph
style is given a linked character style): `BaseTextChar`, `TableheaderChar`,
`zzCoverlargeChar`

### C087753e-tc — 1 unique style

`cell-format` — author-created table cell style

### DIS-15926 — 1 unique style

`BoldBold` — author typo (applied bold to bold)

### 8601-enquiry / 8601-enquiry-tc — 0 unique styles

These two are the **cleanest 8601-era documents** and should be used as
the canonical references for the pre-Typefi era (if ever needed).

## Canonical Typefi numbering scheme (from DIS-15926)

DIS-15926 is the cleanest modern reference. It has only **7 abstractNum**
definitions and **8 num** instances. This is the canonical Typefi numbering
set:

| abstractNum | format | lvlText | bound style | numId |
|-------------|--------|---------|-------------|-------|
| 0 | decimal | `%1` | IntroHeading1..9 (multilevel) | 8 |
| 1 | bullet | `—` | ListContinue1 | 3 |
| 2 | bullet | (empty) | (none) | — |
| 3 | decimal | `%1` | Heading1..9 (multilevel) | 4 |
| 4 | decimal | `%1.` | basic ordered list | 1 |
| 5 | bullet | (empty) | (none) | — |
| 6 | upperLetter | `Annex %1` | ANNEX, a2..a6 (multilevel) | 7 |

**Critical observation**: Heading2..6 have `numId=""` (empty). They
inherit numbering from Heading1 via the multilevel abstractNum's levels
1–5. This is standard Word multilevel behavior — the explicit numPr
lives on Heading1 only.

### Numbering pollution in other docs

- **C087753e-tc**: 136 abstractNum, 136 num — extreme list-numbering
  pollution. Word creates a new abstractNum every time someone clicks
  "Restart numbering" or "Continue numbering" on a list. Almost all are
  duplicate `lowerLetter %1)` or `bullet —`. Indicates heavy manual
  list-numbering fiddling during editing.
- **IEC-DIS-24931**: 53 abstractNum, **244 num** instances — also extreme
  pollution. Same root cause.
- **DIS-19123-2**: 28 abstractNum, 25 num — moderate pollution.
- **FDIS-19157**: 27 abstractNum, 28 num — moderate.
- **8601 era**: 13–15 abstractNum — clean, but uses different scheme
  (abstractNum 12 = Heading1 decimal `%1`, abstractNum 10 = ANNEX
  upperLetter `Annex %1`).

### Comparison to our `data/iso-dis/numbering.yml`

Our extracted `numbering.yml` has **abstractNum 0–3 as single-level
decimal `%1.`** with decreasing indents (2.63, 2.13, 1.63, 1.13). This
does NOT match DIS-15926's canonical scheme. The source for our YAML
appears to be a different document (possibly ISO 6709 ed.3 — the same
source as our styles.yml).

## Critical configuration inconsistencies in our project

1. **`data/iso-dis/styles.yml`** is extracted from `ISO 6709 ed.3`
   (Era B / early Typefi), per its own description.
2. **`data/iso-dis/numbering.yml`** likewise from ISO 6709 ed.3.
3. **`data/iso-dis/style_mapping.yml`** references Era C style IDs
   (`Warningtext`, `Warningtitle`, `InlineCode`, `zzCoverlarge`,
   `zzCopyrightaddress`, `TermsAdmitted`) that DO NOT EXIST in our own
   `styles.yml` extracted from Era B.
4. **Spec fixture** is `spec/fixtures/20250530-ISO_DIS_15926-100.docx`
   (Era C).

**Consequence**: when our adapter emits a paragraph with style
`Warningtext`, that style exists in the target template.docx (because
we copy template.docx as the starting DOCX package), but it is NOT in
our project's `styles.yml` data file. If any code path validates the
style against `styles.yml`, it will incorrectly flag it as missing.
If any code path generates styles.xml from `styles.yml` (instead of
copying from template.docx), the late-Typefi styles will be absent.

## Recommendations

1. **Re-extract `styles.yml` and `numbering.yml` from
   `20250530-ISO_DIS_15926-100.docx`** (Era C, late Typefi). This makes
   the data files consistent with the spec fixture and with
   `style_mapping.yml`.
2. **Add an exclusion list** to `style_mapping.yml`:
   ```yaml
   excluded_styles:
     - bib*        # 8601-era bibliography (50 styles)
     - au*         # 8601-era author (12 styles)
     - cite*       # 8601-era cross-ref (14 styles)
     - std*        # 8601-era std-ids (10 styles)
     - coverpage-* # 8601-era cover (10 styles)
     - boilerplate-* # 8601-era
     - GridTable*, TableGrid*, ColorfulGrid*, LightGrid*, MediumGrid*
     - ListTable*, PlainTable*, TableClassic*, TableColorful*
     - *Accent1..6
     - Heading6Char, BodyText*Char, *Char (auto-linked character styles)
   ```
3. **Document the era explicitly** in `style_mapping.yml`:
   ```yaml
   template_era: late_typefi   # 2025+ canonical
   reference_doc: spec/fixtures/20250530-ISO_DIS_15926-100.docx
   ```
4. **Use `DIS-15926` as the single source of truth** for canonical style
   inventory and numbering scheme. Treat `DIS-19123-2` as the OGC-template
   outlier; treat `IEC-DIS-24931` as a list-pollution outlier.
5. **Never emit** any style starting with a lowercase letter (all
   lowercase style IDs in the data are 8601-era pre-Typefi).
