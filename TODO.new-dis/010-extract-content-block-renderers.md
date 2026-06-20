# 010 — Extract per-content-type Renderers

## Problem

`adapter.rb` is **1233 lines** and handles every content type inline
(clauses, terms, bibliographies, tables, figures, formulas, notes,
examples, admonitions, sourcecode, quotes, definition lists, lists,
paragraphs, images). This violates:

- **MECE**: One class holds many concerns.
- **OCP**: Adding a new content type means editing the adapter.
- **SRP**: The adapter is orchestrator + renderer.
- **Specs**: Each concern can't be tested in isolation without
  constructing the whole adapter.

## Approach

Extract per-content-type renderer classes. The adapter becomes a thin
orchestrator that:
1. Walks the model.
2. For each node, hands it to the appropriate renderer.

### Renderer class contract

Each renderer follows the same shape:

```ruby
module IsoDoc::Iso::Docx
  class NoteRenderer
    def initialize(resolver, context, inline_renderer)
      @resolver = resolver
      @context = context
      @inline_renderer = inline_renderer
    end

    def render(note, doc)
      @context.with_note do
        with_bookmark(note) do
          render_note_title(note, doc)
          render_note_body(note, doc)
        end
      end
    end

    private

    def render_note_title(note, doc); end
    def render_note_body(note, doc); end
    def with_bookmark(note, &blk); end
  end
end
```

### Renderers to extract

| Renderer class | Responsibility | Lines moved (approx) |
|----------------|----------------|----------------------|
| `ClauseRenderer` | `visit_clause`, `visit_annex`, `visit_terms_section`, `visit_definitions`, `visit_references_section` | 120 |
| `TermRenderer` | `visit_term`, `render_term_designation_list`, `render_term_definitions`, `render_term_notes`, `render_term_examples` | 100 |
| `BibliographyRenderer` | `visit_bibliography`, `visit_bibliographic_item`, `bib_item_style`, `with_bibitem_bookmark`, `render_bib_item_content`, `render_formatted_ref` | 60 |
| `NoteRenderer` | `visit_note` body-level + table-cell variants | 40 |
| `ExampleRenderer` | `visit_example` body-level + table-cell variants | 40 |
| `AdmonitionRenderer` | `visit_admonition`, `Box-begin/end/title` wrapping | 40 |
| `FigureRenderer` | `visit_figure`, image rendering, `Figuredescription/Figurenote/Figuresubtitle` | 100 |
| `TableRenderer` | `visit_table`, cell rendering, table notes/examples | 120 |
| `FormulaRenderer` (already exists) | Extend with `<dl>` rendering using `KeyTitle/KeyText` | +30 |
| `SourcecodeRenderer` (already exists) | Unchanged | — |
| `QuoteRenderer` | `visit_quote` | 15 |
| `DefinitionListRenderer` | `visit_definition_list` (formula context vs general) | 30 |
| `ListRenderer` | `visit_unordered_list`, `visit_ordered_list`, nested handling | 80 |
| `ParagraphRenderer` | `visit_paragraph`, `resolve_paragraph_style`, class-based style dispatch | 60 |
| `HeaderFooterRenderer` | header/footer content (currently no dedicated class) | NEW |

### Where do they live?

Each renderer is a separate file under `lib/isodoc/iso/docx/renderers/`,
autoloaded from a new module declared in `lib/isodoc/iso/docx.rb`:

```ruby
module IsoDoc::Iso::Docx
  module Renderers
    autoload :ClauseRenderer,        "isodoc/iso/docx/renderers/clause_renderer"
    autoload :TermRenderer,          "isodoc/iso/docx/renderers/term_renderer"
    autoload :BibliographyRenderer,  "isodoc/iso/docx/renderers/bibliography_renderer"
    autoload :NoteRenderer,          "isodoc/iso/docx/renderers/note_renderer"
    autoload :ExampleRenderer,       "isodoc/iso/docx/renderers/example_renderer"
    autoload :AdmonitionRenderer,    "isodoc/iso/docx/renderers/admonition_renderer"
    autoload :FigureRenderer,        "isodoc/iso/docx/renderers/figure_renderer"
    autoload :TableRenderer,         "isodoc/iso/docx/renderers/table_renderer"
    autoload :QuoteRenderer,         "isodoc/iso/docx/renderers/quote_renderer"
    autoload :DefinitionListRenderer,"isodoc/iso/docx/renderers/definition_list_renderer"
    autoload :ListRenderer,          "isodoc/iso/docx/renderers/list_renderer"
    autoload :ParagraphRenderer,     "isodoc/iso/docx/renderers/paragraph_renderer"
    autoload :HeaderFooterRenderer,  "isodoc/iso/docx/renderers/header_footer_renderer"
  end
end
```

The adapter holds a `Renderers` registry object:

```ruby
class Adapter
  def initialize(model, context)
    @renderers = Renderers::Registry.new(@resolver, @context, @inline_renderer)
  end

  def visit_block(node, doc)
    @renderers.dispatch(node, doc)
  end
end
```

### `Renderers::Registry` — single dispatch point

```ruby
module IsoDoc::Iso::Docx::Renderers
  class Registry
    def initialize(resolver, context, inline_renderer)
      @resolver, @context, @inline_renderer = resolver, context, inline_renderer
      build_registry
    end

    def dispatch(node, doc)
      renderer = @table[node.class] or return nil
      renderer.render(node, doc)
    end

    private

    def build_registry
      @table = {
        Metanorma::Document::Clause            => ClauseRenderer.new(*deps),
        Metanorma::Document::Annex             => ClauseRenderer.new(*deps),
        Metanorma::Document::Term              => TermRenderer.new(*deps),
        Metanorma::Document::BibliographicItem => BibliographyRenderer.new(*deps),
        Metanorma::Document::Note              => NoteRenderer.new(*deps),
        Metanorma::Document::Example           => ExampleRenderer.new(*deps),
        Metanorma::Document::Admonition        => AdmonitionRenderer.new(*deps),
        Metanorma::Document::Figure            => FigureRenderer.new(*deps),
        Metanorma::Document::Table             => TableRenderer.new(*deps),
        # ... etc
      }
    end

    def deps; [@resolver, @context, @inline_renderer]; end
  end
end
```

This subsumes TODO 009's `VISITOR_TABLE` — the registry IS the table,
but it maps classes to renderer objects instead of method names.

## Migration strategy

Do not extract all renderers in one commit. Each renderer is a
standalone PR:

1. PR-A: Create `Renderers::Registry`, extract `NoteRenderer` first
   (smallest unit). Verify specs pass.
2. PR-B: Extract `ExampleRenderer`, `AdmonitionRenderer` together (they
   share the Box-* wrapping pattern).
3. PR-C: Extract `BibliographyRenderer`, `TermRenderer`.
4. PR-D: Extract `FigureRenderer`, `TableRenderer`.
5. PR-E: Extract remaining renderers.
6. PR-F: Adapter shrinks to orchestrator only.

## Files affected

- Create: `lib/isodoc/iso/docx/renderers/` directory
- Create: `lib/isodoc/iso/docx/renderers/registry.rb`
- Create: 12 renderer files (one per content type)
- Modify: `lib/isodoc/iso/docx.rb` — add `Renderers` autoload module
- Modify: `lib/isodoc/iso/docx/adapter.rb` — shrink from 1233 to ~500 lines

## Acceptance criteria

- `wc -l lib/isodoc/iso/docx/adapter.rb` returns < 600.
- Each renderer file is < 250 lines.
- Adding a new content type is a 2-file change: new renderer class +
  one entry in `Renderers::Registry#build_registry`.
- All existing adapter specs pass without modification (behavior preserved).
- New per-renderer specs (TODO 022) cover each renderer independently.

## Required specs

- `renderers/registry_spec.rb`:
  - Dispatch by class returns matching renderer.
  - Unknown class returns nil (not a crash).
  - All entries in registry have classes that exist (no NameError).
- One spec per renderer (TODO 022 covers this).
