# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Policy metadata for the legacy (Nokogiri-era) checks in LegacyChecks
      # (lib/metanorma/iso/validate.rb) — the sidecar until TODO 34 migrates
      # them into rule classes. Consumed by the validation-policy-page
      # generator (metanorma/metanorma-iso#1709).
      #
      # Owner rulings (2026-11), binding on this table:
      # - every entry carries BOTH a policy-tree category path into the ISO
      #   House Style 2026-08 section tree
      #   (www.iso.org/ISO-house-style.html) AND a metanorma functional tag
      #   (:style / :structure / :references);
      # - each citation names its SOURCE separately: +:house_style+ carries a
      #   House Style +section:+ and the short +rule:+ wording from that
      #   page, +:directives+ carries the ISO/IEC Directives Part 2:2021
      #   clause number, and both are given when a check restates a DIR 2
      #   rule via the House Style.
      #
      # One entry per emitting check method, keyed by the LegacyChecks method
      # name; +code:+ is the log code the method emits (most legacy checks
      # share the generic STANDOC_48 style-warning sink via +style_warning+).
      # Coverage of this table against the legacy source is enforced by
      # spec/metanorma/validation/legacy_policy_spec.rb.
      LEGACY_POLICY = {
        "scope_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "the Scope is worded as statements of fact and contains no " \
                "requirements, permissions or recommendations",
          source: [:directives], directives: "14.2",
          mn_category: :style,
        },
        "introduction_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "the Introduction is informative and contains no requirements",
          source: [:directives], directives: "13.2",
          mn_category: :style,
        },
        "definition_style" => {
          code: "STANDOC_48",
          category: "Formatting > Vocabulary documents",
          rule: "a definition does not take the form of, or contain, a " \
                "requirement",
          source: [:directives], directives: "16.5.6",
          mn_category: :style,
        },
        "example_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "examples only illustrate the text: no requirements and no " \
                "information indispensable for the use of the document",
          source: [:directives], directives: "25.5",
          mn_category: :style,
        },
        "note_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "notes only assist the understanding of the text: no " \
                "requirements, recommendations or permissions",
          source: [:directives], directives: "24.5",
          mn_category: :style,
        },
        "footnote_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "footnotes only assist the understanding of the text: no " \
                "requirements, recommendations or permissions",
          source: [:directives], directives: "26.5",
          mn_category: :style,
        },
        "section_style" => {
          code: "STANDOC_48",
          category: "Plain language",
          rule: "Technical Report clauses contain collected data, not " \
                "provisions, and state no requirements",
          source: [:directives], directives: "3.1.8, 7.2",
          mn_category: :style,
        },
        "style_problem_words" => {
          code: "STANDOC_48",
          category: "Numbers, values and dates > Numbers",
          section: "Numbers, values and dates > Numbers",
          rule: "'billion' is ambiguous: use 'one billion' for " \
                "'1 000 million'",
          source: [:house_style],
          mn_category: :style,
        },
        "style_abbrev" => {
          code: "STANDOC_48",
          category: "Abbreviated terms, abbreviations and contractions > " \
                    "Abbreviated terms",
          section: "Abbreviated terms, abbreviations and contractions > " \
                   "Abbreviated terms",
          rule: "abbreviated terms take no full stops between letters " \
                "(lowercase forms); do not use language-specific unit " \
                "abbreviations (ppm)",
          source: [:house_style, :directives], directives: "8.4",
          mn_category: :style,
        },
        "style_punct" => {
          code: "STANDOC_48",
          category: "Punctuation",
          section: "Punctuation",
          rule: "no 'and/or' (write 'either x or y, or both'), no ampersand " \
                "in ordinary text; a superscript cross-reference is not " \
                "followed by terminal punctuation",
          source: [:house_style],
          mn_category: :style,
        },
        "style_subscript" => {
          code: "STANDOC_48",
          category: "Symbols > Quantities and units",
          section: "Symbols > Quantities and units",
          rule: "avoid more than one level of subscript; the maximum is " \
                "three levels of subscript nesting",
          source: [:house_style],
          mn_category: :style,
        },
        "style_number" => {
          code: "STANDOC_48",
          category: "Numbers, values and dates > Numbers",
          section: "Numbers, values and dates > Numbers",
          rule: "the decimal sign is a comma on the line (mark up decimal " \
                "values with stem:[]); 'billion' is unambiguous; no hyphen " \
                "instead of a minus sign",
          source: [:house_style, :directives], directives: "9.1",
          mn_category: :style,
        },
        "style_number_grouping" => {
          code: "STANDOC_48",
          category: "Numbers, values and dates > Numbers",
          section: "Symbols > Mathematical symbols",
          rule: "group digits by three to facilitate reading (e.g. 1 234, " \
                "567 890); mark up numbers with stem:[]",
          source: [:house_style, :directives], directives: "9.1",
          mn_category: :style,
        },
        "style_percent" => {
          code: "STANDOC_48",
          category: "Numbers, values and dates > Numbers",
          section: "Numbers, values and dates > Numbers",
          rule: "always use digits with the percentage symbol, preceded by " \
                "a space ('an increase of 5 %')",
          source: [:house_style],
          mn_category: :style,
        },
        "style_units" => {
          code: "STANDOC_48",
          category: "Symbols > Quantities and units",
          section: "Symbols > Quantities and units",
          rule: "a space separates value and unit symbol; no space between " \
                "the value and the degree/minute/second sign; use the unit " \
                "symbols of the ISO 80000 series (s, min, h, A, r/min), not " \
                "non-standard forms",
          source: [:house_style, :directives], directives: "9.1",
          mn_category: :style,
        },
        "list_punctuation" => {
          code: "STANDOC_48",
          category: "Punctuation > Lists",
          section: "Punctuation > Lists",
          rule: "every list is introduced by a sentence ending with a colon " \
                "or a full stop",
          source: [:house_style],
          mn_category: :style,
        },
        "list_semicolon_phrase" => {
          code: "STANDOC_48",
          category: "Punctuation > Lists",
          section: "Punctuation > Lists",
          rule: "items of one sentence broken into a list start in lower " \
                "case and end with a semicolon; the final item ends with " \
                "a full stop",
          source: [:house_style],
          mn_category: :style,
        },
        "list_full_sentence" => {
          code: "STANDOC_48",
          category: "Punctuation > Lists",
          section: "Punctuation > Lists",
          rule: "items comprising several sentences start with a capital " \
                "letter and end with a full stop",
          source: [:house_style],
          mn_category: :style,
        },
        "title_no_full_stop_validate" => {
          code: "STANDOC_48",
          category: "Punctuation > Full stops",
          section: "Punctuation > Full stops",
          rule: "no full stop at the end of clause/subclause headings, " \
                "table titles or figure titles",
          source: [:house_style],
          mn_category: :style,
        },
        "normref_validate" => {
          code: "ISO_24",
          category: "Referencing > General",
          section: "Referencing > General",
          rule: "the Normative references clause shall not be subdivided " \
                "into subclauses",
          source: [:house_style, :directives], directives: "15.4",
          mn_category: :references,
        },
        "subclause_validate" => {
          code: "STANDOC_48",
          category: "Formatting > Document set-up > Numbering",
          section: "Formatting > Document set-up > Numbering",
          rule: "clauses are subdivided into subclauses only as far as the " \
                "fifth level; too many levels of subdivision make the " \
                "document hard to follow",
          source: [:house_style, :directives], directives: "22.3.2",
          mn_category: :structure,
        },
      }.freeze
    end
  end
end
