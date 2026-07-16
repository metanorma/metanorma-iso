---
title: 108-001 - Fix cover page sectPr position and header/footer refs
priority: P0
status: open
depends_on: []
---

# 108-001: Fix Cover Page Section Break Position and Header/Footer Refs

## Problem

The cover page section break is in the WRONG position and MISSING header/footer references.

### Current (WRONG):
```
Index 0-11: Cover content (doc number, title, warning, etc.)
Index 12: "© ISO 2016"              ← still on cover page!
Index 13-15: Copyright text + address + "Published in Switzerland"
Index 16: SECTPR (no header/footer refs, no cols, no docGrid)
Index 17: "Contents"                 ← no page break
```

### Expected (from reference):
```
Index 0-11: Cover content
Index 12: " " (space paragraph)
Index 13: SECTPR (header rId7, footers rId8/rId9, cols, docGrid)
Index 14: "© ISO 2016"              ← starts NEW page
Index 15-17: Copyright text + address + "Published in Switzerland"
Index 18: PAGE BREAK (before Contents)
```

## Root Cause

The adapter's `visit_root` does not render cover page boilerplate. The cover page content comes from the template, but:
1. The boilerplate (copyright, license) is rendered AFTER the cover page content
2. The section break is placed AFTER the boilerplate (not before it)
3. The section break has no header/footer references

The adapter's `visit_root` method visits:
- preface (foreword, introduction)
- sections
- annexes
- bibliography
- colophon
- indexsect

But does NOT visit:
- **boilerplate** (copyright-statement, license-statement)
- **cover page** (rendered from template, not model)

## Fix

### Step 1: Visit boilerplate in visit_root

```ruby
def visit_root(model, doc)
  visit_cover_page(model, doc) if has_cover_content?(model)
  visit_boilerplate(model.boilerplate, doc) if model.boilerplate
  doc.page_break  # Page break before TOC
  visit_toc(model, doc) if has_toc?(model)
  doc.page_break  # Page break before Foreword
  visit_preface(model.preface, doc) if model.preface
  # ... rest unchanged
end
```

### Step 2: Insert section break between cover and copyright

The cover page section must end with a sectPr that includes:
- headerReference type="even" → header1.xml
- footerReference type="even" → footer1.xml
- footerReference type="default" → footer2.xml
- w:cols space="720"
- w:docGrid linePitch="360"

### Step 3: Move copyright to separate section

The copyright block must start on a new page:
- © ISO year
- All rights reserved text
- Address block
- "Published in Switzerland"

Then a page break before the TOC.

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — visit_root, visit_boilerplate, visit_cover_page
