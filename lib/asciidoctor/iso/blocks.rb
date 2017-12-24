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
          xml.formula **attr_code(stem_attributes) do |s|
            s.stem stem_content
          end
        end
      end

      def sidebar (node)
        if $draft 
          note_attributes = {
            color: node.attr("color") ? node.attr("color") : "red",
          }
          content = flatten_rawtext(node.content).join("\n")
          noko do |xml|
            xml.review_note content, **attr_code(note_attributes)
          end
        end
      end

      def admonition(node)
        result = []
        note_attributes = {
          anchor: node.id,
        }

        if $term_def
          termnote_contents = node.content
          warn <<~WARNING_MESSAGE if node.blocks?
            asciidoctor: WARNING (#{current_location(node)}): comment can not contain blocks of text in XML RFC:\n #{node.content}
          WARNING_MESSAGE

          result << noko do |xml|
            xml.termnote **attr_code(note_attributes) do |xml_cref|
              xml_cref << termnote_contents
            end
          end
        else
          cref_contents = node.content
          result << noko do |xml|
            xml.note **attr_code(note_attributes) do |xml_cref|
              if node.blocks?
                xml_cref << cref_contents
              else
                xml_cref.p { |p| p << cref_contents }
              end
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

        section_attributes = {
          anchor: node.id.empty? ? nil : node.id,
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
          when "bibliography"
            xml.bibliography **attr_code(section_attributes) do |xml_section|
              $biblio = true
              xml_section << node.content
              $biblio = true
            end
          else
            if $term_def
              xml.termdef **attr_code(section_attributes) do |xml_section|
                xml_section.term { |name| name << node.title } 
                xml_section << node.content
              end
            elsif node.attr("style") == "appendix"
              xml.annex **attr_code(section_attributes) do |xml_section|
                xml_section.name { |name| name << node.title } 
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
          xml.figure **attr_code(artwork_attributes) do |f|
            f.name { |name| name << node.title } unless node.title.nil?
          end
        end
      end

      def quote(node)
        blockquote_attributes = {
          anchor: node.id,
        }

        noko do |xml|
          xml.quote **attr_code(blockquote_attributes) do |xml_blockquote|
            if node.blocks?
              xml_blockquote << node.content
            else
              xml_blockquote.p { |p| p << node.content }
            end
          end
        end
      end
      def listing(node)
        sourcecode_attributes = {
          anchor: node.id,
        }

        # NOTE: html escaping is performed by Nokogiri
        sourcecode_content =
          # sourcecode_attributes[:src].nil? ? node.lines.join("\n") : ""
          node.content

        noko do |xml|
          if node.parent.context != :example
            xml.figure do |xml_figure|
              xml_figure.sourcecode { |s| s << node.content }
            end
          else
            xml.sourcecode { |s| s << node.content }
          end
        end
      end


    end
  end
end

