# TODO 005: Verify DOCX opens in Word without "unreadable content" error

## Status: TODO (requires manual Word testing)

## Context
All known XML-level fixes have been applied:
- xml:space="preserve" for newline/whitespace content (TODO 001)
- Hyperlink text uses Text.cast (TODO 002)
- ZIP internal_file_attributes=0 (already in place)
- Numeric rId format in relationships (already in place)
- FrozenError fixes for element_order (TODO 004)

## Structural analysis confirms:
- XML is well-formed, no parse errors
- All namespace prefixes declared on root
- Element ordering correct (pPr before r, tblPr before tblGrid, etc.)
- body ends with sectPr
- 104 matched bookmarks (no duplicates)
- 22 matched footnote references
- Tables have valid gridAfter
- No control characters, BOM, or encoding issues
- All cross-part relationship references valid
- Content types correct for all parts

## Test file
Generated: `data/rice_fixed9.docx`

## Steps
1. Open `data/rice_fixed9.docx` in Microsoft Word
2. Verify no "unreadable content" dialog appears
3. If dialog still appears, extract and compare with Word's repaired version
