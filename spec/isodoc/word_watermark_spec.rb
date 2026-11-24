require "spec_helper"
require "tmpdir"
require "base64"

# Group the simple and DIS output regressions by the shared header contract.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::WordConvert do
  let(:input) do
    <<~XML
      <iso-standard xmlns="https://www.metanorma.org/ns/iso">
        <bibdata>
          <docidentifier type="iso-reference">ISO 1234:2026(en)</docidentifier>
          <status><stage>#{stage}</stage><substage>60</substage></status>
          <copyright><from>2026</from><owner><organization>
            <abbreviation>ISO</abbreviation>
          </organization></owner></copyright>
        </bibdata>
        <sections><clause id="scope" displayorder="1"><title>Scope</title>
          <p>Watermark regression.</p>
        </clause></sections>
      </iso-standard>
    XML
  end

  let(:output) do
    Dir.mktmpdir("word-watermark") do |dir|
      filename = File.join(dir, "watermark")
      described_class.new(options).convert(filename, input, false)
      File.read("#{filename}.doc", encoding: "UTF-8")
    end
  end

  let(:header) do
    attachment = output.match(/Content-ID: <header.html>.*?\n\n(.*?)(?=\n--)/m)
    Base64.decode64(attachment[1]).force_encoding("UTF-8")
  end

  shared_examples "a clean Word header" do
    it "omits the stale Edited DIS editorial instruction" do
      expect(header).not_to include("Edited DIS", "MUST BE USED FOR FINAL",
                                    "#C45911", "WordArt_x0020_")
    end

    it "preserves running document IDs, page fields, copyright and body",
       :aggregate_failures do
      expect(header).to include("ISO 1234:2026(en)", "2026", "PAGE", "©",
                                "All rights reserved")
      expect(header).to include("id=eha", "id=eh2", "id=h2", "id=h2l",
                                "id=ef2", "id=f2", "id=ef3", "id=f3")
      expect(output).to include("Watermark regression.")
    end
  end

  [40, 50, 60, 90].each do |document_stage|
    context "with automatic DIS layout at stage #{document_stage}" do
      let(:stage) { document_stage }
      let(:options) { {} }

      it_behaves_like "a clean Word header"
    end
  end

  context "with explicit DIS layout before enquiry" do
    let(:stage) { 30 }
    let(:options) { { isowordtemplate: "dis" } }

    it_behaves_like "a clean Word header"
  end

  context "with explicit simple layout" do
    let(:stage) { 50 }
    let(:options) { { isowordtemplate: "simple" } }

    it_behaves_like "a clean Word header"
  end
end
