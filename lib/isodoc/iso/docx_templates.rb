# frozen_string_literal: true

require "yaml"

module IsoDoc
  module Iso
    # Paths of the bundled DOCX template assets (reference .docx/.dotx
    # templates and the YAML configs extracted from them by
    # Docx::TemplateExtractor), keyed by template era.
    module DocxTemplates
      TEMPLATE_FILES = {
        dis: "data/iso-dis/template.docx",
        simple: "data/iso-simple/template.dotx",
      }.freeze

      DEFAULT_TEMPLATE = :dis

      module_function

      # Gem root (the directory holding data/).
      def gem_root
        File.expand_path("../../..", __dir__)
      end

      def normalize(template)
        key = template.to_s.downcase.to_sym
        TEMPLATE_FILES.key?(key) ? key : DEFAULT_TEMPLATE
      end

      # Path to the reference template document for +template+.
      def template_path(template)
        File.join(gem_root, TEMPLATE_FILES[normalize(template)])
      end

      # Directory holding the YAML configs (styles.yml, numbering.yml,
      # doc_defaults.yml, style_mapping.yml, document_metadata.yml)
      # extracted for +template+.
      def config_dir(template)
        File.dirname(template_path(template))
      end

      def style_mapping_path(template)
        File.join(config_dir(template), "style_mapping.yml")
      end

      def document_metadata_path(template)
        File.join(config_dir(template), "document_metadata.yml")
      end
    end

    # Bundled default DOCX template (the DIS era reference document).
    def self.default_docx_template
      DocxTemplates.template_path(:dis)
    end

    # Semantic-key → DOCX styleId mapping loaded from
    # data/iso-{dis,simple}/style_mapping.yml. Single source of truth for
    # what each document element maps to in each template era; values are
    # verified against styles.yml by Docx::StyleMappingValidator.
    class DocxStyleMapping
      attr_reader :paragraph_styles, :character_styles, :numbering

      def initialize(template: :dis, config_path: nil)
        data = YAML.load_file(config_path || DocxTemplates.style_mapping_path(template))
        # Semantic keys are canonically symbols (the lookup API takes
        # symbols); styleIds/numIds stay strings.
        @paragraph_styles = symbolize_keys(data.fetch("paragraph_styles", {}))
        @character_styles = symbolize_keys(data.fetch("character_styles", {}))
        @numbering = symbolize_keys(data.fetch("numbering", {}))
        @auto_numbered_styles = data.fetch("auto_numbered_styles", [])
        @excluded_styles = data.fetch("excluded_styles", {})
      end

      def self.load_default(template: :dis)
        new(template: template)
      end

      # StyleIds whose numPr auto-numbers; autonum carriers must be
      # stripped from titles rendered into these styles.
      def auto_numbered_styles
        @auto_numbered_styles
      end

      # Exclusion list ({"globs": [...]}): styleIds matched by these globs
      # are known template styles that must NOT appear in the mapping.
      def excluded_styles
        @excluded_styles
      end

      def paragraph_style(key)
        paragraph_styles[key.to_sym]
      end

      def character_style(key)
        character_styles[key.to_sym]
      end

      # Heading styleId for a 1-based level; nil when the level has no
      # mapping (strict — callers decide on fallbacks).
      def heading_style(level)
        paragraph_styles[:"heading#{level}"]
      end

      # Annex heading styleId; annexes start at level 2 (level 1 is the
      # :annex ANNEX heading itself).
      def annex_heading_style(level)
        return nil unless level.to_i >= 2

        paragraph_styles[:"annex_heading#{level.to_i}"]
      end

      def numbering_id(key)
        numbering[key.to_sym]
      end

      # True when the style's numPr auto-numbers it (headings, annex
      # clauses): autonum carriers must be stripped from rendered titles.
      def auto_numbered_style?(style_id)
        auto_numbered_styles.include?(style_id)
      end

      private

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(k, v), out|
          out[k.to_sym] = v
        end
      end
    end
  end
end
