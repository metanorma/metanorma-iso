# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for wikipedia.org references (unstable-site
        # policy: Wikipedia is not a citable source in standards; cite
        # a stable source). Text occurrences and <link target="..."> URLs
        # are both caught: StyleRule's prose extraction includes inline
        # element string attributes, so link targets flow into the
        # scanned text. <eref> elements carry bibliographic item
        # identifiers rather than URLs, so they need no separate walk.
        class StyleWikipediaRule < StyleRule
          WIKIPEDIA_REGEX = /\bwikipedia\.org\b/i.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, WIKIPEDIA_REGEX,
              "style: '%s' (unstable reference; cite a stable source)"
            )
          end
        end
      end
    end
  end
end
