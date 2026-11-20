# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::BackTransformer do
  def back_for(body_xml)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections><clause id="c1"><title>Scope</title><p id="p1">Text.</p></clause></sections>
        #{body_xml}
      </metanorma>
    XML
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(xml)
    context = Metanorma::Iso::Sts::Transformer::Context.new(source)
    described_class.new(context).transform(source)
  end

  def doc_of(back)
    Nokogiri::XML(back.to_xml)
  end

  let(:two_annexes) do
    <<~XML
      <annex id="_a1" obligation="normative"><title>Rules</title><p id="ap1">First.</p></annex>
      <annex id="_a2" obligation="informative"><title>Notes</title><p id="ap2">Second.</p></annex>
    XML
  end

  describe "#transform" do
    it "returns a <back> with one <app> per annex, lettered in order" do
      back = back_for(two_annexes)

      expect(back).to be_a(Sts::NisoSts::Back)
      apps = doc_of(back).xpath("/back/app-group/app")
      expect(apps.map { |a| a["id"] }).to eq(%w[sec_A sec_B])
    end

    it "codes the obligation as @content-type" do
      apps = doc_of(back_for(two_annexes)).xpath("//app")

      expect(apps.map { |a| a["content-type"] }).to eq(%w[normative informative])
    end

    it "emits the label as 'Annex <letter>' and the rendered title" do
      first = doc_of(back_for(two_annexes)).at_xpath("//app[@id='sec_A']")

      expect(first.at_xpath("./label").text).to match(/\AAnnex.A\z/)
      expect(first.at_xpath("./title").text).to eq("Rules")
    end

    it "takes the label number from the presentation autonum when present" do
      annex = %(<annex id="_a1" obligation="normative" autonum="C"><title>T</title><p id="x">y</p></annex>)
      app = doc_of(back_for(annex)).at_xpath("//app")

      expect(app.at_xpath("./label").text).to match(/\AAnnex.C\z/)
    end

    it "dispatches annex paragraphs straight into the app" do
      first = doc_of(back_for(two_annexes)).at_xpath("//app[@id='sec_A']")

      expect(first.at_xpath("./p[@id='ap1']").text).to eq("First.")
      expect(first.at_xpath("./sec")).to be_nil
    end

    it "emits no app-group when the document has no annex" do
      back = back_for("")

      expect(back.app_group).to be_nil
      expect(doc_of(back).at_xpath("//app")).to be_nil
    end

    it "omits @content-type for an annex without obligation" do
      app = doc_of(back_for(%(<annex id="_a1"><title>T</title><p id="x">y</p></annex>))).at_xpath("//app")

      expect(app["content-type"]).to be_nil
    end

    it "refuses an annex carrying a definition list rather than dropping it" do
      annex = <<~XML
        <annex id="_a1" obligation="normative"><title>T</title>
          <dl id="d1"><dt>A</dt><dd><p id="dp">Alpha</p></dd></dl>
        </annex>
      XML

      expect { back_for(annex) }.to raise_error(ArgumentError, /def-list/)
    end
  end
end
