require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module Blocks

      def stem(node)
        stem_attributes = {
          anchor: node.id,
        }
        # NOTE: html escaping is performed by Nokogiri
        stem_content = node.lines.join("\n")

        noko do |xml|
          xml.stem stem_content, **attr_code(stem_attributes)
        end
      end

      def admonition(node)
        result = []
        cref_attributes = {
          anchor: node.id,
        }

        if $term_def
          termnote_contents = node.content
          warn <<~WARNING_MESSAGE if node.blocks?
            asciidoctor: WARNING (#{current_location(node)}): comment can not contain blocks of text in XML RFC:\n #{node.content}
          WARNING_MESSAGE

          result << noko do |xml|
            xml.termnote **attr_code(cref_attributes) do |xml_cref|
              xml_cref << termnote_contents
            end
          end
        else
          cref_contents = node.content
          result << noko do |xml|
            xml.cref **attr_code(cref_attributes) do |xml_cref|
              xml_cref << cref_contents
            end
          end
        end
        result
      end

      def example(node)
        result = []
        example_attributes = {
          anchor: node.id,
        }

        if $term_def
          termexample_contents = node.content
          result << noko do |xml|
            xml.termexample **attr_code(example_attributes) do |ex|
              ex << termexample_contents
            end
          end
        else
          example_contents = node.content
          result << noko do |xml|
            xml.example **attr_code(example_attributes) do |ex|
              ex << example_contents
            end
          end
        end
        result
      end

      def preamble(node)
        result = []
        result << noko do |xml|
          xml.foreword do |xml_abstract|
            xml_abstract << node.content
          end
        end
        result
      end

      def section(node)
        result = []
        if node.attr("style") == "appendix"
          $seen_back_matter = true
        end

        section_attributes = {
          anchor: node.id,
        }

        result << noko do |xml|
          case node.title.downcase
          when "introduction"
            xml.introduction **attr_code(section_attributes) do |xml_section|
              xml_section << node.content
            end
          when "patent notice"
            xml.patent_notice **attr_code(section_attributes) do |xml_section|
              xml_section << node.content
            end
          when "scope"
            xml.scope **attr_code(section_attributes) do |xml_section|
              xml_section << node.content
            end
          when "normative references"
            xml.norm_ref **attr_code(section_attributes) do |xml_section|
              $norm_ref = true
              xml_section << node.content
              $norm_ref = false
            end
          when "terms and definitions"
            xml.terms_defs **attr_code(section_attributes) do |xml_section|
              $term_def = true
              xml_section << node.content
              $term_def = false
            end
          else
            if $term_def
              xml.termdef **attr_code(section_attributes) do |xml_section|
                xml_section.term { |name| name << node.title } 
                xml_section << node.content
              end
            else
              xml.clause **attr_code(section_attributes) do |xml_section|
                xml_section.name { |name| name << node.title } unless node.title.nil?
                xml_section << node.content
              end
            end
          end
        end

        result
      end

      def image(node)
        uri = node.image_uri node.attr("target")
        artwork_attributes = {
          anchor: node.id,
          src: uri,
        }

        noko do |xml|
          xml.img **attr_code(artwork_attributes)
        end
      end

    end
  end
end

