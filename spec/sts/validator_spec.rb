# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Validator do
  let(:validator) { described_class.new }

  # Minimal shell satisfying the document-structure rules: root
  # <standard>, processing-meta per Guidelines 4.3.2, front with
  # std-meta permissions + foreword, body with scope/norm-refs/terms.
  def sts_xml(body)
    <<~XML
      <?xml version="1.0"?>
      <standard xmlns:tbx="urn:iso:std:iso:30042:ed-1" xml:lang="en" dtd-version="1.2">
        <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml-version="3.0" math-representation="mathml" terminology-model="tbx">
          <custom-meta-group>
            <custom-meta>
              <meta-name>iec_iso_coding_guidelines_edition</meta-name>
              <meta-value>2.1</meta-value>
            </custom-meta>
          </custom-meta-group>
        </processing-meta>
        <front>
          <std-meta>
            <permissions>
              <copyright-statement>All rights reserved</copyright-statement>
            </permissions>
          </std-meta>
          <sec sec-type="foreword"><title>Foreword</title><p>Foreword text.</p></sec>
        </front>
        <body>
          <sec sec-type="scope"><label>1</label><title>Scope</title><p>Scope text.</p></sec>
          <sec sec-type="norm-refs"><label>2</label><title>Normative references</title><p>There are no normative references.</p></sec>
          <sec sec-type="terms"><label>3</label><title>Terms and definitions</title><p>No terms are defined.</p></sec>
          #{body}
        </body>
      </standard>
    XML
  end

  it "passes a shell conforming to Guidelines 4.1-4.4" do
    report = validator.validate(sts_xml(""))
    structural = report.errors.select do |e|
      e.rule_id.start_with?("iso-gdg-4.1", "iso-gdg-4.3", "iso-gdg-4.4")
    end
    expect(structural).to be_empty
  end

  it "fails when the root is not <standard>" do
    report = validator.validate("<other/>")
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-4.1-1")
  end

  it "fails when <standard> lacks <processing-meta>" do
    report = validator.validate("<standard><front/><body/></standard>")
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-4.3.2-6")
  end

  it "fails when processing-meta lacks the coding profile attributes" do
    xml = sts_xml("").sub('base-tagset="interchange"', 'base-tagset="full"')
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-4.3.2-6")
  end

  it "fails when a cross-reference target id does not exist (Guidelines 3.4)" do
    xml = sts_xml(<<~X)
      <sec><title>Extra</title><p>See <xref ref-type="sec" rid="nope">x</xref>.</p></sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-10.1.2-1")
  end

  it "fails when duplicate ids exist (Annex A.3.1)" do
    xml = sts_xml(<<~X)
      <sec id="dup"><title>A</title><p>a</p></sec>
      <sec id="dup"><title>B</title><p>b</p></sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-A.3.1-8")
  end

  it "fails when a list-type is outside the OSD enumeration (Guidelines 5.7)" do
    xml = sts_xml(<<~X)
      <sec><title>X</title><list list-type="order"><list-item><p>i</p></list-item></list></sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-5.7-2")
  end

  it "fails when a note lacks the NOTE designation label (Guidelines 5.6)" do
    xml = sts_xml(<<~X)
      <sec><title>X</title>
        <non-normative-note><p>Some note.</p></non-normative-note>
      </sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-5.6-2")
  end

  it "fails when a table-wrap carries no label (Guidelines 6.2.2)" do
    xml = sts_xml(<<~X)
      <sec><title>X</title>
        <table-wrap id="tw1"><caption><title>Unnamed</title></caption>
          <table><tbody><tr><td>c</td></tr></tbody></table>
        </table-wrap>
      </sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-6.2.2-1")
  end

  it "fails when <tbx:see> is used (Guidelines 9.2.7)" do
    xml = sts_xml(<<~X)
      <sec><title>X</title>
        <term-sec id="t1"><label>3.1</label>
          <tbx:termEntry id="te1"><tbx:langSet xml:lang="en">
            <tbx:definition><tbx:deco><p>d</p></tbx:deco></tbx:definition>
            <tbx:tig><tbx:term>term</tbx:term></tbx:tig>
            <tbx:see>elsewhere</tbx:see>
          </tbx:langSet></tbx:termEntry>
        </term-sec>
      </sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-9.2.7-1")
  end

  it "fails when body text starts with the copyright symbol (Guidelines B.2.1)" do
    xml = sts_xml(<<~X)
      <sec><title>X</title><p>© ISO 2025</p></sec>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-B.2.1-2")
  end
end
