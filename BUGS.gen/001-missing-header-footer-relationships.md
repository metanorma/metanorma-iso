---
title: BUG 001 - Header/footer rIds missing from document.xml.rels
priority: P0
status: closed
---

# BUG 001: Header/Footer rIds Missing from document.xml.rels

## Symptom

Word reports "unreadable content" and offers to repair. After repair, all section
headers and footers are missing.

## Root Cause

The `word/_rels/document.xml.rels` part contains no relationships for header
or footer parts. The sectPr elements in `word/document.xml` reference:

```
headerReference r:id="rId16"  (front matter even)
headerReference r:id="rId17"  (front matter default)
footerReference r:id="rId18"  (front matter even)
footerReference r:id="rId19"  (front matter default)
headerReference r:id="rId25"  (body even)
headerReference r:id="rId26"  (body default)
footerReference r:id="rId27"  (body even)
footerReference r:id="rId28"  (body default)
```

But the actual rels file only has rId1-rId15, rId20-rId24, rId29-rId39
(hyperlinks, images, footnotes, endnotes, customXml, styles, settings,
webSettings, fontTable, theme, numbering).

rId16-rId19 and rId25-rId28 are NOT defined anywhere.

## Evidence

```bash
$ grep -o 'Relationship Id="[^"]*"' word/_rels/document.xml.rels | sort -V
rId1 rId2 rId3 rId4 rId5 rId6 rId7 rId8 rId9 rId10
rId11-rId15 (hyperlinks)
rId20-rId24 (hyperlinks, images)
rId29-rId39 (more)

# Missing: rId16, rId17, rId18, rId19, rId25, rId26, rId27, rId28
```

## Source of Bug

`lib/isodoc/iso/docx/section_manager.rb` hardcodes these rIds:

```ruby
FRONT_HEADER_EVEN = "rId16"
FRONT_HEADER_DEFAULT = "rId17"
FRONT_FOOTER_EVEN = "rId18"
FRONT_FOOTER_DEFAULT = "rId19"
BODY_HEADER_EVEN = "rId25"
BODY_HEADER_DEFAULT = "rId26"
BODY_FOOTER_EVEN = "rId27"
BODY_FOOTER_DEFAULT = "rId28"
```

These rIds come from the **template's** document.xml.rels. When the adapter
clears the body content but preserves the sectPr, it should also preserve
the relationships that the template's sectPr references.

The current package writer is not emitting these 8 relationship entries
into the output document.xml.rels.

## Fix

The DOCX package writer must emit `Relationship` entries for every
header/footer part it writes. Specifically:

- Type: `.../relationships/header` and `.../relationships/footer`
- Target: `header1.xml`, `header2.xml`, ... `footer1.xml`, ...
- Id: must match what `headerReference/@r:id` and `footerReference/@r:id`
  reference in the sectPr.

Either:
1. Use `Uniword::Docx::IdAllocator` to allocate fresh rIds for the 8
   header/footer parts and rewrite the sectPr references to match.
2. Or, ensure the package writer copies the 8 rId entries from the
   template's rels into the output rels.

## Files to Change

- `lib/isodoc/iso/docx/section_manager.rb` — use allocator-driven rIds
- `lib/isodoc/iso/docx/adapter.rb` — ensure DocumentBuilder receives the
  header/footer parts and their relationships are written
- Possibly `lib/isodoc/iso/docx/zip_packager.rb` or wherever the rels
  part is written
