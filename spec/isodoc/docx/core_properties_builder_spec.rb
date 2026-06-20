# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::CorePropertiesBuilder do
  let(:adapter) { build_adapter }

  def build_from_xml(bibdata_xml)
    xml = minimal_iso_xml(<<~INNER)
      #{bibdata_xml}
      <sections><clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause></sections>
    INNER
    model = parse_iso_document(xml)
    described_class.new(model).build
  end

  describe "#build" do
    it "sets dc:title from composed English title parts" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-intro">Cereals and pulses</title>
          <title language="en" type="title-main">Specifications and test methods</title>
          <title language="en" type="title-part">Rice</title>
          <title language="en" type="title-part-prefix">Part 1</title>
          <docidentifier type="ISO" primary="true">ISO/CD 17301-1:2016</docidentifier>
          <copyright><from>2016</from><owner><organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization></owner></copyright>
        </bibdata>
      BIB

      title_value = props.title.respond_to?(:value) ? props.title.value : props.title
      expect(title_value.to_s).to include("Cereals and pulses")
      expect(title_value.to_s).to include("Specifications and test methods")
      expect(title_value.to_s).to include("Rice")
    end

    it "sets dc:creator from copyright holder organization name" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test Document</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization></owner></copyright>
        </bibdata>
      BIB

      creator_value = props.creator.respond_to?(:value) ? props.creator.value : props.creator
      expect(creator_value.to_s).to eq("International Organization for Standardization")
    end

    it "falls back to publisher when no copyright holder" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test Document</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>ISO</name>
            </organization>
          </contributor>
        </bibdata>
      BIB

      creator_value = props.creator.respond_to?(:value) ? props.creator.value : props.creator
      expect(creator_value.to_s).to eq("ISO")
    end

    it "sets cp:lastModifiedBy same as dc:creator" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      creator = props.creator.respond_to?(:value) ? props.creator.value : props.creator
      last_mod = props.last_modified_by.respond_to?(:value) ? props.last_modified_by.value : props.last_modified_by
      expect(last_mod.to_s).to eq(creator.to_s)
    end

    it "defaults dc:creator to ISO when no organization is available" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
        </bibdata>
      BIB

      creator_value = props.creator.respond_to?(:value) ? props.creator.value : props.creator
      expect(creator_value.to_s).to eq("ISO")
    end

    it "sets dcterms:created from created date" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <date type="created"><on>2024-01-15</on></date>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      expect(props.created).not_to be_nil
      expect(props.created.value.to_s).to include("2024-01-15")
      expect(props.created.type.to_s).to eq("dcterms:W3CDTF")
    end

    it "falls back to published when no created date" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <date type="published"><on>2024-06-01</on></date>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      expect(props.created).not_to be_nil
      expect(props.created.value.to_s).to include("2024-06-01")
    end

    it "sets dcterms:modified to current time" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      expect(props.modified).not_to be_nil
      expect(props.modified.type.to_s).to eq("dcterms:W3CDTF")
    end

    it "sets cp:revision from version revision-date" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <version><revision-date>2016-05-01</revision-date></version>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      revision_value = props.revision.respond_to?(:value) ? props.revision.value : props.revision
      expect(revision_value.to_s).to eq("2016-05-01")
    end

    it "defaults cp:revision to 1 when version absent" do
      props = build_from_xml(<<~BIB)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO" primary="true">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
      BIB

      revision_value = props.revision.respond_to?(:value) ? props.revision.value : props.revision
      expect(revision_value.to_s).to eq("1")
    end
  end
end
