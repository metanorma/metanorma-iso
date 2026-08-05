# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders an OrderedList or UnorderedList inside a table cell.
          # Each list item becomes a numbered paragraph carrying the cell's
          # row-type style. The numbering kind (decimal vs dash) is selected
          # by the +num_id_key+ constructor parameter.
          class ListHandler
            include Base

            def initialize(resolver:, inline_renderer:, num_id_key:)
              super(resolver: resolver, inline_renderer: inline_renderer)
              @num_id_key = num_id_key
            end

            def render(element, target)
              num_id = @resolver.numbering_id(@num_id_key)
              Array(element.listitem).each do |item|
                render_item(item, target, num_id)
              end
            end

            private

            def render_item(item, target, num_id)
              para = Uniword::Builder::ParagraphBuilder.new
              if target.style_key
                para.style = @resolver.paragraph_style(target.style_key)
              end
              para.numbering(num_id, 0) if num_id
              append_item_content(item, para)
              target << para
            end

            def append_item_content(item, para)
              paragraphs = item.paragraphs
              if paragraphs && !paragraphs.empty?
                paragraphs.each { |p| @inline_renderer.render(p, para) }
              else
                @inline_renderer.render(item, para)
              end
            end
          end
        end
      end
    end
  end
end
