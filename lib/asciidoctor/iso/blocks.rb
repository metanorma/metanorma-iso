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

        if terms_and_definitions(node)
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

        if terms_and_definitions(node)
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

    end
  end
end

