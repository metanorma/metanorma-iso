# frozen_string_literal: true

require_relative "spec_helper"

require "tmpdir"

# The metanorma-core document_transformers adapter: the driver hands
# over the reader's parse result (the typed Root) plus the compile
# options — the adapter normalizes to the SourceDocument wrapper and
# picks up the sibling presentation XML.
RSpec.describe Metanorma::Iso::Sts::Transformer::Standard do
  let(:source_xml) do
    <<~XML
      <metanorma>
        <bibdata><title language="en" type="main">T</title><docidentifier>ISO 1:2025</docidentifier><language>en</language></bibdata>
        <sections><clause id="c1"><title>Scope</title><p id="p1">Text.</p></clause></sections>
      </metanorma>
    XML
  end

  let(:root) { Metanorma::Iso::Document::Root.from_xml(source_xml) }

  it "normalizes the driver's raw Root into a SourceDocument" do
    adapter = described_class.new(root, {})
    adapter.transform
    expect(adapter.to_xml).to include("<standard")
    expect(adapter.to_xml).to include("<title-wrap")
  end

  it "accepts an already-wrapped SourceDocument (standalone path)" do
    source = Metanorma::Iso::Sts::Transformer::SourceDocument.parse(source_xml)
    adapter = described_class.new(source, {})
    adapter.transform
    expect(adapter.to_xml).to include("<standard")
  end

  it "indexes the presentation XML handed over via options" do
    presentation = <<~XML
      <metanorma>
        <bibdata><title language="en" type="main">T</title><docidentifier>ISO 1:2025</docidentifier><language>en</language></bibdata>
        <sections><clause id="c1"><title>Scope</title>
          <requirement id="_p1" anchor="rc-9" model="ogc" type="class">
            <fmt-provision id="_f1"><table id="t9" autonum="2"><fmt-name>Table 2 — Class</fmt-name><tbody><tr><th>Identifier</th><td><tt>/req/x</tt></td></tr></tbody></table></fmt-provision>
          </requirement>
        </clause></sections>
      </metanorma>
    XML
    xml_with_req = source_xml.sub("<p id=\"p1\">Text.</p>",
                                  "<requirement id=\"_r1\" anchor=\"rc-9\" model=\"ogc\" type=\"class\"><identifier>/req/x</identifier></requirement>")
    root2 = Metanorma::Iso::Document::Root.from_xml(xml_with_req)
    adapter = described_class.new(root2, { sts_presentation_xml: presentation })
    out = adapter.transform.to_xml
    expect(out).to include("content-type=\"recommendclass\"")
    expect(out).to include("Table\u00A02")
  end

  it "reads the sibling presentation XML from the source filename" do
    Dir.mktmpdir do |dir|
      src = File.join(dir, "document.adoc")
      File.write(src, "irrelevant")
      File.write(File.join(dir, "document.presentation.xml"), <<~XML)
        <metanorma>
          <bibdata><title language="en" type="main">T</title><docidentifier>ISO 1:2025</docidentifier><language>en</language></bibdata>
          <sections><clause id="c1"><title>Scope</title>
            <requirement id="_p2" anchor="rc-7" model="ogc" type="class">
              <fmt-provision id="_f2"><table id="t7" autonum="9"><fmt-name>Table 9 — Class</fmt-name><tbody><tr><th>Identifier</th><td><tt>/req/y</tt></td></tr></tbody></table></fmt-provision>
            </requirement>
          </clause></sections>
        </metanorma>
      XML
      xml_with_req = source_xml.sub("<p id=\"p1\">Text.</p>",
                                    "<requirement id=\"_r2\" anchor=\"rc-7\" model=\"ogc\" type=\"class\"><identifier>/req/y</identifier></requirement>")
      root2 = Metanorma::Iso::Document::Root.from_xml(xml_with_req)
      adapter = described_class.new(root2, { sourcefilename: src })
      out = adapter.transform.to_xml
      expect(out).to include("Table\u00A09")
    end
  end
end
