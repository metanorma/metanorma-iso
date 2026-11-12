# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Rules
        # Ambiguous decimal-comma lint (metanorma/metanorma-standoc#1372,
        # source report pdf-association/3dpdf-twg#5). In documents whose
        # locale renders DECIMAL COMMAS, a digit-comma-digit sequence
        # inside a list-comma context is ambiguous: the reader cannot tell
        # which commas are decimal separators and which are list
        # separators ("1, 2, 0,01 mm and 5,25 mm").
        #
        # A paragraph carrying digit-comma-digit sequences but NO list
        # commas is unambiguous -- the decimal comma is the only comma
        # reading -- and passes. The fix is the existing inline encoding:
        # the number:[] macro (e.g. number:0,01[]), rendered via
        # Plurimath as a locale-correct decimal number.
        #
        # Gating: the rule applies only when the document language renders
        # decimal commas (bibdata language, per StateExtractor). The
        # point-decimal locales default (English) and never see the
        # ambiguity.
        class StyleDecimalCommaRule < StyleRule
          code "ISO_143"

          policy category: "Numbers, values and dates > Numbers",
                 rule: "do not write a digit-comma-digit number in list " \
                       "context: the reader cannot tell decimal commas " \
                       "from list commas; encode decimal numbers with the " \
                       "number:[] inline macro",
                 source: :house_style, mn_category: :style

          DECIMAL_COMMA_REGEX = /\d+,\d+/.freeze

          # A comma-space separator with content following it: a list
          # separator, not a trailing punctuation comma.
          LIST_COMMA_REGEX = /, (?=\S)/.freeze

          # Languages whose decimal separator is the comma (CLDR decimal
          # conventions). Gated on the bibdata language's primary
          # subtag, so region variants ("fr-FR") resolve to their base
          # language. Point-decimal locales (en, ja, zh, ...) are absent
          # and turn the rule off. A language absent from this list means
          # the rule stays silent for it, never that its convention is
          # endorsed.
          COMMA_DECIMAL_LANGUAGES = %w[
            af sq be bg ca hr cs da nl et fi fr de el hu is it
            lv lt mk nb nn no pl pt ro ru sr sk sl es sv tr uk
          ].freeze

          def style_applicable?(context)
            lang = primary_language(context.state&.lang)
            COMMA_DECIMAL_LANGUAGES.include?(lang)
          end

          def scan_text(node, text)
            occurrences = text.scan(DECIMAL_COMMA_REGEX).uniq
            return [] if occurrences.empty?
            return [] unless text.match?(LIST_COMMA_REGEX)

            occurrences.map do |occurrence|
              build_warning(node, format(AMBIGUOUS_LABEL, occurrence))
            end
          end

          AMBIGUOUS_LABEL = "ambiguous decimal comma in list context: %s " \
                            "could be read as a decimal number or as part " \
                            "of a list; encode decimal numbers with the " \
                            "number:[] inline macro (e.g. number:0,01[])".freeze

          private

          def primary_language(lang)
            lang.to_s.split(/[-_]/).first.to_s.downcase
          end
        end
      end
    end
  end
end
