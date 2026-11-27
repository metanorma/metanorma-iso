# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::ListTransformer do
  include TransformerUnitSupport

  let(:sections) do
    <<~XML
      <clause id="c1"><title>Clause</title>
        <ol id="o-alpha" type="alphabet">
          <li id="a1"><p id="pa1">First</p></li>
          <li id="a2"><p id="pa2">Second</p>
            <ul id="nested"><li id="n1"><p id="pn1">Inner</p></li></ul>
          </li>
        </ol>
        <ol id="o-roman" type="roman"><li id="r1"><p id="pr1">One</p></li><li id="r2"><p id="pr2">Two</p></li></ol>
        <ol id="o-arabic" type="arabic"><li id="z1"><p id="pz1">One</p></li><li id="z2"><p id="pz2">Two</p></li></ol>
        <ul id="o-bullet"><li id="u1"><p id="pu1">Dot</p></li></ul>
        <dl id="dl1"><dt id="t1">AC</dt><dd id="d1"><p id="pd1">Alternating</p></dd><dt id="t2">DC</dt><dd id="d2"><p id="pd2">Direct</p></dd></dl>
      </clause>
    XML
  end
  let(:context) { context_for(source_xml(sections: sections)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def list_xml(id)
    node = node_of(root, id.start_with?("o-bullet") || id == "nested" ? "UnorderedList" : "OrderedList", id: id)
    xml_of(transformer.transform(node))
  end

  describe "#transform" do
    it "maps an alphabet ol to list-type alpha-lower with a) b) labels" do
      doc = list_xml("o-alpha")

      expect(doc.at_xpath("/list/@list-type").value).to eq("alpha-lower")
      expect(doc.xpath("/list/list-item/label").map(&:text)).to eq(["a)", "b)"])
      expect(doc.xpath("/list/list-item/p").map(&:text)).to eq(%w[First Second])
    end

    it "keeps the source id on list items so xrefs to them resolve" do
      doc = list_xml("o-alpha")

      expect(doc.xpath("/list/list-item/@id").map(&:value)).to eq(%w[a1 a2])
      expect(doc.xpath("//list-item[@id='n1']")).not_to be_empty
    end

    it "maps a roman ol to roman-lower with i) ii) labels" do
      doc = list_xml("o-roman")

      expect(doc.at_xpath("/list/@list-type").value).to eq("roman-lower")
      expect(doc.xpath("/list/list-item/label").map(&:text)).to eq(["i)", "ii)"])
    end

    it "maps an arabic ol to list-type arabic with 1) 2) labels" do
      doc = list_xml("o-arabic")

      expect(doc.at_xpath("/list/@list-type").value).to eq("arabic")
      expect(doc.xpath("/list/list-item/label").map(&:text)).to eq(["1)", "2)"])
    end

    it "maps a ul to a bullet list whose items carry no label" do
      doc = list_xml("o-bullet")

      expect(doc.at_xpath("/list/@list-type").value).to eq("bullet")
      expect(doc.xpath("/list/list-item/label")).to be_empty
      expect(doc.at_xpath("/list/list-item/p").text).to eq("Dot")
    end

    it "keeps a nested list inside the owning list-item" do
      doc = list_xml("o-alpha")
      nested = doc.at_xpath("/list/list-item[2]/list")

      expect(nested.at_xpath("@list-type").value).to eq("bullet")
      expect(nested.at_xpath("list-item/p").text).to eq("Inner")
    end
  end

  describe "#transform_def_list" do
    let(:def_list) { transformer.transform_def_list(node_of(root, "DefinitionList", id: "dl1")) }

    it "emits one def-item per dt/dd pair" do
      expect(def_list).to be_a(Sts::NisoSts::DefList)
      doc = xml_of(def_list)

      expect(doc.xpath("/def-list/def-item/term").map(&:text)).to eq(%w[AC DC])
      expect(doc.xpath("/def-list/def-item/def/p").map(&:text)).to eq(%w[Alternating Direct])
    end
  end
end
