# TODO 013: Render Note/Example fmt_name Labels

## Status: COMPLETED

- Added `FmtNameElement` to inline renderer dispatch (render_mixed_inline_fallback)
- Term notes now render "Note N to entry: " prefix from fmt_name
- Term examples now render "EXAMPLE" label inline with content
- Admonitions now render "CAUTION —" / "WARNING —" prefix from fmt_name
- All handled by the single FmtNameElement addition to the case statement
