require "nokogiri"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      # Legacy Nokogiri validators for checks not yet migrated to Layer 3.
      # section_validate is no longer called via standoc's super — the
      # Iso::Validate#content_validate dispatches directly. These methods
      # remain for the specific checks listed below.

      # ISO_24 normref structure (blocked on TODO 33 model extension).
      def normref_validate(root)
        f = root.at("//references[@normative = 'true']") || return
        f.at("./references | ./clause") &&
          @log.add("ISO_24", f)
      end

      def symbols_validate(_root)
        # Migrated to Layer 3 (TODO 17).
      end

      # Legacy style checks not yet migrated.
      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[@type = 'scope']"))
        tech_report_style(root)
      end

      def tech_report_style(root)
        @doctype == "technical-report" or return
        root.xpath("//sections/clause[not(@type = 'scope')] | //annex")
          .each do |s|
          r = requirement_check(extract_text(s)) and
            style_warning(s,
                          "Technical Report clause may contain requirement", r)
        end
      end

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause")
          .each do |c|
          style_warning(c, "Exceeds the maximum clause depth of 7", nil)
        end
      end
    end
  end
end
