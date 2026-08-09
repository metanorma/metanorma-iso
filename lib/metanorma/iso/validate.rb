require "metanorma-standoc"
require_relative "validate_style"
require_relative "validate_numeric"
require_relative "validate_requirements"
require_relative "validate_section"
require_relative "validate_title"
require_relative "validate_list"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      def copied_instance_variables
        super + %i[amd vocab validate_years]
      end

      # Semantic validation entry point. Skips RNG/Jing schema_validate
      # entirely — structural validity is the metanorma-document model's
      # responsibility. Runs standoc's Nokogiri-based validators (for
      # population of @doc_ids etc. consumed by standoc consumers — TODO 34
      # will retire these) followed by the model-driven Layer 3 pipeline.
      def validate(doc)
        @log.add_error_ranges(doc)
        content_validate(doc)
      end

      def content_validate(doc)
        @doctype = doc.at("//bibdata/ext/doctype")&.text

        # Standoc population — feeds @doc_ids / @doc_anchors / @doc_xrefs
        # consumed by remaining standoc validators and our Layer 3 rules.
        # The duplicate-detection in repeat_id_validate1 is overridden to
        # no-op (UniqueIdRule handles that on the model side).
        repeat_id_validate(doc.root)
        xref_validate(doc)

        # Legacy Nokogiri checks not yet migrated to Layer 3 (style regex,
        # subscript depth, list internal punctuation, etc.).
        # TODO 34 will migrate these to standoc's Layer 3.
        root = doc.root
        title_validate(root)
        section_style(root)
        subclause_validate(root)
        list_punctuation(doc)
        asset_style(root)

        # Model-driven Layer 3 pipeline — all ISO_N + STANDOC_36/48 rules.
        model_validate(doc)

        # Abort on severity-0 (fatal) errors.
        fatalerrors = @log.abort_messages
        fatalerrors.empty? or
          @conv.clean_abort("\n\nFATAL ERRORS:\n\n#{fatalerrors.join("\n\n")}", doc)
      end

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

      # Override standoc's duplicate-id detection helpers to skip emission
      # of STANDOC_36 (population continues; duplicate detection happens in
      # UniqueIdRule on the model side).
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
