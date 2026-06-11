# TODO 026: Fix Page Margins and Section Properties

## Status: DONE

## What

The adapter generates page margins and section properties that differ from the DIS template. The differences affect page layout and header/footer positioning.

## Why

### Current vs Expected Margins

| Property | Broken (adapter) | DIS Template | Difference |
|----------|-----------------|--------------|------------|
| top | 794 | 794 | Same |
| bottom | 567 | 284 | **283 twips lower** |
| left | 851 | 851 | Same |
| right | 851 | 737 | **114 twips wider** |
| header | 720 | 709 | 11 twips |
| footer | 720 | 0 | **720 twips lower** |
| gutter | 0 | 567 | **567 twips missing** |

### Missing Properties

1. `w:code="9"` on `pgSz` — paper code for A4
2. `<w:type w:val="oddPage"/>` — odd-page section type
3. `<w:cols w:space="720"/>` — column spacing (missing from cover sectPr)
4. `<w:docGrid w:linePitch="299"/>` — document grid (missing from cover sectPr)
5. `<w:titlePg/>` — missing from body (final) sectPr

### Impact

- **Bottom margin 567 vs 284**: Content sits higher on the page in the template; more bottom space in adapter output
- **Right margin 851 vs 737**: Template has narrower right margin (more content width)
- **Footer 720 vs 0**: Template has no footer distance; adapter has a large footer gap
- **Gutter 0 vs 567**: Template has a gutter margin for binding; adapter doesn't

## Architecture

Update `insert_section_break` to use the correct page margins and properties from the template. Ideally, read these from the template's sectPr rather than hardcoding values.

### Recommended Approach

Extract the three section properties from the template DOCX at initialization and use them directly. This ensures the output matches the template's page layout without hardcoding specific values.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `insert_section_break` method

## Depends On

- TODO 014 (header/footer rIds — both affect sectPr)
