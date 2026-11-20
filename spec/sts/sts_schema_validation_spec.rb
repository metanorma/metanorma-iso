# frozen_string_literal: true

require_relative "spec_helper"

# Card P3-004, task 2.25 (public part): the STS the converter writes for the
# public end-to-end inputs validates against the NISO STS extended 1.0
# (MathML 3) XSD that the sts gem ships under reference-docs/.
#
# That XSD predates <processing-meta> (Guidelines ed 2.1, 4.3.2), which the
# converter emits as the first child of <standard>; the schema expects
# <front> there. The spec states that one known difference and validates
# the document without the element. It checks the converter against the
# schema, not against the 17 private reference documents.
RSpec.describe "STS output against the NISO STS XSD", :aggregate_failures do # rubocop:disable RSpec/DescribeClass
  def xsd_dir
    File.join(Gem.loaded_specs.fetch("sts").full_gem_path,
              "reference-docs", "NISO-STS-extended-1-MathML3-XSD")
  end

  let(:schema) do
    Dir.chdir(xsd_dir) do
      Nokogiri::XML::Schema(File.read("NISO-STS-extended-1-mathml3.xsd"))
    end
  end

  def sts_for(fixture)
    Metanorma::Iso::Sts.convert(File.read(FIXTURES_ROOT.join(fixture)))
  end

  def without_processing_meta(xml)
    Nokogiri::XML(xml).tap { |d| d.at_xpath("/standard/processing-meta")&.remove }
  end

  {
    "ISO 8601-1-style document" => "sts_e2e/calendar_notation_e2e_a.input.xml",
    "amendment document" => "sts_e2e_b/widget_amd.xml",
  }.each do |label, fixture|
    context "with the #{label}" do
      let(:sts) { sts_for(fixture) }

      it "is valid apart from the schema's missing <processing-meta>" do
        errors = schema.validate(Nokogiri::XML(sts))
        expect(errors.map(&:message).join("\n"))
          .to match(/\A[\d:]+ ERROR: Element 'processing-meta': This element is not expected/)
        expect(errors.size).to eq(1)
      end

      it "is valid once <processing-meta> is set aside" do
        errors = schema.validate(without_processing_meta(sts))
        expect(errors.map(&:message)).to eq([])
      end

      it "makes the schema reject a corrupted copy" do
        doc = without_processing_meta(sts)
        doc.at_xpath("//body/sec/p | //body/sec/title")
          .add_next_sibling("<not-an-sts-element/>")
        expect(schema.validate(doc)).not_to be_empty
      end
    end
  end
end
