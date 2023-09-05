require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Iso

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(docxml)
        case @doctype
        when "amendment", "technical-corrigendum" then "iso.amendment.xsl"
        else
          "iso.international-standard.xsl"
        end
      end
    end
  end
end

