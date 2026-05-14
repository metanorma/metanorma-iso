# frozen_string_literal: true

require "bundler/setup"
require "lutaml/model"
require "nokogiri"
require "zip"
require "rspec"

require "metanorma/document"
require "metanorma/iso_document"
require "uniword"

require "isodoc/iso/docx_style_mapping"
require "isodoc/iso/docx/style_resolver"
require "isodoc/iso/docx/model_utils"
require "isodoc/iso/docx/context"
require "isodoc/iso/docx/inline"
require "isodoc/iso/docx/adapter"

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
