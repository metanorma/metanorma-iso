require "isodoc"
require "mnconvert"

module IsoDoc
  module Iso
    class StsConvert < IsoDoc::XslfoPdfConvert
      def initialize(_options) # rubocop:disable Lint/MissingSuper
        @libdir = File.dirname(__FILE__)
        @format = :sts
        @suffix = "sts.xml"
      end

      def convert(in_fname, file = nil, debug = false, out_fname = nil)
        file = File.read(in_fname, encoding: "utf-8") if file.nil?
        _docxml, filename, dir = convert_init(file, in_fname, debug)
        /\.xml$/.match?(in_fname) or
          in_fname = Tempfile.open([filename, ".xml"], encoding: "utf-8") do |f|
            f.write file
            f.path
          end
        FileUtils.rm_rf dir
        MnConvert.convert(in_fname,
                          {
                            input_format: MnConvert::InputFormat::MN,
                            output_file: out_fname || "#{filename}.#{@suffix}",
                          })
      end
    end
  end
end
