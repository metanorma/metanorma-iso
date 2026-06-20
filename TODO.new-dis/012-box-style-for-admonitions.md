# 012 — Box-* wrapper for notes, examples, admonitions

## Problem

Era C template defines **`Box-begin`**, **`Box-end`**, and **`Box-title`**
styles specifically for wrapping notes/examples/warnings as a visual box.
Currently the adapter emits each note/example/warning as a single
paragraph with `Note`/`Example`/`Warningtext` style — but those styleIds
don't exist in Era C. The visual result is wrong (Word either ignores
them or renders as plain body text).

`Notecontinued`, `Noteindent`, `Examplecontinued`, `Exampleindent*` are
universal Typefi styles used for the **body** of multi-paragraph notes
and examples inside the Box-* wrapper.

## Approach

`AdmonitionRenderer`, `NoteRenderer`, `ExampleRenderer` share a common
"box wrapper" pattern. Extract into a shared helper:

```ruby
module IsoDoc::Iso::Docx::Renderers
  module BoxWrapper
    def with_box(title: nil, doc:)
      doc << box_paragraph(:box_begin)
      if title
        title_para = build_paragraph(style: @resolver.paragraph_style(:box_title))
        @inline_renderer.render(title, title_para)
        doc << title_para
      end
      yield
      doc << box_paragraph(:box_end)
    end

    private

    def box_paragraph(key)
      Uniword::Builder::ParagraphBuilder.new.tap do |p|
        p.style = @resolver.paragraph_style(key)
      end
    end
  end
end
```

### NoteRenderer

```ruby
class NoteRenderer < Base
  include BoxWrapper

  def render(note, doc)
    @context.with_note do
      with_box(doc: doc) do
        render_note_label(note, doc)
        render_note_body(note, doc)
      end
    end
  end

  private

  def render_note_body(note, doc)
    paragraphs = Array(note.paragraphs)
    paragraphs.each_with_index do |p, i|
      style = i.zero? ? :note_first : :note_continued
      para = build_paragraph(style: @resolver.paragraph_style(style))
      @inline_renderer.render(p, para)
      doc << para
    end
  end
end
```

YAML:
```yaml
box_begin: Box-begin
box_end: Box-end
box_title: Box-title
note_first: Noteindent
note_continued: Noteindentcontinued
example_first: Exampleindent
example_continued: Exampleindentcontinued
```

### AdmonitionRenderer

Warnings (type="warning" | "caution" | "danger") use the same box
pattern but with `Warningtitle` + `Warningtext` for the body inside
the box:

```ruby
class AdmonitionRenderer < Base
  include BoxWrapper

  def render(admonition, doc)
    with_box(title: admonition.fmt_title, doc: doc) do
      Array(admonition.paragraphs).each do |p|
        para = build_paragraph(style: @resolver.paragraph_style(:admonition))
        @inline_renderer.render(p, para)
        doc << para
      end
    end
  end
end
```

YAML `admonition: Warningtext`, `admonition_title: Warningtitle` are
already correct for Era C.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml` — add `box_begin`, `box_end`,
  `box_title`, `note_first`, `note_continued`, `example_first`,
  `example_continued`
- Create: `lib/isodoc/iso/docx/renderers/box_wrapper.rb` (module mixed
  into Note/Example/Admonition renderers)
- Modify: `NoteRenderer`, `ExampleRenderer`, `AdmonitionRenderer`
  (after TODO 010 extracts them)

## Acceptance criteria

- A note in the rendered DOCX is wrapped by `Box-begin` and `Box-end`
  paragraphs.
- Multi-paragraph note: first paragraph is `Noteindent`, subsequent
  paragraphs are `Noteindentcontinued`.
- Warnings include `Warningtitle` for the title and `Warningtext` for body.
- No fallback chains.

## Required specs

- `note_renderer_spec.rb`:
  - Single-paragraph note → Box-begin + Noteindent + Box-end.
  - Multi-paragraph note → Box-begin + Noteindent + Noteindentcontinued
    + Box-end.
  - Real `Metanorma::Document::Note` instance with paragraphs.
- `example_renderer_spec.rb`:
  - Same pattern with Exampleindent / Exampleindentcontinued.
- `admonition_renderer_spec.rb`:
  - Warning admonition → Box-begin + Warningtitle + Warningtext + Box-end.
