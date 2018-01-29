require "asciidoctor/iso/isoxml/utils"
require "nokogiri"
require "jing"
require "pp"

module Asciidoctor
  module ISO
    module ISOXML
      module Validate
        class << self
          @@requirement_re_str = <<~REGEXP
            \\b
             ( shall | (is|are)_to |
                   (is|are)_required_(not_)?to |
                   has_to |
                   only\\b[^.,]+\\b(is|are)_permitted |
                   it_is_necessary |
                   (needs|need)_to |
                   (is|are)_not_(allowed | permitted |
                                   acceptable | permissible) |
                   (is|are)_not_to_be |
                   (need|needs)_not |
                   do_not )
                \\b
          REGEXP
          @@requirement_re =
            Regexp.new(@@requirement_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def requirement(text)
            text.split(/\.\s+/).each do |t|
              return t if @@requirement_re.match? t
            end
            nil
          end

          @@recommendation_re_str = <<~REGEXP
            \\b
                should |
                ought_(not_)?to |
                it_is_(not_)?recommended_that
            \\b
          REGEXP
          @@recommendation_re =
            Regexp.new(@@recommendation_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def recommendation(text)
            text.split(/\.\s+/).each do |t|
              return t if @@recommendation_re.match? t
            end
            nil
          end

          @@permission_re_str = <<~REGEXP
            \\b
                 may |
                (is|are)_(permitted | allowed | permissible ) |
                it_is_not_required_that |
                no\\b[^.,]+\\b(is|are)_required
            \\b
          REGEXP
          @@permission_re =
            Regexp.new(@@permission_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def permission(text)
            text.split(/\.\s+/).each do |t|
              return t if @@permission_re.match? t
            end
            nil
          end

          @@possibility_re_str = <<~REGEXP
            \\b
               can | cannot | be_able_to |
               there_is_a_possibility_of |
               it_is_possible_to | be_unable_to |
               there_is_no_possibility_of |
               it_is_not_possible_to
            \\b
          REGEXP
          @@possibility_re =
            Regexp.new(@@possibility_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def posssibility(text)
            text.split(/\.\s+/).each do |t|
              return t if @@possibility_re.match? t
            end
            nil
          end

          def external_constraint(text)
            text.split(/\.\s+/).each do |t|
              return t if /\b(must)\b/xi.match? t
            end
            nil
          end

          def style_no_guidance(node, text, docpart)
            r = requirement(text)
            style_warning(node, "#{docpart} may contain requirement", r) if r
            r = permission(text)
            style_warning(node, "#{docpart} may contain permission", r) if r
            r = recommendation(text)
            style_warning(node, "#{docpart} may contain recommendation", r) if r
          end

          def foreword_style(node, text)
            style_no_guidance(node, text, "Foreword")
          end

          def scope_style(node, text)
            style_no_guidance(node, text, "Scope")
          end

          def introduction_style(node, text)
            r = requirement(text)
            style_warning(node, "Introduction may contain requirement", r) if r
          end

          def termexample_style(node, text)
            style_no_guidance(node, text, "Term Example")
            style(node, text)
          end

          def note_style(node, text)
            style_no_guidance(node, text, "Note")
            style(node, text)
          end

          def footnote_style(node, text)
            style_no_guidance(node, text, "Footnote")
            style(node, text)
          end

          def style_warning(node, msg, text)
            w = "ISO style: WARNING (#{Utils::current_location(node)}): #{msg}"
            w += ": #{text}" if text
            warn w
          end

          # style check with a single regex
          def style_single_regex(n, text, re, warning)
            m = re.match(text) and style_warning(n, warning, m[:num])
          end

          # style check with a regex on a token
          # and a negative match on its preceding token
          def style_two_regex_not_prev(n, text, re, re_prev, warning)
            return if text.nil?
            words = text.split(/\W+/).each_index do |i|
              next if i == 0
              m = re.match text[i]
              m_prev = re_prev.match text[i - 1]
              if !m.nil? && m_prev.nil?
                style_warning(n, warning, m[:num])
              end
            end
          end

          def style(n, text)
            style_single_regex(n, text, /\b(?<num>[0-9]+\.[0-9]+)\b/,
                               "possible decimal point")
            style_two_regex_not_prev(n, text, /^(?<num>[0-9]{4,})$/,
                                     %r{(\bISO|\bIEC|\bIEEE|/)$},
                                     "number not broken up in threes")
            style_single_regex(n, text, /\b(?<num>[0-9.,]+%)/,
                               "no space before percent sign")
            style_single_regex(n, text, /\b(?<num>[0-9.,]+ \u00b1 [0-9,.]+ %)/,
                               "unbracketed tolerance before percent sign")
          end
        end
      end
    end
  end
end
