---
title: 108-009 - Fix duplicate terms boilerplate text
priority: P2
status: done
---

# 108-009: Fix Duplicate Terms Boilerplate Text

## Problem

In the terms section (clause 3), the latest output renders BOTH the old and new boilerplate text for terminology:

### Latest output (indices 56-63):
```
56: "For the purposes of this document, the following terms and definitions apply."
57: "ISO and IEC maintain terminology databases for use in standardization at the foll"
58: "ISO Online browsing platform: available at https://www.iso.org/obp"
59: "IEC Electropedia: available at https://www.electropedia.org"
60: "For the purposes of this document, the following terms and definitions apply."   ← DUPLICATE
61: "ISO and IEC maintain terminological databases for use in standardization at the f"  ← SLIGHTLY DIFFERENT WORDING
62: "ISO Online browsing platform: available at http://www.iso.org/obp"               ← http vs https
63: "IEC Electropedia: available at http://www.electropedia.org"                       ← http vs https
```

### Reference output (same area):
```
87: "For the purposes of this document, the following terms and definitions apply."
88: "ISO and IEC maintain terminology databases for use in standardization at the foll"
89: "ISO Online browsing platform: available at https://www.iso.org/obp "
90: "IEC Electropedia: available at https://www.electropedia.org "
91: "For the purposes of this document, the following terms and definitions apply."
92: "ISO and IEC maintain terminological databases for use in standardization at the f"
93: "ISO Online browsing platform: available at http://www.iso.org/obp "
94: "IEC Electropedia: available at http://www.electropedia.org "
```

### Analysis

Both the reference AND latest have the duplicate boilerplate! This is not a bug in our adapter — it's present in the source XML. The presentation XML contains two sets of boilerplate text (one from localized-strings, one from the terms section content).

This comparison records the historical duplicated output; it does not describe the current processor output.

## Resolution

Already fixed by the renderer introduced in `32aed33b`; `spec/isodoc/docx/renderers/terms_section_renderer_spec.rb` verifies the document's wording occurs once and preserves HTTPS link text and targets.

Verified through `Metanorma::Iso::Processor#output(..., :docx)` on
2026-11-18 using `spec/fixtures/iso/is/document-en.dis.presentation.xml`,
the ISO 5878 submission dated 20260429, and the ISO 2533 English submission
dated 20260907. Each emits one introductory sentence, one database sentence,
and one address for each terminology database, unlike the historical reference
above. ISO 5878 retains its own wording referring to ISO 2533:2026.
Submitted content was used only for measurement and was not added to the repo.
No production-code change is needed.
