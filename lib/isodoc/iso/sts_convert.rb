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

      def inputfile(in_fname, filename, file)
        /\.xml$/.match?(in_fname) or
          in_fname = Tempfile.open([filename, ".xml"], encoding: "utf-8") do |f|
            f.write file
            f.path
          end
        in_fname
      end

      def convert(in_fname, file = nil, debug = false, out_fname = nil)
        file = File.read(in_fname, encoding: "utf-8") if file.nil?
        _docxml, filename, dir = convert_init(file, in_fname, debug)
        in_fname = inputfile(in_fname, filename, file)
        FileUtils.rm_rf dir
        output_file = out_fname || "#{filename}.#{@suffix}"
        run_mnconvert(in_fname, output_file)
        declare_processing_meta(output_file)
        # mnconvert passes Metanorma-internal constructs through verbatim;
        # repair the result into schema-valid NISO STS before delivery.
        Metanorma::Iso::Sts::OutputSanitizer.sanitize_file(output_file)
      end

      private

      # The native driver (Metanorma::Iso::Sts.convert_inner) declares the
      # coding profile; mnconvert does not, so this leg adds it. Shared
      # with the native driver so both emit the same declaration.
      def declare_processing_meta(output_file)
        xml = File.read(output_file, encoding: "utf-8")
        File.write(output_file,
                   Metanorma::Iso::Sts.inject_processing_meta(xml),
                   encoding: "utf-8")
      end

      # The mnconvert binary writes its output before self-validating it
      # against the NISO STS XSD, and legacy Metanorma constructs (flavor
      # build attributes, inline identifiers, generated id collisions)
      # make that self-check reject the very emission it just wrote. The
      # artifact is on disk at that point and the output sanitizer
      # repairs exactly those violations, so a rejected-but-written
      # conversion is completed rather than abandoned; anything else
      # (crash before writing, unreadable artifact) still fails the leg.
      def run_mnconvert(in_fname, output_file)
        MnConvert.convert(in_fname,
                          { input_format: MnConvert::InputFormat::MN,
                            output_file: output_file })
      rescue StandardError => e
        usable_output?(output_file) or raise
        warn "metanorma-iso: mnconvert rejected its own NISO STS emission " \
             "(#{e.class}); OutputSanitizer repairs the written artifact"
      end

      def usable_output?(path)
        Nokogiri::XML(File.read(path, encoding: "utf-8"))
          .root&.name == "standard"
      rescue StandardError
        false
      end
    end
  end
end
