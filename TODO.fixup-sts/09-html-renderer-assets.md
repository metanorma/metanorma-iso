# 09 — HTML renderer assets (theme.css, page.js, brand icons)

## Why
The page needs CSS for the layout primitives and JS for the TOC scroll-spy,
theme toggle, and back-to-top. Port OIML's assets and rebrand to ISO.

## Plan
1. **`page.js`** — verbatim from OIML. It is organization-agnostic
   (selectors are by id, not class).
2. **`theme.css`** — port and rebrand:
   - Rename `--color-oiml-blue` → `--color-iso-blue` (`#0061B0`).
   - Drop `--color-oiml-warm` or replace with `--color-iso-red`
     (`#E4002B` — ISO's brand red).
   - Update the `--font-body` fallback chain (keep Helvetica Neue / Segoe UI).
   - Otherwise verbatim (utilities, layout primitives, dark mode).
3. **ISO logo** — use a CSS-only wordmark `<span class="brand-wordmark">ISO</span>`
   styled in `theme.css` (rounded blue badge with "ISO" in white). Skip
   shipping the official ISO logo SVG (licensing).
4. **Metanorma icons** — copy `metanorma-icon-light.svg` and
   `metanorma-icon-dark.svg` from OIML (they are the shared Metanorma
   "aequitate verum" mark, not OIML-specific).

## File list
```
lib/metanorma/iso/sts/html_renderer/assets/
├── theme.css
├── page.js
├── metanorma-icon-light.svg
└── metanorma-icon-dark.svg
```

## Acceptance
- All 4 asset files exist.
- `grep -i "oiml" lib/metanorma/iso/sts/html_renderer/assets/` returns nothing.
- Rendered HTML's `<style>` block is well-formed CSS (no Liquid artifacts).
- Rendered page renders in a browser (visual verification in TODO #13).
