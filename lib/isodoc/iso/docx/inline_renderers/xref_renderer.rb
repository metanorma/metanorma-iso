# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <xref target="..."> as a Word internal hyperlink (anchor).
        class XrefRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            target = element.target
            if target
              link = Uniword::Hyperlink.new(anchor: target, text: text)
              link_model = link.to_model(allocator: doc.allocator)
              parent.apply_hyperlink_style(link_model)
              para << link_model
            else
              run = Uniword::Builder::RunBuilder.new
              run.text(text).underline.color("0000FF")
              para << run.build
            end
          end
        end
      end
    end
  end
end
