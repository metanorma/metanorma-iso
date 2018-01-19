require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module ISOXML
      module Blocks
        def stem(node)
          stem_attributes = { anchor: Utils::anchor_or_uuid(node) }
          # NOTE: html escaping is performed by Nokogiri
          stem_content = node.lines.join("\n")

          noko do |xml|
            xml.formula **attr_code(stem_attributes) do |s|
              s.stem stem_content
              Validate::style(node, stem_content)
            end
          end
        end

        def sidebar(node)
          if $draft
            note_attributes = {
              source: node.attr("source") 
            }
            content = Utils::flatten_rawtext(node.content).join("\n")
            noko do |xml|
              xml.review_note content, **attr_code(note_attributes)
            end
          end
        end

        def termnote(node)
          # TODO: reinstate
          # note_attributes = { anchor: Utils::anchor_or_uuid(node) }
          note_attributes = {}
          warning(node, "comment can not contain blocks of text in XML RFC", node.content) if node.blocks?
          noko do |xml|
            xml.termnote **attr_code(note_attributes) do |xml_cref|
              xml_cref << node.content
              Validate::style(node, Utils::flatten_rawtext(node.content).join("\n"))
            end
          end.join("\n")
        end

        def note(node)
          noko do |xml|
            xml.note **attr_code(anchor: Utils::anchor_or_uuid(node)) do |xml_cref|
              if node.blocks?
                xml_cref << node.content
              else
                xml_cref.p { |p| p << node.content }
              end
              Validate::note_style(node, Utils::flatten_rawtext(node.content).join("\n"))
            end
          end.join("\n")
        end

        def admonition(node)
          return termnote(node) if $term_def
          return note(node) if node.attr("name") == "note"
          noko do |xml|
            name = node.attr("name")
            unless node.attr("type").nil?
              name = "danger" if node.attr("type").downcase == "danger"
              name = "safety precautions" if node.attr("type").downcase == "safety precautions"
            end
            xml.warning do |xml_cref|
              xml_cref.name name.upcase
              if node.blocks?
                xml_cref << node.content
              else
                xml_cref.p { |p| p << node.content }
              end
            end
          end.join("\n")
        end

        def term_example(node)
          noko do |xml|
            xml.termexample **attr_code(anchor: node.id) do |ex|
              content = node.content
              ex << content
              Validate::termexample_style(node, Utils::flatten_rawtext(content).join("\n"))
            end
          end.join("\n")
        end

        def example(node)
          return term_example(node) if $term_def
          noko do |xml|
            xml.example **attr_code(anchor: node.id) do |ex|
              content = node.content
              ex << content
              Validate::termexample_style(node, Utils::flatten_rawtext(content).join("\n"))
            end
          end.join("\n")
        end

        def preamble(node)
          result = []
          result << noko do |xml|
            xml.foreword do |xml_abstract|
              content = node.content
              xml_abstract << content
              Validate::foreword_style(node, Utils::flatten_rawtext(content).join("\n"))
            end
          end
          result
        end

        def image(node)
          uri = node.image_uri node.attr("target")
          artwork_attributes = {
            anchor: Utils::anchor_or_uuid(node),
            src: uri,
          }

          noko do |xml|
            xml.figure **attr_code(artwork_attributes) do |f|
              f.name { |name| name << node.title } unless node.title.nil?
            end
          end
        end

        def quote(node)
          noko do |xml|
            xml.quote **attr_code(anchor: node.id) do |xml_blockquote|
              if node.blocks?
                xml_blockquote << node.content
              else
                xml_blockquote.p { |p| p << node.content }
              end
            end
          end
        end

        def listing(node)
          # NOTE: html escaping is performed by Nokogiri
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
end
