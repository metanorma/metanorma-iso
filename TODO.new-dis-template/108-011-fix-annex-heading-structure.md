---
title: 108-011 - Fix annex heading structure
priority: P2
status: open
---

# 108-011: Fix Annex Heading Structure

## Problem

Annex headings have structural differences between latest and reference.

### Reference pattern (e.g., Annex A):
```
Index 222: PAGE BREAK (empty paragraph)
Index 223: "(normative) Determination of defects "   [no style, obligation + title]
Index 224: "Annex ADetermination of defects"          [ANNEX style, "Annex"+letter+title]
Index 225: "A.1Principle"                              [Heading1 style]
```

### Latest pattern (same annex):
```
Index 185: PAGE BREAK (empty paragraph)
Index 186: "(normative) Determination of defects"     [no style]
Index 187: "Annex ADetermination of defects"           [ANNEX style]
Index 188: "A.1Principle"                              [Heading1 style]
```

### Key differences:

1. **Annex obligation paragraph** — Both have "(normative)" or "(informative)" text on separate line. Match is OK.
2. **Annex title** — Both use ANNEX style. "Annex A" + title merged. Match is OK.
3. **Subsection headings** — Both use Heading1 for first level (A.1, B.1, etc.). Match is OK.

### But in reference, annex figures use different title style:

Reference has `AnnexFigureTitle` (6 uses) for annex figure captions.
Latest uses `Figuretitle` (3 uses) for ALL figures.

### Fix

When in annex context (`@context.in_annex`), figure titles should use `AnnexFigureTitle` instead of `Figuretitle`.

Also check if annex table titles should use `AnnexTableTitle` (reference has 1 use).

## Files to Change

- `lib/isodoc/iso/docx/style_resolver.rb` — context-aware figure title style
- `data/iso-dis/style_mapping.yml` — annex figure/table title mapping
