# TODO 035: Render variant-title-toc for Annexes

## Status: DONE

## What

The repaired output includes `variant-title-toc` paragraphs after each ANNEX paragraph. These are TOC variant titles without the obligation marker. Our adapter doesn't render these.

## Why

### Current (Latest Output)

```
ANNEX: (normative)Determination of defects
a2: Principle
```

### Expected (Repaired Output)

```
ANNEX: Annex A(normative)Determination of defects
variant-title-toc: Annex ADetermination of defects
a2: A.1Principle
```

The `variant-title-toc` paragraph contains the annex letter and title without the obligation in parentheses. The repaired output has 5 such paragraphs (one per annex).

### Analysis

This is likely the `<variant-title>` element from the model, which provides an alternate title format for TOC display. The old rendering pipeline included these; our adapter skips them.

## Architecture

After rendering each ANNEX paragraph, check if the annex has a `variant_title` and render it with `variant-title-toc` style.

## Files

- `lib/isodoc/iso/docx/adapter.rb` — `render_annex_title` or `visit_annex`
- `data/iso-dis/style_mapping.yml` — add variant_title_toc mapping

## Depends On

- None (low priority — cosmetic)
