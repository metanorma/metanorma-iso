# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "smoke test" do
  it "parses DIS presentation XML" do
    path = File.expand_path("spec/fixtures/samples/international-standard/document-en.dis.presentation.xml", Dir.pwd)
    expect(File.exist?(path)).to be(true)
    xml = File.read(path, encoding: "utf-8")
    expect(xml.size).to be > 1000
    model = Metanorma::IsoDocument::Root.from_xml(xml)
    expect(model).to be_a(Metanorma::IsoDocument::Root)
  end

  it "generates DOCX from DIS presentation XML" do
    path = File.expand_path("spec/fixtures/samples/international-standard/document-en.dis.presentation.xml", Dir.pwd)
    adapter = build_adapter(template: :dis)
    Dir.mktmpdir do |dir|
      output = File.join(dir, "output.docx")
      adapter.convert(path, output)
      expect(File.size(output)).to be > 1000
    end
  end
end
