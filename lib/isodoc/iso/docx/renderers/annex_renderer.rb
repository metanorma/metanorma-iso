# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Annex section: forces a page break before, sets the
        # annex zone flag (so descendants know they're inside an annex),
        # and uses the dedicated Annex paragraph style for the title.
        class AnnexRenderer < SectionRenderer
          def around_section(_section, doc, &)
            doc.page_break
            @context.section_depth += 1
            @context.with_annex(&)
          ensure
            @context.section_depth -= 1
          end

          def title_style_for(_section)
            @resolver.paragraph_style(:annex)
          end

          private

          # A variant-only annex still needs one real heading for Word's
          # ANNEX style selector. A second hidden paragraph leaves a
          # visible paragraph mark and can duplicate the title on refresh.
          def section_title(section)
            title = super
            return title if title && !heading_body_empty?(title)

            Array(section.variant_title).find { |variant| variant.type == "toc" } || title
          end
        end
      end
    end
  end
end
