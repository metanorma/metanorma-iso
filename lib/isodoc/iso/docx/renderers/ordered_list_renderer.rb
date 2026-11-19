# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an OrderedList as a sequence of numbering-applied
        # paragraphs (ListNumber1..4 by nesting depth) using the Era C
        # decimal_list numId (1, 2, 3, ...).
        #
        # Era C's 7-abstractNum scheme exposes decimal ordered-list
        # numbering as numId 1 (and 2 as an alt referencing the same
        # abstractNum). The numbering ID flows from `style_mapping.yml`
        # via StyleResolver — this renderer holds no literal styleId
        # or numId.
        class OrderedListRenderer
          include Base
          include ListAttachments
          include ListItemContent

          def render(list, doc)
            num_id = @resolver.numbering_id(:decimal_list)
            style = @resolver.paragraph_style(:"list_number#{style_level}")
            Array(list.listitem).each do |item|
              render_item(item, doc, num_id, style)
            end
            render_attached_notes(list, doc)
          end

          private

          def render_item(item, doc, num_id, style_id)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style_id if style_id
            para.numbering(num_id, list_level) if num_id
            render_item_content(item, doc, para)
          end
        end
      end
    end
  end
end
