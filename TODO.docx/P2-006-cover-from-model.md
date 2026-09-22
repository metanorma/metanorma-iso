---
title: 108-015 - Fix cover page rendering from model
priority: P0
status: open
depends_on: [108-001]
---

# 108-015: Render Cover Page from Model (Not Template)

## Problem

The cover page content (doc number, title, TC/SC, edition, date, stage, warning) is currently rendered from the template DOCX content. This means:
1. The cover page still has ISO 15926 content (from the DIS template)
2. The adapter clears template paragraphs but cover content persists somehow
3. The model has all the data needed (bibdata) but the adapter doesn't render it

## What the Model Provides

From `model.bibdata`:
- `docidentifier` → "ISO/CD 17301-1:2016"
- `docnumber` → "17301"
- `title` → "Cereals and pulses — Specifications and test methods — Part 1"
- `contributor` → TC/SC/WG information
- `edition` → "2"
- `date` → "2016-05-01"
- `status/stage` → "CD"

## What the Cover Page Needs

Per the reference DOCX structure:
```
Para 0: [zzCover] "17301"
Para 1: [zzCover] "ISO/CD 17301-1 (draft 2016-05-01)"
Para 2: [zzCover] "TC 34/SC 4/WG 3"
Para 3: [zzCover] "Second edition"
Para 4: [zzCover] ""
Para 5: [zzCover] "Date: 2016-05-01"
Para 6: [CoverTitleA1] "Cereals and pulses — Specifications and test methods — Part 1"
Para 7: [zzCover] ""
Para 8: [zzCover] "CD stage"
```

Then from boilerplate:
```
Para 9: [zzwarninghdr] "Warning for WDs and CDs"
Para 10: [zzWarning] "This document is not an ISO International Standard..."
Para 11: [zzWarning] "Recipients of this draft are invited to submit..."
```

## Fix

Add a `visit_cover_page` method that:
1. Renders doc number paragraph
2. Renders doc identifier paragraph
3. Renders TC/SC/WG paragraph
4. Renders edition paragraph
5. Renders date paragraph
6. Renders main title paragraph
7. Renders stage paragraph

This needs the model's bibdata to provide all the metadata.

## Model Access

```ruby
def visit_cover_page(model, doc)
  bib = model.bibdata
  return unless bib

  render_cover_line(doc, bib.docnumber)           # "17301"
  render_cover_line(doc, format_doc_id(bib))       # "ISO/CD 17301-1 (draft 2016-05-01)"
  render_cover_line(doc, format_tc_sc(bib))        # "TC 34/SC 4/WG 3"
  render_cover_line(doc, format_edition(bib))      # "Second edition"
  render_cover_line(doc, "")                        # blank
  render_cover_line(doc, "Date: #{format_date(bib)}") # "Date: 2016-05-01"
  render_cover_title(doc, format_title(bib))       # Main title with CoverTitleA1 style
  render_cover_line(doc, "")                        # blank
  render_cover_line(doc, format_stage(bib))        # "CD stage"
end
```

## Files to Change

- `lib/isodoc/iso/docx/adapter.rb` — add visit_cover_page
