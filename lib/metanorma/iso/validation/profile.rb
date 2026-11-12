# frozen_string_literal: true

require "yaml"

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
      #
      # Published profiles (issue #1720) are declarative selections over
      # the rule policy metadata, shipped as YAML under
      # +lib/metanorma/iso/validation/profiles/+. Load one with
      # {Profile.load}; see {Profile::Published}.
      class Profile
        attr_reader :name, :only_codes, :except_codes, :strict_warnings

        # Schema identifier of published profile files. Versioned: an
        # unrecognized schema aborts the load, so importers pin behavior.
        PROFILE_SCHEMA = "metanorma-validation-profile/1"

        # Directory of published profile files shipped with this gem.
        PROFILES_DIR = File.join(__dir__, "profiles").freeze

        class << self
          # Load a published profile by name from
          # {PROFILES_DIR}+/<name>.yml+. Raises ArgumentError when the
          # file does not exist or the schema is unrecognized.
          def load(name)
            path = File.join(PROFILES_DIR, "#{name}.yml")
            unless File.exist?(path)
              raise ArgumentError,
                    "unknown validation profile: #{name.inspect} " \
                    "(expected #{path})"
            end

            doc = YAML.safe_load_file(path, aliases: true)
            schema = doc["schema"]
            unless schema == PROFILE_SCHEMA
              raise ArgumentError,
                    "unsupported profile schema #{schema.inspect} in " \
                    "#{path} (expected #{PROFILE_SCHEMA.inspect})"
            end

            Published.new(
              name: doc["profile"] || name,
              flavor: doc["flavor"],
              selectors: doc["select"] || [],
              path: path,
            )
          end
        end

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

        # Model-layer rule classes outside the StyleRule hierarchy that
        # belong to the style-warning family.
        STYLE_LINT_CLASSES = %w[
          ListCountRule
          ListDepthRule
          ListPunctuationRule
          StyleDirectivesRefsRule
          StyleEmptyClauseRule
          StyleMixedListsRule
          StylePenultimateListRule
        ].freeze

        # The style-warning codes the PUBLICATION profile suppresses:
        # every StyleRule descendant's code (the ISO House Style text
        # lints), the explicit style-lint family codes, and the standoc
        # generic style sink the flavour inherits. One code per rule
        # (ISO-codes audit), so the family is enumerated; a new style
        # rule stays publication-suppressed by descending from StyleRule
        # or joining {STYLE_LINT_CLASSES}.
        STYLE_WARNING_CODES = (
          descendants = RuleRegistry.new.all
            .select { |cls| cls < Rules::StyleRule }
            .map(&:code_value)
          family = STYLE_LINT_CLASSES
            .filter_map { |name| Rules.const_get(name).code_value }
          (descendants + family + ["STANDOC_48"]).uniq.sort.freeze
        ).freeze

        # Style warnings suppressed; useful for publication-ready
        # documents where style lints have already been addressed.
        PUBLICATION = new(name: "publication",
                          except_codes: STYLE_WARNING_CODES)

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

        # A published profile: a declarative selection over the rule
        # policy metadata (Base.policy_metadata: mn_category, source,
        # category) plus explicit rule class names. Loaded via
        # {Profile.load}.
        #
        # Selection semantics: a +select:+ entry's keys are conjunctive
        # (all must match), entries are disjunctive (any may match). An
        # entry with a +class:+ key maps those class names directly.
        #
        #   select:
        #     - mn_category: style
        #       source: house_style
        #     - class: [StylePerCentRule]
        #
        # Selector values are plain YAML scalars; +mn_category+ and
        # +source+ are compared as symbols (+source+ matches when the
        # rule's source list INCLUDES the value), +category+ matches when
        # the value equals any of the rule's category entries. Rules
        # without policy metadata are only reachable through +class:+
        # entries.
        class Published < Profile
          attr_reader :flavor, :selectors, :path

          def initialize(name:, flavor: nil, selectors: [], path: nil)
            super(name: name)
            @flavor = flavor&.to_sym
            @selectors = selectors
            @path = path
          end

          # The rule classes this profile selects from a registry (any
          # object responding to +#all+ and returning rule classes, e.g.
          # {RuleRegistry}). Deterministic: sorted by class name.
          def select(registry)
            pool = registry.all
            metadata_selected = pool.select { |cls| matches_selectors?(cls) }
            class_selected = declared_classes(pool)
            (metadata_selected + class_selected).uniq.sort_by(&:name)
          end

          # Runtime-filter compatibility: instances of the selected
          # classes pass; others are dropped. Lets a published profile be
          # used anywhere a Profile is expected (e.g. ModelValidator.run).
          def select_rules(rule_instances)
            classes = select(RuleRegistry.new)
            rule_instances.select { |r| classes.include?(r.class) }
          end

          private

          def matches_selectors?(cls)
            selectors.any? { |entry| matches_entry?(cls, entry || {}) }
          end

          def matches_entry?(cls, entry)
            class_names = entry["class"]
            return Array(class_names).include?(short_name(cls)) if class_names

            %w[mn_category source category].all? do |key|
              next true unless entry[key]

              selector_matches?(cls, key, entry[key])
            end
          end

          def selector_matches?(cls, key, value)
            meta = cls.policy_metadata
            return false unless meta

            case key
            when "mn_category" then meta[:mn_category] == value.to_sym
            when "source" then Array(meta[:source]).include?(value.to_sym)
            when "category" then Array(meta[:category]).include?(value)
            end
          end

          def declared_classes(pool)
            selectors.flat_map { |e| Array(e && e["class"]) }.map do |short|
              pool.find { |cls| short_name(cls) == short } or
                raise ArgumentError,
                      "unknown rule class #{short.inspect} " \
                      "in profile #{name.inspect}"
            end
          end

          def short_name(cls)
            cls.name.split("::").last
          end
        end
      end
    end
  end
end
