# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_5: doctype must be one of the recognised ISO/Metanorma document
        # types. Rule reads from context.state.doctype (already populated by
        # the validator's content_validate which sets @doctype from
        # //bibdata/ext/doctype).
        class DoctypeRule < Base
          code "ISO_5"

          ALLOWED_DOCTYPES = %w[
            international-standard
            technical-specification
            technical-report
            publicly-available-specification
            international-workshop-agreement
            guide
            amendment
            technical-corrigendum
            committee-document
            addendum
            supplement
            extract
            recommendation
          ].freeze

          def applicable?(context)
            context.state && !context.state.amd
          end

          def check(context)
            doctype = context.state.doctype
            return [] if doctype.nil? || doctype.to_s.empty?
            return [] if ALLOWED_DOCTYPES.include?(doctype)

            [build_issue(location: nil, params: [doctype])]
          end
        end
      end
    end
  end
end