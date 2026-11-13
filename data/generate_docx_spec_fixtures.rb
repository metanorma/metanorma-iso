# frozen_string_literal: true

# One-shot generator for the DOCX spec fixtures:
#   spec/examples/rice.presentation.xml          (from rice.adoc)
#   spec/fixtures/samples/*/<name>.presentation.xml (already copied from
#     mn-samples-iso; regenerated here only where missing)
#   spec/fixtures/samples/*/<name>.docx          (legacy isodoc reference DOCX)
#
# Usage: bundle exec ruby -Ilib data/generate_docx_spec_fixtures.rb

require "asciidoctor"
require "metanorma-iso"
require "fileutils"

require File.expand_path("relaton_core_shadow_fix", __dir__)

def semantic_from_adoc(adoc_path)
  Asciidoctor.convert(File.read(adoc_path), backend: :iso, header_footer: false)
end

def presentation_from_semantic(sem_xml, out_path, options = {})
  opts = { datauriimage: true }.merge(options)
  conv = IsoDoc::Iso::PresentationXmlConvert.new(opts)
  conv.convert("fixture", sem_xml, nil, out_path)
end

def legacy_docx_reference(pres_xml, out_path, options = {})
  opts = { datauriimage: true, docx: true }.merge(options)
  conv = IsoDoc::Iso::WordConvert.new(opts)
  xml = File.read(pres_xml)
  conv.convert("fixture", xml, nil, out_path)
end

# rice presentation fixture
adoc = File.expand_path("spec/examples/rice.adoc", Dir.pwd)
sem = semantic_from_adoc(adoc)
File.write(File.expand_path("spec/examples/rice.presentation.xml", Dir.pwd), sem)
puts "rice.presentation.xml written"

SAMPLES = File.expand_path("spec/fixtures/samples", Dir.pwd)

PAIRS = {
  "international-standard/document-en.dis" => nil,
  "international-standard/document-en.wd" => { template: :simple },
  "international-standard/document-en" => nil,
  "amendment/document-en.damd" => nil,
  "amendment/document-en.final" => nil,
  "amendment/document-en.wd" => { template: :simple },
  "technical-report/document" => nil,
  "guide/document" => nil,
  "international-workshop-agreement/document" => nil,
  "publicly-available-specification/document" => nil,
  "technical-specification/document" => nil,
}.freeze

PAIRS.each_key do |stem|
  pres = File.join(SAMPLES, "#{stem}.presentation.xml")
  next if File.exist?(pres)

  puts "MISSING pres xml: #{pres} (copy from mn-samples-iso or render)"
end

# Legacy reference DOCX (old isodoc converter), for the paragraph-count
# comparison specs.
PAIRS.keys.each do |stem|
  pres = File.join(SAMPLES, "#{stem}.presentation.xml")
  next unless File.exist?(pres)
  ref = File.join(SAMPLES, "#{stem}.docx")
  next if File.exist?(ref)

  begin
    legacy_docx_reference(pres, ref)
    puts "reference #{ref} written (#{File.size(ref)} bytes)"
  rescue StandardError => e
    puts "FAILED #{stem}: #{e.class}: #{e.message.first(200)}"
  end
end
