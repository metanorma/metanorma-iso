# 011 — Hyperlink character style

## Problem
External hyperlinks in the DOCX output have no w:rStyle. The ISO DIS template defines
a `Hyperlink` character style (mapped in style_mapping.yml as `hyperlink: Hyperlink`).
External link runs should use this character style so they render with the template's
link formatting (blue underline, etc.).

## Fix
In `render_link` in inline.rb, apply the `Hyperlink` character style to the runs
inside the hyperlink element.

## Files
- `lib/isodoc/iso/docx/inline.rb` — `render_link`
