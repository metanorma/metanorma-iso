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
        para_style_value(p) == "CoverTitleA1"
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
        para_style_value(p) == "CoverTitleA2"
      end
      expect(subtitle_paras.length).to eq(1),
        "expected one CoverTitleA2 paragraph for the part subtitle"
      subtitle_text = subtitle_paras.first.runs.map { |r| r.text || "" }.join
      expect(subtitle_text).to include("Rice")

      main_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "CoverTitleA1"
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

    def localized_edition_cover(language, edition, unlocalized: 2)
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <language>#{language}</language>
          #{%(<edition language="">#{unlocalized}</edition>) if unlocalized}
          <edition language="#{language}">#{edition}</edition>
        </bibdata>
        <sections/>
      INNER
      doc = adapter.send(:create_document)
      renderer.render(parse_iso_document(xml).bibdata, doc)
      doc.model.body.paragraphs.map do |paragraph|
        paragraph.runs.map { |run| Array(run.text).join }.join
      end
    end

    it "formats a numeric English edition as an ordinal" do
      expect(localized_edition_cover("en", "2", unlocalized: nil))
        .to include("2nd edition")
    end

    it "preserves capitalization of nouns in German edition labels" do
      expect(localized_edition_cover("de", "zweite Ausgabe"))
        .to include("Zweite Ausgabe")
    end

    it "preserves mixed case in localized English edition labels" do
      expect(localized_edition_cover("en", "Second Edition"))
        .to include("Second Edition")
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

    it "renders identifier+language as the first cover paragraph with zzCoverlarge" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO/DIS 15926-100</docidentifier>
          <language>en</language>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections/>
      INNER

      model = parse_iso_document(xml)
      doc = adapter.send(:create_document)

      renderer.render(model.bibdata, doc)

      first_styled = doc.model.body.paragraphs.find do |p|
        para_style_value(p) == "zzCoverlarge"
      end
      expect(first_styled).not_to be_nil,
        "expected a zzCoverlarge paragraph on the cover"
      text = first_styled.runs.map { |r| r.text || "" }.join
      expect(text).to eq("ISO/DIS 15926-100(en)"),
        "cover-large line should be identifier with language tag in parens"
    end

    it "handles nil bibdata gracefully" do
      doc = adapter.send(:create_document)
      renderer.render(nil, doc)

      expect(doc.model.body.paragraphs).to be_empty
    end

    describe "compact cover for stages before DIS" do
      def cover_texts(stage:)
        xml = minimal_iso_xml(<<~INNER)
          <bibdata type="standard">
            <title language="en" type="title-intro">Cereals and pulses</title>
            <title language="en" type="title-main">Specifications and test methods</title>
            <title language="en" type="title-part">Rice</title>
            <title language="en" type="title-part-prefix">Part 1</title>
            <title language="fr" type="title-main">Céréales et légumineuses</title>
            <docidentifier type="ISO" primary="true">ISO/CD 17301-1:2016</docidentifier>
            <docidentifier type="iso-undated">ISO/CD 17301-1</docidentifier>
            <docidentifier type="iso-with-lang">ISO/CD 17301-1:2016(en)</docidentifier>
            <docidentifier type="iso-tc">17301</docidentifier>
            <docnumber>17301</docnumber>
            <date type="updated"><on>2016-05-01</on></date>
            <edition language="">2</edition>
            <edition language="en">second edition</edition>
            <version>2016-05-01</version>
            <language>en</language>
            <status><stage>#{stage}</stage></status>
            <ext>
              <editorial-group>
                <technical-committee type="full">TC 34</technical-committee>
                <subcommittee type="full">SC 4</subcommittee>
                <workgroup type="full">WG 3</workgroup>
              </editorial-group>
            </ext>
          </bibdata>
          <sections/>
        INNER

        model = parse_iso_document(xml)
        doc = adapter.send(:create_document)
        renderer.render(model.bibdata, doc)
        doc.model.body.paragraphs.map do |p|
          p.runs.map { |r| Array(r.text).join }.join
        end
      end

      let(:cd_cover) do
        ["17301", "ISO/CD 17301-1 (draft 2016-05-01)", "TC 34/SC 4/WG 3",
         "Second edition", "Date: 2016-05-01",
         "Cereals and pulses — Specifications and test methods — Part 1: Rice",
         "", "CD stage", ""]
      end

      it "renders the reference CD cover paragraph sequence" do
        expect(cover_texts(stage: 30)).to eq(cd_cover)
      end

      it "keeps the labelled working-document line from stage 40" do
        expect(cover_texts(stage: 40))
          .to include("Reference number of working document: 17301")
      end

      it "keeps the DIS stage badge from stage 40" do
        expect(cover_texts(stage: 40)).to include("DIS stage")
      end

      it "drops the standalone document number from stage 40" do
        expect(cover_texts(stage: 40)).not_to include("17301")
      end
    end

    describe "classic cover identity fields" do
      def render_cover_texts(bibdata_inner)
        xml = minimal_iso_xml(<<~INNER)
          <bibdata type="standard">
            <title language="en" type="title-main">Guidelines for translation</title>
            <title language="fr" type="title-main">Lignes directrices pour la traduction</title>
            #{bibdata_inner}
          </bibdata>
          <sections/>
        INNER

        model = parse_iso_document(xml)
        doc = adapter.send(:create_document)
        renderer.render(model.bibdata, doc)
        doc.model.body.paragraphs.map do |p|
          p.runs.map { |r| Array(r.text).join }.join
        end
      end

      let(:dis_bibdata) do
        <<~INNER
          <docidentifier type="ISO" primary="true">ISO/FDTR 29166:2011</docidentifier>
          <docidentifier type="iso-tc">29166</docidentifier>
          <docidentifier type="iso-undated">ISO/FDTR 29166</docidentifier>
          <language>en</language>
          <version>2011-12</version>
          <date type="updated"><on>2011-12</on></date>
          <contributor>
            <role type="authorizer"><description>committee</description></role>
            <organization>
              <name>ISO</name>
              <subdivision type="Technical committee" subtype="JTC">
                <identifier type="full">JTC 1/SC 34</identifier>
              </subdivision>
            </organization>
          </contributor>
          <contributor>
            <role type="author"><description>secretariat</description></role>
            <organization>
              <name>ISO</name>
              <subdivision type="Secretariat"><name>SAC</name></subdivision>
            </organization>
          </contributor>
          <status><stage>50</stage></status>
          <copyright><from>2011</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        INNER
      end

      it "renders the working document reference number from iso-tc" do
        texts = render_cover_texts(dis_bibdata)
        expect(texts).to include("Reference number of working document: 29166")
      end

      it "renders the project reference number with the draft suffix" do
        texts = render_cover_texts(dis_bibdata)
        expect(texts)
          .to include("Reference number of project: ISO/FDTR 29166 (draft 2011-12)")
      end

      it "renders the draft suffix from a structured version element" do
        bibdata = dis_bibdata.sub("<version>2011-12</version>",
                                  "<version><draft>2</draft>" \
                                  "<revision-date>2011-12</revision-date></version>")
        texts = render_cover_texts(bibdata)
        expect(texts)
          .to include("Reference number of project: ISO/FDTR 29166 (draft 2)")
      end

      it "renders the committee identification from the approval group" do
        texts = render_cover_texts(dis_bibdata)
        expect(texts).to include("Committee identification: JTC 1/SC 34")
      end

      it "renders the secretariat" do
        texts = render_cover_texts(dis_bibdata)
        expect(texts).to include("Secretariat: SAC")
      end

      it "keeps the Date line ahead of the project reference" do
        texts = render_cover_texts(dis_bibdata)
        expect(texts.index { |t| t.start_with?("Date: 2011-12") })
          .to be < texts.index { |t| t.start_with?("Reference number of project:") }
      end

      it "omits the working document line when no iso-tc identifier exists" do
        texts = render_cover_texts(dis_bibdata.sub(
                                     %(<docidentifier type="iso-tc">29166</docidentifier>\n), ""
                                   ))
        expect(texts.join("\n")).not_to include("Reference number of working document")
      end

      it "falls back to the bare document number without iso-undated" do
        texts = render_cover_texts(dis_bibdata.sub(
                                     %(<docidentifier type="iso-undated">ISO/FDTR 29166</docidentifier>\n), ""
                                   ))
        expect(texts).to include("29166")
        expect(texts.join("\n")).not_to include("Reference number of project")
      end

      it "renders the second-language subtitle as an italic cover line" do
        xml = minimal_iso_xml(<<~INNER)
          <bibdata type="standard">
            <title language="en" type="title-main">Guidelines for translation</title>
            <title language="fr" type="title-main">Lignes directrices pour la traduction</title>
            <language>en</language>
            <status><stage>50</stage></status>
          </bibdata>
          <sections/>
        INNER

        model = parse_iso_document(xml)
        doc = adapter.send(:create_document)
        renderer.render(model.bibdata, doc)

        subtitle_paras = doc.model.body.paragraphs.select do |p|
          para_style_value(p) == "zzCover" &&
            p.runs.map { |r| Array(r.text).join }.join.include?("Lignes directrices")
        end
        expect(subtitle_paras.length).to eq(1),
          "expected one zzCover paragraph carrying the second-language title"
        run = subtitle_paras.first.runs.first
        expect(run.properties.italic).to be_truthy
      end

      it "takes the EN subtitle for FR documents" do
        xml = minimal_iso_xml(<<~INNER)
          <bibdata type="standard">
            <title language="en" type="title-main">Standard atmosphere</title>
            <title language="fr" type="title-main">Atmosphère type</title>
            <language>fr</language>
            <status><stage>50</stage></status>
          </bibdata>
          <sections/>
        INNER

        model = parse_iso_document(xml)
        doc = adapter.send(:create_document)
        renderer.render(model.bibdata, doc)

        texts = doc.model.body.paragraphs
          .map { |p| p.runs.map { |r| Array(r.text).join }.join }
        expect(texts.join("\n")).to include("Standard atmosphere")
      end

      it "composes the translated subtitle from intro, main and part" do
        xml = minimal_iso_xml(<<~INNER)
          <bibdata type="standard">
            <title language="en" type="title-main">Specifications and test methods</title>
            <title language="fr" type="title-intro">Céréales et légumineuses</title>
            <title language="fr" type="title-main">Spécification et méthodes d'essai</title>
            <title language="fr" type="title-part">Riz</title>
            <title language="fr" type="title-part-prefix">Partie</title>
            <language>en</language>
            <status><stage>50</stage></status>
          </bibdata>
          <sections/>
        INNER

        model = parse_iso_document(xml)
        doc = adapter.send(:create_document)
        renderer.render(model.bibdata, doc)

        texts = doc.model.body.paragraphs
          .map { |p| p.runs.map { |r| Array(r.text).join }.join }
        expect(texts.join("\n"))
          .to include("Céréales et légumineuses — " \
                      "Spécification et méthodes d'essai — Partie: Riz")
      end
    end
  end
end
