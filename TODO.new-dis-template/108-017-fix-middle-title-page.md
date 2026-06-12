---
title: 108-017 - Fix middle title page (second section break)
priority: P1
status: open
depends_on: [108-003]
---

# 108-017: Fix Middle Title Page (Second Section Break)

## Problem

The reference has a second section break at index 71 (after Introduction) that creates a "middle title" page with the document title rendered again. The latest has a similar section break but at index 40 (earlier, because of missing TOC entries and page breaks).

### Reference structure:
```
Index 60: Introduction content...
Index 71: SECTPR (with header rId16/rId17, footer rId18/rId19)
Index 72: "Cereals and pulses — Specifications and test methods — Part 1" [zzSTDTitle]
Index 73: "1Scope" [Heading1]
```

### Latest structure:
```
Index 40: SECTPR (with header rId16/rId17, footer rId18/rId19)
Index 41: "Cereals and pulses — Specifications and test methods — Part 1" [zzSTDTitle]
Index 42: "1Scope" [Heading1]
```

## Key Differences

1. **Position**: The middle title section break should come after the Introduction (not after some other content)
2. **Style on sectPr paragraph**: Latest uses `PAGEBREAK` style, reference has no style
3. **Content before**: Reference has full Introduction content + blank paragraph before sectPr

## Fix

1. After rendering Introduction, insert a section break (not a page break)
2. The section break paragraph should have no pStyle (or minimal formatting)
3. After the section break, render the document title with zzSTDTitle style
4. Then render the body sections (Scope, Normative refs, etc.)

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_root flow, section break insertion
