# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a <definitions> section — the ISO "Symbols and
        # abbreviated terms" clause (Metanorma::Standoc::Document::
        # Sections::DefinitionSection).
        #
        # Same skeleton as a clause: heading at the current section
        # depth, then children walked in document order. While the
        # children render, the context carries the :definitions zone so
        # DefinitionListRenderer emits the symbol definition list as a
        # two-column table (term column + definition column), matching
        # the classic isodoc Word chain (WordFunction::Body#dl_parse_table).
        class DefinitionSectionRenderer < SectionRenderer
          def around_section(_section, _doc, &)
            @context.section_depth += 1
            @context.with_definitions(&)
          ensure
            @context.section_depth -= 1
          end

          def title_style_for(_section)
            depth = [@context.section_depth, 6].min
            @resolver.heading_style(depth)
          end
        end
      end
    end
  end
end
