require "nokogiri"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      def section_validate(doc)
        unless %w(amendment technical-corrigendum).include? @doctype
          normref_validate(doc.root)
          symbols_validate(doc.root)
        # sections_sequence_validate migrated to SectionSequenceRule (TODO 19).
        end
        section_style(doc.root)
        subclause_validate(doc.root)
        # ISO_44 / ISO_45 vocab terms titles: migrated to VocabTermsTitlesRule.
        super
      end

      # ISO_23 foreword structure: migrated to
      # Metanorma::Iso::Validation::Rules::ForewordStructureRule (TODO 15).
      # ISO_24 normref structure: blocked on TODO 33 model extension
      # (StandardReferencesSection drops nested clause/refs children).
      # ISO_29/30/31 section presence: migrated to ScopePresenceRule,
      # NormativeReferencesPresenceRule, TermsPresenceRule (TODO 18).
      # ISO_39 scope subclauses: migrated to ScopeSubclausesRule (TODO 20).
      # ISO_43 only-child clause: migrated to OnlyChildClauseRule (TODO 21).

      # ISO/IEC DIR 2, 15.4
      def normref_validate(root)
        f = root.at("//references[@normative = 'true']") || return
        f.at("./references | ./clause") &&
          @log.add("ISO_24", f)
      end

      def symbols_validate(root)
        # Migrated to Layer 3 rules: SymbolsSectionCountRule (ISO_25),
        # SymbolsSectionContentRule (ISO_26), SymbolsInAnnexRule (ISO_27).
        # See TODO.validate/17.
      end


      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[@type = 'scope']"))
        # ISO_39 scope subclauses: migrated to ScopeSubclausesRule (TODO 20).
        tech_report_style(root)
      end

      def tech_report_style(root)
        @doctype == "technical-report" or return
        root.xpath("//sections/clause[not(@type = 'scope')] | //annex")
          .each do |s|
          r = requirement_check(extract_text(s)) and
            style_warning(s,
                          "Technical Report clause may contain requirement", r)
        end
      end

      # ISO_42 normative bibitem style: migrated to
      # Metanorma::Iso::Validation::Rules::NormativeBibitemRule (TODO 10).

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause")
          .each do |c|
          style_warning(c, "Exceeds the maximum clause depth of 7", nil)
        end
      end

      # ISO/IEC DIR 2, 22.3.2
      # ISO_43 only-child clause: migrated to OnlyChildClauseRule (TODO 21).
      # ISO_44 / ISO_45 vocab terms titles: migrated to VocabTermsTitlesRule
      # (TODO 22).
    end
  end
end
