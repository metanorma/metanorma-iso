# 022 — Spec: Per-renderer output

## Goal

Each renderer extracted in TODO 010 has a dedicated spec that asserts
its DOCX output for canonical Era C content. Specs use real
`Metanorma::Document` instances built from XML fixtures — never
`double()`.

## Renderers covered

| Spec file                          | Renderer                |
|------------------------------------|-------------------------|
| `clause_renderer_spec.rb`          | `ClauseRenderer`        |
| `term_renderer_spec.rb`            | `TermRenderer`          |
| `bibliography_renderer_spec.rb`    | `BibliographyRenderer`  |
| `note_renderer_spec.rb`            | `NoteRenderer`          |
| `example_renderer_spec.rb`         | `ExampleRenderer`       |
| `admonition_renderer_spec.rb`      | `AdmonitionRenderer`    |
| `figure_renderer_spec.rb`          | `FigureRenderer`        |
| `table_renderer_spec.rb`           | `TableRenderer`         |
| `quote_renderer_spec.rb`           | `QuoteRenderer`         |
| `definition_list_renderer_spec.rb` | `DefinitionListRenderer`|
| `list_renderer_spec.rb`            | `ListRenderer`          |
| `paragraph_renderer_spec.rb`       | `ParagraphRenderer`     |
| `header_footer_renderer_spec.rb`   | `HeaderFooterRenderer`  |

## Common spec infrastructure

A `RendererTestContext` factory builds the `StyleResolver`, `Context`,
and `InlineRenderer` instances that every renderer needs:

```ruby
# spec/support/docx/renderer_test_context.rb
module IsoDoc
  module Iso
    module Docx
      module RendererTestContext
        def self.build(zone: :body, **opts)
          mapping = DocxStyleMapping.load_default
          library = StyleLibrary.load_default
          resolver = StyleResolver.new(mapping, library)
          context = Context.new(zone: zone, **opts)
          inline = InlineRenderer.new(resolver, context)
          SectionManager.new(context)
          [resolver, context, inline]
        end
      end
    end
  end
end
```

A `ModelFactory` builds real model objects from XML snippets:

```ruby
# spec/support/docx/model_factory.rb
module IsoDoc
  module Iso
    module Docx
      module ModelFactory
        def self.note_from(xml_fragment)
          doc = Metanorma::Document.from_xml(<<~XML)
            <iso-standard xmlns="https://www.metanorma.org/ns/iso">
              <sections>
                <clause>
                  #{xml_fragment}
                </clause>
              </sections>
            </iso-standard>
          XML
          doc.sections.first.clauses.first.notes.first
        end
        # ... similar factories for example, figure, table, etc.
      end
    end
  end
end
```

## Spec sketch — `NoteRenderer`

```ruby
require "spec_helper"
require "isodoc/iso/docx"
require "support/docx/renderer_test_context"
require "support/docx/model_factory"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe NoteRenderer do
        let(:resolver) { RendererTestContext.build.first }
        let(:context)  { RendererTestContext.build(zone: :body)[1] }
        let(:doc)      { Uniword::Document.new }

        subject(:renderer) { described_class.new(resolver, context) }

        it "renders a note as Box-begin / Noteindent / Box-end" do
          note = ModelFactory.note_from(<<~XML)
            <note id="n1"><p>Note body text.</p></note>
          XML
          renderer.render(note, doc)
          paragraphs = doc.paragraphs
          expect(paragraphs.size).to eq(3)
          expect(paragraphs[0].style_id).to eq("Box-begin")
          expect(paragraphs[1].style_id).to eq("Noteindent")
          expect(paragraphs[1].text).to eq("Note body text.")
          expect(paragraphs[2].style_id).to eq("Box-end")
        end

        it "uses Noteindentcontinued for subsequent paragraphs" do
          note = ModelFactory.note_from(<<~XML)
            <note id="n1">
              <p>First paragraph.</p>
              <p>Second paragraph.</p>
            </note>
          XML
          renderer.render(note, doc)
          paragraphs = doc.paragraphs.select { |p| p.text.to_s.match?(/paragraph/) }
          expect(paragraphs[0].style_id).to eq("Noteindent")
          expect(paragraphs[1].style_id).to eq("Noteindentcontinued")
        end
      end
    end
  end
end
```

## Spec sketch — `BibliographyRenderer`

```ruby
require "spec_helper"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe BibliographyRenderer do
        let(:resolver) { RendererTestContext.build(zone: :bibliography)[0] }
        let(:context)  { RendererTestContext.build(zone: :bibliography)[1] }
        let(:doc)      { Uniword::Document.new }

        subject(:renderer) { described_class.new(resolver, context) }

        it "renders a bib item with the Bibliography style" do
          bib = ModelFactory.bib_item_from(<<~XML)
            <bibitem id="iso-1234" type="standard">
              <title>ISO 1234</title>
              <docidentifier>ISO 1234:2025</docidentifier>
            </bibitem>
          XML
          renderer.render_bib_item(bib, doc)
          para = doc.paragraphs.last
          expect(para.style_id).to eq("Bibliography")
        end

        it "renders a normative reference with the NormReference style" do
          bib = ModelFactory.bib_item_from(<<~XML)
            <bibitem id="iso-5678" type="standard">
              <title>ISO 5678</title>
              <docidentifier>ISO 5678:2025</docidentifier>
            </bibitem>
          XML
          context.within_normative = true
          renderer.render_bib_item(bib, doc)
          para = doc.paragraphs.last
          expect(para.style_id).to eq("NormReference")
        end
      end
    end
  end
end
```

## Spec sketch — `DefinitionListRenderer`

```ruby
require "spec_helper"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe DefinitionListRenderer do
        it "renders a formula key list as KeyTitle + KeyText" do
          resolver, context = RendererTestContext.build(zone: :formula)
          formula_context = context.with_formula_key
          dl = ModelFactory.definition_list_from(<<~XML)
            <dl>
              <dt>X</dt><dd>horizontal coordinate</dd>
              <dt>Y</dt><dd>vertical coordinate</dd>
            </dl>
          XML
          renderer = described_class.new(resolver, formula_context)
          renderer.render(dl, Uniword::Document.new)
          # Asserts: each dt → KeyTitle paragraph, each dd → KeyText paragraph
        end

        it "renders a glossary as GlossaryTerm + GlossaryDefinition" do
          resolver, context = RendererTestContext.build(zone: :terms)
          dl = ModelFactory.definition_list_from(<<~XML)
            <dl>
              <dt>term</dt><dd>definition</dd>
            </dl>
          XML
          renderer = described_class.new(resolver, context)
          renderer.render(dl, Uniword::Document.new)
          # Asserts: dt → GlossaryTerm, dd → GlossaryDefinition
        end
      end
    end
  end
end
```

## Spec sketch — `ClauseRenderer` (numbering)

```ruby
require "spec_helper"

module IsoDoc
  module Iso
    module Docx
      RSpec.describe ClauseRenderer do
        it "body Heading1 gets numId=4, ilvl=0" do
          resolver, context = RendererTestContext.build(zone: :body)
          clause = ModelFactory.clause_from(<<~XML)
            <clause id="c1"><title>Scope</title></clause>
          XML
          described_class.new(resolver, context).render(clause, doc)
          para = doc.paragraphs.first
          expect(para.style_id).to eq("Heading1")
          expect(para.numbering.num_id).to eq(4)
          expect(para.numbering.level).to eq(0)
        end

        it "annex clause gets ANNEX style with numId=7" do
          resolver, context = RendererTestContext.build(zone: :annex)
          annex = ModelFactory.annex_from(<<~XML)
            <annex id="a1"><title>Mathematical conventions</title></annex>
          XML
          described_class.new(resolver, context).render(annex, doc)
          para = doc.paragraphs.first
          expect(para.style_id).to eq("ANNEX")
          expect(para.numbering.num_id).to eq(7)
        end

        it "Heading2 has no explicit numPr (inherits via style)" do
          resolver, context = RendererTestContext.build(zone: :body)
          clause = ModelFactory.clause_from(<<~XML)
            <clause id="c1"><title>Scope<clause id="c2"><title>Sub</title>
            </clause></title></clause>
          XML
          described_class.new(resolver, context).render(clause.clauses.first, doc)
          para = doc.paragraphs.first
          expect(para.style_id).to eq("Heading2")
          expect(para.numbering).to be_nil
        end
      end
    end
  end
end
```

## Required support code

- `RendererTestContext.build` factory.
- `ModelFactory` with `note_from`, `example_from`, `figure_from`,
  `table_from`, `quote_from`, `definition_list_from`, `clause_from`,
  `annex_from`, `bib_item_from`, `paragraph_from` builders. All use real
  `Metanorma::Document.from_xml`.
- Each spec is a single file (per the one-spec-file-at-a-time rule).

## Acceptance criteria

- Each of the 13 spec files passes when run alone:
  `bundle exec rspec spec/isodoc/iso/docx/note_renderer_spec.rb`
- Every assertion uses real model objects — no `double()`.
- Every `expect(... .style_id)` references an Era C canonical styleId
  (`Noteindent`, `Box-begin`, `KeyTitle`, `InlineCode`, `ANNEX`,
  `Bibliography`, `NormReference`, etc.).
- Coverage: every public `render` method on each renderer has at least
  one positive case and one edge case.

## Notes

- These specs are the per-renderer contract; they let us extract
  renderers from the 1233-line adapter with confidence that behavior is
  preserved.
- They also serve as documentation: a maintainer unfamiliar with the
  project can read any one of these specs and understand what a
  renderer is supposed to emit.
