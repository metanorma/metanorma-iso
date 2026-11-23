# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# Keep with the DOCX specs that render through the adapter.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::Adapter, "note and example styles" do
  let(:body) do
    <<~INNER
      <sections>
        <clause id="s1">
          <fmt-title>Scope</fmt-title>
          <note id="n1"><p>First note para.</p><p>Second note para.</p></note>
          <example id="e1"><p>First example para.</p><p>Second example para.</p></example>
        </clause>
      </sections>
    INNER
  end

  def styles_by_text(template)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      build_adapter(template: template).convert(minimal_iso_xml(body), path)
      Zip::File.open(path) do |zip|
        doc = Nokogiri::XML(zip.read("word/document.xml")).remove_namespaces!
        doc.xpath("//p").to_h do |p|
          [p.xpath(".//t").map(&:text).join, p.at_xpath("./pPr/pStyle/@val")&.value]
        end
      end
    end
  end

  context "with the simple template" do
    subject(:styles) { styles_by_text(:simple) }

    it "styles every paragraph of a multi-paragraph note" do
      expect(styles.values_at("First note para.", "Second note para."))
        .to eq(%w[Note Note])
    end

    it "styles every paragraph of a multi-paragraph example" do
      expect(styles.values_at("First example para.", "Second example para."))
        .to eq(%w[Example Example])
    end
  end

  context "with the DIS template" do
    subject(:styles) { styles_by_text(:dis) }

    it "keeps the distinct continuation styles" do
      expect(styles.values_at("Second note para.", "Second example para."))
        .to eq(%w[Notecontinued Exampleindentcontinued])
    end
  end
end
