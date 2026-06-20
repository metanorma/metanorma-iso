---
title: BUG 014 - TOC entries missing heading text
priority: P1
status: closed
---

# BUG 014: TOC Entries Missing Heading Text

## Symptom

The table of contents shows blank lines with only page reference
fields — no heading text or numbers visible:

```
Contents



Contents
```

The user sees mostly empty TOC entries because the heading text and
section numbers are not present in the TOC paragraphs.

## Root Cause

Each TOC entry paragraph has the PAGEREF field machinery but no
visible run with the heading text:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="TOC1"/></w:pPr>
  <w:r><w:tab/></w:r>
  <w:r><w:fldChar/></w:r>
  <w:r><w:instrText> PAGEREF _653a90c4-... \h </w:instrText></w:r>
  <w:r><w:fldChar/></w:r>
  <w:r><w:fldChar/></w:r>
</w:p>
```

A proper TOC entry needs:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="TOC1"/></w:pPr>
  <w:r><w:t>1</w:t></w:r>                           <!-- section number -->
  <w:r><w:tab/></w:r>
  <w:r><w:t>Scope</w:t></w:r>                        <!-- heading text -->
  <w:r><w:tab/></w:r>
  <w:r><w:fldChar w:fldCharType="begin"/></w:r>
  <w:r><w:instrText> PAGEREF _... \h </w:instrText></w:r>
  <w:r><w:fldChar w:fldCharType="separate"/></w:r>
  <w:r><w:t>1</w:t></w:r>                            <!-- cached page number -->
  <w:r><w:fldChar w:fldCharType="end"/></w:r>
</w:p>
```

## Fix

The TOC builder needs to:
1. Look up each heading by bookmark id from the document model
2. Render the heading's number and title text in the TOC entry
3. Wrap the PAGEREF field with correct `fldCharType` markers
4. Optionally wrap the entry in a hyperlink to the bookmark

A simpler alternative: emit the TOC as a single TOC field with
`<w:fldChar w:fldCharType="begin"/>` ... `<w:instrText> TOC \o "1-3" \h \z \u </w:instrText>` ... `<w:fldChar w:fldCharType="separate"/>` ...
[cached entries] ... `<w:fldChar w:fldCharType="end"/>`. Word will
regenerate the entries on first open.

## Files to Change

- `lib/isodoc/iso/docx/toc_builder.rb` (or wherever the TOC entries
  are constructed)
- `uniword/lib/uniword/builder/toc_builder.rb` (likely missing
  fldCharType)

## Related

- BUG 002: fldChar missing fldCharType (same field-character issue)
