# TODO 024: Fix ANNEX Paragraph Structure — Match DIS Template Format

## Status: DONE

## What

The ANNEX paragraph structure differs significantly from the DIS template. The adapter outputs "Annex A" + br + "(normative)" + br + br + title. The template outputs br + "(normative)" + SEQ fields + br + br + title (no "Annex A" text — auto-numbered).

## Why

### Current (Broken)

```xml
<w:pStyle w:val="ANNEX"/>
<w:r><w:rPr><w:b/></w:rPr><w:t>Annex A</w:t></w:r>
<w:r><w:br/></w:r>
<w:r><w:t>(normative)</w:t></w:r>
<w:r><w:br/></w:r>
<w:r><w:br/></w:r>
<w:r><w:rPr><w:b/></w:rPr><w:t>Determination of defects</w:t></w:r>
```

### Expected (DIS Template)

```xml
<w:pStyle w:val="ANNEX"/>
<w:r><w:br/></w:r>                                     <!-- Leading break -->
<w:r><w:t>(normative)</w:t></w:r>                      <!-- Type only, no bold -->
<w:r><w:fldChar w:fldCharType="begin" w:fldLock="1"/></w:r>
<w:r><w:instrText xml:space="preserve">SEQ aaa \h </w:instrText></w:r>
<w:r><w:fldChar w:fldCharType="end"/></w:r>
<w:r><w:fldChar w:fldCharType="begin" w:fldLock="1"/></w:r>
<w:r><w:instrText xml:space="preserve">SEQ table \r0\h </w:instrText></w:r>
<w:r><w:fldChar w:fldCharType="end"/></w:r>
<w:r><w:fldChar w:fldCharType="begin" w:fldLock="1"/></w:r>
<w:r><w:instrText xml:space="preserve">SEQ figure \r0\h </w:instrText></w:r>
<w:r><w:fldChar w:fldCharType="end"/></w:r>
<w:r><w:br/></w:r>
<w:r><w:br/></w:r>
<w:r><w:t>Conformance and abstract test suite</w:t></w:r>  <!-- Title, no bold -->
```

### Key Differences

1. **No "Annex A" text** — auto-numbered by ANNEX style (see TODO 015)
2. **Leading `<w:br/>`** — empty line at top of annex
3. **SEQ fields** — reset counter fields for table/figure numbering within the annex (`SEQ aaa \h`, `SEQ table \r0 \h`, `SEQ figure \r0 \h`)
4. **No bold on title** — the ANNEX style already applies bold; explicit bold is not needed
5. **"(normative)" not bold** — same reason

### SEQ Fields Purpose

The SEQ fields reset the internal counters for each annex:
- `SEQ aaa \h` — hidden annex counter increment
- `SEQ table \r0 \h` — reset table counter to 0
- `SEQ figure \r0 \h` — reset figure counter to 0

These ensure that tables and figures within each annex are numbered starting from 1 (e.g., "Table A.1", "Figure A.1").

## Architecture

Update the annex heading rendering to:
1. Remove "Annex A" text (auto-numbered)
2. Add leading `<w:br/>`
3. Add SEQ field elements after "(normative)"
4. Remove explicit bold formatting (style handles it)
5. Add two `<w:br/>` before title text

The SEQ fields require Uniword support for field characters (`fldChar` and `instrText`). Check if Uniword has builder support for these; if not, add it.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — annex heading rendering
- Possibly Uniword builder additions for field characters

## Depends On

- TODO 015 (remove manual section numbers)
