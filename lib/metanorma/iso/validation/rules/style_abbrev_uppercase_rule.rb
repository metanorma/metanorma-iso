# frozen_string_literal: true

require "set"

module Metanorma
  module Iso
    module Validation
      module Rules
        # Style warning: abbreviated terms are written consistently in
        # one casing. A token that appears in the document in uppercase
        # form ("ISO", "CPU") must not also appear lowercase ("iso",
        # "cpu") — the lowercase instance is the violation.
        #
        # Document-frequency approach: first pass collects the
        # uppercase tokens (2–5 letters) across all prose paragraphs,
        # second pass flags the lowercase occurrences of a collected
        # token. English words that legitimately appear capitalized are
        # stoplisted ("NOTE", "EXAMPLE" labels, short function words).
        # "etc", "e.g." and "i.e." are exempt (single letters fall
        # below the token length; the words are stoplisted).
        class StyleAbbrevUppercaseRule < StyleRule
          code "ISO_66"

          policy category: "Abbreviated terms",
                 rule: "abbreviated terms are written consistently in one casing throughout the document",
                 source: :house_style, mn_category: :style

          UPPERCASE_TOKEN_REGEX = /\b[A-Z]{2,5}\b/.freeze
          LOWERCASE_TOKEN_REGEX = /\b[a-z]{2,5}\b/.freeze

          # English words excluded from the casing comparison: short
          # function words that surface in uppercase in labels and
          # headings, the document-vocabulary words used as labels
          # ("NOTE", "EXAMPLE", ...), and the lowercase-only
          # abbreviations ("etc.", "cf.").
          STOPWORDS = %w[
            all also and any are as at be been both but by can cannot
            case cf come could data date did do does done each eg end
            etc example for from get got had has have here him his how
            ie important in into is it its key lab max may min
            more most much must new no non none note not now of off on
            once one only onto or other our out over own per range ran
            run same see set she should some such sum than that the
            their them then there these they this those thus time title
            to too top total two type under until up upon us use used
            using via was way web well were what when where which while
            who why will with within without you your
          ].to_set.freeze

          LABEL = "style: '%s' is written in lowercase but '%s' is used " \
                  "elsewhere in the document (abbreviations are written " \
                  "consistently)".freeze

          # URL/URI payload is not abbreviation prose: its lowercase
          # token runs ("www.iso.org") must never enter the casing
          # comparison. Every ISO document carries https://www.iso.org
          # in its boilerplate foreword (metanorma/metanorma-pdfa#118).
          URI_TOKEN_REGEX = %r{
            (?:https?|ftp|telnet|file)://\S+
            |(?:mailto|urn|callto|sms):\S+
            |\bwww\.\S+
          }xi.freeze

          def check(context)
            tokens = collected_uppercase_tokens(context.root)
            issues = []
            each_paragraph(context.root) do |paragraph, parent|
              text = prose_text(paragraph)
              next if text.empty?

              issues.concat(scan_text(parent, text, tokens))
            end
            issues
          end

          private

          # Both passes scan the same text: markup-free prose with
          # URL/URI payload stripped, over paragraphs outside the
          # flavor-injected boilerplate.
          def collected_uppercase_tokens(root)
            tokens = Set.new
            each_paragraph(root) do |paragraph, _|
              tokens.merge(prose_text(paragraph).scan(UPPERCASE_TOKEN_REGEX))
            end
            tokens
          end

          def each_paragraph(root, &block)
            each_paragraph_with_parent(root,
                                       boilerplate_subtrees(root),
                                       &block)
          end

          # The <boilerplate> block (copyright statement, license
          # statement, ...) is publisher text, not author prose.
          def boilerplate_subtrees(root)
            return [] unless root&.respond_to?(:boilerplate)

            Array(root.boilerplate)
          end

          def prose_text(paragraph)
            extract_text(paragraph, strip: prose_exclusions)
              .gsub(URI_TOKEN_REGEX, " ")
              .strip
          end

          # Link elements are excluded whole: their content is the
          # rendered URL text, and their targets are XML attributes the
          # extraction never carries.
          def prose_exclusions
            super + %i(link fmt_link)
          end

          # Second pass: lowercase occurrences of a collected token.
          def scan_text(node, text, tokens)
            text.scan(LOWERCASE_TOKEN_REGEX)
                .uniq
                .reject { |token| STOPWORDS.include?(token) }
                .select { |token| tokens.include?(token.upcase) }
                .map do |token|
                  build_warning(node, format(LABEL, token, token.upcase))
                end
          end
        end
      end
    end
  end
end
