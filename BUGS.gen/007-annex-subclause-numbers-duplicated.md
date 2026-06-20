---
title: BUG 007 - Annex sub-clause numbers duplicated
priority: P1
status: closed
---

# BUG 007: Annex Sub-Clause Numbers Duplicated

## Symptom

Annex sub-clause headings show the number twice:

```
A.1    A.1Principle
A.2    A.2Apparatus
A.2.1    A.2.1Sample divider,
```

## Root Cause

Same as BUG 004 and BUG 005. The `a2`, `a3`, etc. styles in the DIS
template use `<w:numPr>` for auto-numbering.

The adapter writes the section number ("A", ".", "1") as text runs:

```xml
<w:p>
  <w:pPr><w:pStyle w:val="a2"/></w:pPr>
  <w:bookmarkStart w:id="45" w:name="_b9220d43-..."/>
  <w:bookmarkEnd w:id="45"/>
  <w:r><w:t>A</w:t></w:r>
  <w:r><w:t>.</w:t></w:r>
  <w:r><w:t>1</w:t></w:r>
  <w:r><w:t>Principle</w:t></w:r>
</w:p>
```

Word renders: auto-number "A.1" + text "A.1Principle" = "A.1 A.1Principle".

## Fix

Same as BUG 004: strip autonum carriers from heading rendering when
the target style uses `numPr`.

## Files to Change

- `lib/isodoc/iso/docx/inline.rb` — extend `render_heading_ordered` to
  filter `<semx element="autonum">` content (covers this bug,
  BUG 004, BUG 005, BUG 006 all at once)
