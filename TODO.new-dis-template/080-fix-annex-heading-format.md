# 080: Annex heading format — obligation + title merged without space

## Problem
Output renders annex obligation and title as "(normative)Determination of defects" (merged). Reference has them as separate runs: "(normative)" then a space, then two line breaks, then "Determination of defects".

## Reference XML:
```xml
<w:r><w:br/></w:r>
<w:r><w:rPr><w:b w:val="0"/></w:rPr><w:t>(normative)</w:t></w:r>
<w:r><w:t xml:space="preserve"> </w:t></w:r>
<w:r><w:br/></w:r>
<w:r><w:br/></w:r>
<w:r><w:rPr><w:bCs/></w:rPr><w:t>Determination of defects</w:t></w:r>
```

## Output XML:
```xml
<w:r><w:br/></w:r>
<w:r><w:t>(normative)</w:t></w:r>
SEQ fields...
<w:r><w:br/></w:r>
<w:r><w:br/></w:r>
<w:r><w:rPr><w:b/></w:rPr><w:t>Determination of defects</w:t></w:r>
```

The structure is nearly correct! The differences are:
1. Missing space run between obligation and line breaks
2. Title has `<w:b/>` (bold) but reference has `<w:bCs/>` (bold complex script only)
3. Missing `<w:b w:val="0"/>` on the obligation run (explicitly NOT bold)

These are minor formatting differences. The title text IS rendering correctly.

## Fix
1. Add a space run (`" "`) after the obligation text
2. Use `bCs` instead of `b` for the title run
3. Set `b val="0"` on the obligation run (not bold)

These are cosmetic — the title renders either way. Low priority.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `render_annex_title`
