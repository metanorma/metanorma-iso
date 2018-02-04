require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module Section
      @scope = false
      @biblio = false
      @term_def = false
      @norm_ref = false

      def in_scope
        @scope
      end

      def in_biblio
        @biblio
      end

      def in_terms
        @term_def
      end

      def in_norm_ref
        @norm_ref
      end

      def section(node)
        a = { id: Utils::anchor_or_uuid(node) }
        noko do |xml|
          case node.title.downcase
          when "introduction" then
            if node.level == 1
              introduction_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          when "patent notice" then patent_notice_parse(xml, node)
          when "scope" then scope_parse(a, xml, node)
          when "normative references" then norm_ref_parse(a, xml, node)
          when "terms and definitions" 
            term_def_parse(a, xml, node, node.title.downcase)
          when "terms, definitions, symbols and abbreviations"
            term_def_parse(a, xml, node, node.title.downcase)
          when "symbols and abbreviated terms" 
            symbols_parse(a, xml, node)
          when "bibliography" then bibliography_parse(a, xml, node)
          else
            if @term_def
              term_def_subclause_parse(a, xml, node)
            elsif @biblio
              bibliography_parse(a, xml, node)
            elsif node.attr("style") == "appendix" && node.level == 1
              annex_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          end
        end.join("\n")
      end

      def clause_parse(attrs, xml, node)
        attrs["inline-header".to_sym] = true if node.option? "inline-header"
        w = "Scope contains subsections: should be succint"
        style_warning(node, w, nil) if @scope
        # Not testing max depth of sections: Asciidoctor already limits
        # it to 5 levels of nesting
        sect = node.level == 1 ? "clause" : "subsection"
        xml.send sect, **attr_code(attrs) do |xml_section|
          xml_section.title { |n| n << node.title } unless node.title.nil?
          xml_section << node.content
        end
      end

      def annex_parse(attrs, xml, node)
        attrs["inline-header".to_sym] = true if node.option? "inline-header"
        attrs[:subtype] = "informative"
        if node.attributes.has_key?("subtype")
          attrs[:subtype] = node.attr("subtype")
        end
        xml.annex **attr_code(attrs) do |xml_section|
          xml_section.title { |name| name << node.title }
          xml_section << node.content
        end
      end

      def bibliography_parse(attrs, xml, node)
        @biblio = true
        xml.references **attr_code(attrs) do |xml_section|
          title = node.level == 1 ? "Bibliography" : node.title
          xml_section.title { |t| t << title }
          xml_section << node.content
        end
        @biblio = true
      end

      def symbols_parse(attrs, xml, node)
        xml.symbols_abbrevs **attr_code(attrs) do |xml_section|
          xml_section << node.content
        end
      end

      def term_def_subclause_parse(attrs, xml, node)
        xml.term **attr_code(attrs) do |xml_section|
          xml_section.preferred { |name| name << node.title }
          xml_section << node.content
        end
      end

      def term_def_parse(attrs, xml, node, title)
        @term_def = true
        xml.terms **attr_code(attrs) do |xml_section|
          if title == "terms, definitions, symbols and abbreviations"
            title = "Terms, Definitions, Symbols and Abbreviations"
          else
            title = "Terms and Definitions"
          end
          xml_section.title { |t| t << title }
          xml_section << node.content
        end
        @term_def = false
      end

      def norm_ref_parse(attrs, xml, node)
        @norm_ref = true
        xml.references **attr_code(attrs) do |xml_section|
          xml_section.title { |t| t << "Normative References" }
          xml_section << node.content
        end
        @norm_ref = false
      end

      def introduction_parse(attrs, xml, node)
        xml.content **attr_code(attrs) do |xml_section|
          xml_section.title = "Introduction"
          content = node.content
          xml_section << content
          introduction_style(node,
                             Utils::flatten_rawtext(content).
                             join("\n"))
        end
      end

      def patent_notice_parse(xml, node)
        # xml.patent_notice do |xml_section|
        #  xml_section << node.content
        # end
        xml << node.content
      end

      def scope_parse(attrs, xml, node)
        @scope = true
        xml.clause **attr_code(attrs) do |xml_section|
          xml_section.title { |t| t << "Scope" }
          content = node.content
          xml_section << content
          c = Utils::flatten_rawtext(content).join("\n")
          scope_style(node, c)
        end
        @scope = false
      end
    end
  end
end
