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
    module ISOXML
      module Utils
        class << self
          def anchor_or_uuid(node)
            uuid = UUIDTools::UUID.random_create
            (node.id.nil? || node.id.empty?) ? "_" + uuid : node.id
          end

          def stage_abbreviation(stage)
            return "PWI" if stage == "00"
            return "NWIP" if stage == "10"
            return "WD" if stage == "20"
            return "CD" if stage == "30"
            return "DIS" if stage == "40"
            return "FDIS" if stage == "50"
            return "IS" if stage == "60"
            return "(Review)" if stage == "90"
            return "(Withdrawal)" if stage == "95"
            return "??"
          end

          def current_location(node)
            if node.respond_to?(:lineno) && !node.lineno.nil? &&
                !node.lineno.empty?
              return "Line #{node.lineno}"
            end
            if node.respond_to?(:id) && !node.id.nil?
              return "ID #{node.id}"
            end
            while !node.nil? && 
                (!node.respond_to?(:level) || node.level.positive?) && 
                (!node.respond_to?(:context) || node.context != :section )
              node = node.parent
              if !node.nil? && node.context == :section
                return "Section: #{node.title}"
              end
            end
            "??"
          end

          # if node contains blocks, flatten them into a single line;
          # and extract only raw text
          def flatten_rawtext(node)
            result = []
            if node.respond_to?(:blocks) && node.blocks?
              node.blocks.each { |b| result << flatten_rawtext(b) }
            elsif node.respond_to?(:lines)
              node.lines.each do |x|
                if node.respond_to?(:context) && (node.context == :literal ||
                    node.context == :listing)
                  result << x.gsub(/</, "&lt;").gsub(/>/, "&gt;")
                else
                  # strip not only HTML tags <tag>,
                  # but also Asciidoc crossreferences <<xref>>
                  result << x.gsub(/<[^>]*>+/, "")
                end
              end
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

        # block for processing XML document fragments as XHTML,
        # to allow for HTMLentities
        def noko(&block)
          # fragment = ::Nokogiri::XML::DocumentFragment.parse("")
          # fragment.doc.create_internal_subset("xml", nil, "xhtml.dtd")
          head = <<~HERE
        <!DOCTYPE html SYSTEM
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head> <title></title> <meta charset="UTF-8" /> </head>
        <body> </body> </html>
          HERE
          doc = ::Nokogiri::XML.parse(head)
          fragment = doc.fragment("")
          ::Nokogiri::XML::Builder.with fragment, &block
          fragment.to_xml(encoding: "US-ASCII").lines.map do |l|
            l.gsub(/\s*\n/, "")
          end
        end

        def attr_code(attributes)
          attributes = attributes.reject { |_, val| val.nil? }.map
          attributes.map do |k, v|
            [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
          end.to_h
        end

        def current_location(node)
          if node.respond_to?(:lineno) && !node.lineno.nil? &&
              !node.lineno.empty?
            return "Line #{node.lineno}"
          end
          if node.respond_to?(:id) && !node.id.nil?
            return "ID #{node.id}"
          end
          while !node.nil? && (!node.respond_to?(:level) ||
              node.level.positive?) && node.context != :section
            node = node.parent
            if !node.nil? && node.context == :section
              return "Section: #{node.title}"
            end
          end
          "??"
        end

        def warning(node, msg, text)
          warntext = "asciidoctor: WARNING (#{current_location(node)}): #{msg}"
          warntext += ": #{text}" if text
          warn warntext
        end
      end
    end
  end
end
