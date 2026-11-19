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

  describe "#render_license on the simple (WD/CD) template" do
    let(:adapter) { build_adapter(template: :simple) }

    def license_xml
      minimal_iso_xml(<<~INNER)
        <boilerplate>
          <license-statement>
            <clause>
              <title>Warning for WDs and CDs</title>
              <p>This document is not an ISO International Standard.</p>
              <p>Recipients of this draft are invited to submit comments.</p>
            </clause>
          </license-statement>
        </boilerplate>
        <sections/>
      INNER
    end

    def style_and_text(para)
      [para_style_value(para),
       para.runs.map { |r| r.text || "" }.join]
    end

    it "styles the warning as zzwarninghdr / zzwarning" do
      renderer.render_license(parse_iso_document(license_xml).boilerplate, doc)

      pairs = doc.model.body.paragraphs.map { |p| style_and_text(p) }
      expect(pairs.first(3).map(&:first))
        .to eq(%w[zzwarninghdr zzwarning zzwarning])
    end

    it "closes the warning box with an unstyled nbsp spacer paragraph" do
      renderer.render_license(parse_iso_document(license_xml).boilerplate, doc)

      expect(style_and_text(doc.model.body.paragraphs.last))
        .to eq([nil, "\u00A0"])
    end

    it "defines the warning styles in the template" do
      %w[zzwarninghdr zzwarning].each do |id|
        expect(IsoDoc::Iso::Docx::StyleLibrary.load_default(template: :simple)
          .paragraph_style?(id)).to be(true), "#{id} missing from styles.yml"
      end
    end

    it "adds no spacer when there is no license statement" do
      renderer.render_license(nil, doc)
      expect(doc.model.body.paragraphs).to be_empty
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
     "Published in Switzerland"]
  end

  it "preserves the copyright page when legal and feedback statements are absent" do
    expect(copyright_page(copyright_xml)).to eq([*copyright_block, :page_break, "Contents"])
  end

  context "with the full ISO address paragraph" do
    let(:copyright_xml) do
      minimal_iso_xml(<<~INNER)
        <boilerplate>
          <copyright-statement>
            <clause>
              <p>All rights reserved.</p>
              <p align="left">ISO copyright office<br/> CP 401<br/> Email:  <link target="mailto:copyright@iso.org"/><br/> Website: www.iso.org</p>
              <p>Published in Switzerland</p>
            </clause>
          </copyright-statement>
        </boilerplate>
        <sections/>
      INNER
    end

    it "prints the address once" do
      expect(address_paragraphs.length).to eq(1)
    end

    it "uses the address style" do
      expect(address_paragraphs.first[:style]).to eq("zzCopyrightaddress")
    end

    it "keeps the email and website text" do
      expect(address_paragraphs.first[:text]).to include("copyright@iso.org", "www.iso.org")
    end

    context "when a legal statement also names the copyright office" do
      let(:copyright_xml) do
        minimal_iso_xml(<<~INNER)
          <boilerplate>
            <legal-statement>
              <clause><p>Ask the ISO copyright office for permission.</p></clause>
            </legal-statement>
          </boilerplate>
          <sections/>
        INNER
      end

      it "keeps the legal paragraph in the copyright style" do
        expect(address_paragraphs.map { |p| p[:style] }).to eq(["zzCopyright"])
      end
    end

    def address_paragraphs
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        build_adapter.convert(copyright_xml, path)
        extract_docx(path) do |document, ns|
          document.xpath("//w:body/w:p[contains(., 'copyright office')]", ns).map do |p|
            { style: p.at_xpath("w:pPr/w:pStyle/@w:val", ns).value, text: p.text }
          end
        end
      end
    end
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
