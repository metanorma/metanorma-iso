# frozen_string_literal: true

require "nokogiri"

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders Metanorma::IsoDocument::RawParagraph — a paragraph whose
        # mixed inline content is captured as a raw XML string in
        # +content+ (see <tt>map_all_content to: :content</tt>).
        #
        # The raw XML is reparsed into a ParagraphBlock model so the
        # ordinary inline dispatch walks its children (xref, semx,
        # span, fmt-xref, etc.). Without this reparsing, the renderer
        # would fall back to +collect_text+ and emit the XML source as
        # literal text — exactly the "semx is appearing in the output"
        # symptom.
        class RawParagraphRenderer
          include Base

          def render(element, para)
            content = element.content
            return if content.nil? || content.to_s.empty?

            wrapped = wrap_for_parse(content)
            parsed = Metanorma::Document::Components::Paragraphs::ParagraphBlock.from_xml(wrapped)
            parent.render_mixed_inline_fallback(parsed, para)
          end

          private

          # Wrap raw inline XML in a <p> element with the ISO namespace so
          # ParagraphBlock.from_xml parses it correctly. The original
          # content is the inner XML of a <p>; without wrapping, the parser
          # sees multiple root elements and silently drops them.
          def wrap_for_parse(content)
            "<p xmlns=\"https://www.metanorma.org/ns/iso\">#{content}</p>"
          end
        end
      end
    end
  end
end