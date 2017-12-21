require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module Base
      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def document_ns_attributes(_doc)
        # ' xmlns="http://projectmallard.org/1.0/" xmlns:its="http://www.w3.org/2005/11/its"'
        nil
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        if node.respond_to?(:lineno)
          warn %(asciidoctor: WARNING (#{current_location(node)}): converter missing for #{name || node.node_name} node in ISO backend)
        else
          warn %(asciidoctor: WARNING (#{current_location(node)}): converter missing for #{name || node.node_name} node in ISO backend)
        end
        nil
      end

      def document(node)
        result = []
        result << '<?xml version="1.0" encoding="UTF-8"?>'
        result << "<iso_standard>"
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        # result << node.content if node.blocks?
        result << "</iso_standard>"
        result = result.flatten
        ret = result * "\n"
        ret1 = Nokogiri::XML(ret)
        ret1 = cleanup(ret1)
        Validate::validate(ret1)
        ret1.to_xml(indent: 2)
      end

      def front(node, xml)
        xml.front do |xml_front|
          title node, xml_front
          metadata node, xml_front
          xml_front << node.content
        end
      end

      def middle(node, xml)
        xml.middle do |xml_middle|
          xml_middle << node.content if node.blocks?
        end
      end

      def metadata(node, xml)
        xml.documenttype  node.attr("doctype")
        xml.documentstatus do |s|
          s.stage node.attr("docstage")
          s.substage node.attr("docsubstage") if node.attr("docsubstage")
        end
        docnum_attrs = { partnumber: node.attr("partnumber") }
        xml.id do |i|
          i.documentnumber node.attr("docnumber"), **attr_code(docnum_attrs)
          i.tc_documentnumber node.attr("tc-docnumber") if node.attr("tc-docnumber")
          i.ref_documentnumber node.attr("ref-docnumber") if node.attr("ref-docnumber")
        end
        xml.version do |v|
          v.edition node.attr("edition") if node.attr("edition")
          v.revdate node.attr("revdate") if node.attr("revdate")
          v.copyright_year node.attr("copyright-year") if node.attr("copyright-year")
        end
        xml.author do |a| 
          tc_attrs = { number: node.attr("technical-committee-number") }
          a.technical_committee node.attr("technical-committee"), **attr_code(tc_attrs)
          sc_attrs = { number: node.attr("subcommittee-number") }
          a.subcommittee node.attr("subcommittee"), **attr_code(sc_attrs) if node.attr("subcommittee")
          wg_attrs = { number: node.attr("workgroup-number") }
          a.workgroup node.attr("workgroup"), **attr_code(wg_attrs) if node.attr("workgroup")
        end
      end

      def title(node, xml)
        xml.title_en do |t|
          t.title_intro {|t1| t1 << node.attr("title-intro") } if  node.attr("title-intro")
          t.title_main {|t1| t1 << node.attr("title-main") } if  node.attr("title-main")
          if  node.attr("title-part")
            t.title_part node.attr("title-part")
          end
        end
        xml.title_fr do |t|
          t.title_intro {|t1| t1 << node.attr("title-intro-fr") } if  node.attr("title-intro-fr")
          t.title_main {|t1| t1 << node.attr("title-main-fr") } if  node.attr("title-main-fr")
          if  node.attr("title-part-fr")
            t.title_part node.attr("title-part-fr")
          end
        end
      end

      def paragraph1(node)
        result = []
        result1 = node.content
        if result1 =~ /^(<t>|<dl>|<ol>|<ul>)/
          result = result1
        else
          t_attributes = {
            anchor: node.id,
          }
          result << noko { |xml| xml.t result1, **attr_code(t_attributes) }
        end
        result
      end

      def paragraph(node)
        result = []
        if node.role == "source"
          result << noko do |xml|
            xml.termref do |xml_t|
              xml_t << node.content
            end
          end
        else
          result << noko do |xml|
            xml.para do |xml_t|
              xml_t << node.content
            end
          end
        end
        result
      end

      def inline_footnote(node)
        result = []
        result << noko do |xml|
          xml.fn do |xml_t|
            xml_t << node.text
          end
        end
        result
      end

      def open(node)
        # open block is a container of multiple blocks, treated as a single block.
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
        end.join
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
          else
            if node.role == "alt"
              xml.admitted_term << node.text
            elsif node.role == "deprecated"
              xml.deprecated_term << node.text
            elsif node.role == "domain"
              xml.domain << node.text
            else
              xml << node.text
            end
          end
        end.join
      end

      def cleanup(xmldoc)
        intro = xmldoc.at("//intro")
        front = xmldoc.at("//front")
        unless intro.nil? or front.nil?
          intro.remove
          front << intro
        end
        xmldoc
      end

      # block for processing XML document fragments as XHTML, to allow for HTMLentities
      def noko(&block)
        # fragment = ::Nokogiri::XML::DocumentFragment.parse("")
        # fragment.doc.create_internal_subset("xml", nil, "xhtml.dtd")
        head = <<HERE
        <!DOCTYPE html SYSTEM
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
        <title></title>
        <meta charset="UTF-8" />
        </head>
        <body>
        </body>
        </html>
HERE
        doc = ::Nokogiri::XML.parse(head)
        fragment = doc.fragment("")
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml(encoding: "US-ASCII").lines.map { |l| l.gsub(/\s*\n/, "") }
      end

      def attr_code(attributes)
        attributes = attributes.reject { |_, val| val.nil? }.map
        attributes.map do |k, v|
          [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
        end.to_h
      end

      def current_location(node)
        return "Line #{node.lineno}" if node.respond_to?(:lineno) && !node.lineno.nil? && !node.lineno.empty?
        return "ID #{node.id}" if node.respond_to?(:id) && !node.id.nil?
        while !node.nil? && (!node.respond_to?(:level) || node.level > 0) && node.context != :section
          node = node.parent
          return "Section: #{node.title}" if !node.nil? && node.context == :section
        end
        "??"
      end

      def terms_and_definitions(node)
        while !node.nil? and node.level > 0 and node.context != :section
          node = node.parent
          return true if !node.nil? and node.level == 0 and node.title == "Terms and definitions"
        end
        return false
      end
    end
  end
end
