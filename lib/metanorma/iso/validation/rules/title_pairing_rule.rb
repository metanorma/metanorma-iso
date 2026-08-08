# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_10 / ISO_11 / ISO_12 / ISO_13 / ISO_14 / ISO_15: title bilingual
        # pairing. The EN and FR title components must be symmetric — each
        # component present in one language must be present in the other.
        #
        #   ISO_10: missing EN title-intro  (when FR has it)
        #   ISO_11: missing FR title-intro  (when EN has it)
        #   ISO_12: missing EN title-main   (when FR has it)
        #   ISO_13: missing FR title-main   (when EN has it)
        #   ISO_14: missing EN title-part   (when FR has it)
        #   ISO_15: missing FR title-part   (when EN has it)
        #
        # Walks bibdata.title.items (collection of AbstractTitle) and groups
        # by (_type, language).
        class TitlePairingRule < Base
          code "ISO_10" # default; other codes emitted explicitly.

          COMPONENTS = %w[title-intro title-main title-part].freeze
          MISSING_CODE_BY_COMPONENT_AND_LANG = {
            ["title-intro", "en"] => "ISO_10",
            ["title-intro", "fr"] => "ISO_11",
            ["title-main",  "en"] => "ISO_12",
            ["title-main",  "fr"] => "ISO_13",
            ["title-part",  "en"] => "ISO_14",
            ["title-part",  "fr"] => "ISO_15"
          }.freeze

          def applicable?(context)
            !context.root.nil? && !context.root.bibdata.nil?
          end

          def check(context)
            items = title_items(context.root.bibdata)
            return [] if items.empty?

            present = index_present(items)
            build_issues_for_missing(present)
          end

          private

          def title_items(bibdata)
            titles = bibdata.titles if bibdata.class.method_defined?(:titles)
            return [] unless titles

            # TitleCollection wraps AbstractTitle items. Collection class
            # exposes them via .items; bare AbstractTitle arrays pass through.
            return Array(titles) unless titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection)

            Array(titles.items)
          end

          # Builds a hash: { "title-intro" => Set["en", "fr"], ... }
          # Only languages "en" and "fr" are tracked.
          def index_present(items)
            present = COMPONENTS.each_with_object({}) { |c, h| h[c] = [] }
            items.each do |item|
              type = item._type.to_s
              lang = item.language.to_s
              next unless COMPONENTS.include?(type)
              next unless %w[en fr].include?(lang)

              present[type] << lang unless present[type].include?(lang)
            end
            present
          end

          def build_issues_for_missing(present)
            issues = []
            COMPONENTS.each do |component|
              issues.concat(missing_issues_for(component, present[component]))
            end
            issues
          end

          def missing_issues_for(component, present_langs)
            issues = []
            %w[en fr].each do |expected_lang|
              next if present_langs.include?(expected_lang)
              next unless present_langs.include?(other_lang(expected_lang))

              code = MISSING_CODE_BY_COMPONENT_AND_LANG[[component, expected_lang]]
              issues << build_issue_explicit(code, component, expected_lang)
            end
            issues
          end

          def other_lang(lang)
            lang == "en" ? "fr" : "en"
          end

          def build_issue_explicit(code, component, lang)
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code,
              location: "bibdata/title[@type='#{component}'][@language='#{lang}']",
              params: []
            )
          end
        end
      end
    end
  end
end
