# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Rule namespace. Each ISO_N / STANDOC_N log key gets its own class
      # (one file per rule). New rule = new file + one autoload line here.
      module Rules
        autoload :Base, "metanorma/iso/validation/rules/base"
        autoload :TreeTraversal, "metanorma/iso/validation/rules/tree_traversal"
        autoload :DoctypeRule, "metanorma/iso/validation/rules/doctype_rule"
        autoload :IterationRule, "metanorma/iso/validation/rules/iteration_rule"
        autoload :TechnicalCommitteeTypeRule,
                 "metanorma/iso/validation/rules/technical_committee_type_rule"
        autoload :SubcommitteeTypeRule,
                 "metanorma/iso/validation/rules/subcommittee_type_rule"
        autoload :ScopePresenceRule,
                 "metanorma/iso/validation/rules/scope_presence_rule"
        autoload :NormativeReferencesPresenceRule,
                 "metanorma/iso/validation/rules/normative_references_presence_rule"
        autoload :TermsPresenceRule,
                 "metanorma/iso/validation/rules/terms_presence_rule"
        autoload :ForewordStructureRule,
                 "metanorma/iso/validation/rules/foreword_structure_rule"
        # TODO 16 (ISO_24) is blocked on TODO 33: the StandardReferencesSection
        # model drops nested <clause>/<references> children during from_xml.
        autoload :ScopeSubclausesRule,
                 "metanorma/iso/validation/rules/scope_subclauses_rule"
        autoload :OnlyChildClauseRule,
                 "metanorma/iso/validation/rules/only_child_clause_rule"
        autoload :NormativeBibitemRule,
                 "metanorma/iso/validation/rules/normative_bibitem_rule"
        autoload :TermdefStyleRule,
                 "metanorma/iso/validation/rules/termdef_style_rule"
        autoload :SymbolsSectionCountRule,
                 "metanorma/iso/validation/rules/symbols_section_count_rule"
        autoload :SymbolsSectionContentRule,
                 "metanorma/iso/validation/rules/symbols_section_content_rule"
        autoload :SymbolsInAnnexRule,
                 "metanorma/iso/validation/rules/symbols_in_annex_rule"
        autoload :VocabTermsTitlesRule,
                 "metanorma/iso/validation/rules/vocab_terms_titles_rule"
        autoload :TitlePairingRule,
                 "metanorma/iso/validation/rules/title_pairing_rule"
        autoload :SubpartIecRule,
                 "metanorma/iso/validation/rules/subpart_iec_rule"
        autoload :TitleNamesDoctypeRule,
                 "metanorma/iso/validation/rules/title_names_doctype_rule"
        autoload :TitleFirstLevelRule,
                 "metanorma/iso/validation/rules/title_first_level_rule"
        autoload :TitleSiblingsConsistencyRule,
                 "metanorma/iso/validation/rules/title_siblings_consistency_rule"
      end
    end
  end
end
