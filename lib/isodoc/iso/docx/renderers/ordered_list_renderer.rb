# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an OrderedList as a sequence of numbering-applied
        # paragraphs using the Era C decimal_list numId (1, 2, 3, ...).
        #
        # Era C's 7-abstractNum scheme exposes decimal ordered-list
        # numbering as numId 1 (and 2 as an alt referencing the same
        # abstractNum). The numbering ID flows from `style_mapping.yml`
        # via StyleResolver — this renderer holds no literal styleId
        # or numId.
        class OrderedListRenderer
          include Base

          def render(list, doc)
            num_id = @resolver.numbering_id(:decimal_list)
            Array(list.listitem).each do |item|
              render_item(item, doc, num_id)
            end
          end

          private

          def render_item(item, doc, num_id)
            para = Uniword::Builder::ParagraphBuilder.new
            para.numbering(num_id, 0) if num_id
            emit_item_content(item, para)
            doc << para
          end

          def emit_item_content(item, para)
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
