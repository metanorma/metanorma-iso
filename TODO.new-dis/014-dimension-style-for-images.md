# 014 — Dimension styles for images

## Problem

DIS 15926 (Era C) defines **`Dimension50`**, **`Dimension75`**,
**`Dimension100`** as universal styles for controlling image cell width
(50%, 75%, 100% of available width). Currently images are rendered with
explicit EMU widths, ignoring the template's preferred sizing convention.

## Approach

`FigureRenderer` (or a new `ImageRenderer` extracted from it) applies a
`Dimension*` style when the figure's image is the only content and its
declared width matches one of the three breakpoints.

### Sizing rules

| Image width (as % of page body) | Style applied |
|----------------------------------|---------------|
| ≥ 90%                            | `Dimension100` |
| 60% – 89%                        | `Dimension75` |
| ≤ 59%                            | `Dimension50` |

### Implementation

```ruby
class FigureRenderer < Base
  def render_graphic(figure, doc)
    image = figure.image
    return unless image

    para = build_paragraph(style: dimension_style_for(image))
    add_image_to_paragraph(image, para)
    doc << para
  end

  private

  def dimension_style_for(image)
    pct = image_width_percentage(image)
    key = case
          when pct >= 90 then :dimension_100
          when pct >= 60 then :dimension_75
          else                :dimension_50
          end
    @resolver.paragraph_style(key)
  end

  def image_width_percentage(image)
    return 100 unless image.width && @context.body_width
    (image.width.to_f / @context.body_width * 100).round
  end
end
```

### YAML

```yaml
dimension_50: Dimension50
dimension_75: Dimension75
dimension_100: Dimension100
```

### Context extension

`Context` exposes `body_width` (in EMU or twips, TBD based on section
properties) so renderers can compute percentage. This belongs on the
section manager, not as an ivar on adapter.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml`
- Modify: `lib/isodoc/iso/docx/renderers/figure_renderer.rb`
- Modify: `lib/isodoc/iso/docx/context.rb` — add `body_width` (delegated
  to `SectionManager`)

## Acceptance criteria

- Full-width image (≥90%) → paragraph has `Dimension100`.
- Medium image (60-89%) → paragraph has `Dimension75`.
- Small image (≤59%) → paragraph has `Dimension50`.
- Image with no explicit width defaults to `Dimension100`.

## Required specs

- `figure_renderer_spec.rb`:
  - Three image-width fixtures produce correct Dimension* styles.
  - Real `Metanorma::Document::Figure` with `image` attribute set.
