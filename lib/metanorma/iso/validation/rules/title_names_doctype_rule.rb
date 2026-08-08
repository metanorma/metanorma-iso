# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # ISO_17 / ISO_18: title text must not name the document type
        # (e.g. must not contain "International Standard", "Technical
        # Specification", etc.). ISO/IEC DIR 2, 11.5.2.
        #
        # ISO_17: title-main names the doctype
        # ISO_18: title-intro names the doctype
        class TitleNamesDoctypeRule < Base
          code "ISO_17" # default; ISO_18 emitted explicitly.

          DOCTYPE_WORDS_REGEX = /International\sStandard | Technical\sSpecification |
            Publicly\sAvailable\sSpecification | Technical\sReport | Guide /xi.freeze

          def applicable?(context)
            !context.root.nil? &&
              !context.root.bibdata.nil? &&
              context.state.lang.to_s == "en"
          end

          def check(context)
            items = title_items(context.root.bibdata)
            issues = []

            main = find_title(items, "title-main", "en")
            issues << build_issue_explicit("ISO_17", main) if names_doctype?(main)

            intro = find_title(items, "title-intro", "en")
            issues << build_issue_explicit("ISO_18", intro) if names_doctype?(intro)

            issues
          end

          private

          def title_items(bibdata)
            titles = bibdata.titles if bibdata.class.method_defined?(:titles)
            return [] unless titles

            return Array(titles) unless titles.is_a?(Metanorma::IsoDocument::Metadata::TitleCollection)

            Array(titles.items)
          end

          def find_title(items, type, lang)
            items.find { |it| it._type == type && it.language == lang }
          end

          def names_doctype?(title)
            return false if title.nil?
            return false unless title.class.method_defined?(:value)

            DOCTYPE_WORDS_REGEX.match?(title.value.to_s)
          end

          def build_issue_explicit(code, title)
            Metanorma::Iso::Validation::Issue.from_finding(
              code: code, location: model_location(title), params: []
            )
          end
        end
      end
    end
  end
end
