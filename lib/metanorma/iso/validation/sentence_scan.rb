# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Sentence analysis helper for the context-dependent style rules
      # (issue #1705, tranche A). Pure functions over extracted prose
      # text: no model access and no NLP dependency, so rules can rely
      # on deterministic splitting.
      #
      # Splitting is deliberately conservative, because over-splitting
      # is the main quality risk for the rules built on top of it:
      #
      #   - Sentence terminators are ".", "?" and "!" followed by
      #     whitespace or the end of the text.
      #   - A "." is NOT a terminator when it is part of a decimal
      #     number ("3.5", "3.5.2"), of an exempted abbreviation
      #     ("e.g.", "i.e.", "approx.", "no.", "ca.", ...), or of a
      #     single-capital initial ("J. Smith").
      #   - A "." is NOT a terminator when the next word begins with a
      #     lowercase letter: ISO prose starts sentences with capitals,
      #     so this trades the rare under-split for never cutting a
      #     sentence in half.
      #
      # Under-splitting is acceptable (it only suppresses findings);
      # over-splitting produces false positives.
      module SentenceScan
        # One sentence: its stripped text, the offset of its first
        # character within the scanned text, and its 0-based position.
        Sentence = Struct.new(:text, :start, :index)

        # Abbreviations whose trailing "." does not end a sentence.
        # Matched case-insensitively against the token immediately
        # before the period ("No. 10", "ca. 5 mm", "see e.g. the table").
        ABBREVIATIONS = %w[
          e.g i.e viz al ca approx no nos min max fig figs eq eqn eqs
          sect sec ch cl p pp col vol vs cf etc ed eds ref refs dr mr
          mrs ms prof st
        ].freeze

        TERMINATORS = %w[. ! ?].freeze

        module_function

        # Split +text+ into sentences. Returns an Array of
        # {SentenceScan::Sentence} structs carrying the stripped sentence
        # text, its start offset in +text+, and its 0-based index.
        def sentences(text)
          str = text.to_s
          result = []
          seg_start = 0
          i = 0
          while i < str.length
            if terminator_at?(str, i)
              j = sentence_end(str, i)
              append_sentence(result, str[seg_start...j], seg_start)
              seg_start = j
              i = j
            else
              i += 1
            end
          end
          append_sentence(result, str[seg_start..], seg_start)
          result
        end

        # Sentence texts only, in order. Convenience wrapper over
        # #sentences for rules that do not need offsets.
        def split(text)
          sentences(text).map(&:text)
        end

        # True when +offset+ is the start offset of some sentence in
        # +text+.
        def starts_sentence?(text, offset)
          sentences(text).any? { |s| s.start == offset }
        end

        # True when the character at +i+ ends a sentence.
        def terminator_at?(str, i)
          ch = str[i]
          return false unless TERMINATORS.include?(ch)

          return false if ch == "." && decimal_dot?(str, i)
          return false if ch == "." && abbreviation_dot?(str, i)
          return false if ch == "." && initial_dot?(str, i)

          nxt = str[i + 1]
          return true if nxt.nil?
          return false unless nxt.match?(/\s/)

          !(ch == "." && lowercase_follows?(str, i + 1))
        end

        # Offset just past the whitespace run following the terminator
        # at +i+ (the next sentence's raw segment start).
        def sentence_end(str, i)
          j = i + 1
          j += 1 while j < str.length && str[j].match?(/\s/)
          j
        end

        def append_sentence(result, raw, seg_start)
          return if raw.nil?

          stripped = raw.strip
          return if stripped.empty?

          offset = seg_start + (raw.length - raw.lstrip.length)
          result << Sentence.new(stripped, offset, result.length)
        end

        # A "." between two digits is a decimal separator ("3.5",
        # "3.5.2"), never a sentence end.
        def decimal_dot?(str, i)
          i.positive? && str[i - 1].match?(/\d/) &&
            i + 1 < str.length && str[i + 1].match?(/\d/)
        end

        # A "." terminating an exempted abbreviation ("e.g.", "approx.",
        # "no.") does not end a sentence.
        def abbreviation_dot?(str, i)
          token = token_before(str, i)
          return false if token.empty?

          ABBREVIATIONS.include?(token.downcase)
        end

        # The run of letters and internal dots immediately before
        # position +i+ ("e.g" out of "e.g.").
        def token_before(str, i)
          j = i
          j -= 1 while j.positive? && str[j - 1].match?(/[A-Za-z.]/)
          str[j...i]
        end

        # A "." after a single-capital initial ("J. Smith") does not end
        # a sentence.
        def initial_dot?(str, i)
          return false unless i.positive? && str[i - 1].match?(/[A-Z]/)

          i == 1 || str[i - 2].match?(/\s/)
        end

        # True when the next non-space character after +from+ is a
        # lowercase letter. ISO prose starts sentences with capitals, so
        # a lowercase continuation means the period was not a sentence
        # end (or the split would be unsafe).
        def lowercase_follows?(str, from)
          k = from
          k += 1 while k < str.length && str[k].match?(/\s/)
          return false if k >= str.length

          str[k].match?(/[a-z]/)
        end
      end
    end
  end
end
