require "metanorma-standoc"
require_relative "validate_style"
require_relative "validate_numeric"
require_relative "validate_requirements"
require_relative "validate_section"
require_relative "validate_title"
require_relative "validate_list"
require_relative "validate_xref"
require "nokogiri"
require "jing"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      def copied_instance_variables
        super + %i[amd vocab validate_years]
      end

      # ISO_2 / ISO_3 subcommittee type validation: migrated to
      # Metanorma::Iso::Validation::Rules::TechnicalCommitteeTypeRule and
      # SubcommitteeTypeRule (see TODO.validate/04).
      # ISO_4 / ISO_35 termdef style: migrated to TermdefStyleRule (TODO 07).

      # ISO_5 doctype validation: migrated to
      # Metanorma::Iso::Validation::Rules::DoctypeRule (see TODO.validate/05).

      # ISO_6 iteration validation: migrated to
      # Metanorma::Iso::Validation::Rules::IterationRule (see TODO.validate/06).

      def bibdata_validate(doc)
        # Iteration + doctype checks have migrated to Layer 3 rules.
        # Remaining bibdata checks land here as they're migrated.
      end

      # DRG directives 3.7; but anticipated by standoc
      def subfigure_validate(xmldoc)
        elems = { footnote: "fn", note: "note", key: "key" }
        xmldoc.xpath("//figure//figure").each do |f|
          elems.each do |k, v|
            f.xpath(".//#{v}").each do |n|
              @log.add("ISO_7", n, params: [k])
            end
          end
        end
      end

      def figure_validate(xmldoc)
        subfigure_validate(xmldoc)
      end

      def content_validate(doc)
        super
        root = doc.root
        title_validate(root)
        iso_xref_validate(root)
        bibdata_validate(root)
        bibitem_validate(root)
        figure_validate(root)
        list_validate(doc)
        model_validate(doc)
      end

      # Foundation hook: runs the new model-driven validator alongside the
      # existing Ruby + RNG pipeline. At foundation stage the registry is
      # empty and Layer 1 has no declarations, so this is a no-op for
      # behavior. As rules are migrated (TODOs 02-31), each one removes its
      # corresponding method above and the new pipeline takes over.
      # End-state (TODO 32) deletes the legacy methods entirely and this
      # becomes the sole validator.
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
        listcount_validate(doc)
        list_punctuation(doc)
      end

      def bibitem_validate(xmldoc)
        xmldoc.xpath("//bibitem[date/on = '–']").each do |b|
          n = b.xpath("./note/@type").map { |n| n.text.split(",").map(&:strip) }
            .flatten
          n.include?("Unpublished-Status") or @log.add("ISO_8", b)
        end
      end

      def schema_file
        case @doctype
        when "amendment", "technical-corrigendum" # @amd
          "isostandard-amd.rng"
        else "isostandard-compile.rng"
        end
      end

      # Override standoc's duplicate-id detection helpers to skip emission
      # of STANDOC_36 (population continues; duplicate detection happens in
      # Metanorma::Iso::Validation::Rules::UniqueIdRule). Without these
      # overrides, both code paths fire and the same duplicate is reported
      # twice. TODO 34 will remove these overrides along with the standoc
      # helpers themselves.
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
