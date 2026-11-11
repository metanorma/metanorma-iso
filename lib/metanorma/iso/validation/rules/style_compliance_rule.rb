# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for "compliance"/"compliant" (ISO House Style:
        # use "conformity"/"conforming"; "compliance" is reserved for
        # legislation and regulatory instruments).
        class StyleComplianceRule < StyleRule
          COMPLIANCE_REGEX =
            /\b(compliance|compliant|non-compliance|noncompliance|
                non-compliant|noncompliant)\b/xi.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, COMPLIANCE_REGEX,
              "style: '%s' (use 'conformity'/'conforming'; House Style " \
              "reserves 'compliance' for legislation)"
            )
          end
        end
      end
    end
  end
end
