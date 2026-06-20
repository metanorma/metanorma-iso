# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::CoverRenderer do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:renderer) { described_class.new(resolver, context) }

  describe "#render" do
    it "renders cover page paragraphs from bibdata" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-intro">Cereals</title>
          <title language="en" type="title-main">Specifications</title>
          <title language="en" type="title-part">Rice</title>
          <docidentifier type="ISO" primary="true">ISO/CD 17301-1:2016</docidentifier>
          <date type="updated"><on>2016-05-01</on></date>
          <status><stage>30</stage></status>
          <copyright><from>2016</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections><clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause></sections>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      paragraphs = doc.model.body.paragraphs
      texts = paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }

      expect(texts).to include("17301")
      expect(texts).to include("ISO/CD 17301-1:2016 (draft 2016-05-01)")
      expect(texts).to include("CD stage")
    end

    it "renders cover title with CoverTitleA1 style" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Quality Management</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      title_paras = doc.model.body.paragraphs.select do |p|
        p.properties&.style&.value == "CoverTitleA1"
      end
      expect(title_paras.length).to be >= 1
      title_text = title_paras.first.runs.map { |r| r.text || "" }.join
      expect(title_text).to include("Quality Management")
    end

    it "renders cover subtitle with CoverTitleA2 style when part title present" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-intro">Cereals</title>
          <title language="en" type="title-main">Specifications</title>
          <title language="en" type="title-part">Rice</title>
          <docidentifier type="ISO" primary="true">ISO/CD 17301-1:2016</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      subtitle_paras = doc.model.body.paragraphs.select do |p|
        p.properties&.style&.value == "CoverTitleA2"
      end
      expect(subtitle_paras.length).to eq(1),
        "expected one CoverTitleA2 paragraph for the part subtitle"
      subtitle_text = subtitle_paras.first.runs.map { |r| r.text || "" }.join
      expect(subtitle_text).to include("Rice")

      main_paras = doc.model.body.paragraphs.select do |p|
        p.properties&.style&.value == "CoverTitleA1"
      end
      main_text = main_paras.first.runs.map { |r| r.text || "" }.join
      expect(main_text).to include("Cereals").and include("Specifications")
      expect(main_text).not_to include("Rice"),
        "part title should not appear in main title once it has a subtitle"
    end

    it "renders edition text with ordinal suffix" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO">ISO 1234</docidentifier>
          <edition>2</edition>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("2nd edition")
    end

    it "renders committee reference from ext model" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO">ISO 1234</docidentifier>
          <ext>
            <editorial-group>
              <technical-committee type="full">TC 34</technical-committee>
              <subcommittee type="full">SC 4</subcommittee>
              <workgroup type="full">WG 3</workgroup>
            </editorial-group>
          </ext>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      texts = doc.model.body.paragraphs.map { |p| p.runs.map { |r| r.text || "" }.join }
      expect(texts).to include("TC 34/SC 4/WG 3")
    end

    it "handles nil bibdata gracefully" do
      doc = adapter.send(:create_document)
      renderer.render(nil, doc)

      expect(doc.model.body.paragraphs).to be_empty
    end
  end
end
