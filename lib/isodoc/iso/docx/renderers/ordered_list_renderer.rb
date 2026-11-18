# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an OrderedList as ListNumber1..4 paragraphs (by nesting
        # depth) whose label ("a)", "1)", "i)", "A.", ...) is literal text
        # followed by a tab, exactly as ISO's own Word output does. The
        # label comes from the Presentation XML `li/fmt-name`, which
        # already encodes the list `type` (arabic, alphabet, roman,
        # alphabet_upper, roman_upper), the depth default and the per-list
        # restart. No numPr is emitted: the template numbering.xml has no
        # lettered list definitions, and literal labels restart for free.
        class OrderedListRenderer
          include Base
          include ListAttachments
          include ListItemContent

          def render(list, doc)
            style = @resolver.paragraph_style(:"list_number#{style_level}")
            Array(list.listitem).each { |item| render_item(item, doc, style) }
            render_attached_notes(list, doc)
          end

          private

          def render_item(item, doc, style_id)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style_id if style_id
            append_label(item, para)
            render_item_content(item, doc, para)
          end

          def append_label(item, para)
            label = collect_all_text(item.fmt_name)
            para << Uniword::Wordprocessingml::Run.new(text: label)
            para << Uniword::Wordprocessingml::Run.new(
              tab: Uniword::Wordprocessingml::Tab.new,
            )
          end
        end
      end
    end
  end
end
