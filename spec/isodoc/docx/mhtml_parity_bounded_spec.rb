# frozen_string_literal: true

require "bundler/setup"
require "rspec"
require "isodoc/iso/docx/mhtml_parity"

RSpec.describe "IsoDoc::Iso::Docx::MhtmlParity" do
  let(:parity_class) { IsoDoc::Iso::Docx::MhtmlParity }
  let(:duplicate_delta_report) do
    <<~REPORT.chomp
      --- submitted
      +++ output
      - 3: b
      + 4: b
      - 10: x
      + 10: y
      - 11: old
      + 11: new
    REPORT
  end

  before do
    stub_const("#{parity_class}::Alignment::MAX_EXACT_TOKENS", 8)
    stub_const("#{parity_class}::Alignment::WINDOW_TOKENS", 4)
  end

  def compare(expected, actual)
    allow(parity_class).to receive(:normalize).with("submitted").and_return(expected)
    allow(parity_class).to receive(:normalize).with("output").and_return(actual)
    parity_class.new("submitted", "output")
  end

  it "aligns the window and counts duplicate deltas beyond it at original positions" do
    comparison = compare(%w[prefix a b c d x y x y x old suffix],
                         %w[prefix a c b d y x y x y new suffix])

    expect(comparison.report).to eq(duplicate_delta_report)
  end

  it "does not report reordered equal counts beyond the alignment window as a match" do
    comparison = compare(%w[a b c d x y x y x y],
                         %w[b a c d y x y x y x])

    expect([comparison.match?, comparison.report])
      .to eq([false, "--- submitted\n+++ output\n- 1: a\n+ 2: a"])
  end

  it "retains exact alignment for a short residual in a very long artifact" do
    shared = Array.new(100_000, "cell")
    comparison = compare(shared + %w[a b c], shared + %w[b a c])

    expect(comparison.report).to eq("--- submitted\n+++ output\n- 100001: a\n+ 100002: a")
  end

  it "keeps boundary tokens matched after an insertion inside the window" do
    comparison = compare(%w[p a b c d e f g h Y s],
                         %w[p X a b c d e f g h Z s])

    expect(comparison.report.lines.grep(/^[+-] /).map(&:strip))
      .to eq(["+ 2: X", "- 10: Y", "+ 11: Z"])
  end

  it "keeps boundary tokens matched after a deletion inside the window" do
    comparison = compare(%w[p X a b c d e f g h Y s],
                         %w[p a b c d e f g h Z s])

    expect(comparison.report.lines.grep(/^[+-] /).map(&:strip))
      .to eq(["- 2: X", "- 11: Y", "+ 10: Z"])
  end

  it "handles an empty side after trimming a large insertion" do
    comparison = compare(%w[prefix suffix], ["prefix"] + Array.new(12, "cell") + ["suffix"])

    expect(comparison.report.lines.grep(/^[+-] /).map(&:strip))
      .to eq((2..13).map { |position| "+ #{position}: cell" })
  end
end
