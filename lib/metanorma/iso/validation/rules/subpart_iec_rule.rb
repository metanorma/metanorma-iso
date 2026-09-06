# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_16: subpart (docidentifier matching /-\d+-\d+/) is only valid
        # on IEC documents. Flags when an ISO docid has a subpart pattern
        # but no IEC publisher. ISO/IEC DIR 2, 11.4.
        class SubpartIecRule < Base
          code "ISO_16"

          SUBPART_PATTERN = /-\d+-\d+/.freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibdata.nil?
          end

          def check(context)
            docid = find_docidentifier(context.root.bibdata, "ISO")
            return [] unless docid
            return [] unless subpart?(docid)
            return [] if iec_publisher?(context.root.bibdata)

            [build_issue(location: model_location(docid), params: [])]
          end

          private

          def subpart?(docid)
            value = docid_value(docid)
            return false if value.nil?

            SUBPART_PATTERN.match?(value)
          end

          def docid_value(docid)
            return docid.value unless docid.class.method_defined?(:value)

            docid.value
          end
        end
      end
    end
  end
end
