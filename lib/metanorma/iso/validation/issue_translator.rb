# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Single sink for every validation finding. Translates Layer 1 errors
      # (Lutaml::Model::*Error) and Layer 3 Issues
      # (Lutaml::Model::Validation::Issue) into both:
      #   1. @log.add(code, location, params: [...]) — preserves the existing
      #      error-reporting pipeline (renders to .err.html).
      #   2. Report#add_issue — accumulates the structured Report used by
      #      Reporters (text/json/yaml).
      #
      # Rules emit raw findings via Base#build_issue; the orchestrator hands
      # every Issue to translate_layer3. Layer 1 declarations trigger
      # Lutaml::Model errors which the orchestrator hands to translate_layer1.
      # Neither rules nor Layer 1 know about @log or Report — only this class
      # does (DRY).
      class IssueTranslator
        def initialize(log:, report:)
          @log = log
          @report = report
        end

        # layer1_errors: Array of StandardError subclasses raised by
        # Lutaml::Model::Serializable#validate (InvalidValueError,
        # PatternNotMatchedError, RequiredAttributeMissingError, etc.).
        def translate_layer1(layer1_errors)
          layer1_errors.each { |err| add(**classify_layer1(err)) }
        end

        # layer3_issues: Array of Lutaml::Model::Validation::Issue produced
        # by Lutaml::Model::Validation.validate(context, registry).
        def translate_layer3(layer3_issues)
          layer3_issues.each do |issue|
            add(code: issue.code, location: issue.location,
                params: extract_params(issue))
          end
        end

        private

        def add(code:, location:, params: [])
          return unless code

          @log.add(code, nil, params: params) if @log
          @report.add_issue(code: code, location: location, params: params)
        end

        # Layer 1 errors are mapped to ISO_F_<attr> codes by the IssueTranslator
        # as Layer 1 declarations are introduced. Unmapped errors default to
        # STANDOC_7 (Metanorma XML Syntax) — the closest existing category.
        LAYER1_DEFAULT_CODE = "STANDOC_7"

        LAYER1_CODE_BY_ERROR = {
          "Lutaml::Model::InvalidValueError" => "STANDOC_7",
          "Lutaml::Model::PatternNotMatchedError" => "STANDOC_7",
          "Lutaml::Model::RequiredAttributeMissingError" => "STANDOC_7",
          "Lutaml::Model::CollectionCountOutOfRangeError" => "STANDOC_7",
          "Lutaml::Model::IncorrectSequenceError" => "STANDOC_7",
          "Lutaml::Model::ChoiceUpperBoundError" => "STANDOC_7",
          "Lutaml::Model::ChoiceLowerBoundError" => "STANDOC_7"
        }.freeze

        def classify_layer1(err)
          code = LAYER1_CODE_BY_ERROR.fetch(err.class.name) { LAYER1_DEFAULT_CODE }
          { code: code, location: nil, params: [safe_message(err)] }
        end

        # Some lutaml-model error classes have buggy #to_s/#message implementations
        # (e.g. CollectionCountOutOfRangeError calls .end on a non-Range). Wrap
        # so a translator failure doesn't mask the underlying validation error.
        def safe_message(err)
          err.message
        rescue StandardError => e
          "#{err.class.name} (translator note: message raised #{e.class})"
        end

        # Lutaml::Model::Validation::Issue has no +params+ field; we use
        # +message+ as the single param so @log can interpolate it into
        # STANDOC_48 / STANDOC_7 templates ("%s").
        def extract_params(issue)
          issue.message ? [issue.message] : []
        end
      end
    end
  end
end
