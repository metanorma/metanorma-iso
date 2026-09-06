# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Validation profile. Filters which rules run and configures
      # warning-severity behavior. Composable — new profiles are new
      # instances, no existing code changes (OCP).
      #
      # @example Built-in profiles
      #   Metanorma::Iso.validate(xml, profile: Profile::PUBLICATION)
      #   Metanorma::Iso.validate(xml, profile: Profile::STRICT)
      #
      # @example Custom profile
      #   profile = Profile.new(
      #     name: "ci",
      #     only_codes: ["ISO_5", "ISO_29", "ISO_30", "ISO_31"],
      #     strict_warnings: true
      #   )
      #   Metanorma::Iso.validate(xml, profile: profile)
      class Profile
        attr_reader :name, :only_codes, :except_codes, :strict_warnings

        def initialize(name: "default", only_codes: nil, except_codes: [],
                       strict_warnings: false)
          @name = name
          @only_codes = only_codes
          @except_codes = except_codes
          @strict_warnings = strict_warnings
        end

        # All rules run; warnings are not fatal.
        DEFAULT = new(name: "default")

        # All rules run; warnings are treated as errors (non-zero exit).
        STRICT = new(name: "strict", strict_warnings: true)

        # Style warnings suppressed; useful for publication-ready
        # documents where style lints have already been addressed.
        PUBLICATION = new(name: "publication",
                          except_codes: ["STANDOC_48"])

        # Filter a list of rule instances. Returns only the instances
        # whose +#code+ matches the profile's filter criteria.
        def select_rules(rule_instances)
          result = rule_instances
          result = result.select { |r| only_codes.include?(r.code) } if only_codes
          result = result.reject { |r| except_codes.include?(r.code) } unless except_codes.empty?
          result
        end

        # Whether a Report's findings should be treated as fatal.
        # When true, warnings (severity "warning") make the report
        # invalid alongside errors.
        def fatal_findings?(report)
          return !report.valid? unless strict_warnings

          report.issues.any? { |i| i.error? || i.warning? }
        end
      end
    end
  end
end
