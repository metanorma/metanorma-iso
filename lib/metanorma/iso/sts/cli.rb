# frozen_string_literal: true

require "fileutils"
require "pathname"
require "thor"

module Metanorma
  module Iso
    module Sts
      # Thor CLI for `oiml-sts`.
      #
      # Commands:
      #   convert <input.xml> [output.xml]      Convert one MN-XML to STS XML.
      #   convert-dir <input-dir> <output-dir>  Batch convert every presentation XML.
      #   validate <sts.xml>                    Validate against the ISO NISO STS coding guidelines (ed 2.1).
      class Cli < Thor
        package_name "oiml-sts"

        desc "convert INPUT [OUTPUT]", "Convert a Metanorma presentation XML to OIML NISO STS XML"
        method_option :validate, type: :boolean, default: false,
                                  desc: "Run the validator on the output and exit non-zero on errors"
        def convert(input, output = nil)
          warn_oiml_sts_deprecated
          sts_xml = Sts.convert(read_input(input))
          output_path = output || default_output_for(input)
          write_output(output_path, sts_xml)
          $stdout.puts "Wrote #{output_path} (#{sts_xml.bytesize} bytes)"
          if options[:validate]
            report = Sts.validate(sts_xml)
            $stdout.puts report.to_s
            exit 1 unless report.valid?
          end
        end

        desc "convert-dir INPUT_DIR OUTPUT_DIR",
             "Batch convert every document.presentation.xml under INPUT_DIR"
        def convert_dir(input_dir, output_dir)
          warn_oiml_sts_deprecated
          require "pathname"

          inputs = Pathname.new(input_dir).glob("**/document.presentation.xml")
          raise "No presentation XMLs found under #{input_dir}" if inputs.empty?

          FileUtils.mkdir_p(output_dir)
          inputs.sort.each do |input|
            slug = input.parent.basename.to_s
            output = File.join(output_dir, "#{slug}.sts.xml")
            $stdout.puts "Converting #{slug}..."
            sts_xml = Sts.convert(input.read)
            write_output(output, sts_xml)
          rescue StandardError => e
            $stderr.puts "  FAILED: #{e.class}: #{e.message}"
          end
        end

        desc "validate STS_XML", "Validate an ISO NISO STS XML against the coding guidelines ed 2.1"
        def validate(input)
          report = Sts.validate(read_input(input))
          $stdout.puts report.to_s
          exit 1 unless report.valid?
        end

        private

        # oiml-sts is superseded by the metanorma pipeline (metanorma-core#12):
        # `metanorma compile -t oiml -x oimlsts <file>.adoc`. Retained for one
        # release cycle; scheduled for removal.
        def warn_oiml_sts_deprecated
          $stderr.puts "[DEPRECATED] `oiml-sts` is superseded by " \
                       "`metanorma compile -t oiml -x oimlsts <file>.adoc` " \
                       "and will be removed in a future release."
        end

        def read_input(path)
          Pathname.new(path).read
        end

        def write_output(path, content)
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
        end

        def default_output_for(input)
          input.sub(/\.xml\z/, ".sts.xml")
        end
      end
    end
  end
end
