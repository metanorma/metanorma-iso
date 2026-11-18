---
title: 108-004 - Move copyright block to separate page after cover
priority: P1
status: done
depends_on: [108-001]
---

# 108-004: Move Copyright Block to Separate Page After Cover

## Resolution

Already fixed: `spec/isodoc/docx/section_manager_spec.rb:12`, added in
`62faf403`, verifies the cover section break precedes copyright and a page
break separates copyright from Contents.

Verified through `Metanorma::Iso::Processor#output(..., :docx)` on
2026-11-18 using `spec/fixtures/iso/is/document-en.dis.presentation.xml`,
the ISO 5878 submission dated 20260429, and the ISO 2533 English submission
dated 20260907. All three follow the expected ordering below: every
copyright paragraph follows the cover section break, with a page break
before Contents. Submitted content was used only for measurement and was
not added to the repo. No production-code change is needed for this item.

## Problem

In the latest output, the copyright block (© ISO year, All rights reserved, address, "Published in Switzerland") appears on the COVER PAGE, right before the section break. In the reference, it starts on a SEPARATE PAGE (after the first section break).

### Current (WRONG):
```
...cover content...
"© ISO 2016"                    ← on cover page
"All rights reserved..."
"ISO copyright office..."
"Published in Switzerland"
[SECTPR - end of cover section]
"Contents"
```

### Expected (CORRECT):
```
...cover content...
" " (space paragraph)
[SECTPR - end of cover section, has header/footer refs]
"© ISO 2016"                    ← on NEW page
"All rights reserved..."
"ISO copyright office..."
"Published in Switzerland"
[PAGE BREAK]
"Contents"
```

## Root Cause

The adapter renders cover page content and boilerplate in one sequence without inserting a section break between them. The cover page content (doc number, title, warning) and copyright boilerplate end up in the same section.

## Fix

1. Render cover page content (from model bibdata + template)
2. Insert section break with proper header/footer refs
3. Render copyright block on new page
4. Insert page break before TOC

This requires the adapter to:
- Know when cover page ends
- Insert a sectPr with cover page header/footer refs
- Then render the copyright block
- Then page break before TOC

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb`
