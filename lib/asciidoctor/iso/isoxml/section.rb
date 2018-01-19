require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module ISOXML
      module Section

        def section(node)
          attrs = { anchor: Utils::anchor_or_uuid(node) }
          noko do |xml|
            case node.title.downcase
            when "introduction"
              xml.introduction **attr_code(attrs) do |xml_section|
                content = node.content
                xml_section << content
                Validate::introduction_style(node, Utils::flatten_rawtext(content).join("\n"))
              end
            when "patent notice"
              xml.patent_notice do |xml_section|
                xml_section << node.content
              end
            when "scope"
              $scope = true
              xml.scope **attr_code(attrs) do |xml_section|
                content = node.content
                xml_section << content
                Validate::scope_style(node, Utils::flatten_rawtext(content).join("\n"))
              end
              $scope = false
            when "normative references"
              $norm_ref = true
              xml.norm_ref **attr_code(attrs) do |xml_section|
                xml_section << node.content
              end
              $norm_ref = false
            when "terms and definitions"
              $term_def = true
              xml.terms_defs **attr_code(attrs) do |xml_section|
                xml_section << node.content
              end
              $term_def = false
            when "terms, definitions, symbols and abbreviated terms"
              $term_def = true
              xml.terms_defs **attr_code(attrs) do |xml_section|
                xml_section << node.content
              end
              $term_def = false
            when "symbols and abbreviations"
              xml.symbols_abbrevs **attr_code(attrs) do |xml_section|
                xml_section << node.content
              end
            when "bibliography"
              $biblio = true
              xml.bibliography **attr_code(attrs) do |xml_section|
                xml_section << node.content
              end
              $biblio = true
            else
              if $term_def
                xml.termdef **attr_code(attrs) do |xml_section|
                  xml_section.term { |name| name << node.title }
                  xml_section << node.content
                end
              elsif node.attr("style") == "appendix"
                attrs[:subtype] = node.attributes.has_key?("subtype") ? node.attr("subtype") : "informative"
                xml.annex **attr_code(attrs) do |xml_section|
                  xml_section.name { |name| name << node.title }
                  xml_section << node.content
                end
              else
                Validate::style_warning(node, "Scope contains subsections: should be succint", nil) if $scope
                # won't come up, Asciidoctor limits to 5 levels of nesting, which is 4 levels of subclauses
                Validate::style_warning(node, "Five levels of subclause", nil) if node.level == 7
                xml.clause **attr_code(attrs) do |xml_section|
                  unless node.title.nil?
                    xml_section.name { |name| name << node.title }
                  end
                  xml_section << node.content
                end
              end
            end
          end.join("\n")
        end

      end
    end
  end
end
