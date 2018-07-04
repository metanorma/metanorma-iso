require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "uuidtools"
require "pp"

module Asciidoctor
  module ISO
    module Utils
      class << self
        def anchor_or_uuid(node = nil)
          uuid = UUIDTools::UUID.random_create
          node.nil? || node.id.nil? || node.id.empty? ? "_" + uuid : node.id
        end

        def current_location(n)
          return "Line #{n.lineno}" if n.respond_to?(:lineno) &&
            !n.lineno.nil? && !n.lineno.empty?
          return "Line #{n.line}" if n.respond_to?(:line) &&
            !n.line.nil?
          return "ID #{n.id}" if n.respond_to?(:id) && !n.id.nil?
          while !n.nil? &&
              (!n.respond_to?(:level) || n.level.positive?) &&
              (!n.respond_to?(:context) || n.context != :section)
            n = n.parent
            return "Section: #{n.title}" if n&.respond_to?(:context) &&
              n&.context == :section
          end
          "??"
        end

        def warning(node, msg, text)
          return if @novalid
          warntext = "asciidoctor: WARNING"\
            "(#{current_location(node)}): #{msg}"
          warntext += ": #{text}" if text
          warn warntext
        end

        def flatten_rawtext_lines(node, result)
          node.lines.each do |x|
            if node.respond_to?(:context) && (node.context == :literal ||
                node.context == :listing)
              result << x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
            else
              # strip not only HTML <tag>, and Asciidoc xrefs <<xref>>
              result << x.gsub(/<[^>]*>+/, "")
            end
          end
          result
        end

        # if node contains blocks, flatten them into a single line;
        # and extract only raw text
        def flatten_rawtext(node)
          result = []
          if node.respond_to?(:blocks) && node.blocks?
            node.blocks.each { |b| result << flatten_rawtext(b) }
          elsif node.respond_to?(:lines)
            result = flatten_rawtext_lines(node, result)
          elsif node.respond_to?(:text)
            result << node.text.gsub(/<[^>]*>+/, "")
          else
            result << node.content.gsub(/<[^>]*>+/, "")
          end
          result.reject(&:empty?)
        end
      end

      def convert(node, transform = nil, opts = {})
        transform ||= node.node_name
        opts.empty? ? (send transform, node) : (send transform, node, opts)
      end

      def document_ns_attributes(_doc)
        nil
      end

      NOKOHEAD = <<~HERE.freeze
          <!DOCTYPE html SYSTEM
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head> <title></title> <meta charset="UTF-8" /> </head>
          <body> </body> </html>
      HERE

      # block for processing XML document fragments as XHTML,
      # to allow for HTMLentities
      def noko(&block)
        doc = ::Nokogiri::XML.parse(NOKOHEAD)
        fragment = doc.fragment("")
        ::Nokogiri::XML::Builder.with fragment, &block
        fragment.to_xml(encoding: "US-ASCII").lines.map do |l|
          l.gsub(/\s*\n/, "")
        end
=begin
f = fragment.to_xml(encoding: "US-ASCII")
  byebug if @xxxxxx
  @xxxxxx = false
[f]
=end
      end

      def attr_code(attributes)
        attributes = attributes.reject { |_, val| val.nil? }.map
        attributes.map do |k, v|
          [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
        end.to_h
      end

      # if the contents of node are blocks, output them to out;
      # else, wrap them in <p>
      def wrap_in_para(node, out)
        if node.blocks? then out << node.content
        else
          out.p { |p| p << node.content }
        end
      end

      SUBCLAUSE_XPATH = "//clause[ancestor::clause or ancestor::annex or "\
        "ancestor::introduction]".freeze
    end
  end
end
