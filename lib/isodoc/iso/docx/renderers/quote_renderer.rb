# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a block quote. Era C splits the layout into two styles:
        #   - Disp-quotep     — the quoted body paragraphs
        #   - Disp-quoteattrib — the attribution paragraph (e.g. source)
        #
        # The body is walked via +#@walker+ so multi-paragraph quotes
        # produce one Disp-quotep paragraph per <p> child rather than
        # collapsing into a single run-flattened paragraph.
        class QuoteRenderer
          include Base

          def render(quote, doc)
            render_body(quote, doc)
            render_attribution(quote, doc)
          end

          private

          def render_body(quote, doc)
            paragraphs = quote_paragraphs(quote)
            if paragraphs.empty?
              para = build_paragraph(:quote)
              @inline_renderer.render(quote, para)
              doc << para
              return
            end

            paragraphs.each do |p|
              para = build_paragraph(:quote)
              @inline_renderer.render(p, para)
              doc << para
            end
          end

          def render_attribution(quote, doc)
            attribution = quote_attr(quote, :attribution)
            return unless attribution

            Array(quote_attr(attribution, :p)).each do |p|
              para = build_paragraph(:quote_attributor)
              @inline_renderer.render(p, para)
              doc << para
            end
          end

          def quote_paragraphs(quote)
            Array(quote_attr(quote, :paragraphs))
          end

          def quote_attr(node, attr)
            return nil unless node.class.attributes.key?(attr)

            node.public_send(attr)
          end
        end
      end
    end
  end
end
