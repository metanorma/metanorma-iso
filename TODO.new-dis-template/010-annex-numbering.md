# TODO 010: Implement Annex Numbering and Rendering

## Status: COMPLETE

## What

Update annex rendering to use the new template's annex numbering system (abstractNumId=6) with automatic letter assignment and figure/table sub-numbering.

## Why

The reference DOCX uses a single multilevel numbering definition (abstractNumId=6) for annexes that handles:
- Level 0: `ANNEX` style → "Annex A", "Annex B" (upperLetter format)
- Level 1: `a2` style → "A.1", "A.2" (decimal)
- Level 2: `a3` style → "A.1.1" (decimal)
- Level 3: `a4` style → "A.1.1.1" (decimal)
- Level 4: `a5` style → "A.1.1.1.1" (decimal)
- Level 5: `a6` style → "A.1.1.1.1.1" (decimal)
- Level 6: (no style) → "Figure A.1 —" (for figure numbering)
- Level 7: (no style) → "Table A.1 —" (for table numbering)
- Level 8: (no style) → "(i)" (lowerRoman for list items)

The current adapter may not properly use this numbering. The annex letter comes from the numbering definition's auto-incrementing upperLetter format, not from the XML content.

## Architecture

### Key Insight: Numbering-Driven Annex Letters

In the reference DOCX, the ANNEX paragraph has:
- Style: `ANNEX`
- Numbering: `numId=7, ilvl=0`
- Text: "(informative)" or "(normative)" — but the "Annex A" prefix comes from the numbering definition's `lvlText w:val="Annex %1"` with `numFmt w:val="upperLetter"`

This means:
1. The first annex paragraph gets `numId=7, ilvl=0` → "Annex A"
2. The second gets the same → "Annex B"
3. Sub-clauses use `ilvl=1` → "A.1", "A.2", etc.

### Adapter Changes

When rendering an annex:
1. Create the `ANNEX` paragraph with numbering reference (`numId=7, ilvl=0`)
2. The annex title text should include the annex type: "(informative)" or "(normative)"
3. Sub-clauses get the appropriate `a2`..`a6` style with `numId=7` and correct `ilvl`

### Figure/Table Numbering in Annexes

Within annexes, figure and table numbers are derived from the same numbering:
- Level 6: `lvlText="Figure %1.%7 —"` → "Figure A.1 —"
- Level 7: `lvlText="Table %1.%8 —"` → "Table A.1 —"

This means figure/table numbering in annexes is tied to the annex's numbering instance.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — annex rendering with numbering
- `lib/isodoc/iso/docx/style_resolver.rb` — annex numbering resolution

## Depends On

- TODO 002 (new template with correct numbering.xml)
- TODO 005 (style mapping with correct numId=7)
