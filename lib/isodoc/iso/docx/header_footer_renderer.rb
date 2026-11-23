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
      # The layout follows the ISO DIS template's own header and footer
      # parts: a centred header line, and a footer of two centred lines —
      # the copyright statement (FooterCentered), then the page number on
      # its own line below. The page-number style follows the section's
      # PageScheme:
      #   - Roman scheme   → FooterPageRomanNumber
      #   - Arabic scheme  → FooterPageNumber
      #   - Otherwise      → FooterCentered (fallback)
      class HeaderFooterRenderer
        # OOXML field instruction for the current page number.
        PAGE_FIELD_INSTRUCTION = " PAGE "

        def initialize(resolver)
          @resolver = resolver
        end

        # DIS uses HeaderCentered; Simple keeps the template part's own
        # paragraph and run formatting.
        def render_header(part_content, text)
          unless @resolver.paragraph_style(:header_centered)
            return render_template_header(part_content, text)
          end

          part_content.paragraphs.clear
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:header_centered)
          run = Uniword::Builder::RunBuilder.new
          run.text(text.to_s).bold
          para << run.build
          part_content.paragraphs << para.build
        end

        # DIS has two centered lines. Simple keeps each odd/even part's
        # paragraph layout, tab stops and page-field position.
        def render_footer(part_content, copyright_text, scheme:)
          unless @resolver.paragraph_style(:footer_centered)
            return render_template_footer(part_content, copyright_text)
          end

          part_content.paragraphs.clear
          copyright = styled_paragraph(@resolver.paragraph_style(:footer_centered))
          copyright.runs << Uniword::Wordprocessingml::Run.new(text: copyright_text.to_s)
          part_content.paragraphs << copyright

          page_number = styled_paragraph(footer_style_for(scheme))
          append_page_number_field(page_number)
          part_content.paragraphs << page_number
        end

        private

        # The Simple template uses different direct formatting on each
        # odd/even part, rather than the DIS template's centered styles.
        def render_template_header(content, text)
          content.paragraphs.each do |paragraph|
            run = paragraph.runs.find { |r| !Array(r.text).join.empty? }
            run.text = text.to_s if run
          end
        end

        def render_template_footer(content, text)
          content.paragraphs.each do |paragraph|
            in_field = false
            paragraph.runs.each do |run|
              case run.field_char&.fldCharType
              when "begin" then in_field = true
              when "end" then in_field = false
              end
              # Drop the template's cached page value; Word computes PAGE.
              run.text = nil if in_field
              run.text = text.to_s if Array(run.text).join.include?("©")
            end
          end
        end

        def styled_paragraph(style)
          paragraph = Uniword::Wordprocessingml::Paragraph.new
          paragraph.properties = Uniword::Wordprocessingml::ParagraphProperties.new
          if style
            paragraph.properties.style =
              Uniword::Properties::StyleReference.new(value: style)
          end
          paragraph
        end

        def footer_style_for(scheme)
          return @resolver.paragraph_style(:footer_roman) if scheme.roman?
          return @resolver.paragraph_style(:footer_page_number) if scheme.arabic?

          @resolver.paragraph_style(:footer_centered)
        end

        # Append a PAGE complex field as four <w:r> runs (begin, instrText,
        # separate, end). Each OOXML field component MUST be wrapped in a
        # <w:r> — bare <w:fldChar>/<w:instrText> as paragraph children is
        # schema-invalid and Word rejects the document.
        def append_page_number_field(paragraph)
          paragraph.runs << field_char_run("begin")
          paragraph.runs << instr_text_run(PAGE_FIELD_INSTRUCTION)
          paragraph.runs << field_char_run("separate")
          paragraph.runs << field_char_run("end")
        end

        def field_char_run(kind)
          Uniword::Wordprocessingml::Run.new(
            field_char: Uniword::Wordprocessingml::FieldChar.new(
              fldCharType: kind,
            ),
          )
        end

        def instr_text_run(text)
          Uniword::Wordprocessingml::Run.new(
            instr_text: Uniword::Wordprocessingml::InstrText.new(text: text),
          )
        end
      end
    end
  end
end
