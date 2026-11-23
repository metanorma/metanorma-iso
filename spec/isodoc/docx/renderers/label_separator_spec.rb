# frozen_string_literal: true

require_relative "../spec_helper"

# Keep the related renderer controls together in the repository's DOCX spec layout.
# The memoized values separate conversion setup and observations from assertions.
# rubocop:disable-next RSpec/SpecFilePathFormat, RSpec/MultipleMemoizedHelpers
RSpec.describe IsoDoc::Iso::Docx::BoxWrapper do
  let(:adapter) { build_adapter }
  let(:xml) do
    minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title>
        <note id="n1"><fmt-name>NOTE</fmt-name><p>Note body.</p></note>
        <note id="n2"><fmt-name>NOTE 2</fmt-name><p>Numbered note body.</p></note>
        <example id="e1"><fmt-name>EXAMPLE</fmt-name><p>Example body.</p></example>
        <example id="e2"><fmt-name>EXAMPLE 2</fmt-name><p>Numbered example body.</p></example>
        <note id="n3"><fmt-name>NOTE 3</fmt-name><ol><li><p>Listed body.</p></li></ol></note>
        <example id="e3"><fmt-name>EXAMPLE 3</fmt-name><table id="tbl1"><tbody><tr><td>Cell.</td></tr></tbody></table></example>
        <admonition id="a1" type="warning"><fmt-name>WARNING</fmt-name><p>Warning body.</p></admonition>
      </clause>
      <terms id="terms"><title>Terms</title><term id="t1">
        <fmt-name>3.1</fmt-name>
        <preferred><expression><name>alpha</name></expression></preferred>
        <termnote id="tn1"><fmt-name>Note 1 to entry:</fmt-name><p>Term note body.</p></termnote>
      </term></terms></sections>
    INNER
  end

  let(:paragraphs) do
    convert_and_extract(adapter, xml) { |pkg| pkg.document.body.paragraphs }
  end
  let(:inline_styles) { %w[Note Example] }
  let(:block_labels) { ["NOTE 3", "EXAMPLE 3"] }
  let(:warning_styles) { %w[Warningtitle Warningtext] }
  let(:inline_sequences) do
    paragraphs.select { |para| inline_styles.include?(para_style_value(para)) }
      .map { |para| para.runs.map { |run| run.tab ? :tab : run_text(run) } }
      .select { |sequence| sequence.join.include?("body.") }
  end
  let(:expected_inline_sequences) do
    [["NOTE", :tab, "Note body."],
     ["NOTE 2", :tab, "Numbered note body."],
     ["EXAMPLE", :tab, "Example body."],
     ["EXAMPLE 2", :tab, "Numbered example body."],
     ["Note 1 to entry: ", "Term note body."]]
  end
  let(:block_paragraphs) do
    paragraphs.select do |para|
      block_labels.include?(para.runs.map { |run| run_text(run) }.join.strip)
    end
  end
  let(:block_sequences) do
    block_paragraphs.map do |para|
      [para.runs.map { |run| run_text(run) }.join, para.runs.any?(&:tab)]
    end
  end
  let(:warning_sequences) do
    paragraphs.select { |para| warning_styles.include?(para_style_value(para)) }
      .map do |para|
        [para_style_value(para), para.runs.map { |run| run_text(run) }.join,
         para.runs.any?(&:tab)]
      end
  end
  let(:cell_xml) do
    minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title>
        <table id="t1"><tbody><tr><td>
          <note id="n1"><fmt-name>NOTE</fmt-name><p>Cell note body.</p></note>
        </td></tr></tbody></table>
      </clause></sections>
    INNER
  end
  let(:cell_sequence) do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      adapter.convert(cell_xml, path)
      extract_docx(path) do |doc, ns|
        note = doc.at_xpath("//w:tc/w:p[w:pPr/w:pStyle/@w:val='Note']", ns)
        note.xpath("w:r/*[self::w:t or self::w:tab]", ns).map do |node|
          node.name == "tab" ? :tab : node.text
        end
      end
    end
  end

  it "separates inline labels from body text with one real tab and no space" do
    expect(inline_sequences).to eq(expected_inline_sequences)
  end

  it "leaves standalone block labels without a trailing separator" do
    expect(block_sequences).to eq([["NOTE 3", false], ["EXAMPLE 3", false]])
  end

  it "keeps standalone block labels with the following block" do
    expect(block_paragraphs.map { |para| para.properties&.keep_next_wrapper })
      .to all(be_truthy)
  end

  it "preserves the separate admonition title and body without tabs" do
    expect(warning_sequences).to eq(
      [["Warningtitle", "WARNING", false], ["Warningtext", "Warning body.", false]],
    )
  end

  it "separates table-cell note labels from their body with a real tab" do
    expect(cell_sequence).to eq(["NOTE", :tab, "Cell note body."])
  end
end
