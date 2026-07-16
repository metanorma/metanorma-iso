---
title: 108-019 - Fix normative reference formatting
priority: P2
status: open
---

# 108-019: Fix Normative Reference Formatting

## Problem

Normative reference entries have formatting differences:

### Reference (correct):
```
"ISO 712:2009) , Cereals and cereal products — Determination of..."
```
Note the `)` after the year and the `, ` separator. Some references have footnote markers after the year.

### Latest:
```
"ISO 712:2009, Cereals and cereal products — Determination of..."
```
Missing the `)` footnote marker and different spacing.

## Specific differences

1. **Footnote markers**: Reference has `)` after some ISO reference years (e.g., "ISO 712:2009)"). These are footnote reference markers that link to a footnote explaining the reference status. Latest omits them.

2. **Separator**: Reference uses ") ," (close paren, comma, space). Latest uses "," (just comma, space).

3. **Style**: Reference uses `normref` style for these paragraphs (same as latest). But reference also has `ListParagraph` style for some bib entries (in bibliography section, not normative refs).

## Root Cause

The inline renderer may not be rendering footnote markers inside bibliographic item entries. The model's biblio_tag likely contains the footnote references, but they're not being rendered as footnote reference elements.

## Fix

1. Check if the model's biblio_tag contains footnote references
2. Render footnote markers as proper `<w:footnoteReference>` elements
3. Ensure the `)` is part of the footnote marker rendering

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — render_bib_item_content
- `lib/isodoc/iso/docx/inline.rb` — footnote reference rendering
