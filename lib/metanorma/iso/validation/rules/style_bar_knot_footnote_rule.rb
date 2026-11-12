# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: the units "bar" and "kn" (knot) carry mandated
        # explanatory footnotes — "1 bar = 0,1 MPa" and
        # "1 kn = 1,852 km/h" (ISO House Style). A document whose
        # formulae use these units without a footnote providing the
        # mandated conversion is flagged.
        #
        # Scope: units are detected in formula (<stem>) content only.
        # Table cells and running text are excluded: "bar" and "kn" are
        # ordinary English words ("progress bar", "knuckle") whose
        # unit reading cannot be resolved from flat text without
        # value+unit parsing.
        class StyleBarKnotFootnoteRule < StyleRule
          policy category: "Quantities and units > bar and kn",
                 rule: "the units 'bar' and 'kn' carry the footnotes '1 bar = 0,1 MPa' and '1 kn = 1,852 km/h'",
                 source: :house_style, mn_category: :style

          STEM_CLASSES = [
            Metanorma::Document::Components::Inline::StemInlineElement,
            Metanorma::Document::Components::Inline::FmtStemElement,
          ].freeze

          # \bar in LaTeX math is the overline accent, not the unit —
          # a preceding backslash is excluded via lookbehind.
          BAR_UNIT_REGEX = /(?<!\\)\bbar\b/.freeze
          KN_UNIT_REGEX = /\bkn\b/.freeze

          BAR_FOOTNOTE_REGEX = /\bbar\b[^.]*\bMPa\b|\bMPa\b[^.]*\bbar\b/m.freeze
          KN_FOOTNOTE_REGEX = /\bkn\b.*1[.,]852|1[.,]852.*\bkn\b/m.freeze

          BAR_LABEL = "style: the unit 'bar' is used in a formula but the " \
                      "footnote '1 bar = 0,1 MPa' is absent".freeze
          KN_LABEL = "style: the unit 'kn' is used in a formula but the " \
                     "footnote '1 kn = 1,852 km/h' is absent".freeze

          def check(context)
            return [] if context.root.nil?

            stems, footnote_texts = collect_texts(context.root)
            issues = []
            issues.concat(unit_issues(stems, footnote_texts))
            issues
          end

          private

          def collect_texts(root)
            stem_texts = []
            footnote_texts = []
            STEM_CLASSES.each do |klass|
              each_instance_of(root, klass) do |stem|
                stem_texts << [stem, extract_text(stem)]
              end
            end
            each_instance_of(
              root, Metanorma::Document::Components::Inline::FnElement
            ) do |fn|
              footnote_texts << extract_text(fn)
            end
            [stem_texts, footnote_texts]
          end

          def unit_issues(stems, footnote_texts)
            issues = []
            issues.concat(missing_footnote_issues(
                            stems, footnote_texts,
                            unit_regex: BAR_UNIT_REGEX,
                            footnote_regex: BAR_FOOTNOTE_REGEX,
                            label: BAR_LABEL
                          ))
            issues.concat(missing_footnote_issues(
                            stems, footnote_texts,
                            unit_regex: KN_UNIT_REGEX,
                            footnote_regex: KN_FOOTNOTE_REGEX,
                            label: KN_LABEL
                          ))
            issues
          end

          # One finding per unit, located at the first formula that
          # uses it, when no footnote provides the mandated conversion.
          def missing_footnote_issues(stems, footnote_texts, unit_regex:,
                                      footnote_regex:, label:)
            matching_stems = stems.select { |_, text| text.match?(unit_regex) }
            return [] if matching_stems.empty?

            return [] if footnote_texts.any? do |text|
              text.match?(footnote_regex)
            end

            stem, = matching_stems.first
            [build_warning(stem, label)]
          end
        end
      end
    end
  end
end
