require "spec_helper"
require "tmpdir"

RSpec.describe "legacy ISO shared structural validation" do
  let(:body) do
    "\n== Scope\n\nThis document describes a method.\n\n== Method\n\nThe method applies to the sample.\n"
  end

  around do |example|
    Dir.mktmpdir("iso-structural-validation-") do |directory|
      Dir.chdir(directory) { example.run }
    end
  end

  it "accepts genuine frontend XML through the configured ISO profile" do
    results = []
    expect_any_instance_of(Metanorma::Iso::Validate).to receive(:shared_schema_validate).and_wrap_original do |original, *args, **options|
      expect(options).to eq(flavor: "iso", representation: "semantic")
      xml = Nokogiri::XML(args.first)
      expect(xml.root.namespace.href).to eq("https://www.metanorma.org/ns/standoc")
      results << original.call(*args, **options)
    end
    Asciidoctor.convert(VALIDATING_BLANK_HDR + body, *OPTIONS)
    expect(results).to eq([[]])
  end

  it "reports invalid authored structure through the registered schema finding" do
    results = []
    expect_any_instance_of(Metanorma::Iso::Validate).to receive(:shared_schema_validate).and_wrap_original do |original, *args, **options|
      results << original.call(*args, **options)
    end
    Asciidoctor.convert(VALIDATING_BLANK_HDR + body.sub("This document", "[align=mid-air]\nThis document"), *OPTIONS)
    expect(results.flatten.join).to include("Invalid attribute align")
    expect(File.read("test.err.html")).to include("Invalid attribute align")
  end

  it "preserves the frontend novalid boundary" do
    expect_any_instance_of(Metanorma::Iso::Validate).not_to receive(:shared_schema_validate)
    header = VALIDATING_BLANK_HDR.sub(":nodoc:", ":nodoc:\n:novalid:")
    Asciidoctor.convert(header + body, *OPTIONS)
  end
end
