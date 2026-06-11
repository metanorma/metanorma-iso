# TODO 055: Fix Bibliography Entry Style — Use (none) Not BiblioEntry

## Status: TODO

## What

Bibliography entries use `BiblioEntry` style instead of `(none)` style (Normal). The reference uses no explicit style for bibliography entries.

## Why

### Reference (rice.docx)
```
 331: BiblioTitle  | Bibliography
 332: (none)       | [1][TAB]ISO 2146:1988[FN7]) , Documentation...
 333: (none)       | [2][TAB]ISO 3696:1987, Water for analytical...
```

### Our Output
```
 276: BiblioTitle  | Bibliography
 277: BiblioEntry  | [1][FN1][BR][TAB]ISO 2146:1988, Documentation...
 278: BiblioEntry  | [2][TAB]ISO 3696:1987, Water for analytical...
```

### Key Issues
1. **Style**: `BiblioEntry` vs `(none)` — reference uses Normal (no explicit style)
2. **Footnote format**: Our output has `[FN1][BR]` where reference has `[FN7]) ` — the footnote is duplicated (FN1 already used in normative refs) and has a `[BR]` before the tab
3. **Missing footnote text**: Reference has `) ` after footnote (closing paren from `citeas`), our output doesn't

## Architecture

For the style issue, either:
- Change `bib_item_style` to return nil when `@context.in_bibliography` is true (not `@context.in_normative`)
- Or accept `BiblioEntry` as an improvement over the reference and move on

The more important issue is the footnote handling in bibliography entries (covered in TODO 050).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `bib_item_style`
- `data/iso-dis/style_mapping.yml` — `biblio_entry` mapping

## Depends On

- TODO 050 (footnote dedup scope)
