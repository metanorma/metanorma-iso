require "metanorma-standoc"

module Metanorma
  module Iso
    class Converter < Standoc::Converter
      REQUIREMENT_RE_STR = <<~REGEXP.freeze
        \\b
         ( shall | (is|are)_to |
           (is|are)_required_(not_)?to |
           (is|are)_required_that |
           has_to |
           only\\b[^.,]+\\b(is|are)_permitted |
           it_is_necessary |
           (is|are)_not_(allowed | permitted |
                         acceptable | permissible) |
           (is|are)_not_to_be |
           [.,:;]_do_not )
        \\b
      REGEXP

      def str_to_regexp(str)
        Regexp.new(str.gsub(/\s/, "").gsub("_", "\\s"), Regexp::IGNORECASE)
      end

      def requirement_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::REQUIREMENT_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each do |t|
          return t if re.match t
        end
        nil
      end

      RECOMMENDATION_RE_STR = <<~REGEXP.freeze
        \\b
            should |
            ought_(not_)?to |
            it_is_(not_)?recommended_that
        \\b
      REGEXP

      def recommendation_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::REQUIREMENT_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each do |t|
          return t if re.match t
        end
        nil
      end

      PERMISSION_RE_STR = <<~REGEXP.freeze
        \\b
             may |
            (is|are)_(permitted | allowed | permissible ) |
            it_is_not_required_that |
            no\\b[^.,]+\\b(is|are)_required
        \\b
      REGEXP

      def permission_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::PERMISSION_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each do |t|
          return t if re.match t
        end
        nil
      end

      POSSIBILITY_RE_STR = <<~REGEXP.freeze
        \\b
           can | cannot | be_able_to |
           there_is_a_possibility_of |
           it_is_possible_to | be_unable_to |
           there_is_no_possibility_of |
           it_is_not_possible_to
        \\b
      REGEXP

      def possibility_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::POSSIBILITY_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each { |t| return t if re.match t }
        nil
      end

      def external_constraint(text)
        text.split(/\.\s+/).each do |t|
          return t if /\b(must)\b/xi.match? t
        end
        nil
      end

      AMBIG_WORDS_RE_STR = <<~REGEXP.freeze
        \\b(
            need_to | needs_to | might | could | family_of_standards | suite_of_standards
        )\\b
      REGEXP

      def ambig_words_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::AMBIG_WORDS_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each do |t|
          return t if re.match t
        end
        nil
      end

      MISSPELLED_WORDS_RE_STR = <<~REGEXP.freeze
        \\b(
            on-line | cyber_security | cyber-security
        )\\b
      REGEXP

      def misspelled_words_check(text)
        @lang == "en" or return
        re = str_to_regexp(self.class::MISSPELLED_WORDS_RE_STR)
        text.gsub(/\s+/, " ").split(/\.\s+/).each do |t|
          return t if re.match t
        end
        nil
      end

      def style_no_guidance(node, text, docpart)
        @lang == "en" or return
        r = requirement_check(text) and
          style_warning(node, "#{docpart} may contain requirement", r,
                        display: false)
        r = permission_check(text) and
          style_warning(node, "#{docpart} may contain permission", r,
                        display: false)
        r = recommendation_check(text) and
          style_warning(node, "#{docpart} may contain recommendation", r,
                        display: false)
      end
    end
  end
end
