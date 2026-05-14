# frozen_string_literal: true

require "yaml"

module IsoDoc
  module Iso
    # Template-aware paths for ISO DOCX templates and style mappings.
    #
    # Supported templates:
    #   :dis    — DIS/FDIS template (stages 40-60, 90), 461 styles
    #   :simple — Simple template (stages 00-30), 72 styles
    module DocxTemplates
      TEMPLATES = {
        dis: { dir: "iso-dis", file: "template.docx" },
        simple: { dir: "iso-simple", file: "template.dotx" },
      }.freeze

      def self.data_dir
        File.expand_path("../../../data", __dir__)
      end

      def self.template_path(template_type)
        spec = TEMPLATES[template_type] || TEMPLATES[:dis]
        File.join(data_dir, spec[:dir], spec[:file])
      end

      def self.style_mapping_path(template_type)
        spec = TEMPLATES[template_type] || TEMPLATES[:dis]
        File.join(data_dir, spec[:dir], "style_mapping.yml")
      end

      def self.config_dir(template_type)
        spec = TEMPLATES[template_type] || TEMPLATES[:dis]
        File.join(data_dir, spec[:dir])
      end

      def self.template_types
        TEMPLATES.keys
      end
    end

    # Default template path (DIS) for backward compatibility.
    def self.default_docx_template
      DocxTemplates.template_path(:dis)
    end

    # Maps isodoc semantic elements to DOCX styleIds from the ISO template.
    #
    # Loaded from a YAML configuration file. Provides lookup methods for
    # paragraph styles, character styles, and numbering definitions.
    class DocxStyleMapping
      attr_reader :paragraph_styles, :character_styles, :numbering

      # @param template [Symbol] :dis or :simple
      # @param config_path [String, nil] explicit path to YAML (overrides template)
      def initialize(template: :dis, config_path: nil)
        config_path ||= DocxTemplates.style_mapping_path(template)
        data = YAML.load_file(config_path)
        @paragraph_styles = symbolize_keys(data.fetch("paragraph_styles", {}))
        @character_styles = symbolize_keys(data.fetch("character_styles", {}))
        @numbering = symbolize_keys(data.fetch("numbering", {}))
      end

      def paragraph_style(key)
        @paragraph_styles[key.to_sym] || @paragraph_styles[key.to_s]
      end

      def character_style(key)
        @character_styles[key.to_sym] || @character_styles[key.to_s]
      end

      def heading_style(level)
        @paragraph_styles[:"heading#{level}"] || "Heading#{level}"
      end

      def annex_heading_style(level)
        key = :"annex_heading#{level}"
        @paragraph_styles[key] || heading_style(level)
      end

      def numbering_id(key)
        entry = @numbering[key.to_sym]
        case entry
        when Hash then entry[:num_id]
        when Integer then entry
        end
      end

      private

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(k, v), result|
          result[k.to_sym] = v
        end
      end
    end
  end
end
