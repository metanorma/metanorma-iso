# frozen_string_literal: true

require "yaml"

module Metanorma
  module Iso
    module Validation
      # Flavor registry composition (issue #1720).
      #
      # A flavor's effective rule registry = flavor-local rules ∪
      # (imported profile selections − exceptions), with flavor shadowing
      # precedence: when the flavor itself defines a rule class with the
      # same code as an imported class, the flavor-local class wins.
      #
      # Import declarations live in the flavor's own gem, under
      # +lib/metanorma/<flavor>/validation_profile/*.yml+ (mirroring the
      # conform-profile directory pattern):
      #
      #   schema: metanorma-validation-profile/1
      #   flavor: bsi
      #   imports:
      #     - profile: house-style          # published metanorma-iso profile
      #       cite_as: "BSI style"          # flavor attribution for findings
      #     - profile: quality-english      # general tier (opt-in)
      #       cite_as: "BSI style"
      #       severity: warning             # imported rules may be re-severitied
      #     - class: [StyleOrdinalsRule]    # cherry-pick by stable class name
      #       except: [StyleNoNosRule, ISO_28]  # class names or codes
      #
      # {ComposedRegistry.for} is the discovery entry point; when the
      # flavor ships no declarations (or there is no flavor), the
      # composed registry carries exactly the plain {RuleRegistry} set —
      # a behavioral no-op, so the existing pipeline (validation runner,
      # policy generator, suppression baseline) consumes it transparently
      # through +#all+.
      #
      # Per-rule metadata of the active composition is exposed for
      # downstream consumers:
      #   - {#severity_override_for}: re-severitiation declared at import
      #     time (carried as entry metadata; runtime application hooks
      #     into the suppression/severity pipeline).
      #   - {#attribution_for}: flavor-attributed reporting (issue #1720).
      #     Imported rules carry the import entry's +cite_as:+ (defaulting
      #     to "<FLAVOR> style"); flavor-local and non-imported rules carry
      #     nil, meaning "use the rule's own policy_metadata citation".
      #     Message decoration must read the citation from the ACTIVE
      #     COMPOSITION (via the run Context's +registry+), never from
      #     hardcoded metadata, so "if a flavor uses a general rule, it is
      #     reported as the flavor's own rule" holds by construction.
      class ComposedRegistry
        # Schema identifier of import declaration files.
        DECLARATION_SCHEMA = "metanorma-validation-profile/1"

        # One composed rule: the class plus the metadata its import (or
        # flavor-local discovery) attached to it.
        Entry = Struct.new(:rule_class, :severity, :cite_as, :source,
                           keyword_init: true)

        class << self
          # Compose the effective registry for +flavor+ (the string a
          # flavor's Validate subclass declares via +validation_flavor+).
          #
          # Reads every +lib/metanorma/<flavor>/validation_profile/*.yml+
          # of the flavor's installed gem. When the flavor is nil, its
          # gem is not installed, or it ships no declaration directory,
          # the composition carries exactly the plain {RuleRegistry} set.
          def for(flavor:)
            return fallback_registry if flavor.nil?

            spec = flavor_gem_spec(flavor)
            return fallback_registry unless spec

            dir = File.join(spec.gem_dir, "lib", "metanorma", flavor,
                            "validation_profile")
            # Sorted parse order: later declarations override earlier
            # ones in imported_entries, so composition is deterministic.
            files = Dir[File.join(dir, "*.yml")].sort
            return fallback_registry if files.empty?

            imports = files.flat_map { |f| parse_declaration(f, flavor) }
            compose(flavor: flavor, imports: imports, declared_at: dir)
          end

          # Core composition over already-parsed import declaration
          # hashes. The seam used by {ComposedRegistry.for} and exercised
          # directly by specs (no gem lookup needed).
          def compose(flavor:, imports:, declared_at: nil)
            new(flavor: flavor, imports: imports, declared_at: declared_at)
          end

          # Parse one import declaration file. Public: declaration
          # validation is a unit of its own (schema and flavor checks).
          def parse_declaration(path, flavor)
            doc = YAML.safe_load_file(path, aliases: true)
            unless doc["schema"] == DECLARATION_SCHEMA
              raise ArgumentError,
                    "unsupported declaration schema #{doc['schema'].inspect} " \
                    "in #{path} (expected #{DECLARATION_SCHEMA.inspect})"
            end
            declared_flavor = doc["flavor"]
            unless declared_flavor.nil? || declared_flavor == flavor
              raise ArgumentError,
                    "declaration #{path} declares flavor " \
                    "#{declared_flavor.inspect}, composed for #{flavor.inspect}"
            end

            Array(doc["imports"])
          end

          private

          def flavor_gem_spec(flavor)
            Gem::Specification.find_by_name("metanorma-#{flavor}")
          rescue Gem::MissingSpecError
            nil
          end

          # The behavioral no-op: a composition carrying exactly the
          # plain registry, no import metadata.
          def fallback_registry
            compose(flavor: nil, imports: [])
          end
        end

        # +imports+: parsed declaration hashes (profile:/class:/except:/
        # severity:/cite_as:). +declared_at+: the declaration directory,
        # when composed through {ComposedRegistry.for}.
        def initialize(flavor:, imports:, declared_at: nil)
          @flavor = flavor
          @imports = imports
          @declared_at = declared_at
          @entries = build_entries
        end

        attr_reader :flavor, :imports, :declared_at

        # All composed rule classes, RuleRegistry-compatible (sorted by
        # class name). The existing pipeline consumes this transparently.
        def all
          @entries.map(&:rule_class)
        end

        # All composed entries with their import metadata.
        def entries
          @entries.dup
        end

        # Severity override declared for +klass+ at import time, or nil.
        def severity_override_for(klass)
          entry_for(klass)&.severity
        end

        # Citation the ACTIVE COMPOSITION attributes to +klass+ findings,
        # or nil for flavor-local / non-imported rules (meaning: use the
        # rule's own policy_metadata citation).
        def attribution_for(klass)
          entry_for(klass)&.cite_as
        end

        # Which import (profile or class list) brought +klass+ in, or
        # :flavor_local / :registry.
        def origin_of(klass)
          entry_for(klass)&.source
        end

        private

        def entry_for(klass)
          @entries.find { |e| e.rule_class == klass }
        end

        def build_entries
          return fallback_entries if imports.empty?

          composed = imported_entries
          local = flavor_local_entries
          # Shadowing precedence: flavor > imported, by rule CODE. When
          # the flavor itself defines a rule class carrying an imported
          # rule's code, its own class replaces the imported entry.
          shadowed_codes = local.keys.map(&:code_value)
          composed.reject! { |klass, _| shadowed_codes.include?(klass.code_value) }
          composed.merge!(local)
          composed.values.sort_by { |e| e.rule_class.name }
        end

        # The behavioral no-op: exactly the plain RuleRegistry set, no
        # import metadata. Used when a flavor (or composition) declares
        # no imports.
        def fallback_entries
          RuleRegistry.new.all.map do |klass|
            Entry.new(rule_class: klass, severity: nil, cite_as: nil,
                      source: :registry)
          end.sort_by { |e| e.rule_class.name }
        end

        # imported_entries: profile/class selections − exceptions.
        # Shadowing is applied in {build_entries}: a flavor-local class
        # with the same code replaces the imported entry.
        def imported_entries
          pool = RuleRegistry.new.all
          imports.each_with_object({}) do |imp, h|
            classes = classes_for_import(imp, pool) - excepted_classes(imp, pool)
            classes.each do |klass|
              h[klass] = Entry.new(
                rule_class: klass,
                severity: severity_for(imp, klass),
                cite_as: cite_for(imp),
                source: import_source(imp),
              )
            end
          end
        end

        def flavor_local_entries
          flavor_local_rules.to_h do |klass|
            [klass, Entry.new(rule_class: klass, severity: nil,
                              cite_as: nil, source: :flavor_local)]
          end
        end

        def classes_for_import(imp, pool)
          profile_name = imp["profile"]
          class_names = imp["class"]
          if profile_name
            Profile.load(profile_name).select(RuleRegistry.new)
          elsif class_names
            Array(class_names).map do |short|
              pool.find { |cls| short_name(cls) == short } or
                raise ArgumentError,
                      "unknown rule class #{short.inspect} in import " \
                      "declaration #{declared_at.inspect}"
            end
          else
            raise ArgumentError,
                  "import entry needs profile: or class: " \
                  "(got #{imp.keys.inspect})"
          end
        end

        # Except tokens resolve against the rule pool: stable class names
        # map directly; codes resolve to every class carrying that code
        # (via the rules' code declarations). Unknown tokens are an error.
        def excepted_classes(imp, pool)
          Array(imp["except"]).flat_map do |token|
            by_name = pool.find { |cls| short_name(cls) == token }
            next [by_name] if by_name

            by_code = pool.select { |cls| cls.code_value == token }
            if by_code.empty?
              raise ArgumentError,
                    "unknown except token #{token.inspect} (no rule class " \
                    "name or code matches) in import declaration " \
                    "#{declared_at.inspect}"
            end

            by_code
          end
        end

        # severity: a scalar applies to every class of the import entry;
        # a hash cherry-picks per class name or code (unknown keys are an
        # error).
        def severity_for(imp, klass)
          severity = imp["severity"]
          case severity
          when String then severity
          when Hash
            value = severity[short_name(klass)] || severity[klass.code_value]
            value || severity["*"]
          when nil then nil
          else
            raise ArgumentError,
                  "unsupported severity #{severity.inspect} in import " \
                  "declaration #{declared_at.inspect}"
          end
        end

        # Flavor-attributed reporting: the import entry's cite_as, or
        # "<FLAVOR> style" (the importing flavor's own policy name).
        def cite_for(imp)
          imp["cite_as"] || "#{flavor.to_s.upcase} style"
        end

        def import_source(imp)
          imp["profile"] || Array(imp["class"])
        end

        # Rule classes the flavor itself defines, discovered from
        # Metanorma::<Flavor>::Validation::Rules when that namespace
        # exists. Flavor-local classes inherit Rules::Base and shadow
        # imported classes by code.
        def flavor_local_rules
          mod_name = flavor.to_s.split(/[_-]/).map(&:capitalize).join
          return [] unless defined?(Metanorma) && Metanorma.const_defined?(mod_name)

          flavor_mod = Metanorma.const_get(mod_name)
          return [] unless flavor_mod.const_defined?(:Validation)

          validation = flavor_mod.const_get(:Validation)
          return [] unless validation.const_defined?(:Rules)

          walk_rules(validation.const_get(:Rules))
        end

        def walk_rules(rules_mod)
          rules_mod.constants.sort
            .map { |name| rules_mod.const_get(name) }
            .select do |const|
              const.is_a?(Class) &&
                const < Metanorma::Iso::Validation::Rules::Base &&
                !const.abstract_rule?
            end
        end

        def short_name(cls)
          cls.name.split("::").last
        end
      end
    end
  end
end
