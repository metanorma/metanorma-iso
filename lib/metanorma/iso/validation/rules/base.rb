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
          class << self
            attr_reader :code_value

            # Declare the ISO_N log key on the class. Required for every
            # concrete rule.
            def code(value)
              @code_value = value.to_s
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
          def build_issue(location:, params: [])
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: location, params: params
            )
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
