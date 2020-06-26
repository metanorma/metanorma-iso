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
        @format = :sts
        @suffix = "sts.xml"
      end

      def convert(input_filename, file = nil, debug = false, output_filename = nil)
        file = File.read(input_filename, encoding: "utf-8") if file.nil?
        docxml, filename, dir = convert_init(file, input_filename, debug)
        /\.xml$/.match(input_filename) or
          input_filename = Tempfile.open([filename, ".xml"], encoding: "utf-8") do |f|
          f.write file
          f.path
        end
        FileUtils.rm_rf dir
        Mn2sts.convert(input_filename, output_filename || "#{filename}.#{@suffix}")
      end
    end
  end
end

