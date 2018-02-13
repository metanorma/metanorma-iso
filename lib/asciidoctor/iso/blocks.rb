require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module Blocks

      def id_attr(node = nil)
        { id: Utils::anchor_or_uuid(node) }
      end

      def open(node)
        # open block is a container of multiple blocks,
        # treated as a single block.
        # We append each contained block to its parent
        result = []
        if node.blocks?
          node.blocks.each do |b|
            result << send(b.context, b)
          end
        else
          result = paragraph(node)
        end
        result
      end

      def stem(node)
        # NOTE: html escaping is performed by Nokogiri
        stem_content = node.lines.join("\n")
        noko do |xml|
          xml.formula **id_attr(node) do |s|
            s.stem stem_content, **{ type: "AsciiMath" }
            style(node, stem_content)
          end
        end
      end

      def sidebar_attrs(node)
        date = node.attr("date") || DateTime.now.iso8601.gsub(/\+.*$/, "")
        date += "T0000" unless /T/.match? date
        { 
          reviewer: node.attr("reviewer") || node.attr("source") || "(Unknown)",
          id: Utils::anchor_or_uuid(node),
          date: date.gsub(/[:-]/, ""),
          from: node.attr("from"),
          to: node.attr("to") || node.attr("from"),
        }
      end

      def sidebar(node)
        return unless is_draft
        content = Utils::flatten_rawtext(node.content).join("\n")
        noko do |xml| 
          xml.review **attr_code(sidebar_attrs(node)) do |r|
            wrap_in_para(node, r)
          end
        end
      end

      def termnote(n)
        noko do |xml|
          xml.termnote **id_attr(n) do |ex|
            wrap_in_para(n, ex)
            style(n, Utils::flatten_rawtext(n.content).join("\n"))
          end
        end.join("\n")
      end

      def note(n)
        noko do |xml|
          xml.note **id_attr(n) do |c|
            wrap_in_para(n, c)
            text = Utils::flatten_rawtext(n.content).join("\n")
            note_style(n, text)
          end
        end.join("\n")
      end

      def admonition_attrs(node)
        name = node.attr("name")
        type = node.attr("type") and
          ["danger", "safety precautions"].each do |t|
          name = t if type.casecmp(t).zero?
        end
        { id: Utils::anchor_or_uuid(node), type: name }
      end

      def admonition(node)
        return termnote(node) if in_terms
        return note(node) if node.attr("name") == "note"
        noko do |xml|
          xml.admonition **admonition_attrs(node) do |a|
            wrap_in_para(node, a)
          end
        end.join("\n")
      end

      def term_example(node)
        noko do |xml|
          xml.termexample **id_attr(node) do |ex|
            c = node.content
            wrap_in_para(node, ex)
            text = Utils::flatten_rawtext(c).join("\n")
            termexample_style(node, text)
          end
        end.join("\n")
      end

      def example(node)
        return term_example(node) if in_terms
        noko do |xml|
          xml.example **id_attr(node) do |ex|
            content = node.content
            ex << content
          end
        end.join("\n")
      end

      def preamble(node)
        noko do |xml|
          xml.foreword do |xml_abstract|
            xml_abstract.title { |t| t << "Foreword" }
            content = node.content
            xml_abstract << content
            text = Utils::flatten_rawtext(content).join("\n")
            foreword_style(node, text)
          end
        end.join("\n")
      end

      def image_attributes(node)
        uri = node.image_uri node.attr("target")
        types = MIME::Types.type_for(uri)
        { src: uri, 
          id: Utils::anchor_or_uuid,
          imagetype: types.first.sub_type.upcase,
          height: node.attr("height"),
          width: node.attr("width") }
      end

      def image(node)
        noko do |xml|
          xml.figure **id_attr(node) do |f|
            f.name { |name| name << node.title } unless node.title.nil?
            f.image **attr_code(image_attributes(node))
          end
        end
      end

      def paragraph(node)
        return termsource(node) if node.role == "source"
        attrs = { align: node.attr("align"),
                  id: Utils::anchor_or_uuid(node) }
        noko do |xml|
          xml.p **attr_code(attrs) do |xml_t|
            xml_t << node.content
            style(node, Utils::flatten_rawtext(node).join(" "))
          end
        end.join("\n")
      end

      def quote_attrs(node)
        { id: Utils::anchor_or_uuid(node), align: node.attr("align") }
      end

      def quote_attribution(node, out)
        if node.attr("attribution")
          out.fullname do |f|
            f.surname { |s| s << node.attr("attribution") }
            # TODO: will break up into name components
          end
        end
        if node.attr("citetitle")
          # TODO: eref
        end
      end

      def quote(node)
        noko do |xml|
          xml.quote **attr_code(quote_attrs(node)) do |q|
            quote_attribution(node, out)
            wrap_in_para(node, q)
          end
        end
      end

      def listing(node)
        # NOTE: html escaping is performed by Nokogiri
        noko do |xml|
          if node.parent.context != :example
            xml.example **id_attr(node) do |e|
              e.sourcecode **id_attr(node) do |s| 
                s << node.content 
              end
            end
          else
            xml.sourcecode **id_attr(node) do |s|
              s << node.content 
            end
          end
        end
      end
    end
  end
end
