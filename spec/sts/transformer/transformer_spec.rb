# frozen_string_literal: true

RSpec.describe Metanorma::Iso::Sts::Transformer do
  let(:input) { File.read(FIXTURES_ROOT.join("sample.xml")) }
  let(:output) { Metanorma::Iso::Sts.convert(input) }

  describe Metanorma::Iso::Sts::Transformer::SourceDocument do
    let(:doc) { described_class.parse(input) }

    it { expect(doc.docidentifier).to eq("OIML R 7") }
    it { expect(doc.language).to eq("en") }
    it { expect(doc.copyright_year).to eq("1979") }
    it { expect(doc.sections.size).to eq(1) }
    it { expect(doc.annexes).to be_empty }
    it { expect(doc).to be_front }
    it { expect(doc).not_to be_has_back }
  end

  describe Metanorma::Iso::Sts::Transformer::DocumentTransformer do
    it "emits <standard> with the source language" do
      expect(output).to include("<standard")
      expect(output).to include('xml:lang="en"')
    end

    it "emits <processing-meta> with OIML defaults" do
      expect(output).to include('tagset-family="sts"')
      expect(output).to include('table-model="xhtml"')
      expect(output).to include('mathml="MathML 3.0"')
    end

    it "emits the OIML identifier as a decomposed NISO STS <std-ident>" do
      expect(output).to include("<std-ident>")
      expect(output).to include("<originator>OIML</originator>")
      expect(output).to include("<doc-type>r</doc-type>")
      expect(output).to include("<doc-number>7</doc-number>")
    end

    it "records the OIML series letter" do
      expect(output).to include("<meta-value>R</meta-value>")
    end

    it "transforms <clause> → <sec> with title" do
      expect(output).to include("<sec")
      expect(output).to include("<title>Scope</title>")
    end

    it "does not leak the metanorma namespace" do
      expect(output).not_to include("metanorma.org/ns/standoc")
    end
  end

  describe "inline mapping" do
    let(:output) do
      Metanorma::Iso::Sts.convert(<<~XML)
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iso">
          <bibdata type="standard">
            <title language="en" type="main">Inline sample</title>
            <docidentifier primary="true" type="ISO">OIML X 1</docidentifier>
            <language>en</language>
          </bibdata>
          <sections>
            <clause id="s_one" inline-header="false" obligation="normative">
              <title>One</title>
              <p id="p1">Text with <em>italic</em> and <strong>bold</strong> and <tt>code</tt>.</p>
              <p id="p2">See <xref target="s_one" style="clause" id="_x1"/><semx element="xref" source="_x1"><fmt-xref type="inline" target="s_one">Clause 1</fmt-xref></semx>.</p>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "maps <em> → <italic>" do
      expect(output).to include("<italic>italic</italic>")
    end

    it "maps <strong> → <bold>" do
      expect(output).to include("<bold>bold</bold>")
    end

    it "maps <tt> → <monospace>" do
      expect(output).to include("<monospace>code</monospace>")
    end

    it "keeps only the presentation mirror of a semantic xref" do
      expect(output).to include('<xref ref-type="sec" rid="s_one">Clause 1</xref>')
      expect(output.scan("Clause 1").size).to eq(1)
    end
  end

  describe Metanorma::Iso::Sts::Transformer::IdGenerator do
    let(:gen) { described_class.new }

    it "keeps the source id of an identified node" do
      clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "s_scope")
      expect(gen.id_for(clause, prefix: "sec")).to eq("s_scope")
    end

    it "falls back to a numbered id when the node has no id" do
      clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new
      expect(gen.id_for(clause, prefix: "sec")).to eq("sec_1")
    end
  end

  describe Metanorma::Iso::Sts::Transformer::FootnoteCollector do
    let(:col) { described_class.new }

    it "returns a unique sts id per source id" do
      expect(col.register("fn_a")).to eq("fn_1")
      expect(col.register("fn_b")).to eq("fn_2")
    end

    it "returns the same id on repeat registration" do
      first = col.register("fn_a")
      expect(col.register("fn_a")).to eq(first)
    end
  end
end
