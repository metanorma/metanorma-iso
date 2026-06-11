# TODO 043: Fix Duplicate Footnotes — Same Content Gets Different Numbers

## Status: DONE

## What

Footnotes 4-10 all contain the same text ("The maximum permissible mass fraction of defects shall be determined with respect to...") but get separate footnote numbers. The reference output deduplicates these by using a single footnote number.

## Why

### Current (Broken)

```
fn 4: The maximum permissible mass fraction of defects...
fn 5: The maximum permissible mass fraction of defects...
fn 6: The maximum permissible mass fraction of defects...
fn 7: The maximum permissible mass fraction of defects...
fn 8: The maximum permissible mass fraction of defects...
fn 9: The maximum permissible mass fraction of defects...
fn 10: The maximum permissible mass fraction of defects...
```

Each table cell that references this footnote gets its own footnote number, even though the content is identical.

### Expected

The same footnote should be reused across cells, using a single footnote number.

## Architecture

Before creating a new footnote, check if a footnote with the same content already exists. If so, reuse the existing footnote ID. This requires a footnote content → ID mapping.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — footnote creation

## Depends On

- None
