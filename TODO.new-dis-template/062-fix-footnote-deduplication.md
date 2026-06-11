# 062: Fix Footnote Deduplication — 8 "Withdrawn" Footnotes Should Be 1

## Problem
The output creates 8 separate footnotes with identical text "Withdrawn." (IDs: 1, 3, 10, 11, 13, 14, 15, 16). The reference correctly has only one "Withdrawn." footnote per usage, reusing the same footnote ID.

Additionally, "Under preparation..." text appears in both footnote #2 and #8 (duplicate content).

## Evidence
```
Output footnotes.xml:
  w:id=1:  "Withdrawn."
  w:id=3:  "Withdrawn."           ← DUPLICATE
  w:id=10: "Withdrawn."           ← DUPLICATE
  w:id=11: "Withdrawn."           ← DUPLICATE
  w:id=13: "Withdrawn."           ← DUPLICATE
  w:id=14: "Withdrawn."           ← DUPLICATE
  w:id=15: "Withdrawn."           ← DUPLICATE
  w:id=16: "Withdrawn."           ← DUPLICATE

  w:id=2:  "Under preparation. (Stage at the time of publication ISO/DIS..."
  w:id=8:  "Under preparation. (Stage at the time of publication ISO/DIS..." ← DUPLICATE

Reference footnotes.xml:
  w:id=1:  "Withdrawn."           (1 instance)
  w:id=3:  "Withdrawn."           (same ID reused for same content)
  w:id=8:  "Withdrawn."
  w=id=9:  "Withdrawn."
  w=id=10: "Withdrawn."
  Total: 10 unique footnotes, each with distinct ID and content
```

### In the document body:
```
Reference: 10 footnoteReference elements with unique IDs (1-10)
Output: 22 footnoteReference elements, with footnote #7 referenced 7 times!
```

Wait — footnote #7 in output is "The maximum permissible mass fraction of defects..." which is NOT a duplicate. The actual issue is:
- 8 footnotes with text "Withdrawn." should share ONE footnote ID
- 2 footnotes with "Under preparation..." should share ONE footnote ID

## Fix
Before creating a new footnote, check if a footnote with identical content already exists. If so, reuse its ID. This is standard Word behavior — identical footnotes share the same reference.

Implementation: maintain a hash of footnote text → footnote ID. Before creating a new footnote entry in footnotes.xml, check the hash first.

## Priority
**MEDIUM** — Document opens fine with duplicates, but it's wrong behavior and inflates footnote numbering.

## Location
- `lib/isodoc/iso/docx/adapter.rb` or `lib/isodoc/iso/docx/inline.rb` — footnote rendering
