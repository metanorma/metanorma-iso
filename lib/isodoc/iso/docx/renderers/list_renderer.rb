# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders UnorderedList and OrderedList as a sequence of
        # numbering-applied paragraphs.
        #
        # Era C template provides:
        #   - ListContinue1 paragraph style for unordered-list items
        #     (the style itself carries numId=3, the dash bullet
        #     numbering definition)
        #   - decimal_list numId for ordered-list items
        #
        # OrderedList is a subclass of UnorderedList; both are registered
        # in the adapter's simple_renderers table. OrderedList must be
        # checked first (exact-class match wins) so it picks up the
        # decimal numbering ID rather than the dash-list fallback.
        class ListRenderer
          include Base

          def render(list, doc)
            if list.is_a?(Metanorma::Document::Components::Lists::OrderedList)
              render_ordered(list, doc)
            else
              render_unordered(list, doc)
            end
          end

          private

          def render_unordered(list, doc)
            num_id = @resolver.numbering_id(:dash_list)
            style = @resolver.paragraph_style(:list_continue1)
            Array(list.listitem).each do |item|
              render_item(item, doc, num_id, 0, style)
            end
          end

          def render_ordered(list, doc)
            num_id = numbering_id_for_type(list.type)
            Array(list.listitem).each do |item|
              render_item(item, doc, num_id, 0, nil)
            end
          end

          def numbering_id_for_type(type_attr)
            case type_attr
            when "arabic", "decimal", "alpha", "loweralpha", "roman", "lowerroman"
              @resolver.numbering_id(:decimal_list)
            else
              @resolver.numbering_id(:decimal_list)
            end
          end

          def render_item(item, doc, num_id, level, style_id)
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = style_id if style_id
            para.numbering(num_id, level) if num_id
            paragraphs = item.paragraphs
            if paragraphs && !paragraphs.empty?
              paragraphs.each { |p| @inline_renderer.render(p, para) }
            else
              @inline_renderer.render(item, para)
            end
            doc << para
          end
        end
      end
    end
  end
end
