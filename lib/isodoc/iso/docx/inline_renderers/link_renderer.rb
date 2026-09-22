# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <link target="..."> as a Word external hyperlink. When
        # the element has no visible text, the target URL is used (with
        # any +mailto:+ prefix stripped).
        class LinkRenderer
          include Base

          def render(element, para)
            text = parent.collect_text(element)
            target = element.target

            if text.nil? || text.empty?
              text = target
              text = text.sub(/\Amailto:/, "") if text&.start_with?("mailto:")
            end
            return if text.nil? || text.empty?

            if target
              link = Uniword::Hyperlink.new(url: target, text: text)
              model = link.to_model(allocator: doc.allocator)
              parent.apply_hyperlink_style(model)
              para << model
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
