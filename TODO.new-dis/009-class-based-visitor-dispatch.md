# 009 — Class-based visitor dispatch

## Problem

`adapter.rb:639` (`visit_block`) dispatches by Ruby class with a long
`case/when` chain. Each new model type means editing the chain — OCP
violation. Worse, several `when` clauses match by string class name,
which breaks if classes are renamed or moved.

## Approach

Replace the case/when with a **class-keyed dispatch table** populated at
adapter construction time. Each model type gets a single visitor method
on the adapter (or its delegate renderer).

```ruby
module IsoDoc::Iso::Docx
  class Adapter
    VISITOR_TABLE = {
      Metanorma::Document::Clause              => :visit_clause,
      Metanorma::Document::Section             => :visit_section,
      Metanorma::Document::Annex               => :visit_annex,
      Metanorma::Document::Term                => :visit_term,
      Metanorma::Document::TermsSection        => :visit_terms_section,
      Metanorma::Document::Definitions         => :visit_definitions,
      Metanorma::Document::Bibliography        => :visit_bibliography,
      Metanorma::Document::ReferencesSection   => :visit_references_section,
      Metanorma::Document::BibliographicItem   => :visit_bibliographic_item,
      Metanorma::Document::Paragraph           => :visit_paragraph,
      Metanorma::Document::Table               => :visit_table,
      Metanorma::Document::Figure              => :visit_figure,
      Metanorma::Document::Formula             => :visit_formula,
      Metanorma::Document::Note                => :visit_note,
      Metanorma::Document::Example             => :visit_example,
      Metanorma::Document::Admonition          => :visit_admonition,
      Metanorma::Document::Sourcecode          => :visit_sourcecode,
      Metanorma::Document::Quote               => :visit_quote,
      Metanorma::Document::DefinitionList      => :visit_definition_list,
      Metanorma::Document::UnorderedList       => :visit_unordered_list,
      Metanorma::Document::OrderedList         => :visit_ordered_list,
      Metanorma::Document::Index               => :visit_index,
      # …etc
    }.freeze

    def visit_block(node, doc)
      method_name = VISITOR_TABLE[node.class]
      return unless method_name
      public_send(method_name, node, doc)
    end
  end
end
```

### Inheritance safety

Per memory note `feedback_case_when_inheritance.md`: subclasses must
appear before superclasses. With a Hash, Ruby returns the first exact
class match — we use `VISITOR_TABLE[node.class]` (exact), not
`VISITOR_TABLE.detect { |k, _| node.is_a?(k) }`. If a model has
subclasses that need different rendering, they are explicitly added to
the table.

To make this safe, add a one-time check at adapter construction:
```ruby
def validate_visitor_table!
  conflicts = VISITOR_TABLE.keys.group_by { |k| k.name }
                              .select { |_n, ks| ks.size > 1 }
  raise "Duplicate visitor entries: #{conflicts}" unless conflicts.empty?
end
```

### Public dispatch

Visitors are public methods — `public_send` is appropriate here (these
are not private methods). This complies with the project rule "never
use `send` to call private methods" — `public_send` only invokes public
API.

## Files affected

- Modify: `lib/isodoc/iso/docx/adapter.rb` — replace case/when with
  VISITOR_TABLE + dispatch method
- Reference: memory note `feedback_case_when_inheritance.md`

## Acceptance criteria

- `visit_block` is 3 lines (table lookup, return-if-nil, dispatch).
- Adding a new content type requires: (1) adding one entry to
  VISITOR_TABLE, (2) adding a `visit_<type>` method. No edits to
  existing dispatch logic. (OCP)
- No string class names anywhere — all `Metanorma::Document::*` constants.
- `bundle exec rspec spec/isodoc/docx/adapter_spec.rb` passes.

## Required specs

- `adapter_visitor_dispatch_spec.rb`:
  - Each entry in VISITOR_TABLE has a corresponding `visit_*` method.
  - Dispatching a `Paragraph` instance invokes `visit_paragraph`.
  - Dispatching an unregistered class returns nil (no crash).
  - Subclass test: if `SpecialParagraph < Paragraph` is registered with
    its own visitor, dispatching a `SpecialParagraph` calls
    `visit_special_paragraph`, not `visit_paragraph`.
