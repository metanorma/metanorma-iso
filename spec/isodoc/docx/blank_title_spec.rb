# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../../support/layout_docx_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::MiddleTitleRenderer do
  include LayoutDocxHelper

  let(:adapter) { build_adapter }

  context "with a whitespace-only title" do
    let(:xml) do
      minimal_iso_xml('<bibdata><title language="en" type="title-main">   </title></bibdata>')
    end

    it "omits the empty title paragraph" do
      expect(middle_title_lines(xml)).to be_empty
    end
  end

  ["", "   "].each do |blank|
    context "with a #{blank.inspect} document-language title" do
      let(:xml) do
        minimal_iso_xml(<<~XML)
          <bibdata><language>fr</language>
            <title language="fr" type="title-main">#{blank}</title>
            <title language="en" type="title-main">English fallback</title>
          </bibdata>
        XML
      end

      it "falls back to English" do
        expect(middle_title_lines(xml)).to eq([["MainTitle1", "English fallback"]])
      end
    end
  end
end
