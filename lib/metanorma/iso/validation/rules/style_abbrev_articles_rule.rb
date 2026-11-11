# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warnings for wrong indefinite articles before
        # initialisms (ISO House Style): initialisms pronounced
        # letter-wise take "an" ("an ISO standard", "an XML file"),
        # not "a".
        #
        # The list below is closed and conservative: only initialisms
        # whose English pronunciation begins with a letter name
        # ("gee", "you", "ess", ...) are flagged, so "a GPS", "a UN",
        # "a SQL" and friends are reported. The reverse direction
        # ("an RFC", "an SAP" read as a word) and acronyms pronounced
        # as words (RAM, NATO) are intentionally out of scope.
        class StyleAbbrevArticlesRule < StyleRule
          LETTER_PRONOUNCED = %w[
            GPS UN URN ERP HR SQL API ISO HTML XML RGB RPG SAP PDF
            JPG RPM RSA SLA UML URL
          ].freeze

          A_ARTICLE_REGEX =
            /\ba\s+(?:#{LETTER_PRONOUNCED.join("|")})\b/.freeze

          def scan_text(node, text)
            findings_for_matches(
              node, text, A_ARTICLE_REGEX,
              "wrong article '%s': this initialism is pronounced " \
              "letter-wise — use 'an'"
            )
          end
        end
      end
    end
  end
end
