# frozen_string_literal: true

require "json"
require "tmpdir"
require_relative "../isodoc/iso/docx/mhtml_parity"

# Run with bundle exec rake -f lib/tasks/docx_parity.rake docx:parity
# DOCX_PARITY_CASES is a JSON array; see spec/fixtures/docx_parity/README.md.
formats = %w[doc docx].freeze
desc "Compare submitted MHTML with Uniword output (DOCX_PARITY_CASES JSON)"
task "docx:parity" do
  cases = JSON.parse(ENV.fetch("DOCX_PARITY_CASES"))
  unless cases.is_a?(Array) && !cases.empty?
    raise ArgumentError, "DOCX_PARITY_CASES must be a nonempty JSON array"
  end

  cases.each do |entry|
    submitted = File.expand_path(entry.fetch("submitted"))
    unless entry.key?("output") ^ entry.key?("source")
      raise ArgumentError, "Supply exactly one of output or source"
    end

    Dir.mktmpdir("docx-parity-") do |dir|
      output = entry["output"] && File.expand_path(entry["output"])
      unless output
        require "metanorma/iso"
        require "isodoc/iso/docx"
        source = File.expand_path(entry.fetch("source"))
        format = entry.fetch("format", "docx")
        raise ArgumentError, "format must be doc or docx" unless formats.include?(format)

        output = File.join(dir, "output.#{format}")
        xml = Nokogiri::XML(File.read(source)) { |config| config.strict.nonet }
        options = entry["template"] ? { isowordtemplate: entry["template"] } : {}
        # Use the normal processor's template selection and Uniword adapter.
        Metanorma::Iso::Processor.new.output(xml, source, output, format.to_sym, options)
        puts "Source: #{source}"
      end
      puts IsoDoc::Iso::Docx::MhtmlParity.new(submitted, output).report
    end
  end
end
