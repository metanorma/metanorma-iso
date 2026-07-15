# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an empty horizontal-rule element as a DOCX horizontal rule.
        # The model node carries no content; the side effect is on +doc+.
        class HorizontalRuleRenderer
          def render(_node, doc)
            doc.horizontal_rule
          end
        end
      end
    end
  end
end
