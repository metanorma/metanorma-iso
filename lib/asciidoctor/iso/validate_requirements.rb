require "metanorma-standoc"

module Asciidoctor
  module ISO
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

      def requirement_re
        Regexp.new(self.class::REQUIREMENT_RE_STR.gsub(/\s/, "")
          .gsub(/_/, "\\s"), Regexp::IGNORECASE)
      end

      def requirement_check(text)
        text.split(/\.\s+/).each do |t|
          return t if requirement_re.match t
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

      def recommendation_re
        Regexp.new(self.class::RECOMMENDATION_RE_STR.gsub(/\s/, "")
          .gsub(/_/, "\\s"), Regexp::IGNORECASE)
      end

      def recommendation_check(text)
        text.split(/\.\s+/).each do |t|
          return t if recommendation_re.match t
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

      def permission_re
        Regexp.new(self.class::PERMISSION_RE_STR.gsub(/\s/, "")
          .gsub(/_/, "\\s"), Regexp::IGNORECASE)
      end

      def permission_check(text)
        text.split(/\.\s+/).each do |t|
          return t if permission_re.match t
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

      def possibility_re
        Regexp.new(self.class::POSSIBILITY_RE_STR.gsub(/\s/, "")
          .gsub(/_/, "\\s"), Regexp::IGNORECASE)
      end

      def possibility(text)
        text.split(/\.\s+/).each { |t| return t if possibility_re.match t }
        nil
      end

      def external_constraint(text)
        text.split(/\.\s+/).each do |t|
          return t if /\b(must)\b/xi.match? t
        end
        nil
      end

      def style_no_guidance(node, text, docpart)
        r = requirement_check(text)
        style_warning(node, "#{docpart} may contain requirement", r) if r
        r = permission_check(text)
        style_warning(node, "#{docpart} may contain permission", r) if r
        r = recommendation_check(text)
        style_warning(node, "#{docpart} may contain recommendation", r) if r
      end
    end
  end
end
