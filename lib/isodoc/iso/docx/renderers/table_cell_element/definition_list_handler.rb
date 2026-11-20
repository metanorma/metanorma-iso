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
              terms.each_with_index do |term, index|
                append_paragraph(term, target)
                append_paragraph(definitions[index], target)
              end
            end

            private

            def append_paragraph(node, target)
              return unless node

              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(target.style_key) if target.style_key
              @inline_renderer.render(node, para)
              target << para
            end
          end
        end
      end
    end
  end
end
