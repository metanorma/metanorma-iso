# 013 — Figure extras rendering (description, note, subtitle)

## Problem

DIS 15926 (Era C) defines three figure-accessory styles —
`Figuredescription`, `Figurenote`, `Figuresubtitle` — universal across
all 8 reference docs. Currently unmapped and unused. The FigureRenderer
only emits the graphic and the title; notes/descriptions/subtitles are
dropped or rendered as plain body text.

## Approach

Extend `FigureRenderer` to walk the figure model's accessory attributes
and emit each as a typed paragraph.

### Model attributes (per `Metanorma::Document::Figure`)

Verify against the metanorma-document gem, but typically:
- `description` — `Figuredescription` style
- `notes` (array) — `Figurenote` style each
- `subtitle` (text or formatted text) — `Figuresubtitle` style

```ruby
class FigureRenderer < Base
  def render(figure, doc)
    render_graphic(figure, doc)
    render_subtitle(figure, doc)
    render_title(figure, doc)
    render_description(figure, doc)
    render_notes(figure, doc)
  end

  private

  def render_subtitle(figure, doc)
    subtitle = figure.fmt_subtitle || figure.subtitle
    return unless subtitle
    para = build_paragraph(style: @resolver.paragraph_style(:figure_subtitle))
    @inline_renderer.render(subtitle, para)
    doc << para
  end

  def render_description(figure, doc)
    description = figure.description
    return unless description
    para = build_paragraph(style: @resolver.paragraph_style(:figure_description))
    @inline_renderer.render(description, para)
    doc << para
  end

  def render_notes(figure, doc)
    Array(figure.notes).each do |note|
      para = build_paragraph(style: @resolver.paragraph_style(:figure_note))
      @inline_renderer.render(note, para)
      doc << para
    end
  end
end
```

### YAML

```yaml
figure_subtitle: Figuresubtitle
figure_description: Figuredescription
figure_note: Figurenote
```

## Files affected

- Modify: `data/iso-dis/style_mapping.yml`
- Modify: `lib/isodoc/iso/docx/renderers/figure_renderer.rb` (after
  TODO 010) or `lib/isodoc/iso/docx/adapter.rb` `visit_figure`
  (if 010 not yet landed)

## Acceptance criteria

- A figure with description, subtitle, and 2 notes produces 5 paragraphs
  in this order: graphic, subtitle, title, description, note1, note2.
- Each accessory paragraph has the correct `<w:pStyle>`.
- No use of `respond_to?` — use `figure.class.attributes.key?(:notes)`
  pattern if attribute existence is uncertain.

## Required specs

- `figure_renderer_spec.rb`:
  - Figure with all accessories → 5 paragraphs in order with correct styles.
  - Figure with no accessories → only graphic + title.
  - Real `Metanorma::Document::Figure` instance built via parsing a
    minimal XML snippet.
