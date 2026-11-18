# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::BoilerplateRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:doc) { adapter.send(:create_document) }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:inline_renderer) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:renderer) { described_class.new(resolver, inline_renderer) }

  describe "#render_license" do
    it "renders license/warning on the cover page" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <license-statement>
            <clause>
              <title>Warning for WDs and CDs</title>
              <p>This document is not an ISO International Standard.</p>
            </clause>
          </license-statement>
        </boilerplate>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      renderer.render_license(model.boilerplate, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("Warning for WDs and CDs")
      expect(texts).to include("This document is not an ISO International Standard.")
    end

    it "handles missing boilerplate gracefully" do
      renderer.render_license(nil, doc)
      expect(doc.model.body.paragraphs).to be_empty
    end

    it "handles empty boilerplate content gracefully" do
      xml = minimal_iso_xml("<boilerplate></boilerplate><sections/>")
      model = parse_iso_document(xml)
      renderer.render_license(model.boilerplate, doc)
      # map_all_content may give nil or empty
    end
  end

  describe "#render_copyright" do
    it "renders copyright statements on the copyright page" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <copyright-statement>
            <clause>
              <p>© ISO 2016</p>
              <p>All rights reserved.</p>
            </clause>
          </copyright-statement>
        </boilerplate>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      renderer.render_copyright(model.boilerplate, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("© ISO 2016")
      expect(texts).to include("All rights reserved.")
    end

    it "renders copyright with zzCopyright style" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <copyright-statement>
            <clause>
              <p>© ISO 2024</p>
            </clause>
          </copyright-statement>
        </boilerplate>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      renderer.render_copyright(model.boilerplate, doc)

      copyright_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "zzCopyright"
      end
      expect(copyright_paras.length).to be >= 1
    end

    it "renders license with Notice style (Era C: zzwarning deprecated)" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <license-statement>
            <clause>
              <title>Warning for WDs and CDs</title>
              <p>This document is circulated for comment.</p>
            </clause>
          </license-statement>
        </boilerplate>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      renderer.render_license(model.boilerplate, doc)

      title_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "Notice"
      end
      body_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "Notice"
      end

      expect(title_paras.length).to be >= 1
      expect(body_paras.length).to be >= 1
    end
  end
end

RSpec.describe IsoDoc::Iso::Docx::BoilerplateRenderer, "#render_copyright in the saved DOCX" do
  let(:additional_statements) { "" }
  let(:copyright_xml) do
    minimal_iso_xml(<<~INNER)
      <boilerplate>
        <copyright-statement>
          <clause>
            <p>All rights reserved.</p>
            <p>ISO copyright office</p>
            <p>Published in Switzerland</p>
          </clause>
        </copyright-statement>
        #{additional_statements}
      </boilerplate>
      <preface>
        <clause type="toc" id="toc">
          <fmt-title depth="1">Contents</fmt-title>
        </clause>
      </preface>
      <sections/>
    INNER
  end
  let(:copyright_block) do
    ["All rights reserved.", "ISO copyright office",
     "Published in Switzerland", "ISO copyright office"]
  end

  it "preserves the copyright page when legal and feedback statements are absent" do
    expect(copyright_page(copyright_xml)).to eq([*copyright_block, :page_break, "Contents"])
  end

  context "with legal and feedback statements" do
    let(:additional_statements) do
      <<~XML
        <legal-statement>
          <clause><title>Legal notice</title><p>Model legal paragraph.</p></clause>
        </legal-statement>
        <feedback-statement>
          <clause><title>Feedback</title><p>Model feedback paragraph.</p></clause>
        </feedback-statement>
      XML
    end

    it "prints both statements between the copyright address and the break before Contents" do
      expect(copyright_page(copyright_xml)).to eq([
                                                    *copyright_block, "Legal notice", "Model legal paragraph.",
                                                    "Feedback", "Model feedback paragraph.", :page_break, "Contents"
                                                  ])
    end
  end

  def copyright_page(xml)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "output.docx")
      build_adapter.convert(xml, path)
      extract_docx(path) do |document, ns|
        cover_break = document.at_xpath("(//w:body/w:p[w:pPr/w:sectPr])[1]", ns)
        paragraphs = cover_break.xpath("following-sibling::w:p", ns).map do |p|
          p.at_xpath(".//w:br[@w:type = 'page']", ns) ? :page_break : p.xpath(".//w:t", ns).map(&:text).join
        end
        paragraphs.take_while { |text| text != "Contents" } + paragraphs.grep("Contents").first(1)
      end
    end
  end
end
