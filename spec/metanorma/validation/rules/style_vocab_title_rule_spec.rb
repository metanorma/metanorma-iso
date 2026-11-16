require "spec_helper"

RSpec.describe Metanorma::Iso::Validation::Rules::StyleVocabTitleRule do
  let(:rule) { described_class.new }

  def context_with(body_xml, vocab: true)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <ext><subdoctype>vocabulary</subdoctype></ext>
          <title type="title-main" language="en">Vocabulary</title>
        </bibdata>
        <sections>#{body_xml}</sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", document: "spec", vocab: vocab
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  def context_with_titles(*titles, vocab: true, body: "")
    title_xml = titles.map do |(type, text)|
      %(<title type="#{type}" language="en">#{text}</title>)
    end.join
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="iso">
        <bibdata>
          <docidentifier>ISO 1</docidentifier>
          <ext><subdoctype>vocabulary</subdoctype></ext>
          #{title_xml}
        </bibdata>
        <sections>#{body}</sections>
      </metanorma>
    XML
    root = Metanorma::IsoDocument::Root.from_xml(xml)
    state = Metanorma::Iso::Validation::ConverterState.new(
      lang: "en", document: "spec", vocab: vocab
    )
    Metanorma::Iso::Validation::Context.new(root: root, log: nil,
                                            state: state, shared: nil)
  end

  it "flags the title 'Terminology' in a vocabulary document" do
    issues = rule.check(
      context_with_titles(["title-main", "Terminology"])
    )
    expect(issues.size).to eq(1)
    expect(issues.first.code).to eq("ISO_119")
    expect(issues.first.message).to include("Vocabulary")
  end

  it "flags the title-main 'Terms and definitions'" do
    issues = rule.check(
      context_with_titles(["title-main", "Terms and definitions"])
    )
    expect(issues.size).to eq(1)
  end

  it "flags the Clause 3 fixed lead-in in a vocabulary document" do
    issues = rule.check(context_with(<<~XML))
      <clause id="c1"><title>Terms</title>
        <p>For the purposes of this document, the following terms
        and definitions apply.</p>
      </clause>
    XML
    expect(issues.size).to eq(1)
    expect(issues.first.message).to include("purposes of this document")
  end

  it "passes a vocabulary document titled Vocabulary without the lead-in" do
    expect(rule.check(context_with(
      '<clause id="c1"><title>Terms</title><p>Terms are defined.</p></clause>'
    ))).to eq([])
  end

  it "does not flag domain titles that begin with Terminology" do
    expect(rule.check(context_with_titles(
      ["title-main", "Terminology work and terminology science"],
      ["title-intro", "Vocabulary"]
    ))).to eq([])
  end

  it "is not applicable to non-vocabulary documents" do
    context = context_with(
      '<clause id="c1"><title>Terms</title><p>For the purposes of this
      document, the following terms and definitions apply.</p></clause>',
      vocab: false
    )
    expect(rule).not_to be_applicable(context)
    expect(rule.check(context)).to eq([])
  end
end
