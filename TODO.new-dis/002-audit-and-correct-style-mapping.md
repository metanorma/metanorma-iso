# 002 — Audit and correct style_mapping.yml

## Problem

Current `data/iso-dis/style_mapping.yml` has 30+ entries whose values
either don't exist in DIS 15926's `styles.xml`, are wrong-case, or are
8601-era IDs that no late-Typefi document defines.

## Concrete defects found (in current file)

### Wrong-case / phantom IDs (styleId not in Era C reference)

| YAML key | Current value | DIS 15926 status |
|----------|---------------|------------------|
| `figure_title` | `Figuretitle` | Not in DIS 15926 (it has `figuretitle` lowercase, Era A) — but `Figuresubtitle` is Era C |
| `table_title` | `Tabletitle` | Not in DIS 15926 — `tabletitle` is Era A only |
| `note` | `Note` | Not in any of the 8 reference docs |
| `example` | `Example` | Not in any of the 8 reference docs |
| `admonition` | `Warningtext` | OK in Era C (present in DIS 15926) |
| `admonition_title` | `Warningtitle` | OK in Era C |
| `figure_title_annex` | `AnnexFigureTitle` | Not in DIS 15926 |
| `table_title_annex` | `AnnexTableTitle` | Not in DIS 15926 |
| `cover_large` | `zzCoverlarge` | OK in Era C |
| `copyright_address` | `zzCopyrightaddress` | OK in Era C |
| `header_centered` | `HeaderCentered` | OK in Era C |
| `footer_centered` | `FooterCentered` | OK in Era C |
| `footer_page_number` | `FooterPageNumber` | OK in Era C |
| `footer_roman` | `FooterPageRomanNumber` | OK in Era C |
| `inline_code` | `InlineCode` | OK in Era C |
| `endnote_reference` | `EndnoteReference` | Not in DIS 15926 |
| `variant_title_toc` | `variant-title-toc` | Not in DIS 15926 |
| `page_break` | `PAGEBREAK` | Not in DIS 15926 |
| `quote` | `Disp-quotep` | OK in Era C |
| `auto_numbered_styles` includes `Heading6` etc. | OK |

### Era C content styles currently UNMAPPED

```yaml
# Should be added
key_text: KeyText
box_begin: Box-begin
box_end: Box-end
box_title: Box-title
figure_description: Figuredescription
figure_note: Figurenote
figure_subtitle: Figuresubtitle
dimension_50: Dimension50
dimension_75: Dimension75
dimension_100: Dimension100
notice: Notice
block_text: BlockText
inline_code_bold: InlineCodeBold
```

### Numbering `intro_clause`, `dash_list_variant`, `plain_dash_list`

Currently mapped to integers 8, 6, 5. After re-extraction (TODO 001),
DIS 15926 has 7 abstractNums and we'll renumber.

## Approach

1. Run `TemplateExtractor` (TODO 001) to get authoritative `styles.yml`.
2. Write `StyleMappingValidator` (TODO 005) to enumerate defects.
3. Apply corrections to `style_mapping.yml`:
   - Fix wrong-case IDs.
   - Add missing Era C mappings.
   - Remove phantom IDs.
4. Re-run validator to confirm zero defects.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml`
- Reference: `data/iso-dis/styles.yml` (post-TODO 001)

## Acceptance criteria

- Every value in `style_mapping.yml` paragraph_styles and character_styles
  is a key in `styles.yml`.
- `auto_numbered_styles` only references styleIds that exist AND have
  `numPr` in their definition.
- `numbering` block IDs match abstractNum IDs in `numbering.yml`.
- YAML file has a header:
  ```yaml
  template_era: late_typefi
  reference_doc: spec/fixtures/20250530-ISO_DIS_15926-100.docx
  ```

## Required specs

- `style_mapping_integrity_spec.rb` (TODO 019) enforces this at CI time.
