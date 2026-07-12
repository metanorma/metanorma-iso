# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      class Transformer::IdGenerator
        def initialize(context)
          @context = context
          @id_map = {}
          @section_counters = {
            table: 0,
            figure: 0,
            formula: 0,
            biblref: 0,
            fn: 0,
            unnumbered_table: 0,
          }
        end

        def register(source_id, sts_id)
          @id_map[source_id] = sts_id
        end

        def remap(source_id)
          @id_map[source_id] || source_id
        end

        def id_for(element)
          case element
          when Metanorma::IsoDocument::Sections::IsoForewordSection
            "sec_foreword"
          when Metanorma::IsoDocument::Sections::IsoAbstractSection
            "sec_abstract"
          when Metanorma::IsoDocument::Sections::IsoClauseSection
            id_for_clause(element)
          when Metanorma::IsoDocument::Sections::IsoAnnexSection
            id_for_annex(element)
          when Metanorma::IsoDocument::Sections::IsoTermsSection
            id_for_terms(element)
          when Metanorma::Document::Components::Tables::TableBlock
            id_for_table(element)
          when Metanorma::Document::Components::AncillaryBlocks::FigureBlock
            id_for_figure(element)
          when Metanorma::Document::Components::AncillaryBlocks::FormulaBlock
            id_for_formula(element)
          when Metanorma::Document::Components::Paragraphs::ParagraphBlock
            id_for_paragraph(element)
          when Metanorma::StandardDocument::Sections::StandardReferencesSection
            id_for_ref_section(element)
          else
            id = element.id if element.class.method_defined?(:id)
            id ? remap(id) : nil
          end
        end

        def section_number(element)
          if element.is_a?(Metanorma::IsoDocument::Sections::IsoClauseSection) ||
              element.is_a?(Metanorma::IsoDocument::Sections::IsoAnnexSection) ||
              element.is_a?(Metanorma::IsoDocument::Sections::IsoTermsSection)
            element.number
          end
        end

        private

        def id_for_clause(clause)
          return remap(clause.id) if clause.id && @id_map.key?(clause.id)

          number = clause.number
          sts_id = if number && !number.empty?
                     "sec_#{number}"
                   elsif clause.type == "intro"
                     "sec_intro"
                   elsif clause.type == "scope"
                     "sec_scope"
                   else
                     clause.id ? remap(clause.id) : nil
                   end

          register(clause.id, sts_id) if clause.id && sts_id
          sts_id
        end

        def id_for_annex(annex)
          return remap(annex.id) if annex.id && @id_map.key?(annex.id)

          number = annex.number
          sts_id = if number && !number.empty?
                     "sec_#{number}"
                   else
                     "sec_A"
                   end

          register(annex.id, sts_id) if annex.id
          sts_id
        end

        def id_for_terms(terms)
          return remap(terms.id) if terms.id && @id_map.key?(terms.id)

          number = terms.number
          sts_id = if number && !number.empty?
                     "sec_#{number}"
                   else
                     "sec_terms"
                   end

          register(terms.id, sts_id) if terms.id
          sts_id
        end

        def id_for_table(table)
          return remap(table.id) if table.id && @id_map.key?(table.id)

          @section_counters[:table] += 1
          number = table.autonum if table.class.method_defined?(:autonum)
          number = nil if number && number.to_s.empty?
          if number
            sts_id = "tab_#{number}"
          else
            letter = ("a".ord + @section_counters[:unnumbered_table]).chr
            @section_counters[:unnumbered_table] += 1
            sts_id = "tab_#{letter}"
          end

          register(table.id, sts_id) if table.id
          sts_id
        end

        def id_for_figure(figure)
          return remap(figure.id) if figure.id && @id_map.key?(figure.id)

          @section_counters[:figure] += 1
          number = figure.autonum if figure.class.method_defined?(:autonum)
          number = nil if number && number.to_s.empty?
          sts_id = if number
                     "fig_#{number}"
                   else
                     "fig_#{@section_counters[:figure]}"
                   end

          register(figure.id, sts_id) if figure.id
          sts_id
        end

        def id_for_formula(formula)
          return remap(formula.id) if formula.id && @id_map.key?(formula.id)

          @section_counters[:formula] += 1
          number = formula.autonum if formula.class.method_defined?(:autonum)
          number = nil if number && number.to_s.empty?
          sts_id = if number
                     num = number.to_s.gsub(/[()]/, "")
                     "formula_#{num}"
                   else
                     "formula_#{@section_counters[:formula]}"
                   end

          register(formula.id, sts_id) if formula.id
          sts_id
        end

        def id_for_paragraph(para)
          return nil unless para.id && !para.id.start_with?("_")

          remap(para.id)
        end

        def id_for_ref_section(ref_section)
          return remap(ref_section.id) if ref_section.id && @id_map.key?(ref_section.id)

          normative = ref_section.normative == "true"
          sts_id = normative ? "sec_normrefs" : "sec_bibl"

          register(ref_section.id, sts_id) if ref_section.id
          sts_id
        end
      end
    end
  end
end
