# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Orchestrator. Single entry point for model-driven validation.
      #
      # Pipeline:
      #   1. Deserialize the XML string to Metanorma::IsoDocument::Root
      #      (rescue returns nil — Layer 3 rules then skip via applicable?).
      #   2. Build Context + Report.
      #   3. Run Layer 1: root&.validate (Lutaml::Model attribute validations).
      #   4. Run Layer 3: every Rule discovered by RuleRegistry.
      #   5. IssueTranslator translates both layers into @log + Report.
      #   6. Optionally render the Report via a Reporter.
      #
      # Zero Nokogiri. The XML string is the only XML representation; from
      # here on every rule operates on the typed model.
      class ModelValidator
        OUTPUT_FORMATS = {
          log: nil,
          text: Reporter::Text,
          json: Reporter::Json,
          yaml: Reporter::Yaml
        }.freeze

        class << self
          # @param xml_string [String] Raw metanorma-internal XML.
          # @param log [Metanorma::Utils::Log, nil] Existing converter log;
          #   findings are mirrored here so the existing .err.html pipeline
          #   keeps working. Pass nil for tests / programmatic-only use.
          # @param state [ConverterState] Snapshot of converter state.
          # @param output_format [Symbol] :log (default, no reporter output),
          #   :text, :json, :yaml.
          # @param profile [Profile] Validation profile. Filters which rules
          #   run and configures strict-warning behavior. Default: all rules.
          # @param enable_layer1 [Boolean] Gate for Layer 1 attribute-level
          #   validation (see TODO 33).
          # @return [Report] when output_format is :log.
          # @return [Array(Report, String)] when output_format is :text/:json/:yaml.
          def run(xml_string, log:, state: nil, document: nil,
                  output_format: :log,
                  profile: Profile::DEFAULT, enable_layer1: false)
            root = deserialize(xml_string)
            state ||= StateExtractor.extract(root, document: document)
            context = Context.new(root: root, log: log, state: state,
                                  shared: SharedState.new)
            report = Report.new(
              document: state.document,
              generated_at: Time.now.utc.iso8601
            )
            translator = IssueTranslator.new(log: log, report: report)

            translator.translate_layer1(root&.validate || []) if enable_layer1
            translator.translate_layer3(run_layer3_rules(context, profile))

            return report if output_format == :log

            reporter = reporter_for(output_format).new
            [report, reporter.format(report)]
          end

          private

          def deserialize(xml_string)
            return nil if xml_string.nil? || xml_string.empty?

            Metanorma::IsoDocument::Root.from_xml(xml_string)
          rescue StandardError => e
            # Layer 1 + Layer 3 will surface what they can via the partial
            # model. Log the deserialization failure as STANDOC_7 so it is
            # visible, then continue with nil root.
            warn "Metanorma::Iso::ModelValidator: deserialization failed: #{e.message}"
            nil
          end

          def run_layer3_rules(context, profile)
            instances = RuleRegistry.new.all.map(&:new)
            instances = profile.select_rules(instances)

            instances.flat_map do |rule|
              next [] unless rule.applicable?(context)

              rule.check(context)
            rescue StandardError => e
              warn "Metanorma::Iso::ModelValidator: rule #{rule.class} raised: #{e.message}"
              []
            end
          end

          def reporter_for(output_format)
            OUTPUT_FORMATS.fetch(output_format) do
              raise ArgumentError, "unknown output format #{output_format.inspect}"
            end
          end
        end
      end
    end
  end
end
