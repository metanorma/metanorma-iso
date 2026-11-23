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
      # The DIS layout follows published ISO documents and the DOC output:
      # headers alternate left (even) and right (odd), and each footer is
      # one line with the page number on the outer edge.
      class HeaderFooterRenderer
        # OOXML field instruction for the current page number.
        PAGE_FIELD_INSTRUCTION = " PAGE "

        def initialize(resolver)
          @resolver = resolver
        end

        # DIS headers sit left on even pages and right on odd and first
        # pages; Simple keeps the template part's own formatting.
        def render_header(part_content, text, parity: :odd)
          unless @resolver.paragraph_style(:header_centered)
            return render_template_header(part_content, text)
          end

          part_content.paragraphs.clear
          para = styled_paragraph(@resolver.paragraph_style(:header_centered))
          align(para, parity == :even ? "left" : "right")
          para.runs << Uniword::Wordprocessingml::Run.new(
            text: text.to_s,
            properties: Uniword::Wordprocessingml::RunProperties.new(
              bold: Uniword::Properties::Bold.new,
            ),
          )
          part_content.paragraphs << para
        end

        # DIS footers are one line: page number then copyright on even
        # pages, copyright then page number on odd and first pages. A
        # margin-relative tab keeps the right side correct in any section
        # width. Simple keeps each template part's layout.
        def render_footer(part_content, copyright_text, scheme:, parity: :odd)
          unless @resolver.paragraph_style(:footer_centered)
            return render_template_footer(part_content, copyright_text)
          end

          part_content.paragraphs.clear
          para = styled_paragraph(@resolver.paragraph_style(:footer_centered))
          align(para, "left")
          copyright = [Uniword::Wordprocessingml::Run.new(text: copyright_text.to_s)]
          page = page_number_runs(scheme)
          first, last = parity == :even ? [page, copyright] : [copyright, page]
          para.runs.concat(first)
          para.runs << right_margin_tab
          para.runs.concat(last)
          part_content.paragraphs << para
        end

        private

        # The Simple template uses different direct formatting on each
        # odd/even part, rather than the DIS template's centered styles.
        def render_template_header(content, text)
          content.paragraphs.each do |paragraph|
            field_depth = 0
            run = paragraph.runs.find do |candidate|
              case candidate.field_char&.fldCharType
              when "begin" then field_depth += 1
              when "end" then field_depth -= 1
              end
              field_depth.zero? && !candidate.field_char &&
                !candidate.instr_text && !candidate.tab && !candidate.text.nil?
            end
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

        def align(paragraph, value)
          paragraph.properties.alignment =
            Uniword::Properties::Alignment.new(value: value)
        end

        def right_margin_tab
          Uniword::Wordprocessingml::Run.new(
            position_tab: Uniword::Wordprocessingml::PositionTab.new(
              relative_to: "margin", alignment: "right", leader: "none",
            ),
          )
        end

        # Same look as the template's FooterPageNumber (bold 11pt) and
        # FooterPageRomanNumber (11pt), which are paragraph styles and so
        # cannot apply to the number alone on a shared line.
        def page_number_properties(scheme)
          return nil unless scheme.roman? || scheme.arabic?

          Uniword::Wordprocessingml::RunProperties.new(
            bold: scheme.arabic? ? Uniword::Properties::Bold.new : nil,
            size: Uniword::Properties::FontSize.new(value: 22),
          )
        end

        # A PAGE complex field as four <w:r> runs (begin, instrText,
        # separate, end). Each OOXML field component MUST be wrapped in a
        # <w:r>; bare <w:fldChar>/<w:instrText> is schema-invalid.
        def page_number_runs(scheme)
          runs = [field_char_run("begin"), instr_text_run(PAGE_FIELD_INSTRUCTION),
                  field_char_run("separate"), field_char_run("end")]
          properties = page_number_properties(scheme)
          runs.each { |run| run.properties = properties } if properties
          runs
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
