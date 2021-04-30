require "isodoc"
require "mn2sts"

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
        unless /\.xml$/.match?(in_fname)
          in_fname = Tempfile.open([filename, ".xml"], encoding: "utf-8") do |f|
            f.write file
            f.path
          end
        end
        FileUtils.rm_rf dir
        Mn2sts.convert(in_fname, out_fname || "#{filename}.#{@suffix}")
      end
    end
  end
end
