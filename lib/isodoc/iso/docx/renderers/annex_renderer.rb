# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Annex section: forces a page break before, sets the
        # annex zone flag (so descendants know they're inside an annex),
        # and uses the dedicated Annex paragraph style for the title.
        class AnnexRenderer < SectionRenderer
          def around_section(section, doc)
            doc.page_break
            @context.section_depth += 1
            @context.with_annex { yield }
          ensure
            @context.section_depth -= 1
          end

          def title_style_for(_section)
            @resolver.paragraph_style(:annex)
          end
        end
      end
    end
  end
end
