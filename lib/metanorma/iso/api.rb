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
        # Validate a metanorma-iso XML document. Auto-detects doctype,
        # language, and script from the model via StateExtractor. Pass
        # explicit keywords to override detection.
        #
        # @param xml [String] The XML document to validate.
        # @param lang [String, nil] Override document language.
        # @param script [String, nil] Override document script.
        # @param doctype [String, nil] Override document type.
        # @param vocab [Boolean, nil] Override vocabulary flag.
        # @param amd [Boolean, nil] Override amendment flag.
        # @param document [String, nil] Source identifier for the report.
        # @param profile [Profile, Symbol] Validation profile.
        # @return [Report]
        def validate(xml, lang: nil, script: nil, doctype: nil,
                     vocab: nil, amd: nil, document: nil, profile: :default)
          overrides_provided = [lang, script, doctype, vocab, amd].any? { |v| !v.nil? }

          unless overrides_provided
            return Validation::ModelValidator.run(
              xml, log: nil, state: nil, document: document,
              profile: resolve_profile(profile)
            )
          end

          root = parse_root(xml)
          detected = Validation::StateExtractor.extract(root, document: document)
          state = Validation::ConverterState.new(
            lang: lang || detected.lang,
            script: script || detected.script,
            doctype: doctype || detected.doctype,
            vocab: vocab.nil? ? detected.vocab : vocab,
            amd: amd.nil? ? detected.amd : amd,
            document: document
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

        # Resolve a profile symbol (:default, :strict, :publication) to
        # a Profile instance. Returns the argument unchanged when it's
        # already a Profile. Public for CLI use.
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

        def parse_root(xml)
          return nil if xml.nil? || xml.empty?

          Metanorma::Iso::Document::Root.from_xml(xml)
        rescue StandardError
          nil
        end
      end
    end
  end
end
