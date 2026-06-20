# 011 — Formula `<dl>` rendering (KeyTitle + KeyText)

## Problem

`adapter.rb:854 visit_definition_list` renders each `<dt>`/`<dd>` pair
as separate paragraphs with no style:

```ruby
def visit_definition_list(dl, doc)
  dt_items = dl.dt
  dd_items = dl.dd
  Array(dt_items).each_with_index do |dt, i|
    term_para = Uniword::Builder::ParagraphBuilder.new
    @inline_renderer.render(dt, term_para)
    doc << term_para

    dd = dd_items.is_a?(Array) ? dd_items[i] : dd_items
    walk_mixed_content(dd, doc) if dd
  end
end
```

DIS 15926 (Era C) defines **`KeyTitle`** and **`KeyText`** styles for
exactly this purpose — the "Key" list explaining symbols in a formula.
Pending task #49 has been on the list for weeks because no one wired
these styles.

## Approach

Replace the generic `visit_definition_list` with a context-aware
`DefinitionListRenderer` that picks the rendering pattern:

- **In formula context** (`@context.in_formula`):
  - Render `<dt>` as a paragraph with `KeyTitle` style.
  - Render `<dd>` as a paragraph with `KeyText` style.
  - Optionally: render as a 2-column borderless table for tighter layout
    (DIS template convention).
- **Outside formula context** (general definition list, e.g., terms):
  - Use the existing paragraph pattern, but apply `Definition` style to
    `<dd>` paragraphs (Era C `Definition` style).

### Context extension

Add `:in_formula` to `Context`:

```ruby
class Context
  def in_formula; @zone == :formula; end

  def with_formula
    prev = @zone
    @zone = :formula
    yield
  ensure
    @zone = prev
  end
end
```

`FormulaRenderer#render` calls `@context.with_formula` around its body,
so the inner `<dl>` knows it's a formula key list.

### New renderer

```ruby
module IsoDoc::Iso::Docx::Renderers
  class DefinitionListRenderer < Base
    def render(dl, doc)
      if @context.in_formula
        render_formula_key(dl, doc)
      else
        render_general(dl, doc)
      end
    end

    private

    def render_formula_key(dl, doc)
      # 2-column borderless table: Key | Definition
      # Or stacked KeyTitle + KeyText paragraphs per pair.
      Array(dl.dt).each_with_index do |dt, i|
        title = build_paragraph(style: @resolver.paragraph_style(:key_title))
        @inline_renderer.render(dt, title)
        doc << title

        dd = Array(dl.dd)[i]
        next unless dd
        text = build_paragraph(style: @resolver.paragraph_style(:key_text))
        @inline_renderer.render(dd, text)
        doc << text
      end
    end

    def render_general(dl, doc)
      Array(dl.dt).each_with_index do |dt, i|
        term = build_paragraph(style: @resolver.paragraph_style(:definition_term))
        @inline_renderer.render(dt, term)
        doc << term

        dd = Array(dl.dd)[i]
        next unless dd
        definition = build_paragraph(style: @resolver.paragraph_style(:definition))
        @inline_renderer.render(dd, definition)
        doc << definition
      end
    end
  end
end
```

### YAML additions

```yaml
# data/iso-dis/style_mapping.yml
paragraph_styles:
  key_title: KeyTitle
  key_text: KeyText
  definition: Definition
  definition_term: DefinitionTerm  # if DIS 15926 has it; else fall back to Definition
```

Verify DIS 15926 has these. `Definition` is universal across all 8 docs.
`KeyTitle` and `KeyText` are universal. `DefinitionTerm` — needs
verification; if absent, drop the key.

## Files affected

- Modify: `data/iso-dis/style_mapping.yml` — add `key_title`, `key_text`
- Modify: `lib/isodoc/iso/docx/context.rb` — add `in_formula`, `with_formula`
- Modify: `lib/isodoc/iso/docx/formula_renderer.rb` — wrap render in
  `with_formula`
- Create: `lib/isodoc/iso/docx/renderers/definition_list_renderer.rb`
  (or move logic if TODO 010 lands first)
- Modify: `lib/isodoc/iso/docx/adapter.rb` — replace `visit_definition_list`
  body with delegation

## Acceptance criteria

- Formula with `<dl>` key list produces output where each `<dt>` paragraph
  has `w:pStyle val="KeyTitle"` and each `<dd>` paragraph has
  `w:pStyle val="KeyText"`.
- General `<dl>` (not in formula) produces `Definition`-styled paragraphs.
- No fallback chains.
- Closes pending task #49.

## Required specs

- `formula_renderer_spec.rb`:
  - Formula with `<dl>` produces KeyTitle + KeyText paragraphs.
  - Spec builds a real Formula model instance with a real DefinitionList
    child, runs through FormulaRenderer, inspects output XML.
  - Asserts each `<w:p>` has the correct `<w:pStyle>`.
- `definition_list_renderer_spec.rb`:
  - Outside formula context, produces `Definition` paragraphs.
  - No use of `respond_to?`, `send`, `instance_variable_get`.
