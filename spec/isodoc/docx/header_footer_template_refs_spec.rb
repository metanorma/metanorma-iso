# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../../support/header_footer_refs_helper"

# Keep saved-DOCX regressions alongside the repository's other DOCX specs.
RSpec.describe IsoDoc::Iso::Docx::SectionManager do # rubocop:disable RSpec/SpecFilePathFormat
  include HeaderFooterRefsHelper

  %i[simple dis].each do |template|
    context "with the #{template} template" do
      it "keeps the template's odd and even part references across conversions" do
        2.times do
          with_generated_header_footer_package(template) do |zip|
            expect(template_part_references(zip).drop(1)).to eq(template_effective_references(template))
          end
        end
      end
    end
  end

  context "with the DIS template" do
    it "keeps both front and body headers in HeaderCentered" do
      with_generated_header_footer_package(:dis) do |zip|
        expect(generated_part_styles(zip).flat_map { |refs| refs.select { |(kind, _), _| kind == "header" }.values })
          .to eq([["HeaderCentered"]] * 4)
      end
    end

    it "keeps each footer on one FooterCentered line" do
      with_generated_header_footer_package(:dis) do |zip|
        expect(generated_part_styles(zip).map { |refs| refs.select { |(kind, _), _| kind == "footer" }.values })
          .to eq([[["FooterCentered"]] * 2, [["FooterCentered"]] * 2])
      end
    end

    it "preserves effective centered alignment through the template style chains" do
      with_generated_header_footer_package(:dis) do |zip|
        styles = Nokogiri::XML(zip.read("word/styles.xml"))
        ids = %w[HeaderCentered FooterCentered FooterPageNumber FooterPageRomanNumber]
        expect(ids.map { |id| effective_part_alignment(styles, id) }).to eq(["center"] * 4)
      end
    end
  end
end
