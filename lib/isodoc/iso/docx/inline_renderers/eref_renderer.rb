# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <eref> as an internal Word hyperlink to the bookmark of
        # the cited bibitem; without a bibitemid there is no target, so
        # the text is emitted unlinked.
        class ErefRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            target = element.bibitemid
            if target && !target.empty?
              link = Uniword::Hyperlink.new(anchor: target, text: text)
              link_model = link.to_model(allocator: doc.allocator)
              parent.apply_hyperlink_style(link_model)
              para << link_model
            else
              para << text
            end
          end
        end
      end
    end
  end
end
