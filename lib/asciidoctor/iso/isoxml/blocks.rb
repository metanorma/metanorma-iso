require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module ISOXML
      module Blocks
        def stem(node)
          stem_attributes = { id: Utils::anchor_or_uuid(node) }
          # NOTE: html escaping is performed by Nokogiri
          stem_content = node.lines.join("\n")

          noko do |xml|
            xml.formula **attr_code(stem_attributes) do |s|
              s.stem stem_content, **{ type: "MathML" }
              Validate::style(node, stem_content)
            end
          end
        end

        def sidebar(node)
          return unless $draft
          date = node.attr("date") || DateTime.now.iso8601.gsub(/\+.*$/, "")
          date += "T0000" unless /T/.match? date
          attrs = { reviewer: node.attr("reviewer") || "(Unknown)",
                              date: date.gsub(/[:-]/, "") }
          content = Utils::flatten_rawtext(node.content).join("\n")
          noko { |xml| xml.review_note content, **attr_code(attrs) }
        end

        def termnote(n)
          # TODO: reinstate
          # note_attributes = { id: Utils::anchor_or_uuid(node) }
          note_attributes = {}
          if n.blocks?
            warning(n, "comment cannot contain blocks of text", n.content)
          end
          noko do |xml|
            xml.termnote **attr_code(note_attributes) do |xml_cref|
              xml_cref << n.content
              Validate::style(n, Utils::flatten_rawtext(n.content).join("\n"))
            end
          end.join("\n")
        end

        def note(n)
          noko do |xml|
            xml.note **attr_code(id: Utils::anchor_or_uuid(n)) do |c|
              if n.blocks? then c << n.content
              else
                c.p { |p| p << n.content }
              end
              text = Utils::flatten_rawtext(n.content).join("\n")
              Validate::note_style(n, text)
            end
          end.join("\n")
        end

        def admonition(node)
          name = node.attr("name")
          return termnote(node) if $term_def
          return note(node) if name == "note"
          noko do |xml|
            type = node.attr("type") and
              ["danger", "safety precautions"].each do |t|
                name = t if type.casecmp(t).zero?
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
            xml.termexample **attr_code(id: node.id) do |ex|
              content = node.content
              ex << content
              text = Utils::flatten_rawtext(content).join("\n")
              Validate::termexample_style(node, text)
            end
          end.join("\n")
        end

        def example(node)
          return term_example(node) if $term_def
          noko do |xml|
            xml.example **attr_code(id: node.id) do |ex|
              content = node.content
              ex << content
              text = Utils::flatten_rawtext(content).join("\n")
              Validate::termexample_style(node, text)
            end
          end.join("\n")
        end

        def preamble(node)
          result = []
          result << noko do |xml|
            xml.content do |xml_abstract|
              xml_abstract.title { |t| t << "Foreword" }
              content = node.content
              xml_abstract << content
              text = Utils::flatten_rawtext(content).join("\n")
              Validate::foreword_style(node, text)
            end
          end
          result
        end

        def image(node)
          uri = node.image_uri node.attr("target")
          types = MIME::Types.type_for(uri)
          fig_attributes = {
            id: Utils::anchor_or_uuid(node),
          }
          img_attributes = {
            src: uri,
            imagetype: types.first.sub_type.upcase
          }

          noko do |xml|
            xml.figure **attr_code(fig_attributes) do |f|
              f.name { |name| name << node.title } unless node.title.nil?
              f.image **attr_code(img_attributes)
            end
          end
        end

        def quote(node)
          noko do |xml|
            xml.quote **attr_code(id: node.id) do |xml_blockquote|
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
