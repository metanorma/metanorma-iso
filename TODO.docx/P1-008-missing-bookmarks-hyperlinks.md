# 070: Fix Missing Bookmarks and Hyperlinks

## Problem
The reference has 293 bookmarks and 120 hyperlinks. The output has only 98 bookmarks and 75 hyperlinks. Missing bookmarks mean cross-references and internal links may be broken.

## Evidence
```
Reference: 293 bookmarks, 120 hyperlinks
Output:     98 bookmarks,  75 hyperlinks
Delta:     -195 bookmarks, -45 hyperlinks
```

The missing bookmarks are likely related to:
1. Missing annex headings (no bookmark targets for Annex A-E)
2. Missing TOC entries (no hyperlink targets)
3. Missing figure/table cross-reference targets

## Fix
1. Ensure every heading generates a bookmark anchor
2. Ensure annex headings get bookmarks
3. Ensure figure/table titles get bookmarks
4. Ensure cross-references (`<xref>`) generate hyperlinks to bookmark targets

## Priority
**MEDIUM** — Internal navigation is degraded but document still opens.

## Location
- `lib/isodoc/iso/docx/adapter.rb` — bookmark generation
- `lib/isodoc/iso/docx/inline.rb` — hyperlink rendering
