# TODO 006: Render Dual Annex Titles

## Status: COMPLETED

- `render_annex_title` now renders both ANNEX title and variant-title-toc paragraph
- Added `variant_title_toc` style mapping to `style_mapping.yml`
- Added `variant-title-toc` style injection via `ensure_adapter_styles` to prevent reconciler stripping
- All 5 annexes have dual title paragraphs matching original DOCX
