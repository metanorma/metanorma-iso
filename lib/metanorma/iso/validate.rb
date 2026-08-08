require "metanorma-standoc"
require_relative "validate_style"
require_relative "validate_numeric"
require_relative "validate_requirements"
require_relative "validate_section"
require_relative "validate_title"
require_relative "validate_list"
require_relative "validate_xref"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      def copied_instance_variables
        super + %i[amd vocab validate_years]
      end

      # Semantic validation entry point. Overrides Standoc::Validate#validate
      # to skip RNG/Jing schema validation entirely — structural validity is
      # the metanorma-document model's responsibility (TODO 31 belongs there,
      # not here). We run only content_validate (legacy Ruby Nokogiri rules
      # pending TODO 34 standoc migration) + model_validate (the new
      # model-driven Layer 3 pipeline).
      def validate(doc)
        @log.add_error_ranges(doc)
        content_validate(doc)
        model_validate(doc)
      end

      # ISO_2/3/4/5/6/7/8/10..45 semantic rules migrated to Layer 3.
      # See TODO.validate/README.md for the per-rule plan of record.

      def bibdata_validate(_doc)
        # Iteration + doctype checks have migrated to Layer 3 rules.
      end

      def figure_validate(_xmldoc)
        # ISO_7 subfigure: structural — handled at metanorma-document level.
      end

      def content_validate(doc)
        super
        root = doc.root
        title_validate(root)
        iso_xref_validate(root)
        bibdata_validate(root)
        bibitem_validate(root)
        list_validate(doc)
        model_validate(doc)
      end

      # Foundation hook: runs the model-driven validator (Layer 1 gated +
      # Layer 3 rules). Eventually becomes the sole validator once TODO 34
      # (standoc migration) lands and content_validate above is gutted.
      def model_validate(doc)
        state = Metanorma::Iso::Validation::ConverterState.new(
          lang: @lang, script: @script, doctype: @doctype,
          vocab: @vocab, amd: @amd, i18n: @i18n,
          novalid: @novalid, document: @localdir
        )
        Metanorma::Iso::Validation::ModelValidator.run(
          doc.to_xml, log: @log, state: state
        )
      end

      def list_validate(doc)
        # listcount_validate migrated to ListCountRule + ListDepthRule (TODO 27).
        list_punctuation(doc)
      end

      def bibitem_validate(_xmldoc)
        # ISO_8 unpublished status: structural — handled at metanorma-document
        # level once BibliographicDate.on accepts string sentinels.
      end

      # Override standoc's duplicate-id detection helpers to skip emission
      # of STANDOC_36 (population continues; duplicate detection happens in
      # Metanorma::Iso::Validation::Rules::UniqueIdRule).
      def repeat_id_validate1(elem)
        return unless elem["id"]

        @doc_ids[elem["id"]] ||= { line: elem.line, anchor: elem["anchor"] }.compact
      end

      def repeat_anchor_validate1(elem)
        return unless elem["anchor"]

        @doc_anchors[elem["anchor"]] ||= { line: elem.line, id: elem["id"] }
        @doc_anchor_seq << elem["anchor"]
      end
    end
  end
end
