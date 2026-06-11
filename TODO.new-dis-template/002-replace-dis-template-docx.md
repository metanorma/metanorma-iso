# TODO 002: Replace DIS Template DOCX

## Status: COMPLETE

## What

Replace `data/iso-dis/template.docx` with a clean template derived from the reference DOCX (`spec/fixtures/20250530-ISO_DIS_15926-100.docx`).

## Why

The old template (312 styles) contains many isodoc-specific styles (`bib*`, `std*`, `au*`, `cite*`, `coverpage*`) that are artifacts of the old converter's semantic markup — not styles ISO uses. The new reference DOCX from ISO's Typefi pipeline has 250 styles that represent what ISO actually expects.

## Changes

### Step 1: Create clean template DOCX

Create a new `data/iso-dis/template.docx` that contains:

1. **styles.xml** — copy verbatim from reference DOCX (250 styles)
2. **numbering.xml** — copy verbatim from reference DOCX (7 abstractNums, 8 nums)
3. **settings.xml** — copy verbatim (mirrorMargins, evenAndOddHeaders, etc.)
4. **fontTable.xml** — copy verbatim (Cambria, Calibri, Times New Roman, MS Mincho, etc.)
5. **theme/theme1.xml** — copy verbatim from reference
6. **webSettings.xml** — copy verbatim
7. **document.xml** — empty body (clear all paragraphs, keep only minimal structure)
8. **footnotes.xml** / **endnotes.xml** — keep separator/continuationSeparator only
9. **header1..4.xml** — keep from reference (HeaderCentered style, with placeholder doc ID)
10. **footer1..4.xml** — keep from reference (FooterCentered + page number fields)
11. **docProps/core.xml** — empty/minimal template values
12. **docProps/app.xml** — minimal template values
13. **No docProps/custom.xml** — properties are set dynamically by the adapter
14. **No customXml/** — Typefi artifacts, not needed
15. **No media/** — no images in the template itself
16. **[Content_Types].xml** — regenerated without customXml/custom.xml entries
17. **_rels/.rels** — standard package relationships
18. **word/_rels/document.xml.rels** — relationships for headers, footers, footnotes, endnotes, styles, numbering, settings, fontTable, webSettings, theme (no images, no customXml, no hyperlinks)

### Step 2: Update style_mapping.yml

The new reference DOCX uses different styleIds for some semantic elements. Update `data/iso-dis/style_mapping.yml`:

**Styles that match directly (no change):**
- `Heading1`..`Heading6` — body clause headings
- `ANNEX`, `a2`..`a6` — annex headings
- `ForewordTitle`, `ForewordText` — foreword
- `IntroTitle` — introduction
- `BodyText` — body text
- `Note` — notes (was `Note0` in old)
- `Example` — examples (was `Example0` in old)
- `BiblioEntry`, `BiblioTitle` — bibliography
- `TermNum3` — term numbers (now has TermNum2..TermNum6 for depth)
- `Terms0` — term name (was `Terms` in old)
- `Source` — source paragraphs
- `ListContinue1` — dash bullets
- `Code` — source code
- `CoverTitleA1`, `CoverTitleA2` — cover titles
- `zzCover`, `zzCoverlarge` — cover metadata
- `zzCopyright`, `zzCopyrightaddress` — copyright block
- `zzContents` — TOC title
- `PAGEBREAK` — page breaks

**Styles that need updated mappings:**
- `figure_title` → `Figuretitle` (was `Figuretitle0`)
- `table_title` → `Tabletitle` (was `Tabletitle0`)
- `term_num` → `TermNum3` (was `TermNum` — now there are TermNum2..TermNum6)
- `terms` → `Terms0` (was `Terms`)
- `admitted_term` → `TermsAdmitted` (was `AdmittedTerm`)
- `toc2` → `TOC2` (was not in old template)

**Styles that no longer exist in new template:**
- All `bib*`, `std*`, `au*`, `cite*` character styles — these were old converter semantic markup
- `coverpage*`, `boilerplate-*` — old converter cover page styles
- `BlockText` — use `Disp-quotep` for block quotes
- `DeprecatedTerms`, `AltTerms`, `AdmittedTerm` — old term styles
- `ListParagraph`, `ListNumber1` — old list styles

**Numbering IDs must be updated:**
```yaml
numbering:
  intro_clause: 8       # abstractNumId=0 (IntroHeading multilevel)
  dash_list: 3          # abstractNumId=1 (ListContinue1 hybridMultilevel)
  body_clause: 4        # abstractNumId=3 (Heading multilevel)
  decimal_list: 1       # abstractNumId=4 (decimal ordered list)
  annex_clause: 7       # abstractNumId=6 (ANNEX multilevel)
  plain_dash_list: 5    # abstractNumId=2 (plain dash bullets)
```

### Step 3: Verify template loads

Run the existing adapter specs against the new template. Key changes to expect:
- Some style names changed (update adapter if needed)
- Numbering IDs changed (update style_mapping.yml)
- Old semantic markup styles gone (adapter should not reference them)

## Files

- `data/iso-dis/template.docx` — new template
- `data/iso-dis/style_mapping.yml` — updated mappings
- `data/iso-dis/numbering.yml` — extract numbering from new template (if YAML used)
- `data/iso-dis/styles.yml` — extract styles from new template (if YAML used)
