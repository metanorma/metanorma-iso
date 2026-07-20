# frozen_string_literal: true

require "bundler/setup"
require "lutaml/model"
require "nokogiri"
require "zip"
require "rspec"

require "metanorma/document"
require "metanorma/iso_document"
require "uniword"

require "isodoc/iso/docx"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.disable_monkey_patching!
end

def parse_iso_document(xml)
  Metanorma::IsoDocument::Root.from_xml(xml)
end

def minimal_iso_xml(body = "")
  <<~XML
    <iso-standard xmlns="https://www.metanorma.org/ns/iso">
      #{body}
    </iso-standard>
  XML
end

# Cache adapters across examples to avoid reloading the DOCX template each time.
# The template is immutable so sharing the adapter is safe.
ADAPTER_CACHE = {}

def build_adapter(**opts)
  key = opts.hash
  cached = ADAPTER_CACHE[key]
  return cached if cached

  adapter = IsoDoc::Iso::Docx::Adapter.new(**opts)
  ADAPTER_CACHE[key] = adapter
  adapter
end

def extract_docx(path)
  require "zip"
  Zip::File.open(path) do |zip|
    doc = Nokogiri::XML(zip.find_entry("word/document.xml").get_input_stream.read)
    ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
    yield doc, ns
  end
end

def convert_and_extract(adapter, xml)
  Dir.mktmpdir do |dir|
    path = File.join(dir, "output.docx")
    adapter.convert(xml, path)
    pkg = Uniword::Docx::Package.from_file(path)
    yield pkg
  end
end

# First paragraph style ID of a Uniword paragraph. uniword 1.2+ made
# ParagraphProperties#style a collection ("multiple tolerated"): parsed
# paragraphs yield an Array of StyleReference, while ParagraphBuilder assigns
# a single StyleReference. Tolerate both shapes (and nil).
def para_style_value(para)
  style = para.properties&.style
  style = style.first if style.is_a?(Array)
  style&.value
end

# Full string content of a Uniword run. uniword 1.2+ made Run#text a
# collection of Text objects, so substring checks must join first.
def run_text(run)
  Array(run.text).join
end
