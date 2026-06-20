---
title: BUG 015 - Document main title rendered twice in body
priority: P1
status: closed
---

# BUG 015: Document Main Title Rendered Twice in Body

## Symptom

The document title appears once on the cover page and again at the
top of the body section, sometimes with the title split into multiple
runs:

```
[Cover page]
Cereals and pulses — Specifications and test methods — Part 1: Rice

[Body section top]
Cereals and pulses — Specifications and test methods — Part 1: Rice
Cereals and pulses — Specifications and test methods — Part 1:Rice
```

(The second body occurrence also has the colon-space collapsed.)

## Root Cause

The adapter renders the title from BOTH:
1. The cover renderer (uses `zzCover`/`CoverTitleA1` style)
2. The body's `zzSTDTitle` paragraph (redundant — the title is metadata
   and shouldn't be in the body)

Plus the second copy is from a different code path that splits the
title by clause (the `<w:rPr/>` empty runs suggest this is the
semantic `<title>` element being rendered through the inline
renderer without `xml:space="preserve"` on the joins).

## Evidence

```xml
<!-- First body occurrence: zzSTDTitle style -->
<w:p>
  <w:pPr><w:pStyle w:val="zzSTDTitle"/></w:pPr>
  <w:r><w:t>Cereals and pulses — Specifications and test methods — Part 1: Rice</w:t></w:r>
</w:p>

<!-- Second body occurrence: no style, runs split -->
<w:p>
  <w:r><w:rPr/><w:t xml:space="preserve">Cereals and pulses — Specifications and test methods — </w:t></w:r>
  <w:r><w:rPr/><w:t>Part 1:</w:t></w:r>
  <w:r><w:rPr/><w:t>Rice</w:t></w:r>
</w:p>
```

The second one has the join defect ("Part 1:Rice" with no space between
"1:" and "Rice") because the inline renderer doesn't preserve
whitespace at run boundaries.

## Fix

1. **Do not render the main title in the body.** The title belongs on
   the cover page only (or in a running header). The body should start
   directly with "1 Scope" or the boilerplate clauses.

2. **If a body title is required by ISO DIS layout**, render it only
   once via the `zzSTDTitle` style. Remove the duplicate walk that
   emits the second split-runs copy.

3. **Fix whitespace preservation** so that adjacent runs joining with
   a trailing space keep the space.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — remove the body-level title
  rendering, or remove the duplicate walk that produces the second copy
- `lib/isodoc/iso/docx/inline.rb` — ensure `xml:space="preserve"` on
  runs that have leading/trailing whitespace

## Related

- BUG 018: same whitespace-loss pattern (likely the same root cause in
  the inline renderer)
