# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Base class for text-linting style rules. Each style rule walks
        # every paragraph in the document, extracts its text content,
        # and applies rule-specific regex/logic via +#scan_text+.
        #
        # Subclasses override +#scan_text(node, text)+ to return an Array
        # of Issues (or [] for no findings). Override +#style_applicable?+
        # for context gating (script, language, doctype).
        #
        # All style warnings emit STANDOC_48 (generic style warning).
        # The "billions" / "ambiguous number" check remains in legacy
        # form because it shares state with style_number_grouping.
        class StyleRule < Base
          abstract!
          code "STANDOC_48"

          def applicable?(context)
            return false if context.root.nil?

            style_applicable?(context)
          end

          def check(context)
            issues = []
            each_paragraph_with_parent(context.root) do |paragraph, parent|
              text = extract_text(paragraph).strip
              next if text.empty?

              issues.concat(scan_text(parent, text))
            end
            issues
          end

          # Hook: return true if this rule should run for the given context.
          # Default: always applicable when root is present (checked in
          # +applicable?+). Override for script/language gating.
          def style_applicable?(_context)
            true
          end

          # Hook: scan one paragraph's text and return any findings.
          # +node+ is the paragraph's immediate container (clause/figure/
          # etc.); +text+ is the extracted text content, stripped.
          # Default: no findings. Override in subclasses.
          def scan_text(_node, _text)
            []
          end

          protected

          # Helper for subclasses: emit one finding per regex match.
          def findings_for_matches(node, text, regex, label_template)
            matches = text.scan(regex).flatten.compact.uniq
            matches.map do |match|
              build_warning(node, format(label_template, match))
            end
          end

          # Helper: emit a single finding when regex matches at all.
          def finding_if_match(node, text, regex, label)
            return [] unless text.match?(regex)

            [build_warning(node, label)]
          end

          def build_warning(node, message)
            build_issue(location: model_location(node), params: [message])
          end
        end
      end
    end
  end
end
