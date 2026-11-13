# 068: Fix Missing Content — Figures, Images, Annex Content

## Problem
The output is missing significant content present in the reference:
1. Missing images (output has 2 drawings; reference has 5 picts)
2. Missing Annex C figures (gelatinization curve, stages)
3. Missing Annex D table content
4. Missing Annex E heading and structure
5. Missing Key paragraphs for figures
6. Missing sub-figures (Figure C.2 stages a/b/c)

## Evidence

### Image format differences:
```
Reference: 5 images as <w:pict> (VML graphics)
Output:    2 images as <w:drawing> (DrawingML)
```

### Missing Annex C content:
```
Reference:
  Para 303: "Figure C.1 gives an example of a typical gelatinization curve..."
  Para 304: "a"
  Para 305: "Key"
  Para 306: "NOTE These results are based on..."
  Para 307: "Figure C.1 — Typical gelatinization curve"
  Para 308: ""
  Para 309: "a)  Initial stages: No grains are fully gelatinized..."
  Para 310: ""
  Para 311: "b)  Intermediate stages: Some fully gelatinized kernels..."
  Para 312: ""
  Para 313: "c)  Final stages: All kernels are fully gelatinized"
  Para 314: "Figure C.2 — Stages of gelatinization"

Output:
  Para 261: "Figure C.1 gives an example..."
  Para 262: ""
  Para 263: "Figure C.1 — Typical gelatinization curve"
  Para 264: "Figure C.2 — Stages of gelatinization"
  (missing: Key paragraph, NOTE, sub-figure descriptions a/b/c)
```

### Missing Annex D table:
The reference has a full table (Table D.1) with interlaboratory test results. The output just has the table caption.

### Missing Annex E heading:
```
Reference:
  Para 321: "(informative) Extraneous information"
  Para 322: "Annex E Extraneous information"

Output:
  (no heading at all - jumps from Table D.1 directly to content)
```

## Fix
1. Ensure figure images are rendered (format conversion from VML to DrawingML is fine, but images must exist)
2. Ensure Key paragraphs, NOTE paragraphs, and sub-figure descriptions are rendered
3. Ensure Annex D table content is rendered (not just the caption)
4. Ensure Annex E gets its heading paragraph

## Priority
**HIGH** — Missing figures and tables is loss of significant content.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — figure, table, and annex rendering
