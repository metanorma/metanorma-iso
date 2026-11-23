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
            text = parent.collect_all_text(element)
            target = element.target
            target = nil if target.to_s.strip.empty?

            if text.nil? || text.empty?
              text = target
              text = text.sub(/\Amailto:/, "") if text&.start_with?("mailto:")
            end
            return if text.nil? || text.empty?

            if target
              link = Uniword::Hyperlink.new(url: target, text: text)
              model = hyperlink_model(link, target)
              parent.apply_hyperlink_style(model)
              para << model
            else
              run = Uniword::Builder::RunBuilder.new
              run.text(text).underline.color("0000FF")
              para << run.build
            end
          end

          private

          # A footnote body is written to word/footnotes.xml, whose
          # relationships are separate from the document's.
          def hyperlink_model(link, target)
            return link.to_model(allocator: doc.allocator) unless parent.in_footnote_body?

            link.to_model.tap { |m| m.id = parent.footnote_hyperlink_rid(target) }
          end
        end
      end
    end
  end
end
