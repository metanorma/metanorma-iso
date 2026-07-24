# 08 — HTML renderer templates

## Why
The renderer emits HTML through small Liquid templates so markup lives in
files designers can edit, not in Ruby string concatenation. Port OIML's
template set verbatim (the markup is organization-agnostic — it implements
`<{{ tag }} id=... class=...>{{ content }}</{{ tag }}>` etc.).

## Plan
1. Create `lib/metanorma/iso/sts/html_renderer/templates/` with:
   - `document.html.liquid` — outer page shell. Change OIML's `www.oiml.org`
     links to `www.iso.org`. Otherwise verbatim.
   - `_element.html.liquid` — verbatim.
   - `_hero.html.liquid` — verbatim.
   - `_footer.html.liquid` — change OIML contact info to ISO
     (`copyright@iso.org`, `www.iso.org`). Footer version reads
     `metanorma-iso` instead of `metanorma-oiml`.
   - `_link.html.liquid` — verbatim.
   - `_meta_header.html.liquid` — verbatim.
   - `_img.html.liquid` — verbatim.
2. The `TEMPLATES_DIR` constant in `ruby.rb` points at this directory.

## Acceptance
- All 7 templates exist.
- No OIML-specific strings leak into the rendered HTML (grep for `oiml`,
  `OIML`, `Bureau International de Métrologie Légale`).
- Liquid includes resolve correctly (the renderer's `LocalFileSystem`
  pattern means `{% include '_element.html.liquid' %}` works).
