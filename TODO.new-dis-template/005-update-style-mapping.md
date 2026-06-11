# TODO 005: Update Style Mapping for New Template

## Status: COMPLETE

## What

Update the style mapping (`data/iso-dis/style_mapping.yml`) to match the new template's style IDs and numbering definitions.

## Why

The new template has different style IDs for several elements (e.g., `Figuretitle` instead of `Figuretitle0`, `Terms0` instead of `Terms`, `Note` instead of `Note0`). The numbering IDs also changed. The adapter currently references old style IDs that won't exist in the new template.

## Detailed Mapping Changes

### Paragraph Styles

| Semantic Key | Old StyleId | New StyleId | Notes |
|-------------|-------------|-------------|-------|
| title | zzSTDTitle | zzSTDTitle | unchanged |
| heading1..6 | Heading1..6 | Heading1..6 | unchanged |
| annex | ANNEX | ANNEX | unchanged |
| annex_heading2..6 | a2..a6 | a2..a6 | unchanged |
| foreword | ForewordTitle | ForewordTitle | unchanged |
| foreword_text | ForewordText | ForewordText | unchanged |
| introduction | IntroTitle | IntroTitle | unchanged |
| bibliography | BiblioTitle | BiblioTitle | unchanged |
| note | Note0 | **Note** | changed |
| example | Example0 | **Example** | changed |
| figure_title | Figuretitle0 | **Figuretitle** | changed |
| table_title | Tabletitle0 | **Tabletitle** | changed |
| term_num | TermNum | **TermNum3** | changed (depth-aware) |
| terms | Terms | **Terms0** | changed |
| admitted_term | AdmittedTerm | **TermsAdmitted** | changed |
| body_text | BodyText | BodyText | unchanged |
| list_continue1 | ListContinue1 | ListContinue1 | unchanged |
| source | Source | Source | unchanged |
| biblio_entry | BiblioEntry | BiblioEntry | unchanged |
| code | Code | Code | unchanged |
| cover_title | CoverTitleA1 | CoverTitleA1 | unchanged |
| cover_doc_identity | CoverTitleA1 | CoverTitleA1 | unchanged |
| colophon | boilerplate-copyright | **zzCopyright** | changed |
| toc1 | TOC1 | TOC1 | unchanged |
| toc2 | — | **TOC2** | added |

### New Styles to Map

| Semantic Key | New StyleId | Notes |
|-------------|-------------|-------|
| cover_large | zzCoverlarge | cover doc ID (big text) |
| cover_meta | zzCover | cover metadata lines |
| cover_subtitle | CoverTitleA2 | part subtitle |
| copyright_address | zzCopyrightaddress | copyright address block |
| contents_title | zzContents | "Contents" heading |
| page_break | PAGEBREAK | manual page break |
| main_title1 | MainTitle1 | middle title line 1 |
| main_title2 | MainTitle2 | middle title line 2 |
| definition | Definition | term definition (already mapped) |
| figure_graphic | FigureGraphic | figure image placeholder |
| table_body | Tablebody | table body cell |
| table_header | Tableheader | table header cell |
| table_footer | Tablefooter | table footer cell |
| header_centered | HeaderCentered | header text style |
| footer_centered | FooterCentered | footer text style |
| footer_page_number | FooterPageNumber | footer page number |
| footer_roman | FooterPageRomanNumber | footer roman page number |
| disp_quote | Disp-quotep | block quote paragraph |
| disp_quote_attrib | Disp-quoteattrib | block quote attribution |
| warning_title | Warningtitle | warning/admonition title |
| warning_text | Warningtext | warning/admonition body |
| boxed_text | boxedText | boxed note/text |
| boxed_title | boxedTitle | boxed note title |
| index_head | IndexHead | index heading |
| index_entry | IndexEntry | index entry |

### Removed Styles (no longer needed)

These were old isodoc converter semantic markup that the ISO pipeline doesn't use:
- All `bib*` character styles — bibliography semantic markup
- All `std*` character styles — standard reference markup
- All `au*` character styles — author/editor markup
- All `cite*` character styles — citation markup
- `coverpage*` — old cover page system
- `boilerplate-*` — old boilerplate styles
- `BlockText` — replaced by `Disp-quotep`
- `DeprecatedTerms`, `AltTerms` — old term styles
- `ListParagraph`, `ListNumber1` — old list styles
- `normref` — old normative references style
- `stem`, `stem1` — old formula styles

### Numbering Changes

```yaml
numbering:
  intro_clause: 8       # abstractNumId=0: IntroHeading1..9 multilevel
  dash_list: 3          # abstractNumId=1: ListContinue1 dash bullets
  body_clause: 4        # abstractNumId=3: Heading1..9 multilevel
  decimal_list: 1       # abstractNumId=4: decimal ordered list
  annex_clause: 7       # abstractNumId=6: ANNEX + a2..a6 + Figure/Table numbering
  plain_dash_list: 5    # abstractNumId=2: plain dash bullets (no style)
```

### Character Styles

The new template has very few character styles:
- `Hyperlink` — hyperlinks
- `Courier` — monospace
- `CourierBold` — bold monospace
- `InlineCode*` — inline code variants
- `BoldItalic`, `BoldSub`, `BoldItalicSub` — bold/italic combinations
- `Regular`, `RegularBold`, `RegularItalic` — regular weight variants
- `Chinese` — East Asian font override
- `Heading7Char`..`Heading9Char` — heading character styles
- `TPS*` — Typefi system (not for our use)
- `FootnoteReference` — footnote reference
- `FootnoteTextChar` — footnote text character

The old semantic markup character styles (`bib*`, `std*`, `au*`, `cite*`) are NOT in the new template. If the adapter needs inline semantic markup, it will need a different approach (perhaps bookmark-based or custom XML-based). For now, just map:
- `hyperlink` → `Hyperlink`
- `footnote_reference` → `FootnoteReference`
- `code_inline` → `InlineCode`

## Files

- `data/iso-dis/style_mapping.yml` — complete rewrite
- `lib/isodoc/iso/docx/style_resolver.rb` — may need updates for new style keys
- `lib/isodoc/iso/docx/adapter.rb` — update any hardcoded style references

## Depends On

- TODO 002 (new template DOCX in place)
