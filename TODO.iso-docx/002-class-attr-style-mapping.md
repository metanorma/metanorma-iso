# 002 — class attr style mapping for special paragraphs

## Problem
Some `<p>` elements have explicit `class` attributes that map directly to styles:
- `class="zzSTDTitle1"` → `zzSTDTitle` style
- `class="boldtitle"` → bold run formatting
- `class="nonboldtitle"` → regular run formatting
- `class="date"` → date style

Currently `resolve_paragraph_style` does `@resolver.paragraph_style(cls.to_sym)`
but the mapping doesn't have `zzSTDTitle1` (it has `zzSTDTitle`).

## Fix
Add fallback: if exact class key not found, try normalizing (strip trailing digits,
handle known aliases). Map known classes:
- `zzSTDTitle1` → `zzSTDTitle`
- `boldtitle` / `nonboldtitle` → handled by run formatting, not paragraph style
- `date` → body text style

## Files
- `lib/isodoc/iso/docx/style_resolver.rb` — normalize class keys
- `data/iso-dis/style_mapping.yml` — add aliases if needed
