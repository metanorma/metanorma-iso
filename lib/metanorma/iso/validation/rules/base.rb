# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Base class for ISO validation rules. Subclasses declare their log
        # key via +code "ISO_N"+ and implement +#check(context)+ to return an
        # Array of Lutaml::Model::Validation::Issue. Severity/category/message
        # template are looked up from +ISO_LOG_MESSAGES+ by code (DRY: the
        # log_messages hash stays the single source of truth).
        #
        # Shared navigation helpers (descendants, extract_text,
        # closest_ancestor, each_anchored) are added incrementally as rule
        # TODOs need them. The foundation ships the minimum.
        class Base < Lutaml::Model::Validation::Rule
          include TreeTraversal

          # Policy documentation metadata vocabulary (issue #1709).
          POLICY_KEYS = %i[category rule source directives mn_category].freeze
          POLICY_SOURCES = %i[house_style directives].freeze
          POLICY_MN_CATEGORIES = %i[style structure references].freeze

          class << self
            # Mark a class as abstract — RuleRegistry skips abstract
            # classes when discovering runnable rules. Used by StyleRule
            # and other base classes in the rule hierarchy.
            def abstract!
              @abstract_rule = true
            end

            def abstract_rule?
              @abstract_rule == true
            end

            # Code value declared via +code "ISO_N"+. Walks up the
            # inheritance chain so a subclass inherits its parent's code
            # unless it declares its own. Style rules declare their own
            # code per class: the log code is the suppression key, so one
            # code per rule and no sharing.
            def code_value
              return @code_value if instance_variable_defined?(:@code_value) && @code_value

              sup = superclass
              sup.respond_to?(:code_value) ? sup.code_value : nil
            end

            # Declare the ISO_N log key on the class.
            def code(value)
              @code_value = value.to_s
            end

            # Policy documentation metadata (issue #1709). Declared per rule
            # class; consumed by the validation-policy-page generator.
            #
            #   policy category: "Punctuation > Lists",
            #                    rule: "no more than one numbered list per clause",
            #                    source: :house_style, mn_category: :style
            #   directives "24.3" # when the rule restates a DIR 2 clause
            #
            # +category+ is the rule's path in the policy-document tree
            # (a String, or an Array of Strings when one rule spans several
            # sections). +source+ is :house_style ("ISO House Style",
            # www.iso.org/ISO-house-style.html), :directives ("ISO/IEC
            # Directives Part 2:2021"), or an Array of both when the rule
            # cites both. +mn_category+ is the metanorma functional view:
            # :style, :structure or :references. Declarations accumulate
            # across calls; +directives+ widens a :house_style-only source
            # to cite both sources. Rules without declarations carry nil
            # metadata; the coverage spec (policy_metadata_spec) enforces
            # completeness.
            def policy(**opts)
              unknown = opts.keys - POLICY_KEYS
              unless unknown.empty?
                raise ArgumentError,
                      "unknown policy metadata keys: #{unknown.inspect}"
              end

              @policy_metadata = (policy_metadata || {}).merge(opts)
              normalize_policy_metadata!
            end

            # Declare the ISO/IEC Directives Part 2 clause the rule
            # restates ("24.3"). Marks the rule as citing the Directives:
            # a :house_style-only source widens to cite both sources.
            def directives(clause)
              policy(directives: clause.to_s)
            end

            # Accumulated policy metadata hash, or nil when the rule class
            # declares none.
            def policy_metadata
              @policy_metadata
            end

            private

            # Keep the metadata coherent: declared values must come from the
            # policy vocabulary, and a declared Directives clause implies the
            # :directives source (widening a scalar :house_style into the
            # both-sources Array). Deterministic and order-independent.
            def normalize_policy_metadata!
              meta = @policy_metadata
              validate_policy_values!(meta)

              source = meta[:source]
              return unless meta[:directives]
              return if source && Array(source).include?(:directives)

              meta[:source] = source.nil? ? :directives : Array(source) + [:directives]
            end

            def validate_policy_values!(meta)
              invalid_sources = Array(meta[:source]).reject do |s|
                POLICY_SOURCES.include?(s)
              end
              unless invalid_sources.empty?
                raise ArgumentError,
                      "unknown policy sources: #{invalid_sources.inspect}"
              end

              mn = meta[:mn_category]
              return unless mn && !POLICY_MN_CATEGORIES.include?(mn)

              raise ArgumentError, "unknown mn_category: #{mn.inspect}"
            end
          end

          # Override Lutaml::Model::Validation::Rule#code to return the
          # DSL-declared value. Raises if a subclass forgets +code "ISO_N"+.
          def code
            value = self.class.code_value
            return value if value

            raise NotImplementedError,
                  "#{self.class} must declare `code \"ISO_N\"`"
          end

          def category
            log_spec[:category].to_s
          end

          # Map ISO_LOG_MESSAGES severity (0/1/2/3) to Issue severity
          # (error/warning/info). 0=abort and 2=serious both map to "error"
          # so the IssueTranslator and Report treat them identically; the
          # distinction is preserved in the message itself.
          def severity
            case log_spec[:severity]
            when 1 then "warning"
            when 3 then "info"
            else "error"
            end
          end

          def applicable?(_context)
            true
          end

          def check(_context)
            []
          end

          private

          def log_spec
            self.class.log_messages.fetch(code.to_sym) { default_log_spec }
          end

          def default_log_spec
            { category: "Unknown", severity: 2, error: "%s" }
          end

          # Build a Metanorma::Iso::Validation::Issue carrying the rule's code,
          # severity, category, formatted message, AND raw params. The raw
          # params let IssueTranslator hand them to @log.add without
          # re-interpolation; the formatted message lets Reporters render
          # without re-running the template.
          #
          # The standardized policy citation suffix is appended from the
          # rule's policy_metadata — one chokepoint per layer, per the
          # owner's citation ruling: every rule-emitted validation message
          # ends with the "(ISO House Style (2026), <category path>)" /
          # "(ISO/IEC DIR 2:2021, <clause>)" citation. Rules without
          # metadata emit uncited (the coverage specs enforce metadata
          # completeness); the decorator never raises.
          def build_issue(location:, params: [])
            suffix = Metanorma::Iso::Validation::Citation
              .suffix(self.class.policy_metadata)
            params = cited_params(params, suffix)
            issue = Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: location, params: params
            )
            return issue if suffix.nil? || issue.message.end_with?(suffix)

            issue.message = "#{issue.message} #{suffix}"
            issue
          end

          # The @log pipeline renders the registry template over the raw
          # params: a "%s" template renders its single fully-worded param
          # verbatim, so the citation rides the param and BOTH pipelines
          # (log and Report) carry it at the end of the message. Structured
          # or static templates would land the citation mid-message, so
          # those are decorated at the Issue-message level only.
          def cited_params(params, suffix)
            return params if suffix.nil? || params.empty?
            return params unless log_spec[:error] == "%s"

            params[0..-2] + ["#{params.last} #{suffix}"]
          end

          # Model-based location string for an Issue. Returns nil for nil
          # nodes; "ClassName#id" when the model has an id; "ClassName"
          # otherwise. NEVER produces XPath — locations are diagnostic
          # labels, not XML queries.
          def model_location(node)
            return nil if node.nil?

            class_name = node.class.name.split("::").last
            id = read_id(node)
            return class_name if id.nil? || id.to_s.empty?

            "#{class_name}##{id}"
          end

          # Read +id+ from a model node if (and only if) the node's class
          # declares an :id attribute. Uses method_defined? rather than
          # respond_to? to keep type checks static (per project rules).
          def read_id(node)
            return nil unless node.class.method_defined?(:id)

            value = node.id
            return nil if value.nil? || value.to_s.empty?

            value
          end

          def format_message(template, params)
            return template if params.empty?
            return template unless template.include?("%")

            template % Array(params)
          rescue ArgumentError
            template
          end

          # Shared helpers (added incrementally as rule TODOs need them):
          # - descendants(node)
          # - extract_text(node, strip: [])
          # - closest_ancestor(node, type)
          # - each_anchored(root)

          def self.log_messages
            Metanorma::Iso::Converter::ISO_LOG_MESSAGES
          end
        end
      end
    end
  end
end
