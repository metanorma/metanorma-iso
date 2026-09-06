# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_3: <Subcommittee> subdivisions inside committee contributors
        # must use one of the allowed subtypes (SC, JSC).
        # Source: contributor[role/description='committee']/organization/
        # subdivision[@type='Subcommittee']/@subtype.
        class SubcommitteeTypeRule < Base
          code "ISO_3"

          ALLOWED_SUBTYPES = %w[SC JSC].freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibdata.nil?
          end

          def check(context)
            issues = []
            each_contributor_subdivision(context.root.bibdata, "committee") do |subdivision, type|
              next unless type == "Subcommittee"
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
