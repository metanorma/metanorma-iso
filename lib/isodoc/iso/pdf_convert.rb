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
        case doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        when "amendment", "technical-corrigendum" then "itu.recommendation-annex.xsl"
        else
          "iso.international-standard.xsl"
        end
      end

      def convert(filename, file = nil, debug = false)
        file = File.read(filename, encoding: "utf-8") if file.nil?
        docxml, outname_html, dir = convert_init(file, filename, debug)
        /\.xml$/.match(filename) or
          filename = Tempfile.open([outname_html, ".xml"], encoding: "utf-8") do |f|
          f.write file
          f.path
        end
        FileUtils.rm_rf dir
        ::Metanorma::Output::XslfoPdf.new.convert(
          filename, outname_html + ".pdf", File.join(@libdir, pdf_stylesheet(docxml)))
      end
    end
  end
end

