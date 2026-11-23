# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Manages the three-section DOCX layout and header/footer lifecycle.
      #
      # ISO DIS documents have three distinct sections:
      #   1. Cover page — blank header/footer parts, no page numbering
      #   2. Front matter — roman numeral page numbers, even/odd headers
      #   3. Body — arabic page numbers starting at 1, even/odd headers
      #
      # Each section break is a sectPr attached to the last paragraph of
      # the section. The SectionManager creates these with the correct
      # page size, margins, headers, footers, and page numbering.
      #
      # Header/footer parts are reused from the loaded DOCX template.
      # Template section references select the parts for each section.
      # Missing body references inherit the front matter's parts, as in Word.
      # HeaderFooterRenderer updates the selected parts' content.
      class SectionManager
        # ISO A4 page dimensions in twips
        PAGE_WIDTH = 11_906
        PAGE_HEIGHT = 16_838

        # Cover page margins (different from body — narrower left)
        COVER_MARGINS = {
          top: 794, bottom: 284, left: 851, right: 737,
          header: 709, footer: 0, gutter: 567,
        }.freeze

        # Fallback front matter and body margins, used only when the
        # template carries no section properties for that section.
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

        DEFAULT_REFERENCES = {
          front: {
            header_even: FRONT_HEADER_EVEN, header_default: FRONT_HEADER_DEFAULT,
            footer_even: FRONT_FOOTER_EVEN, footer_default: FRONT_FOOTER_DEFAULT
          }.freeze,
          body: {
            header_even: BODY_HEADER_EVEN, header_default: BODY_HEADER_DEFAULT,
            footer_even: BODY_FOOTER_EVEN, footer_default: BODY_FOOTER_DEFAULT
          }.freeze,
        }.freeze

        # Captured by the adapter before it clears the template's body.
        attr_writer :template_margins, :template_references

        MARGIN_NAMES = %i[top right bottom left header footer gutter].freeze

        def initialize(resolver, header_footer_renderer)
          @resolver = resolver
          @hf_renderer = header_footer_renderer
          @template_margins = {}
          @template_references = {}
        end

        # The page margins of the template's front matter and body
        # sections, in document order, as { front:, body: }. Read this
        # before the template content is cleared. The cover keeps its own
        # layout: the template's cover section is a plain default page,
        # not the ISO cover design.
        def self.template_margins(root)
          body = root&.body
          return {} unless body

          sections = body.paragraphs.filter_map { |para| para.properties&.section_properties }
          sections << body.section_properties if body.section_properties
          { front: margins_of(sections[1]), body: margins_of(sections[2]) }.compact
        end

        def self.margins_of(section)
          page_margins = section&.page_margins
          return unless page_margins

          margins = MARGIN_NAMES.to_h { |name| [name, page_margins.public_send(name)] }
          margins if margins.values.none?(&:nil?)
        end

        def self.template_references(root)
          body = root&.body
          return {} unless body

          sections = body.paragraphs.filter_map { |para| para.properties&.section_properties }
          sections << body.section_properties if body.section_properties
          return {} unless sections[1]

          front = references_of(sections[1])
          { front: front, body: front.merge(references_of(sections[2])) }
        end

        def self.references_of(section)
          return {} unless section

          { header: section.header_references, footer: section.footer_references }
            .each_with_object({}) do |(kind, refs), result|
            refs.each { |ref| result[:"#{kind}_#{ref.type}"] = ref.r_id }
          end
        end

        # The tables use the same margins as the section they appear in.
        # Leave fallback sizing to the renderer when no template was loaded.
        def text_width(section)
          margins = @template_margins[section]
          return unless margins

          PAGE_WIDTH - margins[:left] - margins[:right] - margins[:gutter]
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
        def insert_cover_section(doc)
          sec = build_section(margins: COVER_MARGINS)
          sec.header_references << Uniword::Wordprocessingml::HeaderReference.new(
            type: "even", r_id: blank_cover_part(doc, :header, 0).r_id,
          )
          %w[even default].each_with_index do |type, index|
            sec.footer_references << Uniword::Wordprocessingml::FooterReference.new(
              type: type, r_id: blank_cover_part(doc, :footer, index).r_id,
            )
          end
          append_section_paragraph(doc, sec)
        end

        # Insert a section break ending the front matter.
        # Front matter: roman numeral page numbers, even/odd headers.
        def insert_front_matter_section(doc, header_text:, copyright_text:)
          scheme = front_matter_scheme
          refs = @template_references.fetch(:front, DEFAULT_REFERENCES[:front])
          write_header_footer_parts(doc, refs, header_text, copyright_text, scheme)

          sec = build_section(
            margins: @template_margins.fetch(:front, BODY_MARGINS),
            page_numbering: { format: scheme.format },
          )
          add_header_footer_refs(sec, refs)

          append_section_paragraph(doc, sec)
        end

        # Apply the final body section properties.
        # Body: arabic page numbers starting at 1.
        def apply_body_section(doc, header_text:, copyright_text:)
          scheme = body_scheme
          refs = @template_references.fetch(:body, DEFAULT_REFERENCES[:body])
          write_header_footer_parts(doc, refs, header_text, copyright_text, scheme)

          sec = build_section(
            margins: @template_margins.fetch(:body, BODY_MARGINS),
            page_numbering: { start: 1 },
          )
          add_header_footer_refs(sec, refs)

          body = doc.model&.body
          body.section_properties = sec if body
        end

        private

        def build_section(margins:, page_numbering: nil)
          sec = Uniword::Wordprocessingml::SectionProperties.new
          sec.page_size = Uniword::Wordprocessingml::PageSize.new(
            width: PAGE_WIDTH, height: PAGE_HEIGHT,
          )
          sec.page_margins = Uniword::Wordprocessingml::PageMargins.new(**margins)
          sec.columns = Uniword::Wordprocessingml::Columns.new(space: 720)
          sec.doc_grid = Uniword::Wordprocessingml::DocGrid.new(line_pitch: 360)

          if page_numbering
            sec.page_numbering = Uniword::Wordprocessingml::PageNumbering.new
            sec.page_numbering.start = page_numbering[:start] if page_numbering[:start]
            sec.page_numbering.fmt = page_numbering[:format] if page_numbering[:format]
          end

          sec
        end

        def add_header_footer_refs(sec, references)
          references.each do |key, r_id|
            kind, type = key.to_s.split("_", 2)
            if kind == "header"
              sec.header_references << Uniword::Wordprocessingml::HeaderReference.new(type: type, r_id: r_id)
            else
              sec.footer_references << Uniword::Wordprocessingml::FooterReference.new(type: type, r_id: r_id)
            end
          end
        end

        def write_header_footer_parts(doc, references, header_text, copyright_text, scheme)
          references.each do |key, r_id|
            if key.to_s.start_with?("header_")
              write_header_part(doc, r_id, header_text)
            else
              write_footer_part(doc, r_id, copyright_text, scheme)
            end
          end
        end

        def blank_cover_part(doc, kind, index)
          parts = doc.model.header_footer_parts
          # The adapter reuses the template model across conversions. These
          # parts have no store-level type so Uniword leaves the body refs alone.
          existing = parts.of_kind(kind).reject(&:loaded?).select { |part| part.type.nil? }
          return existing[index] if existing[index]

          definition = Uniword::Ooxml::PartRegistry.find_by_key(kind)
          target = parts.next_target(kind)
          content = definition.loader_model.new
          content.paragraphs << Uniword::Wordprocessingml::Paragraph.new
          parts << Uniword::Docx::HeaderFooterPart.new(
            kind: kind, target: target, rel_type: definition.rel_type,
            content_type: definition.content_type, content: content,
            r_id: doc.allocator.alloc_rid(target: target, type: definition.rel_type)
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

          @hf_renderer.render_header(part[:content], text)
        end

        def write_footer_part(doc, r_id, copyright_text, scheme)
          part = find_part(doc, r_id)
          return unless part

          @hf_renderer.render_footer(part[:content], copyright_text, scheme: scheme)
        end

        # Create a paragraph with section properties attached.
        # In OOXML, a sectPr inside a pPr creates a section break.
        def append_section_paragraph(doc, section_properties)
          section_properties.rsid_r = "00000000"
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
