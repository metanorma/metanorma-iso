# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::TermsSectionRenderer do
  let(:adapter) { build_adapter }

  it "renders terms section title with Heading1" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <terms id="terms">
          <title>Terms and definitions</title>
          <term id="t1"><preferred><expression><name>Term one</name></expression></preferred></term>
        </terms>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      heading_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "Heading1"
      end
      expect(heading_paras.length).to be >= 1,
        "terms section title should use Heading1"
    end
  end
end
