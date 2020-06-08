require "isodoc"
require "mn2sts"

module IsoDoc
  module Iso

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class StsConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
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
        Mn2sts.convert(filename, outname_html + ".sts.xml")
      end
    end
  end
end

