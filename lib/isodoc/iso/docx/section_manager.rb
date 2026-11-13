# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Manages the three-section DOCX layout and header/footer lifecycle.
      #
      # ISO DIS documents have three distinct sections:
      #   1. Cover page — no headers/footers, no page numbering
      #   2. Front matter — roman numeral page numbers, even/odd headers
      #   3. Body — arabic page numbers starting at 1, even/odd headers
      #
      # Each section break is a sectPr attached to the last paragraph of
      # the section. The SectionManager creates these with the correct
      # page size, margins, headers, footers, and page numbering.
      #
      # Header/footer parts are reused from the loaded DOCX template.
      # The DIS template provides 8 pre-allocated parts (4 headers, 4 footers)
      # with valid rIds in the package relationships. The SectionManager
      # rewrites their content for each section's needs via the
      # HeaderFooterRenderer.
      #
      # Layout:
      #   Front matter: rId16 (header even), rId17 (header default),
      #                 rId18 (footer even), rId19 (footer default)
      #   Body:         rId25 (header even), rId26 (header default),
      #                 rId27 (footer even), rId28 (footer default)
      class SectionManager
        # ISO A4 page dimensions in twips
        PAGE_WIDTH = 11_906
        PAGE_HEIGHT = 16_838

        # Cover page margins (different from body — narrower left)
        COVER_MARGINS = {
          top: 794, bottom: 284, left: 851, right: 737,
          header: 709, footer: 0, gutter: 567,
        }.freeze

        # Body margins
        BODY_MARGINS = {
          top: 794, bottom: 567, left: 1077, right: 1077,
          header: 720, footer: 720, gutter: 0,
        }.freeze

        # Template header/footer part rIds for front matter section
        FRONT_HEADER_EVEN = "rId16"
        FRONT_HEADER_DEFAULT = "rId17"
        FRONT_FOOTER_EVEN = "rId18"
        FRONT_FOOTER_DEFAULT = "rId19"

        # Template header/footer part rIds for body section
        BODY_HEADER_EVEN = "rId25"
        BODY_HEADER_DEFAULT = "rId26"
        BODY_FOOTER_EVEN = "rId27"
        BODY_FOOTER_DEFAULT = "rId28"

        def initialize(resolver, header_footer_renderer)
          @resolver = resolver
          @hf_renderer = header_footer_renderer
        end

        # The PageScheme for the front matter section.
        # Front matter always uses roman numerals with a page-number field.
        def front_matter_scheme
          PageScheme.roman
        end

        # The PageScheme for the body section.
        # Body always uses arabic numerals with a page-number field.
        def body_scheme
          PageScheme.arabic
        end

        # Insert a section break ending the cover page.
        # Cover page: no headers/footers, no page numbering.
        def insert_cover_section(doc)
          sec = build_section(margins: COVER_MARGINS)
          append_section_paragraph(doc, sec)
        end

        # Insert a section break ending the front matter.
        # Front matter: roman numeral page numbers, even/odd headers.
        def insert_front_matter_section(doc, header_text:, copyright_text:)
          scheme = front_matter_scheme
          write_header_part(doc, FRONT_HEADER_EVEN, header_text)
          write_header_part(doc, FRONT_HEADER_DEFAULT, header_text)
          write_footer_part(doc, FRONT_FOOTER_EVEN, copyright_text, scheme)
          write_footer_part(doc, FRONT_FOOTER_DEFAULT, copyright_text, scheme)

          sec = build_section(
            margins: BODY_MARGINS,
            page_numbering: { format: scheme.format },
          )
          add_header_footer_refs(sec,
            header_even: FRONT_HEADER_EVEN,
            header_default: FRONT_HEADER_DEFAULT,
            footer_even: FRONT_FOOTER_EVEN,
            footer_default: FRONT_FOOTER_DEFAULT)

          append_section_paragraph(doc, sec)
        end

        # Apply the final body section properties.
        # Body: arabic page numbers starting at 1.
        def apply_body_section(doc, header_text:, copyright_text:)
          scheme = body_scheme
          write_header_part(doc, BODY_HEADER_EVEN, header_text)
          write_header_part(doc, BODY_HEADER_DEFAULT, header_text)
          write_footer_part(doc, BODY_FOOTER_EVEN, copyright_text, scheme)
          write_footer_part(doc, BODY_FOOTER_DEFAULT, copyright_text, scheme)

          sec = build_section(
            margins: BODY_MARGINS,
            page_numbering: { start: 1 },
          )
          add_header_footer_refs(sec,
            header_even: BODY_HEADER_EVEN,
            header_default: BODY_HEADER_DEFAULT,
            footer_even: BODY_FOOTER_EVEN,
            footer_default: BODY_FOOTER_DEFAULT)

          body = doc.model&.body
          body.section_properties = sec if body
        end

        private

        def build_section(margins:, page_numbering: nil)
          sec = Uniword::Wordprocessingml::SectionProperties.new
          sec.type = "nextPage"
          sec.page_size = Uniword::Wordprocessingml::PageSize.new(
            width: PAGE_WIDTH, height: PAGE_HEIGHT,
          )
          sec.page_margins = Uniword::Wordprocessingml::PageMargins.new(**margins)
          sec.columns = Uniword::Wordprocessingml::Columns.new(space: 720)
          sec.doc_grid = Uniword::Wordprocessingml::DocGrid.new(line_pitch: 360)

          if page_numbering
            sec.page_numbering = Uniword::Wordprocessingml::PageNumbering.new
            sec.page_numbering.start = page_numbering[:start] if page_numbering[:start]
            sec.page_numbering.format = page_numbering[:format] if page_numbering[:format]
          end

          sec
        end

        def add_header_footer_refs(sec, header_even:, header_default:,
                                   footer_even:, footer_default:)
          sec.header_references << Uniword::Wordprocessingml::HeaderReference.new(
            type: "even", r_id: header_even,
          )
          sec.header_references << Uniword::Wordprocessingml::HeaderReference.new(
            type: "default", r_id: header_default,
          )
          sec.footer_references << Uniword::Wordprocessingml::FooterReference.new(
            type: "even", r_id: footer_even,
          )
          sec.footer_references << Uniword::Wordprocessingml::FooterReference.new(
            type: "default", r_id: footer_default,
          )
        end

        # Find a header/footer part from the template by its rId.
        def find_part(doc, r_id)
          parts = doc.model.header_footer_parts
          return nil unless parts

          parts.find { |p| p[:r_id] == r_id }
        end

        def write_header_part(doc, r_id, text)
          part = find_part(doc, r_id)
          return unless part

          @hf_renderer.render_header(part[:content], text, align: :right)
        end

        def write_footer_part(doc, r_id, copyright_text, scheme)
          part = find_part(doc, r_id)
          return unless part

          @hf_renderer.render_footer(part[:content], copyright_text, scheme: scheme)
        end

        # Create a paragraph with section properties attached.
        # In OOXML, a sectPr inside a pPr creates a section break.
        def append_section_paragraph(doc, section_properties)
          para = Uniword::Builder::ParagraphBuilder.new
          para << ""
          model = para.build
          model.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
          model.properties.section_properties = section_properties
          doc << model
        end
      end
    end
  end
end
