# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Rule namespace. Each ISO_N log key gets its own class
      # (one file per rule; one code per rule, never shared). New rule =
      # new file + one autoload line here.
      module Rules
        autoload :Base, "metanorma/iso/validation/rules/base"
        autoload :TreeTraversal, "metanorma/iso/validation/rules/tree_traversal"
        autoload :StyleRule, "metanorma/iso/validation/rules/style_rule"
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
        autoload :SectionSequenceRule,
                 "metanorma/iso/validation/rules/section_sequence_rule"
        autoload :ForewordPresenceRule,
                 "metanorma/iso/validation/rules/foreword_presence_rule"
        autoload :UniqueIdRule,
                 "metanorma/iso/validation/rules/unique_id_rule"
        autoload :ListCountRule,
                 "metanorma/iso/validation/rules/list_count_rule"
        autoload :ListDepthRule,
                 "metanorma/iso/validation/rules/list_depth_rule"
        autoload :StyleNumberRule,
                 "metanorma/iso/validation/rules/style_number_rule"
        autoload :StyleUnitsRule,
                 "metanorma/iso/validation/rules/style_units_rule"
        autoload :StyleAmbigWordsRule,
                 "metanorma/iso/validation/rules/style_ambig_words_rule"
        autoload :UnreferencedAssetsRule,
                 "metanorma/iso/validation/rules/unreferenced_assets_rule"
        autoload :LocalityErefsRule,
                 "metanorma/iso/validation/rules/locality_erefs_rule"
        autoload :SeeXrefsRule,
                 "metanorma/iso/validation/rules/see_xrefs_rule"
        autoload :TermXrefsRule,
                 "metanorma/iso/validation/rules/term_xrefs_rule"
        autoload :ListPunctuationRule,
                 "metanorma/iso/validation/rules/list_punctuation_rule"
        autoload :ModalInClauseRule,
                 "metanorma/iso/validation/rules/modal_in_clause_rule"
        autoload :BrokenXrefRule,
                 "metanorma/iso/validation/rules/broken_xref_rule"
        # ISO House Style 2026-08 word-list rules (issue #1701), in
        # alphabetical order:
        autoload :StyleAcDcRfRule,
                 "metanorma/iso/validation/rules/style_ac_dc_rf_rule"
        autoload :StyleCaCfRule,
                 "metanorma/iso/validation/rules/style_ca_cf_rule"
        autoload :StyleComplianceRule,
                 "metanorma/iso/validation/rules/style_compliance_rule"
        autoload :StyleContractionsRule,
                 "metanorma/iso/validation/rules/style_contractions_rule"
        autoload :StyleCountryNamesRule,
                 "metanorma/iso/validation/rules/style_country_names_rule"
        autoload :StyleCvNotRsdRule,
                 "metanorma/iso/validation/rules/style_cv_not_rsd_rule"
        autoload :StyleEgEtcRule,
                 "metanorma/iso/validation/rules/style_eg_etc_rule"
        autoload :StyleFamilySuiteRule,
                 "metanorma/iso/validation/rules/style_family_suite_rule"
        autoload :StyleImpersonalRule,
                 "metanorma/iso/validation/rules/style_impersonal_rule"
        autoload :StyleImpreciseRefsRule,
                 "metanorma/iso/validation/rules/style_imprecise_refs_rule"
        autoload :StyleInterlabRule,
                 "metanorma/iso/validation/rules/style_interlab_rule"
        autoload :StyleOrdinalsRule,
                 "metanorma/iso/validation/rules/style_ordinals_rule"
        autoload :StyleOxfordSpellingRule,
                 "metanorma/iso/validation/rules/style_oxford_spelling_rule"
        autoload :StylePerCentRule,
                 "metanorma/iso/validation/rules/style_per_cent_rule"
        autoload :StylePluralSTermRule,
                 "metanorma/iso/validation/rules/style_plural_s_term_rule"
        autoload :StyleSelfReferenceRule,
                 "metanorma/iso/validation/rules/style_self_reference_rule"
        autoload :StyleWikipediaRule,
                 "metanorma/iso/validation/rules/style_wikipedia_rule"
        # ISO House Style (2026-08) structural batch (issue #1701), in
        # alphabetical order:
        autoload :StyleBoxedValuesRule,
                 "metanorma/iso/validation/rules/style_boxed_values_rule"
        autoload :StyleDateDurationRule,
                 "metanorma/iso/validation/rules/style_date_duration_rule"
        autoload :StyleDateFormatsRule,
                 "metanorma/iso/validation/rules/style_date_formats_rule"
        autoload :StyleDirectivesRefsRule,
                 "metanorma/iso/validation/rules/style_directives_refs_rule"
        autoload :StyleEmptyClauseRule,
                 "metanorma/iso/validation/rules/style_empty_clause_rule"
        autoload :StyleMixedListsRule,
                 "metanorma/iso/validation/rules/style_mixed_lists_rule"
        autoload :StyleNestedParensRule,
                 "metanorma/iso/validation/rules/style_nested_parens_rule"
        autoload :StylePenultimateListRule,
                 "metanorma/iso/validation/rules/style_penultimate_list_rule"
        # ISO House Style 2026-08 quick wins, second tranche (issue
        # #1701), in alphabetical order:
        autoload :StyleAbbrevArticlesRule,
                 "metanorma/iso/validation/rules/style_abbrev_articles_rule"
        autoload :StyleAbbrevPluralRule,
                 "metanorma/iso/validation/rules/style_abbrev_plural_rule"
        autoload :StyleBareSlashRule,
                 "metanorma/iso/validation/rules/style_bare_slash_rule"
        autoload :StyleCurrencyCodeOrderRule,
                 "metanorma/iso/validation/rules/style_currency_code_order_rule"
        autoload :StyleCurrencySymbolsRule,
                 "metanorma/iso/validation/rules/style_currency_symbols_rule"
        autoload :StyleEnDashRangesRule,
                 "metanorma/iso/validation/rules/style_en_dash_ranges_rule"
        autoload :StyleFormulaeRule,
                 "metanorma/iso/validation/rules/style_formulae_rule"
        autoload :StyleGuidelinesRule,
                 "metanorma/iso/validation/rules/style_guidelines_rule"
        autoload :StyleInclusiveLanguageRule,
                 "metanorma/iso/validation/rules/style_inclusive_language_rule"
        autoload :StyleIsoDatesRule,
                 "metanorma/iso/validation/rules/style_iso_dates_rule"
        autoload :StyleLatinPluralsRule,
                 "metanorma/iso/validation/rules/style_latin_plurals_rule"
        autoload :StyleNoBoxesRule,
                 "metanorma/iso/validation/rules/style_no_boxes_rule"
        autoload :StyleNoNosRule,
                 "metanorma/iso/validation/rules/style_no_nos_rule"
        autoload :StyleVagueTimeRule,
                 "metanorma/iso/validation/rules/style_vague_time_rule"

        # ISO House Style heuristic-limited and model-dependent rules
        # (issue #1705, tranches D+E), in alphabetical order:
        autoload :StyleAbbrevTablesOnlyRule,
                 "metanorma/iso/validation/rules/style_abbrev_tables_only_rule"
        autoload :StyleAbbrevUppercaseRule,
                 "metanorma/iso/validation/rules/style_abbrev_uppercase_rule"
        autoload :StyleApostrophePluralsRule,
                 "metanorma/iso/validation/rules/style_apostrophe_plurals_rule"
        autoload :StyleBarKnotFootnoteRule,
                 "metanorma/iso/validation/rules/style_bar_knot_footnote_rule"
        autoload :StyleEgPlacementRule,
                 "metanorma/iso/validation/rules/style_eg_placement_rule"
        autoload :StyleInformativeNormativeRule,
                 "metanorma/iso/validation/rules/style_informative_normative_rule"
        autoload :StyleQuotationPunctuationRule,
                 "metanorma/iso/validation/rules/style_quotation_punctuation_rule"
        autoload :StyleVerbalFormsRule,
                 "metanorma/iso/validation/rules/style_verbal_forms_rule"
        autoload :StyleVocabTitleRule,
                 "metanorma/iso/validation/rules/style_vocab_title_rule"        # ISO House Style context-dependent rules (issue #1705, tranche
        # A): sentence-level analysis via Validation::SentenceScan, in
        # alphabetical order.
        autoload :StyleAffectEffectRule,
                 "metanorma/iso/validation/rules/style_affect_effect_rule"
        autoload :StyleAOrAnRule,
                 "metanorma/iso/validation/rules/style_a_or_an_rule"
        autoload :StyleAssureEnsureRule,
                 "metanorma/iso/validation/rules/style_assure_ensure_rule"
        autoload :StyleFewerLessRule,
                 "metanorma/iso/validation/rules/style_fewer_less_rule"
        autoload :StyleInAccordanceRule,
                 "metanorma/iso/validation/rules/style_in_accordance_rule"
        autoload :StyleRespectivelyRule,
                 "metanorma/iso/validation/rules/style_respectively_rule"
        autoload :StyleSentenceStartNumberRule,
                 "metanorma/iso/validation/rules/style_sentence_start_number_rule"
        autoload :StyleThatWhichRule,
                 "metanorma/iso/validation/rules/style_that_which_rule"
        autoload :StyleWordsDigitsRule,
                 "metanorma/iso/validation/rules/style_words_digits_rule"
        # Ambiguous decimal-comma lint (metanorma/metanorma-standoc#1372).
        autoload :StyleDecimalCommaRule,
                 "metanorma/iso/validation/rules/style_decimal_comma_rule"
        # ISO House Style structural rules (issue #1705, tranche B):
        # model-traversal detection over document order, in alphabetical
        # order.
        autoload :AbbrevFirstUseRule,
                 "metanorma/iso/validation/rules/abbrev_first_use_rule"
        autoload :AssetCitedFirstRule,
                 "metanorma/iso/validation/rules/asset_cited_first_rule"
        autoload :DocumentOrderWalk,
                 "metanorma/iso/validation/rules/document_order_walk"
        autoload :TermSourceCompleteRule,
                 "metanorma/iso/validation/rules/term_source_complete_rule"      end
    end
  end
end
