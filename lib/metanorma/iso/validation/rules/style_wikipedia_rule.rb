# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for wikipedia.org references (unstable-site
        # policy: Wikipedia is not a citable source in standards; cite
        # a stable source). Text occurrences and <link target="..."> URLs
        # are both caught: the prose scan sees the URL in text, and the
        # link scan reads targets from the model, since target is an XML
        # attribute and content-only prose extraction does not carry
        # attributes. <eref> elements carry bibliographic item
        # identifiers rather than URLs, so they need no separate walk.
        class StyleWikipediaRule < StyleRule
          code "ISO_120"

          policy category: "Referencing > References to websites",
                 rule: "do not reference unstable websites such as Wikipedia; cite a stable source",
                 source: :house_style, mn_category: :references

          WIKIPEDIA_REGEX = /\bwikipedia\.org\b/i.freeze
          FINDING_LABEL = "style: '%s' (unstable reference; cite a stable source)".freeze

          LINK_ELEMENT = Metanorma::Document::Components::Inline::LinkElement

          def scan_text(node, text)
            findings_for_matches(node, text, WIKIPEDIA_REGEX, FINDING_LABEL)
          end

          def check(context)
            super + link_target_issues(context)
          end

          private

          # Flag every link target in every walked paragraph's subtree.
          # Links nest (a <link> may carry inline children), so the walk
          # is by model class, not by paragraph-child position.
          def link_target_issues(context)
            issues = []
            context.walk_cache.paragraphs_with_parent(context.root)
              .each do |paragraph, parent|
              each_instance_of(paragraph, LINK_ELEMENT) do |link|
                text = link.target.to_s
                issues.concat(findings_for_matches(parent, text, WIKIPEDIA_REGEX, FINDING_LABEL))
              end
            end
            issues
          end
        end
      end
    end
  end
end
