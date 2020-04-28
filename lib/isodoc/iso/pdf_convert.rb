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
          filename, outname_html + ".pdf",
          File.join(@libdir, "iso.international-standard.xsl"))
      end
    end
  end
end

