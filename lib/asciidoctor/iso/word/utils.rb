require "uuidtools"

module Asciidoctor
  module ISO::Word
    module Utils
      def ns(xpath)
        xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
      end

      # TODO import these
      #
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
          # [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
          [k, v]
        end.to_h
      end

    end
  end
end
