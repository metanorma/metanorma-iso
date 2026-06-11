# TODO 005: Add Front Matter (Cover, Warning, Copyright, TOC)

## Status: COMPLETE

Front matter rendering implemented:
- `render_cover` — doc identifier, date, title, committee from bibdata
- `render_warning` — CD-stage warning from boilerplate license-statement
- `render_copyright` — copyright notice from boilerplate copyright-statement
- `render_toc` — Contents heading + TOC field from preface TOC clause
- `toc_clause?` — identifies TOC clauses in preface (skipped from regular clause rendering)
- Front matter styles added to `data/iso-dis/style_mapping.yml`
- `SimpleField` support added to `ParagraphBuilder` in uniword

## Files
- `lib/isodoc/iso/docx/adapter.rb` — front matter visitors and helpers
- `data/iso-dis/style_mapping.yml` — front matter style mappings
- `spec/isodoc/docx/adapter_spec.rb` — 5 front matter specs
