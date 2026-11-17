# frozen_string_literal: true

RSpec.describe Metanorma::Iso::Sts::Validator do
  let(:validator) { described_class.new }

  def sts_xml(body)
    <<~XML
      <?xml version="1.0"?>
      <standard xml:lang="en" dtd-version="1.2">
        <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml="MathML 3.0"/>
        #{body}
      </standard>
    XML
  end

  it "passes when the document has processing-meta and a valid root" do
    report = validator.validate(sts_xml("<body/>"))
    expect(report).to be_valid
  end

  it "fails when the root is not <standard>" do
    report = validator.validate("<other/>")
    expect(report.errors.map(&:rule_id)).to include("oiml-x999-root-element")
  end

  it "fails when <standard> lacks <processing-meta>" do
    report = validator.validate('<standard/>')
    expect(report.errors.map(&:rule_id)).to include("oiml-x999-processing-meta")
  end

  # ISO profile: a <std> needs its <std-ref> dated; the OIML X 999
  # <title> requirement does not apply to ISO coding.
  it "fails when <std-ref> does not declare datedness" do
    xml = sts_xml(<<~X)
      <back>
        <ref-list content-type="bibliography">
          <ref><std>
            <std-ref>ISO 123</std-ref>
          </std></ref>
        </ref-list>
      </back>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("iso-gdg-std-ref-dated")
  end

  it "passes when <std-ref> is typed, with or without <title>" do
    xml = sts_xml(<<~X)
      <back>
        <ref-list content-type="bibliography">
          <ref><std type="dated">
            <std-ref type="dated">ISO 123:2024</std-ref>
          </std></ref>
        </ref-list>
      </back>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).not_to include("iso-gdg-std-ref-dated")
  end

  it "fails when <self-uri> appears inside <self-xref>" do
    xml = sts_xml(<<~X)
      <body>
        <sec>
          <self-xref rid="s_x"><self-uri>/foo</self-uri></self-xref>
        </sec>
      </body>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("oiml-x999-no-self-uri-in-xref")
  end

  it "fails when <disp-quote> has <attrib> without <permissions>" do
    xml = sts_xml(<<~X)
      <body>
        <sec>
          <disp-quote><attrib>Some source</attrib></disp-quote>
        </sec>
      </body>
    X
    report = validator.validate(xml)
    expect(report.errors.map(&:rule_id)).to include("oiml-x999-permission-on-reuse-disp-quote")
  end
end
