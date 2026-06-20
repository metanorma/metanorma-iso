# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders header and footer part contents for each DOCX section.
      #
      # Each section has up to four parts (header-even, header-default,
      # footer-even, footer-default). The SectionManager owns which rIds
      # belong to which section; this renderer owns the *content* of each
      # part — the paragraph, style, runs, and page-number field.
      #
      # Style selection is driven by the section's PageScheme:
      #   - Roman scheme   → FooterPageRomanNumber
      #   - Arabic scheme  → FooterPageNumber
      #   - Otherwise      → FooterCentered (fallback)
      # Headers always use HeaderCentered with right-aligned bold text.
      class HeaderFooterRenderer
        # OOXML field instruction for the current page number.
        PAGE_FIELD_INSTRUCTION = " PAGE "

        def initialize(resolver)
          @resolver = resolver
        end

        # Render a header part with right-aligned bold running title text.
        # The header style is always HeaderCentered.
        def render_header(part_content, text, align: :right)
          part_content.paragraphs.clear
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:header_centered)
          para.align = align
          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).bold
          para << run.build
          part_content.paragraphs << para.build
        end

        # Render a footer part: copyright text on the left, page-number
        # field on the right (separated by a tab). The style follows the
        # section's PageScheme — roman sections get FooterPageRomanNumber,
        # arabic sections get FooterPageNumber.
        def render_footer(part_content, copyright_text, scheme:)
          part_content.paragraphs.clear
          style = footer_style_for(scheme)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = style if style
          para.align = :center
          para << copyright_text.to_s
          para << Uniword::Builder.tab
          model = para.build
          append_page_number_field(model)
          part_content.paragraphs << model
        end

        private

        def footer_style_for(scheme)
          return @resolver.paragraph_style(:footer_roman) if scheme.roman?
          return @resolver.paragraph_style(:footer_page_number) if scheme.arabic?

          @resolver.paragraph_style(:footer_centered)
        end

        # Append a PAGE complex field (begin / instrText / separate / end)
        # directly to a built Paragraph model. The field is encoded across
        # four FieldChar/InstrText entries that are siblings of the runs
        # inside the same paragraph.
        def append_page_number_field(paragraph)
          paragraph.field_chars << field_char("begin")
          instr = Uniword::Wordprocessingml::InstrText.new
          instr.text = PAGE_FIELD_INSTRUCTION
          paragraph.instr_text << instr
          paragraph.field_chars << field_char("separate")
          paragraph.field_chars << field_char("end")
        end

        def field_char(kind)
          fc = Uniword::Wordprocessingml::FieldChar.new
          fc.fldCharType = kind
          fc
        end
      end
    end
  end
end
