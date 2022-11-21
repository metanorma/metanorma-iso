require "isodoc"
require "mnconvert"

module IsoDoc
  module Iso
    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class IsoStsConvert < IsoDoc::XslfoPdfConvert
      def initialize(_options)
        @libdir = File.dirname(__FILE__)
        @format = :isosts
        @suffix = "isosts.xml"
      end

      def get_input_fname(input_fname)
        /\.xml$/.match(input_fname) or
          input_fname = Tempfile.open([fname, ".xml"], encoding: "utf-8") do |f|
            f.write file
            f.path
          end
        input_fname
      end

      def convert(input_fname, file = nil, debug = false, output_fname = nil)
        file = File.read(input_fname, encoding: "utf-8") if file.nil?
        _, fname, dir = convert_init(file, input_fname, debug)
        input_fname = get_input_fname(input_fname)
        FileUtils.rm_rf dir
        MnConvert.convert(input_fname,
                          {
                            input_format: MnConvert::InputFormat::MN,
                            output_file: output_fname || "#{fname}.#{@suffix}",
                            output_format: :iso,
                          })
      end
    end
  end
end
