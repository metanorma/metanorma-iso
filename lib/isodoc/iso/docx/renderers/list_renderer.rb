# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders UnorderedList and OrderedList as a sequence of
        # numbering-applied paragraphs.
        #
        # OrderedList is a subclass of UnorderedList; both are registered
        # in the adapter's simple_renderers table. OrderedList must be
        # checked first (exact-class match wins) so it picks up the
        # decimal numbering ID rather than the dash-list fallback.
        class ListRenderer
          include Base

          def render(list, doc)
            num_id = numbering_id_for(list)
            Array(list.listitem).each do |item|
              render_numbered_item(item, doc, num_id, 0)
            end
          end

          private

          def numbering_id_for(list)
            if list.is_a?(Metanorma::Document::Components::Lists::OrderedList)
              numbering_id_for_type(list.type)
            else
              @resolver.numbering_id(:dash_list)
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

          def render_numbered_item(item, doc, num_id, level)
            para = Uniword::Builder::ParagraphBuilder.new
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
