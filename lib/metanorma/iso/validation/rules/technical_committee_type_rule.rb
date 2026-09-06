# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_2: <Technical committee> subdivisions inside committee
        # contributors must use one of the allowed subtypes (TC, PC, JTC, JPC).
        # Source: contributor[role/description='committee']/organization/
        # subdivision[@type='Technical committee']/@subtype.
        class TechnicalCommitteeTypeRule < Base
          code "ISO_2"

          ALLOWED_SUBTYPES = %w[TC PC JTC JPC].freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibdata.nil?
          end

          def check(context)
            issues = []
            each_contributor_subdivision(context.root.bibdata, "committee") do |subdivision, type|
              next unless type == "Technical committee"
              next if ALLOWED_SUBTYPES.include?(subtype_text(subdivision))

              issues << build_issue(location: nil,
                                    params: [subtype_text(subdivision)])
            end
            issues
          end

          private

          def subtype_text(subdivision)
            subdivision.subtype.to_s
          end
        end
      end
    end
  end
end
