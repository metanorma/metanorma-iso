# 061: Fix Cover Page Structure Differences

## Problem
The cover page layout differs significantly between output and reference. The reference has a compact cover with specific fields; the output has a different structure with the copyright block merged into the cover page.

## Evidence

### Reference cover page (14 paras, sectPr at para 13):
```
  0: "17301"                          (document number)
  1: "ISO/CD 17301-1 (draft 2016-05-01)"  (full reference + draft date)
  2: "TC 34/SC 4/WG 3"               (committee info)
  3: "Second edition"
  4: "Date: 2016-05-01"
  5: "Cereals and pulses — Specifications and test methods — Part 1"  (title)
  6: "" (spacer)
  7: "CD stage"                       (stage badge)
  8: "" (spacer)
  9: "Warning for WDs and CDs"        (warning header)
 10: "This document is not an ISO..."
 11: "Recipients of this draft..."
 12: " " (nbsp spacer)
 13: "" (sectPr)
```

### Output cover page (20 paras, sectPr at para 19):
```
  0: "ISO/CD 17301-1:2016"            (reference number with year)
  1: "2nd edition"                     (edition)
  2: "" (empty)
  3: "Date: 2016-05-01"
  4: "Cereals and pulses — Specifications and test methods"  (title part 1)
  5: "Part 1: Rice"                   (title part 2)
  6: "" (spacer)
  7: "Warning for WDs and CDs"
  8: "This document is not an ISO..."
  9: "Recipients of this draft..."
 10: "© ISO 2016"                      ← MOVED INTO COVER from copyright page
 11: "All rights reserved..."          ← MOVED INTO COVER
 12: "ISO copyright office"           ← MOVED INTO COVER
 13: "CP 401 • Ch. de Blandonnet 8"   ← MOVED INTO COVER
 14: "CH-1214 Vernier, Geneva"        ← MOVED INTO COVER
 15: "Phone: +41 22 749 01 11"        ← MOVED INTO COVER
 16: "Email:"                          ← MOVED INTO COVER
 17: "Website: www.iso.org"           ← MOVED INTO COVER
 18: "Published in Switzerland"        ← MOVED INTO COVER
 19: "" (sectPr)
```

### Key differences:
1. **Missing**: TC/SC info (Para 2 in ref: "TC 34/SC 4/WG 3")
2. **Missing**: Stage badge ("CD stage" in ref)
3. **Missing**: Document number as standalone ("17301")
4. **Different**: Title split across 2 paragraphs vs 1
5. **Different**: Edition format ("2nd edition" vs "Second edition")
6. **Different**: Reference format ("ISO/CD 17301-1:2016" vs "ISO/CD 17301-1 (draft 2016-05-01)")
7. **Moved**: Copyright block merged into cover page (should be separate section)

### Cover page styles used:
- Reference: `zzwarninghdr`, `zzwarning`, `zzCopyright`, `zzaddress`
- Output: `zzCoverlarge`, `zzCover`, `CoverTitleA1`, `CoverTitleA2`, `zzCopyright`, `zzCopyrightaddress`, `Warningtitle`, `Warningtext`

## Fix
1. Restructure cover page to match reference layout
2. Add TC/SC info paragraph
3. Add stage badge paragraph
4. Split or merge title as needed
5. Move copyright block back to its own section (or ensure it matches reference structure)

## Priority
**HIGH** — Cover page is the first thing users see. Wrong structure = wrong impression.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — cover page rendering
