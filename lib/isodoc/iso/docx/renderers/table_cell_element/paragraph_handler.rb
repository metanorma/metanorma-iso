# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a ParagraphBlock (or any unmatched element) into a
          # table cell as a single paragraph carrying the cell's row-type
          # style (Tablebody / Tableheader / Tablefooter).
          class ParagraphHandler
            include Base

            def render(element, target)
              cell_para = Uniword::Builder::ParagraphBuilder.new
              if target.style_key
                cell_para.style = @resolver.paragraph_style(target.style_key)
              end
              @inline_renderer.render(element, cell_para)
              target << cell_para
            end
          end
        end
      end
    end
  end
end
