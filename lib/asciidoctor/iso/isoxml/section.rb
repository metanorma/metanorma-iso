require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module ISOXML
      module Section
        def section(node)
          a = { anchor: Utils::anchor_or_uuid(node) }
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
            when "terms and definitions" then term_def_parse(a, xml, node)
            when "terms, definitions, symbols and abbreviated terms"
              term_def_parse(a, xml, node)
            when "symbols and abbreviations" then symbols_parse(a, xml, node)
            when "bibliography" then bibliography_parse(a, xml, node)
            else
              if $term_def
                term_def_subclause_parse(a, xml, node)
              elsif node.attr("style") == "appendix"
                annex_parse(a, xml, node)
              else
                clause_parse(a, xml, node)
              end
            end
          end.join("\n")
        end

        def clause_parse(attrs, xml, node)
          w = "Scope contains subsections: should be succint"
          Validate::style_warning(node, w, nil) if $scope
          # Not testing max depth of sections: Asciidoctor already limits
          # it to 5 levels of nesting
          xml.clause **attr_code(attrs) do |xml_section|
            xml_section.name { |n| n << node.title } unless node.title.nil?
            xml_section << node.content
          end
        end

        def annex_parse(attrs, xml, node)
          attrs[:subtype] = "informative"
          if node.attributes.has_key?("subtype")
            attrs[:subtype] = node.attr("subtype")
          end
          xml.annex **attr_code(attrs) do |xml_section|
            xml_section.name { |name| name << node.title }
            xml_section << node.content
          end
        end

        def bibliography_parse(attrs, xml, node)
          $biblio = true
          xml.bibliography **attr_code(attrs) do |xml_section|
            xml_section << node.content
          end
          $biblio = true
        end

        def symbols_parse(attrs, xml, node)
          xml.symbols_abbrevs **attr_code(attrs) do |xml_section|
            xml_section << node.content
          end
        end

        def term_def_subclause_parse(attrs, xml, node)
          xml.termdef **attr_code(attrs) do |xml_section|
            xml_section.term { |name| name << node.title }
            xml_section << node.content
          end
        end

        def term_def_parse(attrs, xml, node)
          $term_def = true
          xml.terms_defs **attr_code(attrs) do |xml_section|
            xml_section << node.content
          end
          $term_def = false
        end

        def norm_ref_parse(attrs, xml, node)
          $norm_ref = true
          xml.norm_ref **attr_code(attrs) do |xml_section|
            xml_section << node.content
          end
          $norm_ref = false
        end

        def introduction_parse(attrs, xml, node)
          xml.introduction **attr_code(attrs) do |xml_section|
            content = node.content
            xml_section << content
            Validate::introduction_style(node,
                                         Utils::flatten_rawtext(content).
                                         join("\n"))
          end
        end

        def patent_notice_parse(xml, node)
          xml.patent_notice do |xml_section|
            xml_section << node.content
          end
        end

        def scope_parse(attrs, xml, node)
          $scope = true
          xml.scope **attr_code(attrs) do |xml_section|
            content = node.content
            xml_section << content
            c = Utils::flatten_rawtext(content).join("\n")
            Validate::scope_style(node, c)
          end
          $scope = false
        end
      end
    end
  end
end
