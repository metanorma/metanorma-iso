# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_6: bibdata/status/iteration must be a number (or absent).
        # The IsoDocument model types iteration as :integer, so non-numeric
        # XML fails to deserialize (caught at the orchestrator) and integer
        # values are returned numerically. This rule fires when the model
        # parses successfully but the value is non-numeric (defensive — should
        # not happen with the current integer typing, but preserves the
        # original ISO_6 contract for any future string-typed iteration).
        class IterationRule < Base
          code "ISO_6"

          def applicable?(context)
            !context.root.nil? && context.state&.document
          end

          def check(context)
            iteration = context.root.bibdata&.status&.iteration
            return [] if iteration.nil?
            return [] if iteration.to_s.match?(/\A\d+/)

            status = context.root.bibdata.status
            [build_issue(location: model_location(status),
                         params: [iteration.to_s])]
          end
        end
      end
    end
  end
end
