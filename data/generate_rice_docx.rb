# frozen_string_literal: true

# Generate a sample DOCX from rice.xml using the Adapter
# Usage: bundle exec ruby data/generate_rice_docx.rb
#
# Uses presentation XML (with fmt-* elements) for proper term numbering,
# xref labels, and bibliography formatting.

require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "isodoc/iso/docx"

# Prefer presentation XML (with fmt-name, fmt-preferred, etc.)
xml_path = File.join(__dir__, "..", "spec", "examples", "rice.presentation.xml")
unless File.exist?(xml_path)
  xml_path = File.join(__dir__, "..", "spec", "examples", "rice.xml")
end
output_path = File.join(__dir__, "iso-rice-sample-output.docx")

adapter = IsoDoc::Iso::Docx::Adapter.new(template: :dis)
adapter.convert(xml_path, output_path)

puts "Generated: #{output_path}"
puts "Size: #{File.size(output_path)} bytes"
