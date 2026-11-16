---
title: 108-008 - Fix section property differences
priority: P1
status: open
depends_on: [108-001]
---

# 108-008: Fix Section Property Differences

## Problem

The three sectPr elements have structural differences from the reference.

### sectPr[0] (Cover page end)

**Reference:**
```xml
<w:sectPr w:rsidR="00000000">
  <w:headerReference w:type="even" r:id="rId7"/>
  <w:footerReference w:type="even" r:id="rId8"/>
  <w:footerReference w:type="default" r:id="rId9"/>
  <w:pgSz w:w="11906" w:h="16838"/>
  <w:pgMar w:top="794" w:right="737" w:bottom="284" w:left="851" 
           w:header="709" w:footer="0" w:gutter="567"/>
  <w:cols w:space="720"/>
  <w:docGrid w:linePitch="360"/>
</w:sectPr>
```

**Latest (WRONG):**
```xml
<w:sectPr>
  <w:pgSz w:w="11906" w:h="16838"/>
  <w:pgMar w:top="794" w:bottom="284" w:left="851" w:right="737" 
           w:header="709" w:footer="0" w:gutter="567"/>
</w:sectPr>
```

Missing: headerReference, footerReference×2, w:cols, w:docGrid, w:rsidR

### sectPr[1] (Front matter end)

Both have similar structure with header/footer refs and pgNumType. Minor differences:
- Reference has `w:rsidR="00000000"`, latest has different rsidR
- Reference has `w:cols w:space="720"`, latest doesn't

### sectPr[2] (Body)

Both similar. Minor:
- Reference has `w:rsidR="00697CCA"`, latest has `"00538398"`
- Both have footer refs, pgNumType start=1, cols

## Fix

### For sectPr[0]:
1. Add header/footer references (pointing to cover page headers/footers)
2. Add `w:cols w:space="720"`
3. Add `w:docGrid w:linePitch="360"`
4. Set `w:rsidR="00000000"`

### For sectPr[1]:
1. Add `w:cols w:space="720"`

### For sectPr[2]:
Already mostly correct. No changes needed.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — apply_final_section, create_document
- May need Uniword section builder enhancements
