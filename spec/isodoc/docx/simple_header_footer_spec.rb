# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../../support/layout_docx_helper"

# Keep these regression specs beside the existing DOCX renderer specs.
# rubocop:disable-next RSpec/SpecFilePathFormat
RSpec.describe IsoDoc::Iso::Docx::HeaderFooterRenderer do
  include LayoutDocxHelper

  let(:root) { Uniword.load(IsoDoc::Iso::DocxTemplates.template_path(:simple)) }
  let(:renderer) { described_class.new(build_adapter(template: :simple).resolver) }
  let(:scheme) { IsoDoc::Iso::Docx::PageScheme.roman }

  let(:layouts) do
    {
      headers: header_parts(root).map { |p| part_properties(p) },
      footers: footer_parts(root).map { |p| footer_layout(p) },
    }
  end

  before do
    layouts
    header_parts(root).each { |p| renderer.render_header(p.content, "ISO 1234:2026(en)") }
    footer_parts(root).each { |p| renderer.render_footer(p.content, "© ISO 2026", scheme: scheme) }
  end

  it "preserves every template header paragraph's style and direct alignment" do
    expect(header_parts(root).map { |p| part_properties(p) }).to eq(layouts[:headers])
  end

  it "replaces the header text" do
    expect(header_parts(root).map { |p| part_text(p) }).to all(eq("ISO 1234:2026(en)"))
  end

  it "preserves odd and even footer properties, count, tabs and field order" do
    expect(footer_parts(root).map { |p| footer_layout(p) }).to eq(layouts[:footers])
  end

  it "replaces copyright and removes cached page numbers" do
    expect(footer_parts(root).map { |p| part_text(p) }).to all(eq("© ISO 2026"))
  end

  context "with arabic pages" do
    let(:scheme) { IsoDoc::Iso::Docx::PageScheme.arabic }

    it "preserves each page side's layout" do
      expect(footer_parts(root).map { |p| footer_layout(p) }).to eq(layouts[:footers])
    end
  end
end
