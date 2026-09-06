# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_31: document must contain a Terms & definitions section
        # (sections/terms).
        class TermsPresenceRule < Base
          code "ISO_31"

          def applicable?(context)
            !context.root.nil? && !context.state.amd
          end

          def check(context)
            return [] unless context.root.sections
            return [] unless context.root.sections.terms.nil?

            [build_issue(location: "IsoSections", params: [])]
          end
        end
      end
    end
  end
end
