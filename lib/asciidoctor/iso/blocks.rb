require "htmlentities"
require "uri"

module Asciidoctor
  module ISO
    module Blocks
      def id_attr(node = nil)
        { id: Utils::anchor_or_uuid(node) }
      end

      # open block is a container of multiple blocks,
      # treated as a single block.
      # We append each contained block to its parent
      def open(node)
        result = []
        node.blocks.each do |b|
          result << send(b.context, b)
        end
        result
      end

      def literal(node)
        open(node)
      end

      # NOTE: html escaping is performed by Nokogiri
      def stem(node)
        stem_content = node.lines.join("\n")
        noko do |xml|
          xml.formula **id_attr(node) do |s|
            stem_parse(stem_content, s)
          end
        end
      end

      def sidebar_attrs(node)
        date = node.attr("date") || Date.today.iso8601.gsub(/\+.*$/, "")
        date += "T00:00:00Z" unless /T/.match? date
        {
          reviewer: node.attr("reviewer") || node.attr("source") || "(Unknown)",
          id: Utils::anchor_or_uuid(node),
          date: date,
          from: node.attr("from"),
          to: node.attr("to") || node.attr("from"),
        }
      end

      def sidebar(node)
        return unless draft?
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
          end
        end.join("\n")
      end

      def note(n)
        noko do |xml|
          xml.note **id_attr(n) do |c|
            wrap_in_para(n, c)
          end
        end.join("\n")
      end

      def admonition_attrs(node)
        name = node.attr("name")
        if type = node.attr("type")
          ["danger", "safety precautions"].each do |t|
            name = t if type.casecmp(t).zero?
          end
        end
        { id: Utils::anchor_or_uuid(node), type: name }
      end

      def admonition(node)
        return termnote(node) if in_terms?
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
            wrap_in_para(node, ex)
          end
        end.join("\n")
      end

      def example(node)
        return term_example(node) if in_terms?
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

      def figure_title(node, f)
        unless node.title.nil?
          f.name { |name| name << node.title }
        end
      end

      def image(node)
        noko do |xml|
          xml.figure **id_attr(node) do |f|
            figure_title(node, f)
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
          end
        end.join("\n")
      end

      def quote_attrs(node)
        { id: Utils::anchor_or_uuid(node), align: node.attr("align") }
      end

      def quote_attribution(node, out)
        if node.attr("citetitle")
          m = /^(?<cite>[^,]+)(,(?<text>.*$))?$/m.match node.attr("citetitle")
          out.source m[:text],
            **attr_code(target: m[:cite], type: "inline")
        end
        if node.attr("attribution")
          out.author { |a| a << node.attr("attribution") }
        end
      end

      def quote(node)
        noko do |xml|
          xml.quote **attr_code(quote_attrs(node)) do |q|
            quote_attribution(node, q)
            wrap_in_para(node, q)
          end
        end
      end

      def listing(node)
        # NOTE: html escaping is performed by Nokogiri
        noko do |xml|
          xml.sourcecode(**id_attr(node)) { |s| s << node.content }
          # xml.sourcecode(**id_attr(node)) { |s| s << node.lines.join("\n") }
        end
      end
    end
  end
end
