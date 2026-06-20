---
title: BUG 018 - Whitespace lost at run boundaries
priority: P2
status: closed
---

# BUG 018: Whitespace Lost at Run Boundaries

## Symptom

When the inline renderer splits content into multiple runs, the
space between them is sometimes dropped:

```
Part 1:Rice     ← should be "Part 1: Rice"
paddy ricerough rice     ← should be "paddy rice\nrough rice"
```

## Root Cause

The inline renderer produces adjacent runs like:

```xml
<w:r><w:rPr/><w:t xml:space="preserve">Cereals and pulses — ... — </w:t></w:r>
<w:r><w:rPr/><w:t>Part 1:</w:t></w:r>
<w:r><w:rPr/><w:t>Rice</w:t></w:r>
```

Some runs have `xml:space="preserve"` and some don't. Without the
preserve attribute, leading/trailing whitespace in `<w:t>` is
stripped per the OOXML spec.

The third run "Rice" doesn't have a leading space, but the original
text was "Part 1: Rice" with a space — that space got attached to
the previous run's trailing context which was lost.

## Evidence

```xml
<w:r><w:rPr/><w:t>Part 1:</w:t></w:r>      <!-- trailing space lost -->
<w:r><w:rPr/><w:t>Rice</w:t></w:r>          <!-- leading space lost -->
```

## Fix

1. Always add `xml:space="preserve"` to `<w:t>` elements that have
   leading or trailing whitespace (or always, for safety).

2. When splitting inline content into runs, ensure whitespace is
   preserved by either:
   - Including the whitespace as a dedicated `<w:t xml:space="preserve"> </w:t>` run
   - Or attaching the whitespace to the adjacent text run with preserve flag

## Files to Change

- `lib/isodoc/iso/docx/inline.rb` — `add_text` helper should set
  `xml:space="preserve"` whenever the text has leading/trailing whitespace
- `uniword/lib/uniword/wordprocessingml/text.rb` (or wherever `<w:t>`
  is serialized) — ensure preserve attribute is honored

## Verification

After fix, no spaces should be lost between adjacent runs.

## Related

- BUG 015: title rendered as "Part 1:Rice" instead of "Part 1: Rice"
