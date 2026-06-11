# 064: Fix Missing Section Breaks — Annexes and Bibliography

## Problem
The reference has section breaks (sectPr) that start new pages for each annex and the bibliography. The output has only 2 section breaks total (cover page and foreword/intro), with no page breaks between annexes.

## Evidence
```
Reference: 2 inline sectPr (cover, foreword+intro) + body sectPr
  - Annexes have page-break separators (empty paragraphs before annex heading)
  - Each annex starts on a new page

Output: 2 inline sectPr (cover, foreword+intro) + body sectPr
  - Same count, but content runs together
  - No page breaks between annexes
  - Annex C, D, E headings missing entirely (see 059)
```

### Reference annex transitions:
```
Para 218: "The packages shall be marked..."  (end of Clause 9)
Para 219: ""                                  (empty paragraph)
Para 220: "(normative) Determination of defects"  ← new page implied by style
Para 221: "Annex ADetermination of defects"
```

### Output annex transitions:
```
Para 182: "The packages shall be marked..."  (end of Clause 9)
Para 183: "A.1Principle"                      ← NO separator, NO annex heading!
```

Additionally, the reference has `PAGEBREAK` style usage and `w:br w:type="page"` for explicit page breaks before annexes.

## Fix
1. Insert page break before each annex (either via sectPr or `w:br w:type="page"`)
2. Insert page break before Bibliography
3. Ensure each major section starts on a new page as per ISO template

The user's bug report says: "After scope should not cause new page" — but the reference DOES have sections. The issue is that page breaks should be at annex/bibliography boundaries, NOT after scope.

## Priority
**HIGH** — Missing page breaks between annexes make the document structurally wrong.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — section break and page break logic
