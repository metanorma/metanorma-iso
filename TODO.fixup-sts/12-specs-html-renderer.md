# 12 — Specs for the HTML renderer dispatch

## Why
The renderer's dispatch table is the contract between sts-ruby types and
HTML output. It needs coverage so a missing handler surfaces as a test
failure rather than as silently dropped content.

## Plan
1. Create `spec/sts/html_renderer_spec.rb`.
2. Build small `Sts::IsoSts::*` model fragments and assert on the rendered
   HTML. Examples:
   - `Paragraph` → `<p ...>...</p>`.
   - `Sec` with `Title` + nested `Paragraph` →
     `<section id="..."><h2>...<a class="h-anchor"...>§</a></h2><p>...</p></section>`.
   - `List` (bullet) → `<ul>...<li>...</li></ul>`; ordered → `<ol>`.
   - `TableWrap` with caption + `Table` → caption band + `<table>`.
   - `Figure` with `Graphic` → `<figure><img .../></figure>`.
   - `NonNormativeNote` → `<div class="note"><p><span class="note-label">NOTE</span> ...</p></div>`.
   - `IsoMeta` with `TitleWrap(main:)` → no output when `full_document: true`
     (meta is consumed by the hero / footer); when `full_document: false`
     the `_meta_header.html.liquid` is emitted.
   - `Xref` → `<a href="#rid">...</a>`.
   - `ExtLink` → `<a href="...">...</a>`.
   - `Fn` inside `Paragraph` → `<sup class="fn-label">N</sup>` and a
     deferred `<p class="footnote">` at end of document.
3. No doubles — use real `Sts::IsoSts::*` instances.

## Acceptance
- `bundle exec rspec spec/sts/html_renderer_spec.rb` is green.
- At least one example per DISPATCH entry.
