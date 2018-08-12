require "metanorma-standoc"
require "nokogiri"
require "pp"

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
           do_not )
        \\b
      REGEXP
      REQUIREMENT_RE =
        Regexp.new(REQUIREMENT_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE)

      def requirement(text)
        text.split(/\.\s+/).each do |t|
          return t if REQUIREMENT_RE.match t
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
      RECOMMENDATION_RE =
        Regexp.new(RECOMMENDATION_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE)

      def recommendation(text)
        text.split(/\.\s+/).each do |t|
          return t if RECOMMENDATION_RE.match t
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
      PERMISSION_RE =
        Regexp.new(PERMISSION_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE)

      def permission(text)
        text.split(/\.\s+/).each do |t|
          return t if PERMISSION_RE.match t
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
      POSSIBILITY_RE =
        Regexp.new(POSSIBILITY_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE)

      def possibility(text)
        text.split(/\.\s+/).each { |t| return t if POSSIBILITY_RE.match t }
        nil
      end

      def external_constraint(text)
        text.split(/\.\s+/).each do |t|
          return t if /\b(must)\b/xi.match t
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
    end
  end
end
