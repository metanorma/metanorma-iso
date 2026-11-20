# frozen_string_literal: true

require_relative "spec_helper"

# End-to-end coverage of the rice fixture through the full native STS
# pipeline (presentation XML → NISO STS XML → HTML).
RSpec.describe "rice end-to-end STS pipeline", :aggregate_failures, :rice_e2e do
  let(:source_xml) { File.read(rice_xml_path) }

  it "converts presentation XML to STS XML with std-meta" do
    sts = Metanorma::Iso::Sts.convert(source_xml)
    expect(sts).to include("<standard")
    expect(sts).to include("<std-meta")
    expect(sts).to include("<body")
  end

  it "types every cross-reference to a formula as disp-formula" do
    sts = Metanorma::Iso::Sts.convert(source_xml)
    formula_xrefs = sts.scan(/<xref[^>]*rid="formula[^"]*"[^>]*>/)
    expect(formula_xrefs).not_to be_empty
    expect(formula_xrefs).to all(include('ref-type="disp-formula"'))
  end

  it "renders an HTML page from the STS XML" do
    sts = Metanorma::Iso::Sts.convert(source_xml)
    html = Metanorma::Iso::Sts.render_html(sts)

    expect(html).to start_with("<!DOCTYPE html>")
    expect(html).to include("</html>")
    expect(html).to include("hero-title")
    expect(html).to include("<section")
    expect(html).to include("<table")
  end
end
