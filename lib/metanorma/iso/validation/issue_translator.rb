# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Single sink for every validation finding. Translates Layer 1 errors
      # (Lutaml::Model::*Error) and Layer 3 Issues
      # (Metanorma::Iso::Validation::Issue) into both:
      #   1. @log.add(code, location, params: [...]) — preserves the existing
      #      error-reporting pipeline (renders to .err.html). The log does
      #      its own template interpolation from ISO_LOG_MESSAGES, so raw
      #      params are forwarded (not the pre-formatted Issue message).
      #   2. Report#add_issue — accumulates the structured Report used by
      #      Reporters (text/json/yaml). The Report re-interpolates from
      #      ISO_LOG_MESSAGES too.
      #
      # Rules emit raw findings via Base#build_issue (code + params); the
      # orchestrator hands every Issue to translate_layer3. Layer 1
      # declarations trigger Lutaml::Model errors which the orchestrator
      # hands to translate_layer1. Neither rules nor Layer 1 know about
      # @log or Report — only this class does (DRY).
      class IssueTranslator
        # Utils::Log documents create_entry as a public flavor extension
        # surface. Change this entry before its existing suppression hook,
        # without mutating the logger's shared message registry.
        module ComposedLogEntry
          attr_accessor :validation_issue

          def create_entry(loc, msg, severity, error_id, params)
            entry = super
            if validation_issue && validation_issue.code == error_id.to_s
              entry[:error] = validation_issue.message
              if validation_issue.composition_severity
                entry[:severity] = { "error" => 2, "warning" => 1, "info" => 3 }
                  .fetch(validation_issue.composition_severity)
              end
            end
            entry
          end
        end

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

        # layer3_issues: Array of Metanorma::Iso::Validation::Issue produced
        # by ModelValidator#run_layer3_rules. Issues carry raw params; we
        # forward them so @log and Report can each interpolate from
        # ISO_LOG_MESSAGES (single source of truth — DRY).
        def translate_layer3(layer3_issues)
          layer3_issues.each do |issue|
            log_issue(issue)
            @report.add_issue(code: issue.code, location: issue.location,
                              params: issue.params.to_a, issue: issue)
          end
        end

        private

        def log_issue(issue)
          return unless @log
          unless @log.is_a?(Metanorma::Utils::Log)
            return @log.add(issue.code, issue.location, params: issue.params.to_a)
          end

          @log.extend(ComposedLogEntry) unless @log.is_a?(ComposedLogEntry)
          previous = @log.validation_issue
          @log.validation_issue = issue
          begin
            @log.add(issue.code, issue.location, params: issue.params.to_a)
          ensure
            @log.validation_issue = previous
          end
        end

        def add(code:, location:, params: [])
          return unless code

          @log.add(code, location, params: params) if @log
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
      end
    end
  end
end
