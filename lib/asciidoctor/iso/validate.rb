require "nokogiri"

module Asciidoctor
  module ISO
    module Validate
      class << self
        def validate(doc)
          schemadoc = relaxng
          schema = Nokogiri::XML::RelaxNG(schemadoc)
          schema.validate(doc).each do |error|
            $stderr.puts "RELAXNG Validation: #{error.message}"
          end
        end

        def relaxng
          <<~RELAXNG

<?xml version="1.0" encoding="UTF-8"?>
<grammar xmlns="http://relaxng.org/ns/structure/1.0" datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
  <start>
    <ref name="iso_standard"/>
  </start>
  <define name="iso_standard">
    <element name="iso_standard">
      <ref name="front"/>
      <ref name="middle"/>
      <optional>
        <ref name="back"/>
      </optional>
    </element>
  </define>
  <define name="front">
    <element name="front">
      <ref name="title"/>
      <ref name="foreword"/>
      <optional>
        <ref name="introduction"/>
      </optional>
    </element>
  </define>
  <define name="title" combine="choice">
    <element name="title">
      <ref name="titlesect"/>
    </element>
  </define>
  <define name="title" combine="choice">
    <element name="title">
      <ref name="titlesect"/>
      <ref name="titlesect"/>
    </element>
  </define>
  <define name="title" combine="choice">
    <element name="title">
      <ref name="titlesect"/>
      <ref name="titlesect"/>
      <ref name="titlesect"/>
    </element>
  </define>
  <define name="titlesect">
    <element name="titlesect">
      <text/>
    </element>
  </define>
  <define name="foreword">
    <element name="foreword">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="introduction">
    <element name="introduction">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
      <optional>
        <ref name="patent_notice"/>
      </optional>
    </element>
  </define>
  <define name="patent_notice">
    <element name="patent_notice">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="middle">
    <element name="middle">
      <ref name="scope"/>
      <ref name="norm_ref"/>
      <ref name="terms_defs"/>
      <oneOrMore>
        <ref name="clause"/>
      </oneOrMore>
    </element>
  </define>
  <define name="scope">
    <element name="scope">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="norm_ref">
    <element name="norm_ref">
      <zeroOrMore>
        <ref name="iso_ref_title"/>
      </zeroOrMore>
    </element>
  </define>
  <define name="iso_ref_title">
    <element name="iso_ref_title">
      <ref name="isocode"/>
      <optional>
        <ref name="isodate"/>
      </optional>
      <ref name="isotitle"/>
    </element>
  </define>
  <define name="isocode">
    <element name="isocode">
      <text/>
    </element>
  </define>
  <define name="isodate">
    <element name="isodate">
      <choice>
        <text/>
        <ref name="date_footnote"/>
      </choice>
    </element>
  </define>
  <define name="date_footnote">
    <element name="date_footnote">
      <text/>
    </element>
  </define>
  <define name="isotitle">
    <element name="isotitle">
      <text/>
    </element>
  </define>
  <define name="terms_defs">
    <element name="terms_defs">
      <oneOrMore>
        <ref name="termdef"/>
      </oneOrMore>
    </element>
  </define>
  <define name="termdef">
    <element name="termdef">
      <ref name="term"/>
      <optional>
        <ref name="admitted_term"/>
      </optional>
      <optional>
        <ref name="symbol"/>
      </optional>
      <optional>
        <ref name="deprecated_term"/>
      </optional>
      <optional>
        <ref name="domain"/>
      </optional>
      <ref name="para"/>
      <zeroOrMore>
        <ref name="termnote"/>
      </zeroOrMore>
      <zeroOrMore>
        <ref name="termexample"/>
      </zeroOrMore>
      <zeroOrMore>
        <ref name="termref"/>
      </zeroOrMore>
    </element>
  </define>
  <define name="term">
    <element name="term">
      <text/>
    </element>
  </define>
  <define name="admitted_term">
    <element name="admitted_term">
      <text/>
    </element>
  </define>
  <define name="symbol">
    <element name="symbol">
      <text/>
    </element>
  </define>
  <define name="deprecated_term">
    <element name="deprecated_term">
      <text/>
    </element>
  </define>
  <define name="domain">
    <element name="domain">
      <text/>
    </element>
  </define>
  <define name="termnote">
    <element name="termnote">
      <text/>
    </element>
  </define>
  <define name="termexample">
    <element name="termexample">
      <text/>
    </element>
  </define>
  <define name="termref">
    <element name="termref">
      <ref name="isocode"/>
      <optional>
        <ref name="isodate"/>
        <optional>
          <ref name="isosection"/>
          <optional>
            <ref name="modification"/>
          </optional>
        </optional>
      </optional>
    </element>
  </define>
  <define name="isosection">
    <element name="isosection">
      <text/>
    </element>
  </define>
  <define name="modification">
    <element name="modification">
      <text/>
    </element>
  </define>
  <define name="clause">
    <element name="clause">
      <optional>
        <attribute name="anchor">
          <data type="ID"/>
        </attribute>
      </optional>
      <optional>
        <ref name="name"/>
      </optional>
      <zeroOrMore>
        <choice>
          <ref name="para"/>
          <ref name="table"/>
          <ref name="note"/>
          <ref name="stem"/>
          <ref name="warning"/>
          <ref name="ol"/>
          <ref name="ul"/>
        </choice>
      </zeroOrMore>
      <zeroOrMore>
        <ref name="clause"/>
      </zeroOrMore>
    </element>
  </define>
  <define name="back">
    <element name="back">
      <zeroOrMore>
        <ref name="annex"/>
      </zeroOrMore>
      <ref name="bibliography"/>
    </element>
  </define>
  <define name="annex">
    <element name="annex">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="bibliography">
    <element name="bibliography">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="para">
    <element name="para">
      <zeroOrMore>
        <choice>
          <text/>
          <ref name="em"/>
          <ref name="eref"/>
          <ref name="strong"/>
          <ref name="sub"/>
          <ref name="sup"/>
          <ref name="tt"/>
          <ref name="xref"/>
        </choice>
      </zeroOrMore>
    </element>
  </define>
  <define name="ol">
    <element name="ol">
      <oneOrMore>
        <ref name="li"/>
      </oneOrMore>
    </element>
  </define>
  <define name="ul">
    <element name="ul">
      <oneOrMore>
        <ref name="li"/>
      </oneOrMore>
    </element>
  </define>
  <define name="li">
    <element name="li">
      <oneOrMore>
        <choice>
          <ref name="para"/>
          <ref name="table"/>
          <ref name="note"/>
          <ref name="stem"/>
          <ref name="warning"/>
          <ref name="ol"/>
          <ref name="ul"/>
        </choice>
      </oneOrMore>
    </element>
  </define>
  <define name="note">
    <element name="note">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="warning">
    <element name="warning">
      <oneOrMore>
        <ref name="para"/>
      </oneOrMore>
    </element>
  </define>
  <define name="stem">
    <element name="stem">
      <text/>
    </element>
  </define>
  <define name="xref">
    <element name="xref">
      <optional>
        <attribute name="render">
          <choice>
            <value>footnote</value>
            <value>inline</value>
          </choice>
        </attribute>
      </optional>
      <choice>
        <text/>
        <ref name="iso_ref"/>
      </choice>
    </element>
  </define>
  <define name="iso_ref">
    <element name="iso_ref">
      <ref name="isocode"/>
      <optional>
        <ref name="isodate"/>
        <optional>
          <optional>
            <ref name="isosection"/>
          </optional>
        </optional>
      </optional>
    </element>
  </define>
  <define name="eref">
    <element name="eref">
      <text/>
    </element>
  </define>
  <define name="em">
    <element name="em">
      <text/>
    </element>
  </define>
  <define name="strong">
    <element name="strong">
      <text/>
    </element>
  </define>
  <define name="sub">
    <element name="sub">
      <text/>
    </element>
  </define>
  <define name="sup">
    <element name="sup">
      <text/>
    </element>
  </define>
  <define name="tt">
    <element name="tt">
      <text/>
    </element>
  </define>
  <define name="table">
    <element name="table">
      <optional>
        <ref name="name"/>
      </optional>
      <optional>
        <ref name="thead"/>
      </optional>
      <oneOrMore>
        <ref name="tbody"/>
      </oneOrMore>
      <optional>
        <ref name="tfoot"/>
      </optional>
    </element>
  </define>
  <define name="name">
    <element name="name">
      <text/>
    </element>
  </define>
  <define name="thead">
    <element name="thead">
      <oneOrMore>
        <ref name="tr"/>
      </oneOrMore>
    </element>
  </define>
  <define name="tbody">
    <element name="tbody">
      <oneOrMore>
        <ref name="tr"/>
      </oneOrMore>
    </element>
  </define>
  <define name="tfoot">
    <element name="tfoot">
      <oneOrMore>
        <ref name="tr"/>
      </oneOrMore>
    </element>
  </define>
  <define name="tr">
    <element name="tfoot">
      <oneOrMore>
        <choice>
          <ref name="td"/>
          <ref name="th"/>
        </choice>
      </oneOrMore>
    </element>
  </define>
  <define name="th">
    <element name="th">
      <zeroOrMore>
        <choice>
          <text/>
          <ref name="em"/>
          <ref name="eref"/>
          <ref name="strong"/>
          <ref name="sub"/>
          <ref name="sup"/>
          <ref name="tt"/>
          <ref name="xref"/>
        </choice>
      </zeroOrMore>
    </element>
  </define>
  <define name="td">
    <element name="td">
      <zeroOrMore>
        <choice>
          <text/>
          <ref name="em"/>
          <ref name="eref"/>
          <ref name="strong"/>
          <ref name="sub"/>
          <ref name="sup"/>
          <ref name="tt"/>
          <ref name="xref"/>
        </choice>
      </zeroOrMore>
    </element>
  </define>
</grammar>
RELAXNG
        end
      end
    end
  end
end
