# 073: Fix TOC — 26 entries missing

## Problem
Reference has 26 TOC entries (18x TOC1, 7x TOC2, 2x TOC3) with hyperlinks and page numbers. Output has only a `TOC` field instruction with no entries. Word will populate on update, but the reference has them pre-populated.

## Reference structure
Each TOC entry is a paragraph with:
- pStyle `TOC1`/`TOC2`/`TOC3` (based on heading level)
- Contains hyperlinks with anchors like `_Toc271156285`
- Contains `fldChar` field codes (PAGEREF) for page numbers
- Text includes heading number + title + tab + page number

Example (TOC1):
```xml
<w:p>
  <w:pPr><w:pStyle w:val="TOC1"/></w:pPr>
  <w:hyperlink w:anchor="_Toc271156285" w:history="1">
    <w:r><w:rPr><w:rStyle w:val="Hyperlink"/></w:rPr><w:t>Foreword</w:t></w:r>
    ...
    <w:r><w:t>1</w:t></w:r>
  </w:hyperlink>
</w:p>
```

## Fix
In `render_toc` in `adapter.rb`, iterate the document's sections and generate TOC entries with correct styles and hyperlinks. Each heading in the document should have a corresponding TOC entry.

Alternatively, the simple `TOC` field instruction is sufficient for Word to populate — this is lower priority since Word auto-generates TOC on open/update.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — `render_toc` method
