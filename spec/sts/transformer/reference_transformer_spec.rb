# frozen_string_literal: true

require_relative "unit_b_support"

RSpec.describe Metanorma::Iso::Sts::Transformer::ReferenceTransformer do
  include TransformerUnitSupport

  let(:back) do
    <<~XML
      <bibliography>
        <references id="r1" normative="true"><title>Normative references</title>
          <p id="rp">The following are referred to.</p>
          <bibitem id="b1"><formattedref>Dated Title</formattedref><docidentifier>ISO 123:2012</docidentifier></bibitem>
          <bibitem id="b2"><formattedref>Undated Title</formattedref><docidentifier>ISO 456</docidentifier></bibitem>
        </references>
        <references id="r2" normative="false"><title>Bibliography</title>
          <bibitem id="b3"><formattedref>First</formattedref><docidentifier>ISO 789</docidentifier></bibitem>
          <bibitem id="b4"><formattedref>Second</formattedref><docidentifier>IEC 1-2022</docidentifier></bibitem>
        </references>
      </bibliography>
    XML
  end
  let(:context) { context_for(source_xml(back: back)) }
  let(:root) { context.source.typed_root }
  let(:transformer) { described_class.new(context) }

  def section_xml(id)
    sec = nodes_of(root, "StandardReferencesSection").find { |s| s.id == id }
    xml_of(transformer.transform_section(sec))
  end

  describe "#transform_section for normative references" do
    let(:doc) { section_xml("r1") }

    it "emits a sec of type norm-refs with the title and intro paragraph" do
      expect(doc.at_xpath("/sec/@sec-type").value).to eq("norm-refs")
      expect(doc.at_xpath("/sec/@id").value).to eq("r1")
      expect(doc.at_xpath("/sec/title").text).to eq("Normative references")
      expect(doc.at_xpath("/sec/p").text).to eq("The following are referred to.")
    end

    it "emits an unnumbered norm-refs ref-list with one ref per bibitem" do
      refs = doc.xpath("/sec/ref-list[@content-type='norm-refs']/ref")

      expect(refs.map { |r| r["id"] }).to eq(%w[b1 b2])
      expect(refs.flat_map { |r| r.xpath("label") }).to be_empty
    end
  end

  describe "#transform_section for a bibliography" do
    let(:doc) { section_xml("r2") }

    it "emits a bare bibl ref-list with a title" do
      expect(doc.root.name).to eq("ref-list")
      expect(doc.at_xpath("/ref-list/@content-type").value).to eq("bibl")
      expect(doc.at_xpath("/ref-list/title").text).to eq("Bibliography")
    end

    it "numbers the entries [1], [2]" do
      expect(doc.xpath("/ref-list/ref/label").map(&:text)).to eq(["[1]", "[2]"])
    end
  end

  describe "#transform_bibitem" do
    def ref(id)
      item = nodes_of(root, "StandardReferencesSection").flat_map { |s| Array(s.references) }.find { |b| b.id == id }
      xml_of(transformer.transform_bibitem(item))
    end

    it "builds mixed-citation from identifier and formatted reference" do
      expect(ref("b1").at_xpath("/ref/mixed-citation").text).to eq("ISO 123:2012, Dated Title")
    end

    it "marks an identifier with a year as dated, and its std-ref and title" do
      doc = ref("b1")

      expect(doc.at_xpath("/ref/std/@type").value).to eq("dated")
      expect(doc.at_xpath("/ref/std/std-ref/@type").value).to eq("dated")
      expect(doc.at_xpath("/ref/std/std-ref").text).to eq("ISO 123:2012")
      expect(doc.at_xpath("/ref/std/title").text).to eq("Dated Title")
    end

    it "marks an identifier without a year as undated" do
      expect(ref("b2").at_xpath("/ref/std/@type").value).to eq("undated")
    end

    it "treats a -YYYY suffix as a dated reference" do
      expect(ref("b4").at_xpath("/ref/std/@type").value).to eq("dated")
    end

    it "registers the bibitem id as a ref so xrefs resolve to bibr" do
      ref("b1")

      expect(context.id_generator.kind_for("b1")).to eq("ref")
    end
  end
end
