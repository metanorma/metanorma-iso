# 058: Fix Missing Cover Page Section Headers/Footers

## Problem
The first section (cover page, sectPr #0) has **zero** headerReference and footerReference elements. The reference DOCX has header+footer for this section. Word likely reports "unreadable content" or errors because a section with `titlePg` but no header/footer references is invalid.

## Evidence
```
Reference sectPr #0 (cover):
  headerReference type="even" rId=rId7 → header1.xml
  footerReference type="even" rId=rId8 → footer1.xml
  footerReference type="default" rId=rId9 → footer2.xml

Output sectPr #0 (cover):
  (no header/footer references at all!)
  titlePg element present
```

The reference has 6 footer files (footer1-6) and 3 header files (header1-3). The output has only 4 footer files (footer1-4) and 4 header files (header1-4).

## Fix
Add headerReference and footerReference to the cover page sectPr. These should point to blank/empty header and footer files (cover page typically has no visible header/footer, but the references must exist).

Also: the reference cover sectPr has NO `titlePg` element. The output cover sectPr has `titlePg`. Check if this should be removed or if it's fine with proper header/footer refs.

## Priority
**CRITICAL** — This likely causes the "file won't open" error.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — section break / sectPr generation for cover page
- `lib/isodoc/iso/docx/document_properties.rb` — document property/section definitions
