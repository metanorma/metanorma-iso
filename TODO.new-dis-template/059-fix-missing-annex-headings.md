# 059: Fix Missing Annex Headings (A, B, C, D, E)

## Problem
The output DOCX is missing ALL annex title paragraphs. It jumps directly from the last clause (e.g. "9 Marking") into "A.1 Principle" without the "Annex A (normative) Determination of defects" heading paragraph. Similarly for Annexes B through E.

The reference has TWO paragraphs per annex:
1. A "label" paragraph with style like `(informative) Determination of defects` (appears before the main heading)
2. The main heading paragraph: `Annex A Determination of defects`

Neither exists in the output.

## Evidence
```
Reference (before Annex A):
  Para 219: "" (empty separator)
  Para 220: "(normative) Determination of defects"
  Para 221: "Annex ADetermination of defects"
  Para 222: "A.1Principle"

Output (before Annex A):
  Para 182: "9Marking" (last clause)
  Para 183: "A.1Principle" (jumps straight to sub-clause!)

Reference (before Annex C):
  Para 301: "(informative) Gelatinization"
  Para 302: "Annex CGelatinization"

Output (after B.7):
  Para 259: "B.7Test report"
  Para 261: "Figure C.1 gives an example..." (NO Annex C heading at all!)
```

## Impact
- All 5 annex headings are missing (A, B, C, D, E)
- Annexes C, D, E are completely missing their heading paragraphs
- The annex label paragraphs (e.g. "(normative)") and the main annex title paragraphs are both missing
- This means annexes don't start on new pages and have no visual heading
- Content from different annexes runs together

## Fix
The adapter must emit the annex heading paragraphs (both the label and the main heading) before the first sub-clause of each annex. Each annex heading should be rendered as a distinct paragraph with appropriate style.

The reference shows:
- Annex headings use `ANNEX` pStyle (5 occurrences)
- There's typically a preceding empty paragraph or separator before the annex

## Priority
**CRITICAL** — Annex headings are structural content. Without them, the document is fundamentally broken.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — annex rendering logic
