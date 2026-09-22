# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an UnorderedList as a sequence of dash-bullet paragraphs
        # carrying the Era C `ListContinue1` paragraph style.
        #
        # `ListContinue1` itself carries numPr=numId 3 (dash bullets), so
        # the style alone produces both visual formatting AND numbering.
        # We still set the numId explicitly to be robust against templates
        # where `ListContinue1` does not carry its own numPr.
        class UnorderedListRenderer
          include Base

          def render(list, doc)
            num_id = @resolver.numbering_id(:dash_list)
            style = @resolver.paragraph_style(:list_continue1)
            Array(list.listitem).each do |item|
              render_item(item, doc, num_id, style)
            end
          end

          private

          def render_item(item, doc, num_id, style_id)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style_id if style_id
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
