# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: vocabulary documents are titled "Vocabulary"
        # (ISO House Style, Vocabulary documents). A vocabulary
        # document (docsubtype "vocabulary") whose title component is
        # "Terminology" or "Terms and definitions" uses the wrong
        # designating word.
        #
        # Conservative scope: only title-main/title-intro components
        # EQUAL to one of the wrong designators are flagged. Domain
        # titles that merely begin with the word ("Terminology work and
        # terminology science — Vocabulary", ISO 1087) are legitimate
        # and stay unflagged.
        #
        # The Clause 3 fixed lead-in ("For the purposes of this
        # document, the following terms and definitions apply.") does
        # not appear in vocabulary documents: the vocabulary
        # introduction replaces it.
        class StyleVocabTitleRule < StyleRule
          code "ISO_119"

          policy category: "Vocabulary documents > Title",
                 rule: "vocabulary documents are titled 'Vocabulary', not 'Terminology' or 'Terms and definitions'; the Clause 3 fixed lead-in is not used",
                 source: :house_style, mn_category: :style

          WRONG_TITLES = ["Terminology", "Terms and definitions"].freeze

          FIXED_TEXT_REGEX =
            /\bFor\s+the\s+purposes\s+of\s+this\s+document\b/i.freeze

          TITLE_LABEL = "title style: '%s' (vocabulary documents are " \
                        "titled 'Vocabulary')".freeze
          FIXED_TEXT_LABEL = "style: the fixed Clause 3 lead-in 'For the " \
                             "purposes of this document ...' is not used in " \
                             "vocabulary documents".freeze

          def style_applicable?(context)
            context.state&.vocab ? true : false
          end

          def check(context)
            return [] unless style_applicable?(context)

            title_issues(context) + lead_in_issues(context)
          end

          def scan_text(node, text)
            finding_if_match(node, text, FIXED_TEXT_REGEX, FIXED_TEXT_LABEL)
          end

          private

          # English title-main/title-intro components that equal a
          # wrong vocabulary designator.
          def title_issues(context)
            bibdata = context.root&.bibdata
            return [] unless bibdata

            title_items(bibdata).filter_map do |item|
              next unless %w[title-main title-intro].include?(item._type)
              next unless item.language == "en"
              next unless WRONG_TITLES.include?(item.value.to_s.strip)

              build_warning(item, format(TITLE_LABEL, item.value.to_s.strip))
            end
          end

          def lead_in_issues(context)
            issues = []
            cache = context.walk_cache
            cache.paragraphs_with_parent(context.root).each do |paragraph, parent|
              text = cache.text_of(paragraph, strip: prose_exclusions).strip
              next if text.empty?

              issues.concat(scan_text(parent, text))
            end
            issues
          end

          # Mirrors TitleNamesDoctypeRule#title_items.
          def title_items(bibdata)
            titles = bibdata.titles if bibdata.class.method_defined?(:titles)
            return [] unless titles

            return Array(titles) unless titles.is_a?(Metanorma::Iso::Document::Metadata::TitleCollection)

            Array(titles.items)
          end
        end
      end
    end
  end
end
