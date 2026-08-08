# frozen_string_literal: true

module Metanorma
  module Iso
    # Public validation API.
    #
    # Layer 4 of the validation architecture (see TODO.validate/ARCHITECTURE.md).
    # Wraps the Layer 3 ModelValidator with a stable, keyword-arg-driven
    # contract suitable for programmatic use and CLI shims.
    #
    # @example Validate an XML string
    #   report = Metanorma::Iso.validate(xml)
    #   report.valid?       # => true / false
    #   report.errors       # => [#<Issue code: "ISO_5", ...>]
    #   report.to_json      # => structured JSON
    #
    # @example Validate with converter-state context
    #   report = Metanorma::Iso.validate(
    #     xml, lang: "en", script: "Latn", doctype: "international-standard"
    #   )
    #
    # @example Render as text (CLI-style)
    #   report = Metanorma::Iso.validate(xml)
    #   puts Metanorma::Iso::Validation::Reporter::Text.new.format(report)
    #
    module API
      class << self
        # Validate a metanorma-iso XML document.
        #
        # @param xml [String] The XML document to validate.
        # @param lang [String] Document language (default "en").
        # @param script [String] Document script (default "Latn").
        # @param doctype [String, nil] Document type (e.g.
        #   "international-standard"). When nil, doctype-specific rules
        #   skip via +applicable?+ predicates.
        # @param vocab [Boolean] Vocabulary document (default false).
        # @param amd [Boolean] Amendment/technical corrigendum (default false).
        # @param document [String, nil] Source identifier for the report
        #   (file path or "<stdin>"). Used by Reporters in summaries.
        # @return [Metanorma::Iso::Validation::Report] Structured report
        #   carrying every finding. Use #valid?, #errors, #warnings, #infos,
        #   #to_json, #to_yaml, #to_xml.
        def validate(xml, lang: "en", script: "Latn", doctype: nil,
                     vocab: false, amd: false, document: nil)
          state = Validation::ConverterState.new(
            lang: lang, script: script, doctype: doctype,
            vocab: vocab, amd: amd, document: document
          )
          Validation::ModelValidator.run(xml, log: nil, state: state)
        end

        # Render a report in a specific format. Convenience wrapper for
        # the Reporter classes; equivalent to constructing the reporter
        # directly. Returns the Report unchanged when format is :report.
        #
        # @param report [Metanorma::Iso::Validation::Report]
        # @param format [Symbol] :text, :json, :yaml, or :report.
        # @return [String] Formatted output (or the report itself for
        #   :report).
        def render(report, format: :text)
          case format
          when :text then Validation::Reporter::Text.new.format(report)
          when :json then report.to_json
          when :yaml then report.to_yaml
          when :report then report
          else
            raise ArgumentError, "unknown format #{format.inspect}"
          end
        end
      end
    end
  end
end
