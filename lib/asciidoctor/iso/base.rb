require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "isodoc"

module Asciidoctor
  module ISO
    module Base

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        name = name || node.node_name
        w = "converter missing for #{name} node in ISO backend"
        warning(node, w, nil)
        nil
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def doc_converter
        IsoDoc::Convert.new(
          htmlstylesheet: html_doc_path("htmlstyle.css"),
          wordstylesheet: nil,
          standardstylesheet: html_doc_path("isodoc.css"),
          header: html_doc_path("header.html"),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          wordintropage: html_doc_path("word_iso_intro.html"),
        )
      end

      def init
        @fn_number = 0
        @draft = false
        @refids = Set.new
        @anchors = {}
      end

      def document(node)
        init
        ret1 = makexml(node)
        validate(ret1)
        ret = ret1.to_xml(indent: 2)
        filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
          gsub(%r{^.*/}, '')
        File.open("#{filename}", "w") { |f| f.write(ret) }
        doc_converter.convert filename
        ret
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<iso-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</iso-standard>"
        result = textcleanup(result.flatten * "\n")
        ret1 = cleanup(Nokogiri::XML(result))
        ret1.root.add_namespace(nil, "http://riboseinc.com/isoxml")
        ret1
      end

      def is_draft
        @draft
      end

      def front(node, xml)
        title node, xml
        metadata node, xml
      end

      def middle(node, xml)
        xml.sections do |s|
          s << node.content if node.blocks?
        end
      end

      def add_term_source(xml_t, seen_xref, m)
        attr = { bibitemid: seen_xref.children[0]["target"],
                 format: seen_xref.children[0]["format"] }
        xml_t.origin seen_xref.children[0].content, **attr_code(attr)
        xml_t.isosection m[:section].gsub(/ /, "")  if m[:section]
        if m[:text]
          xml_t.modification do |mod| 
            mod.p { |p| p << m[:text]  }
          end
        end
      end

      TERM_REFERENCE_RE_STR = <<~REGEXP
             ^(?<xref><xref[^>]+>)
               (,\s(?<section>[^, ]+))?
               (,\s(?<text>.*))?
             $
      REGEXP
      TERM_REFERENCE_RE =
        Regexp.new(TERM_REFERENCE_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE)


      def extract_termsource_refs(text)
        matched = TERM_REFERENCE_RE.match text
        if matched.nil?
          warning(node, "term reference not in expected format", text)
        end
        matched
      end

      def termsource(node)
        matched = extract_termsource_refs(node.content) or return
        noko do |xml|
          attrs = { status: matched[:text] ? "identical" : "modified" }
          xml.termsource **attrs do |xml_t|
            seen_xref = Nokogiri::XML.fragment(matched[:xref])
            add_term_source(xml_t, seen_xref, matched)
            style(node, matched[:text])
          end
        end.join("\n")
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

      def inline_footnote(node)
        noko do |xml|
          @fn_number += 1
          xml.fn **{reference: @fn_number} do |fn|
            # TODO multi-paragraph footnotes
            fn.p { |p| p << node.text }
            footnote_style(node, node.text)
          end
        end.join("\n")
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

      def inline_break(node)
        noko do |xml|
          xml << node.text
          xml.br
        end.join("\n")
      end

      def page_break(node)
        noko do |xml|
          xml << node.text
          xml.pagebreak
        end.join("\n")
      end

      def thematic_break(node)
        noko do |xml|
          xml << node.text
          xml.hr
        end.join("\n")
      end

      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis then xml.em node.text
          when :strong then xml.strong node.text
          when :monospaced then xml.tt node.text
          when :double then xml << "\"#{node.text}\""
          when :single then xml << "'#{node.text}'"
          when :superscript then xml.sup node.text
          when :subscript then xml.sub node.text
          when :asciimath then xml.stem node.text, **{ type: "AsciiMath" }
          else
            case node.role
            when "alt" then xml.admitted { |a| a << node.text }
            when "deprecated" then xml.deprecates { |a| a << node.text }
            when "domain" then xml.domain { |a| a << node.text }
            when "strike" then xml.strike node.text
            when "smallcap" then xml.smallcap node.text
            else
              xml << node.text
            end
          end
        end.join
      end
    end
  end
end
