---
title: 108-009 - Fix duplicate terms boilerplate text
priority: P2
status: open
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

**Verdict:** This is correct behavior — both outputs match. No fix needed here. The duplication is intentional (old-style + new-style boilerplate).

## Resolution

**CLOSED — Not a bug.** Both reference and latest output have the same duplicate boilerplate text. This comes from the presentation XML source.
