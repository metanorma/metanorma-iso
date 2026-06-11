# 004 — Ordered list numbering types

## Problem
The rice XML has ordered lists with `type="alphabet"` (a, b, c) that should use
the `alpha_list` numbering definition (numId 6). Current code maps this correctly
via `numbering_for_type` but the numbering definitions from the template may not
be wired into the output.

## Fix
Ensure the template numbering.xml is preserved (it is via `copy_package_infrastructure`)
and that list items reference the correct numId from the style mapping.

## Files
- `lib/isodoc/iso/docx/adapter.rb` — verify numbering works
