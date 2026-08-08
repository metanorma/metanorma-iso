# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: requirement / permission / recommendation
        # language (shall, should, may, must, etc.) must not appear in
        # inappropriate contexts such as Foreword, Introduction, Scope,
        # or terms definitions/examples/notes. ISO/IEC DIR 2.
        #
        # Walks every paragraph via +each_paragraph_with_parent+, classifies
        # the containing block by type, and applies the modal-language
        # regex when the context is "no requirement language".
        # Emitted via STANDOC_48 (generic style warning).
        class ModalInClauseRule < Base
          code "STANDOC_48"

          # Requirement language per ISO/IEC DIR 2 Annex H. The _
          # placeholder matches whitespace; this mirrors the legacy
          # REQUIREMENT_RE_STR pattern.
          REQUIREMENT_RE = /(?:
            \bshall\b | (is|are)\s+to |
            (is|are)\s+required(\s+not)?\s+to |
            (is|are)\s+required\s+that |
            has\s+to |
            it\s+is\s+necessary |
            (is|are)\s+not_(allowed|permitted|acceptable|permissible) |
            (is|are)\s+not\s+to\s+be
          )/ix.freeze

          PERMISSION_RE = /\bmay\b|\b(is|are)\s+(permitted|allowed|permissible)\b/ix.freeze
          RECOMMENDATION_RE = /\bshould\b|\bought\s+(not\s+)?to\b/ix.freeze

          def applicable?(context)
            !context.root.nil? && context.state.lang.to_s == "en"
          end

          def check(context)
            issues = []
            each_paragraph_with_parent(context.root) do |paragraph, parent|
              docpart = docpart_of(parent)
              next unless docpart

              text = extract_text(paragraph)
              next if text.strip.empty?

              issues.concat(check_modal(docpart, paragraph, text, :requirement, REQUIREMENT_RE))
              issues.concat(check_modal(docpart, paragraph, text, :permission, PERMISSION_RE))
              issues.concat(check_modal(docpart, paragraph, text, :recommendation, RECOMMENDATION_RE))
            end
            issues
          end

          private

          # Map a parent model node to a docpart symbol. Returns nil when
          # the context is appropriate for requirement language (e.g. the
          # main body clauses, annexes with normative obligation).
          def docpart_of(parent)
            return nil unless parent

            case parent
            when Metanorma::IsoDocument::Sections::IsoForewordSection then :foreword
            when Metanorma::IsoDocument::Sections::IsoAbstractSection then :abstract
            when Metanorma::IsoDocument::Sections::IsoClauseSection
              parent.type == "scope" ? :scope : nil
            else
              nil
            end
          end

          def check_modal(docpart, paragraph, text, kind, regex)
            match = text.match(regex)
            return [] unless match

            label = "#{docpart} may contain #{kind}: #{match[0].strip}"
            [build_issue(location: model_location(paragraph), params: [label])]
          end
        end
      end
    end
  end
end
