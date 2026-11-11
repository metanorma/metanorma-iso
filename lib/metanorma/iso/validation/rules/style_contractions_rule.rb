# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for apostrophe contractions (ISO House Style:
        # use full forms in technical documents). The list is
        # deliberately conservative -- a generic apostrophe regex would
        # flag possessives ("the system's") -- so only recognized
        # contraction forms are matched.
        class StyleContractionsRule < StyleRule
          CONTRACTIONS_REGEX = /
            \b(it's|that's|there's|here's|what's|who's|let's|he's|she's
              |i'm|you're|we're|they're
              |aren't|isn't|wasn't|weren't|don't|doesn't|didn't
              |can't|won't|wouldn't|shouldn't|couldn't|mustn't|needn't
              |hasn't|haven't|hadn't
              |i'll|you'll|he'll|she'll|it'll|we'll|they'll
              |i've|you've|we've|they've
              |i'd|you'd|he'd|she'd|we'd|they'd
              |shan't)\b
          /xi.freeze

          def scan_text(node, text)
            findings_for_matches(node, text, CONTRACTIONS_REGEX,
                                 "style: contraction '%s' (use the full form)")
          end
        end
      end
    end
  end
end
