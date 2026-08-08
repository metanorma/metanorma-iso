# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: requirement / permission / recommendation
        # language (shall, should, may, must, etc.) must not appear in
        # inappropriate contexts such as Foreword, Abstract, Scope.
        # ISO/IEC DIR 2.
        #
        # Overrides StyleRule#scan_text to use the immediate container
        # classification (+docpart_of+). When the parent is an
        # "inappropriate" context, applies modal-language regexes.
        class ModalInClauseRule < StyleRule
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

          def style_applicable?(context)
            context.state.lang.to_s == "en"
          end

          def scan_text(node, text)
            docpart = docpart_of(node)
            return [] unless docpart

            findings_for_modal(docpart, node, text, :requirement, REQUIREMENT_RE) +
              findings_for_modal(docpart, node, text, :permission, PERMISSION_RE) +
              findings_for_modal(docpart, node, text, :recommendation, RECOMMENDATION_RE)
          end

          private

          # Map a parent model node to a docpart symbol. Returns nil when
          # the context is appropriate for requirement language.
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

          def findings_for_modal(docpart, node, text, kind, regex)
            match = text.match(regex)
            return [] unless match

            [build_warning(node, "#{docpart} may contain #{kind}: #{match[0].strip}")]
          end
        end
      end
    end
  end
end
