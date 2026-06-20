# 015 — Disp-quotep for block quotes

## Problem

`adapter.rb:875 visit_quote` renders a blockquote as an indented
paragraph using `:quote` style. Current YAML maps `quote: Disp-quotep`,
which is correct for Era C — but the adapter also calls `para.indent`,
which double-applies indentation on top of the style's own indent.

## Approach

Drop the manual `para.indent`. Let the style do its job. If the style
doesn't indent enough, that's a YAML defect (update `Disp-quotep`'s
paragraph_properties in `styles.yml`), not an adapter concern.

```ruby
class QuoteRenderer < Base
  def render(quote, doc)
    para = build_paragraph(style: @resolver.paragraph_style(:quote))
    @inline_renderer.render(quote, para)
    doc << para
  end
end
```

Disp-quote often has attribution (`<cite>` element). Check the model
for `quote.attributor` or similar attribute and render as a separate
paragraph if present.

```ruby
def render(quote, doc)
  body = build_paragraph(style: @resolver.paragraph_style(:quote))
  @inline_renderer.render(quote, body)
  doc << body

  return unless quote_has_attributor?(quote)
  attr = build_paragraph(style: @resolver.paragraph_style(:quote_attributor))
  @inline_renderer.render(quote.attributor, attr)
  doc << attr
end
```

### YAML

DIS 15926 Era C does not have a separate `Disp-quoteattrib` style
(attribution). The audit shows `Disp-quotep` is the only one. Render
the attributor inside the same `Disp-quotep` paragraph (typically
prefixed with `— ` em-dash).

## Files affected

- Modify: `lib/isodoc/iso/docx/renderers/quote_renderer.rb` (after 010)
  or `adapter.rb:875`
- Modify: `data/iso-dis/style_mapping.yml` (unchanged, `quote` key
  already maps to `Disp-quotep`)

## Acceptance criteria

- Block quote renders as a single `Disp-quotep` paragraph.
- No manual `para.indent` call — style handles indentation.
- Attribution (if present) renders as second `Disp-quotep` paragraph
  prefixed with em-dash.

## Required specs

- `quote_renderer_spec.rb`:
  - Simple blockquote → one `Disp-quotep` paragraph.
  - Blockquote with attribution → two paragraphs.
  - Real `Metanorma::Document::Quote` instance.
