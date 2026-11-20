# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a <dl> inside a table cell as one paragraph per dt and
          # dd, each carrying the cell's row-type style. Inline content,
          # footnotes included, goes through the cell's own renderers.
          class DefinitionListHandler
            include Base

            def render(element, target)
              terms = Array(element.dt)
              definitions = Array(element.dd)
              append_paragraph(nil, target) if terms.empty? && definitions.empty?
              terms.each_with_index do |term, index|
                append_paragraph(term, target)
                paragraphs_of(definitions[index]).each { |part| append_paragraph(part, target) }
              end
            end

            private

            # A dd of several <p> becomes one paragraph each, not one run-on
            # paragraph.
            def paragraphs_of(node)
              return [] unless node

              parts = node.respond_to?(:p) ? Array(node.p) : []
              only_paragraphs = Array(node.element_order).all? do |entry|
                entry.element? ? entry.name == "p" : entry.text_content.to_s.strip.empty?
              end
              parts.size > 1 && only_paragraphs ? parts : [node]
            end

            # A nil node gives an empty paragraph: a w:tc needs one w:p.
            def append_paragraph(node, target)
              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(target.style_key) if target.style_key
              @inline_renderer.render(node, para) if node
              target << para
            end
          end
        end
      end
    end
  end
end
