# TODO 012: End-to-End Validation Against Reference DOCX

## Status: COMPLETE

## What

Generate a DOCX from the rice DIS presentation XML and validate it against the reference DOCX structure, styles, and properties.

## Why

After all template and adapter changes, we need to verify the output matches ISO's expected format. The rice DIS fixture (`spec/fixtures/samples/international-standard/document-en.dis.presentation.xml`) is our primary reference.

## Validation Checklist

### 1. Document Properties
- [ ] `docProps/custom.xml` has all 20 ISO properties with correct values
- [ ] `docProps/core.xml` has title, creator, language
- [ ] `docProps/app.xml` has reasonable values

### 2. Template Infrastructure
- [ ] `word/styles.xml` has all 250+ styles from reference
- [ ] `word/numbering.xml` has correct abstractNum/num definitions
- [ ] `word/settings.xml` has mirrorMargins, evenAndOddHeaders
- [ ] `word/fontTable.xml` has Cambria, Calibri, Times New Roman, MS Mincho
- [ ] `word/theme/theme1.xml` is present

### 3. Document Structure
- [ ] Cover page: zzCoverlarge → zzCover → CoverTitleA1/A2 → zzCopyright block
- [ ] Section break after cover (sectPr with no header/footer)
- [ ] TOC: zzContents title + SDT content control
- [ ] Foreword: ForewordTitle + ForewordText paragraphs
- [ ] Introduction: IntroTitle + body paragraphs
- [ ] Section break before body (sectPr with roman numbering)
- [ ] Middle title: MainTitle1 + MainTitle2
- [ ] Scope: Heading1 + body text
- [ ] Normative references: Heading1 + body text
- [ ] Terms: Heading2 subclauses with TermNum3 + Terms0 + Definition + Note + Source
- [ ] Annex: ANNEX with numbering + a2..a6 subclauses
- [ ] Bibliography: BiblioTitle + BiblioEntry paragraphs
- [ ] Final section break (sectPr with arabic numbering, start=1)

### 4. Headers and Footers
- [ ] Section 1: no headers/footers
- [ ] Section 2: HeaderCentered with doc ID, FooterCentered + FooterPageRomanNumber
- [ ] Section 3: HeaderCentered with doc ID, FooterCentered + FooterPageNumber

### 5. Style Usage
- [ ] All paragraphs use correct style IDs from the new template
- [ ] No references to old styles that don't exist in new template
- [ ] Heading numbering is automatic (from numbering.xml, not hardcoded text)

### 6. Word Compatibility
- [ ] DOCX opens in Word without repair
- [ ] TOC can be updated (Ctrl+A, F9)
- [ ] Page numbering shows correctly (roman → arabic)
- [ ] Headers/footers display correctly on even/odd pages

## Test Approach

1. Generate DOCX from rice DIS presentation XML
2. Open in Word — verify no repair needed
3. Extract and compare styles.xml, numbering.xml against reference
4. Compare document.xml structure paragraph by paragraph
5. Run `uniword diff compare` against reference output
6. Verify all spec fixtures still pass

## Files

- `spec/isodoc/docx/sample_validation_spec.rb` — update expectations for new styles
- `spec/isodoc/docx/adapter_spec.rb` — update style expectations

## Depends On

- All previous TODOs (002-011)
