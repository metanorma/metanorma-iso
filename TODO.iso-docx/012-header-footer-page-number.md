# 012 — Header/footer with page number

## Problem
The current `apply_header_footer` creates an empty paragraph with just alignment.
ISO documents need a page number field in the footer and optionally document
reference text in the header.

## Fix
Use Uniword builders to add a page number field to the footer paragraph.
The header gets right-aligned text (document reference) and the footer gets
centered page number.

## Files
- `lib/isodoc/iso/docx/adapter.rb` — `apply_header_footer`
