---
title: 108-004 - Move copyright block to separate page after cover
priority: P1
status: open
depends_on: [108-001]
---

# 108-004: Move Copyright Block to Separate Page After Cover

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
