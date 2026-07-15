# frozen_string_literal: true

require "digest"
require "time"
require "yaml"

module IsoDoc
  module Iso
    module Docx
      # Value object representing the provenance header embedded in each
      # +data/iso-dis/*.yml+ file produced by +TemplateExtractor+.
      #
      # The header records which reference DOCX the data was extracted
      # from, the SHA-256 of that DOCX at extraction time, and the
      # template era (e.g. +late_typefi+). This lets the test suite
      # fail loudly if the reference DOCX is replaced without
      # re-running extraction.
      #
      # Header shape (all keys optional but recommended):
      #
      #   template_era: late_typefi
      #   reference_doc: 20250530-ISO_DIS_15926-100.docx
      #   reference_doc_sha256: <64-hex>
      #   extracted_at: 2026-06-18T14:43:56Z
      #   extractor_version: 1.0.0
      #
      # +TemplateProvenance+ is a pure value object — it never touches
      # the filesystem except via +record_for+, which computes a fresh
      # SHA-256 from a path the caller supplies.
      class TemplateProvenance
        ERAS = %w[pre_typefi early_typefi late_typefi].freeze

        attr_reader :era, :reference_doc, :reference_doc_sha256,
                    :extracted_at, :extractor_version, :source_path

        YAML_TO_RUBY_KEY = {
          "template_era" => :era,
          "reference_doc" => :reference_doc,
          "reference_doc_sha256" => :reference_doc_sha256,
          "extracted_at" => :extracted_at,
          "extractor_version" => :extractor_version,
        }.freeze

        # Build a +TemplateProvenance+ from a YAML file that carries the
        # standard provenance header. The header may live at the top
        # level of the YAML (as in +numbering.yml+ and +doc_defaults.yml+)
        # or nested one level deep inside the file's primary key (as in
        # +styles.yml+, where provenance lives under +style_library:+).
        # Returns +nil+ if the file does not include the header at all.
        def self.from_yaml(path)
          data = YAML.load_file(path)
          header = locate_provenance(data)
          return nil if header.empty?

          new(**header, source_path: path)
        end

        # Compute a provenance header for a reference DOCX at +path+.
        # The returned object has +reference_doc+ set to the basename,
        # +reference_doc_sha256+ computed from the file bytes, and
        # +extracted_at+ set to the current UTC time. The +era+ is
        # supplied by the caller (Era C is +late_typefi+).
        def self.record_for(path, era: "late_typefi",
                            extractor_version: nil)
          new(
            era: era,
            reference_doc: File.basename(path),
            reference_doc_sha256: Digest::SHA256.file(path).hexdigest,
            extracted_at: Time.now.utc.iso8601,
            extractor_version: extractor_version,
            source_path: path,
          )
        end

        def initialize(era: nil, reference_doc: nil, reference_doc_sha256: nil,
                       extracted_at: nil, extractor_version: nil,
                       source_path: nil)
          @era = era
          @reference_doc = reference_doc
          @reference_doc_sha256 = reference_doc_sha256
          @extracted_at = extracted_at
          @extractor_version = extractor_version
          @source_path = source_path
        end

        # True when +actual_sha256+ matches the recorded
        # +reference_doc_sha256+. Returns +false+ when no SHA was
        # recorded (the header is incomplete).
        def matches_reference?(actual_sha256)
          return false unless reference_doc_sha256

          reference_doc_sha256.casecmp(actual_sha256.to_s).zero?
        end

        # Serialize to a hash suitable for +YAML.dump+ or for splicing
        # into the top of an existing YAML document.
        def to_h
          {
            "template_era" => era,
            "reference_doc" => reference_doc,
            "reference_doc_sha256" => reference_doc_sha256,
            "extracted_at" => extracted_at,
            "extractor_version" => extractor_version,
          }.compact
        end

        private

        def self.locate_provenance(data)
          return {} unless data.is_a?(Hash)

          found = provenance_keys(data)
          return found unless found.empty?

          data.each_value do |value|
            next unless value.is_a?(Hash)
            nested = provenance_keys(value)
            return nested unless nested.empty?
          end
          {}
        end
        private_class_method :locate_provenance

        def self.provenance_keys(data)
          YAML_TO_RUBY_KEY.each_with_object({}) do |(yaml_key, ruby_key), acc|
            acc[ruby_key] = data[yaml_key] if data.key?(yaml_key)
          end
        end
        private_class_method :provenance_keys
      end
    end
  end
end
