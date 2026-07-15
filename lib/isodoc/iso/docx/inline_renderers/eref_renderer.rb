# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <eref> as a Word hyperlink whose URL is the cite key
        # (so cross-document links resolve via Word's bookmark target).
        class ErefRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            cite = element.citeas || element.bibitemid
            if cite && !cite.empty?
              link = Uniword::Hyperlink.new(url: "##{cite}", text: text)
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
