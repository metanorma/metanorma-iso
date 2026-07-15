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
        p.properties&.style&.value == "zzCopyright"
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
        p.properties&.style&.value == "Notice"
      end
      body_paras = doc.model.body.paragraphs.select do |p|
        p.properties&.style&.value == "Notice"
      end

      expect(title_paras.length).to be >= 1
      expect(body_paras.length).to be >= 1
    end
  end
end
