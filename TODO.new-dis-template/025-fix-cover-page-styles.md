# TODO 025: Fix Cover Page Style Usage

## Status: WONTFIX

## What

The cover page uses styles (`zzCoverlarge`, `CoverTitleA1`, `CoverTitleA2`) that don't appear in the DIS template. The DIS template uses only `zzCover` for all cover page lines.

## Why

### Current (Broken)

```
zzCoverlarge  → "ISO/DIS 17301-1:2023"
zzCover       → "3rd edition"
zzCover       → (blank)
zzCover       → "Date: 2023-02-01"
CoverTitleA1  → "Cereals and pulses — Specifications and test methods"
CoverTitleA2  → "Part 1: Rice (DIS)"
zzCover       → (blank)
```

### Expected (DIS Template)

```
zzCover  → "ISO 99999:2022(E)"     (with stdpublisher/stddocNumber char styles)
zzCover  → "2022-03-03"
zzCover  → "ISO TC 999/WG 9"
zzCover  → "ACME"
zzCover  → "food location"
zzCover  → "Représentation standard de l'emplacement des aliments"
```

### Key Differences

1. **No `zzCoverlarge`** — the DIS template uses `zzCover` for the document identifier
2. **No `CoverTitleA1`/`CoverTitleA2`** — titles use `zzCover`
3. **Different content order** — DIS template: doc ID, date, committee, org, title-intro, title-complement
4. **Character styles** — DIS template uses `stdpublisher` for "ISO" and `stddocNumber` for the document number

### Note

The DIS template is a generic template with placeholder data. The actual content should come from the document model's bibdata. The key structural point is: all lines use `zzCover`, not specialized cover styles.

The `zzCoverlarge` and `CoverTitleA1`/`CoverTitleA2` styles DO exist in the template styles.xml, so they're available. The question is whether they should be used. The DIS template reference doesn't use them, but the rice document has different requirements.

### Recommendation

For now, keep using `zzCoverlarge`, `CoverTitleA1`, `CoverTitleA2` since they exist in the template. The content order and data extraction is more important than the exact style choice. This can be refined later by comparing with an actual ISO DIS document output (not the generic template).

## Files

- `lib/isodoc/iso/docx/adapter.rb` — cover page rendering

## Depends On

- None (low priority — style choice, not structural error)
