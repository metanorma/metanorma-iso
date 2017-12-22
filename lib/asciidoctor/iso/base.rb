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
        xml.title do |t0|
          t0.en do |t|
            t.title_intro {|t1| t1 << node.attr("title-intro") } if  node.attr("title-intro")
            t.title_main {|t1| t1 << node.attr("title-main") } if  node.attr("title-main")
            if node.attr("title-part")
              t.title_part node.attr("title-part")
            end
          end
          t0.fr do |t|
            t.title_intro {|t1| t1 << node.attr("title-intro-fr") } if  node.attr("title-intro-fr")
            t.title_main {|t1| t1 << node.attr("title-main-fr") } if  node.attr("title-main-fr")
            if node.attr("title-part-fr")
              t.title_part node.attr("title-part-fr")
            end
          end
        end
      end

      def termsource(node)
        result = []
        result << noko do |xml|
          xml.termref do |xml_t|
            # matched = /^ISO (?<code>[0-9-]+)(:(?<year>[0-9]+))?(, (?<section>.[^, ]+))?(, (?<text>.*))?$/.match flatten_rawtext(node).flatten.join("")
            matched = /^(?<xref><xref[^>]+>)(, (?<section>.[^, ]+))?(, (?<text>.*))?$/.match node.content
            if matched.nil?
              warn %(asciidoctor: WARNING (#{current_location(node)}): term reference not in expected format: #{node.content})
            else
              # xml_t.xref matched[:xref]
              seen_xref = Nokogiri::XML.fragment(matched[:xref])
              xml_t.xref seen_xref.children[0].content, **attr_code(target: seen_xref.children[0]["target"], format: seen_xref.children[0]["format"])
              xml_t.isosection matched[:section] if matched[:section]
              xml_t.modification { |m| m << matched[:text] } if matched[:text]
            end
          end
        end
        result
      end

      def paragraph(node)
        return termsource(node) if node.role == "source"
        result = []
        result << noko do |xml|
          xml.p do |xml_t|
            xml_t << node.content
          end
        end
        result
      end

      def inline_footnote(node)
        noko do |xml|
          xml.fn do |xml_t|
            xml_t << node.text
          end
        end.join
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
          when :emphasis then 
            xml.em node.text
          when :strong then xml.strong node.text
          when :monospaced then xml.tt node.text
          when :double then xml << "\"#{node.text}\""
          when :single then xml << "'#{node.text}'"
          when :superscript then xml.sup node.text
          when :subscript then xml.sub node.text
          when :asciimath then xml.stem node.text
          else
            if node.role == "alt"
              xml.admitted_term { |a| a << node.text }
            elsif node.role == "deprecated"
              xml.deprecated_term { |a| a << node.text }
            elsif node.role == "domain"
              xml.termdomain { |a| a << node.text }
            else
              xml << node.text
            end
          end
        end.join
      end

      def cleanup(xmldoc)
        intro = xmldoc.at("//introduction")
        foreword = xmldoc.at("//foreword")
        front = xmldoc.at("//front")
        unless foreword.nil? or front.nil?
          foreword.remove
          front << foreword
        end
        unless intro.nil? or front.nil?
          intro.remove
          front << intro
        end

        # release termdef tags from surrounding paras
        nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol | //p/deprecated_term")
        while !nodes.empty?
          nodes[0].parent.replace(nodes[0].parent.children)
          nodes = xmldoc.xpath("//p/admitted_term | //p/termsymbol | //p/deprecated_term")
        end
        xmldoc.xpath("//termdef/p/stem").each do |a|
          if a.parent.elements.size == 1 # para containing just a stem expression
            t = Nokogiri::XML::Element.new("termsymbol", xmldoc)
            parent = a.parent
            a.remove
            t.children = a
            parent.replace(t)
          end
        end
        xmldoc.xpath("//p/termdomain").each do |a|
          prev = a.parent.previous
          a.remove
          prev.next = a
        end

        # Remove italicised ISO titles
        xmldoc.xpath("//isotitle").each do |a|
          if a.elements.size == 1 && a.elements[0].name == "em"
            a.children = a.elements[0].children
          end
        end

        # move notes after table footer
        xmldoc.xpath("//tfoot/tr/td/note | //tfoot/tr/th/note").each do |n|
          target = n.parent.parent.parent.parent
          n.remove
          target << n
        end

        # include where definition list inside stem block
        xmldoc.xpath("//formula").each do |s|
          if !s.next_element.nil? && s.next_element.name == "p" && s.next_element.content == "where"
            if !s.next_element.next_element.nil? && s.next_element.next_element.name == "dl"
              dl = s.next_element.next_element.remove
              s.next_element.remove
              s << dl
            end
          end
        end

        # include key definition list inside figure
        xmldoc.xpath("//figure").each do |s|
          if !s.next_element.nil? && s.next_element.name == "p" && s.next_element.content =~ /^\s*Key\s*$/m
            if !s.next_element.next_element.nil? && s.next_element.next_element.name == "dl"
              dl = s.next_element.next_element.remove
              s.next_element.remove
              s << dl
            end
          end
        end

        # examples containing only figures become subfigures of figures
        nodes = xmldoc.xpath("//example/figure")
        while !nodes.empty?
          nodes[0].parent.name = "figure"
          nodes = xmldoc.xpath("//example/figure")
        end

        # move annex/bibliography to back
        if !xmldoc.xpath("//annex | //bibliography").empty?
          b = Nokogiri::XML::Element.new("back", xmldoc)
          xmldoc.root << b
          xmldoc.xpath("//annex").each do |e|
            e.remove
            b << e
          end
          xmldoc.xpath("//bibliography").each do |e|
            e.remove
            b << e
          end
        end

        # move ref before p
        xmldoc.xpath("//p/ref").each do |r|
          parent = r.parent
          r.remove
          parent.previous = r
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

      # if node contains blocks, flatten them into a single line; and extract only raw text
      def flatten_rawtext(node)
        result = []
        if node.respond_to?(:blocks) && node.blocks?
          node.blocks.each { |b| result << flatten_rawtext(b) }
        elsif node.respond_to?(:lines)
          node.lines.each do |x|
            result << if node.respond_to?(:context) && (node.context == :literal || node.context == :listing)
                        x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
            else
              # strip not only HTML tags <tag>, but also Asciidoc crossreferences <<xref>>
              x.gsub(/<[^>]*>+/, "")
            end
          end
        elsif node.respond_to?(:text)
          result << node.text.gsub(/<[^>]*>+/, "")
        else
          result << node.content.gsub(/<[^>]*>+/, "")
        end
        result.reject(&:empty?)
      end


=begin
      def terms_and_definitions(node)
        while !node.nil? and node.level > 0 and node.context != :section
          node = node.parent
          return true if !node.nil? and node.level == 0 and node.title == "Terms and definitions"
        end
        return false
      end
=end
    end
  end
end
