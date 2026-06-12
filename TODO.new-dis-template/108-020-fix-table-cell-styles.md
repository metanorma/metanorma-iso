---
title: 108-020 - Fix table cell styles
priority: P2
status: open
---

# 108-020: Fix Table Cell Styles

## Problem

Table cells use different styles between latest and reference:

### Latest:
- `Tableheader` style: 12 paragraphs (table header cells)
- `Tablebody` style: 121 paragraphs (table body cells)
- Explicit style on every cell paragraph

### Reference:
- No explicit `Tableheader` or `Tablebody` styles on cell paragraphs
- Table cells inherit formatting from table-level properties
- Reference has `ListParagraph` style (14 uses) which may be used in some table contexts

## Analysis

The reference approach lets table cell formatting come from:
1. Table-level properties (tblPr → tblStyle)
2. Row-level formatting (trPr)
3. Cell-level formatting (tcPr)
4. No explicit paragraph style on cell content

The latest applies explicit styles to every cell paragraph. This is technically valid but differs from the reference.

## Fix Options

### Option A: Keep explicit styles (simpler)
Keep Tableheader/Tablebody styles but verify they match the visual formatting.

### Option B: Match reference (remove cell styles)
Remove explicit paragraph styles from table cells. Let table-level style handle formatting.

### Recommendation

Use Option A for now — explicit styles give us more control. The visual result should be the same since the styles are defined correctly. This is a cosmetic difference, not a correctness issue.

## Files to Change

- Potentially no changes needed if visual output is correct
- If alignment with reference is required: `lib/isodoc/iso/docx/adapter.rb` → render_table_section
