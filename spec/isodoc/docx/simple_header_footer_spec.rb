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

  context "with fields and tabs before the header text" do
    let(:header_result) do
      part = header_parts(root).first
      run_class = Uniword::Wordprocessingml::Run
      protected_runs = [
        run_class.new(field_char: Uniword::Wordprocessingml::FieldChar.new(fldCharType: "begin")),
        run_class.new(instr_text: Uniword::Wordprocessingml::InstrText.new(text: " PAGE ")),
        run_class.new(field_char: Uniword::Wordprocessingml::FieldChar.new(fldCharType: "separate")),
        run_class.new(text: "1"),
        run_class.new(field_char: Uniword::Wordprocessingml::FieldChar.new(fldCharType: "end")),
        run_class.new(tab: Uniword::Wordprocessingml::Tab.new),
      ]
      part.content.paragraphs.first.runs.unshift(*protected_runs)
      original_runs = protected_runs.map(&:to_xml)
      original_footers = footer_parts(root).map { |footer| footer.content.to_xml }
      texts = ["", "A", "B", "", "A"].map do |text|
        renderer.render_header(part.content, text)
        part_text(part)
      end
      {
        texts: texts,
        runs_preserved: protected_runs.map(&:to_xml) == original_runs,
        footers_preserved: footer_parts(root).map { |footer| footer.content.to_xml } == original_footers,
      }
    end

    it "updates empty and nonempty headers on every render" do
      expect(header_result[:texts]).to eq(["1", "1A", "1B", "1", "1A"])
    end

    it "preserves fields and tabs" do
      expect(header_result[:runs_preserved]).to be(true)
    end

    it "leaves the footers untouched" do
      expect(header_result[:footers_preserved]).to be(true)
    end
  end

  %i[simple dis].each do |template|
    it "reuses a #{template} adapter after documents with empty headers" do
      adapter = build_adapter(template: template)
      identifiers = ["", "ISO A", "ISO B", "", "ISO A"]
      actual = identifiers.map { |identifier| converted_header_texts(adapter, identifier) }
      expect(actual).to eq(identifiers.zip)
    end
  end
end
