# 021 — Fix references section heading depth

## Status: FIXED

`visit_references_section` now uses `@context.section_depth + 1` to determine
the heading level, matching the behavior of `visit_clause`.

## Fix
`lib/isodoc/iso/docx/adapter.rb` line 273: replaced hardcoded `heading_style(2)`
with `heading_style([depth, 6].min)` where depth = section_depth + 1.
