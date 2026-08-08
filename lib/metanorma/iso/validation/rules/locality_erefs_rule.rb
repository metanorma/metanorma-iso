# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_49: undated references to ISO/IEC documents must not cite
        # specific elements (no locality). Flags erefs where citeas starts
        # with ISO/IEC, doesn't end with year or en-dash, AND has a
        # locality stack.
        class LocalityErefsRule < Base
          code "ISO_49"

          ISO_IEC_PREFIX = /\A(ISO|IEC)/.freeze
          DATED_SUFFIX = /: ?(\d{4}|–)\z/.freeze

          def applicable?(context)
            !context.root.nil?
          end

          def check(context)
            issues = []
            each_eref(context.root) do |eref|
              next unless has_locality?(eref)
              citeas = eref.citeas.to_s
              next unless ISO_IEC_PREFIX.match?(citeas)
              next if DATED_SUFFIX.match?(citeas)

              issues << build_issue(location: model_location(eref),
                                    params: [citeas])
            end
            issues
          end

          private

          def has_locality?(eref)
            return false unless eref.class.method_defined?(:locality_stack)

            !Array(eref.locality_stack).empty?
          end
        end
      end
    end
  end
end
