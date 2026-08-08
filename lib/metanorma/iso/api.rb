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
        # @param doctype [String, nil] Document type.
        # @param vocab [Boolean] Vocabulary document (default false).
        # @param amd [Boolean] Amendment/technical corrigendum (default false).
        # @param document [String, nil] Source identifier for the report.
        # @param profile [Metanorma::Iso::Validation::Profile, Symbol] Validation
        #   profile. Accepts a Profile instance or a Symbol (:default,
        #   :strict, :publication) resolved to the built-in constant.
        # @return [Metanorma::Iso::Validation::Report] Structured report.
        def validate(xml, lang: "en", script: "Latn", doctype: nil,
                     vocab: false, amd: false, document: nil, profile: :default)
          state = Validation::ConverterState.new(
            lang: lang, script: script, doctype: doctype,
            vocab: vocab, amd: amd, document: document
          )
          Validation::ModelValidator.run(
            xml, log: nil, state: state,
            profile: resolve_profile(profile)
          )
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

        private

        def resolve_profile(profile)
          return profile if profile.is_a?(Validation::Profile)

          case profile
          when :default then Validation::Profile::DEFAULT
          when :strict then Validation::Profile::STRICT
          when :publication then Validation::Profile::PUBLICATION
          else
            raise ArgumentError, "unknown profile #{profile.inspect}"
          end
        end
      end
    end
  end
end
