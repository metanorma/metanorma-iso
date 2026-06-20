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
    #
    # Strict by design: lookup methods return the configured value or nil.
    # Callers that need a hard guarantee wrap the lookup in StyleResolver,
    # which raises UnknownStyleError on miss.
    class DocxStyleMapping
      attr_reader :paragraph_styles, :character_styles, :numbering,
                  :auto_numbered_styles, :excluded_styles

      # @param template [Symbol] :dis or :simple
      # @param config_path [String, nil] explicit path to YAML (overrides template)
      def initialize(template: :dis, config_path: nil)
        config_path ||= DocxTemplates.style_mapping_path(template)
        data = YAML.load_file(config_path)
        @paragraph_styles     = symbolize_keys(data.fetch("paragraph_styles", {}))
        @character_styles     = symbolize_keys(data.fetch("character_styles", {}))
        @numbering            = symbolize_keys(data.fetch("numbering", {}))
        @auto_numbered_styles = Set.new(data.fetch("auto_numbered_styles", []))
        @excluded_styles      = data.fetch("excluded_styles", {})
      end

      def paragraph_style(key)
        @paragraph_styles[key.to_sym]
      end

      def character_style(key)
        @character_styles[key.to_sym]
      end

      # Whether the given DOCX styleId has <w:numPr> in the template,
      # meaning the style produces the number on its own and inline
      # autonum carriers in titles should be stripped.
      def auto_numbered_style?(style_id)
        return false unless style_id

        @auto_numbered_styles.include?(style_id.to_s)
      end

      def heading_style(level)
        @paragraph_styles[:"heading#{level}"]
      end

      def annex_heading_style(level)
        @paragraph_styles[:"annex_heading#{level}"]
      end

      def numbering_id(key)
        entry = @numbering[key.to_sym]
        case entry
        when Hash then entry[:num_id]
        when Integer then entry
        end
      end

      # Expanded list of styleIds listed under excluded_styles. Glob
      # patterns in the YAML are matched against the full style library.
      # Returns an empty array if no exclusion list is configured.
      def excluded_style_ids
        globs = (@excluded_styles["style_ids"] || []) +
                (@excluded_styles["globs"] || [])
        return [] if globs.empty?
        globs
      end

      def self.load_default(template: :dis)
        new(template: template)
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
