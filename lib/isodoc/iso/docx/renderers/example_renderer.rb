# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Example block as a Box-wrapped region. The example's
        # body content (paragraphs, lists, etc.) is walked via the shared
        # walker; each child is dispatched normally but inside an
        # +@context.with_example+ zone so children pick up Exampleindent
        # body style via Context#zone.
        class ExampleRenderer
          include Base
          include BoxWrapper

          def render(example, doc)
            @context.with_example do
              with_box(doc) do
                @walker.walk(example, doc)
              end
            end
          end
        end
      end
    end
  end
end
