# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Example block with the XSL inline-label layout:
        # the label ("EXAMPLE") runs inline at the head of the first
        # body paragraph (full-width Example style), and 2nd+ body
        # paragraphs pick up Exampleindent (Exampleindentcontinued)
        # via Context#zone + StyleResolver — the XSL renders example
        # bodies beyond the first inline element inside a container
        # indented 7mm on both sides (example-body-style).
        #
        # This mirrors iso.international-standard.xsl's example
        # contract — inline label, no border, no shading — where the
        # Era C template previously drew a Box-begin/Box-title/
        # Box-end grey box around every example.
        #
        # XSL "block" mode (example contains a table or definition
        # list, or its first child is not a plain paragraph) places
        # the label in its own keep-with-next paragraph; the body
        # walk then proceeds through the normal dispatch path so
        # every body paragraph lands in the indented zone style.
        class ExampleRenderer
          include Base
          include BoxWrapper

          def render(example, doc)
            @context.with_example do
              with_inline_label(example, doc, :example)
            end
          end
        end
      end
    end
  end
end
