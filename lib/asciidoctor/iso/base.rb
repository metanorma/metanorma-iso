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
        Validate::validate(ret1)
        ret1
      end

      def front(node, xml)
        xml.front do |xml_front|
          title node, xml_front
        end
      end

      def middle(node, xml)
        xml.middle do |xml_middle|
          xml_middle << node.content if node.blocks?
        end
      end

      # split on " -- " = "&#8201;&#8212;&#8201;"
      def title(node, xml)
        xml.title do |t|
          title_components = node.doctitle.split(/ -- |&#8201;&#8212;&#8201;/)
            title_components.each do |c|
            t.titlesect {|t1| t1 << c }
          end
        end
      end

      def preamble(node)
        result = []
        abstractable_contexts = %i{paragraph dlist olist ulist verse open}
        abstract_blocks = node.blocks.take_while do |block|
          abstractable_contexts.include? block.context
        end

        remainder_blocks = node.blocks[abstract_blocks.length..-1]

        result << noko do |xml|
          if abstract_blocks.any?
            xml.abstract do |xml_abstract|
              xml_abstract << abstract_blocks.map(&:render).flatten.join("\n")
            end
          end
          xml << remainder_blocks.map(&:render).flatten.join("\n")
        end

        result << "</front><middle>"
        result
      end

      def section(node)
        result = []
        if node.attr("style") == "appendix"
          result << "</middle><back>" unless $seen_back_matter
          $seen_back_matter = true
        end

        section_attributes = {
          anchor: node.id,
        }

        result << noko do |xml|
          xml.clause **attr_code(section_attributes) do |xml_section|
            xml_section.name { |name| name << node.title } unless node.title.nil?
            xml_section << node.content
          end
        end

        result
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
        result << noko do |xml|
          xml.para do |xml_t|
            xml_t << node.content
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
            xml << node.text
          end
        end.join
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
