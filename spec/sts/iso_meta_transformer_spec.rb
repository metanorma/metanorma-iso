# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Metanorma::Iso::Sts::Transformer::IsoMetaTransformer do
  let(:context) { make_context }
  let(:transformer) { described_class.new(context) }

  it "transforms minimal bibdata to iso-meta" do
    bibdata = mock_bibdata(
      contributor: [mock_contributor],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    expect(result).to be_a(Sts::IsoSts::IsoMeta)
    xml = result.to_xml
    expect(xml).to include("<sdo>ISO</sdo>")
    expect(xml).to include("<doc-number>99999</doc-number>")
    expect(xml).to include("<doc-type>IS</doc-type>")
    expect(xml).to include("<doc-ref>ISO 99999</doc-ref>")
  end

  it "transforms bibdata with copyright" do
    bibdata = mock_bibdata(
      contributor: [mock_contributor],
      copyright: [mock_copyright],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    xml = result.to_xml
    expect(xml).to include("<copyright-statement>All rights reserved</copyright-statement>")
    expect(xml).to include("<copyright-year>2025</copyright-year>")
    expect(xml).to include("<copyright-holder>ISO</copyright-holder>")
  end

  it "maps document types correctly" do
    doc_types = {
      "international-standard" => "IS",
      "technical-specification" => "TS",
      "technical-report" => "TR",
      "amendment" => "Amd",
      "guide" => "GUIDE",
    }

    doc_types.each do |input, expected|
      bibdata = mock_bibdata(
        contributor: [mock_contributor],
        ext: mock_ext(doctype: input),
        status: mock_status,
      )
      result = transformer.transform(bibdata)
      xml = result.to_xml
      expect(xml).to include("<doc-type>#{expected}</doc-type>"),
                     "Expected #{input} → #{expected}"
    end
  end

  it "maps release versions from stages" do
    stage_map = {
      "60" => "IS",
      "50" => "FDIS",
      "40" => "DIS",
      "30" => "CD",
      "20" => "WD",
    }

    stage_map.each do |stage, expected|
      bibdata = mock_bibdata(
        contributor: [mock_contributor],
        ext: mock_ext,
        status: mock_status(stage: stage),
      )
      result = transformer.transform(bibdata)
      xml = result.to_xml
      expect(xml).to include("<release-version>#{expected}</release-version>"),
                     "Expected stage #{stage} → #{expected}"
    end
  end

  it "includes release dates" do
    bibdata = mock_bibdata(
      contributor: [mock_contributor],
      date: [mock_date(type: "released", on: "2025-06-01")],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    xml = result.to_xml
    expect(xml).to include("<release-date>")
    expect(xml).to include("2025-06-01")
  end

  it "skips non-released dates" do
    bibdata = mock_bibdata(
      contributor: [mock_contributor],
      date: [mock_date(type: "published", on: "2025-01-01")],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    xml = result.to_xml
    expect(xml).not_to include("<release-date>")
  end

  it "defaults to 'en' language when no language specified" do
    bibdata = mock_bibdata(
      language: nil,
      contributor: [mock_contributor],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    xml = result.to_xml
    expect(xml).to include("<language>en</language>")
  end

  it "handles string language values" do
    bibdata = mock_bibdata(
      language: ["fr"],
      contributor: [mock_contributor],
      ext: mock_ext,
      status: mock_status,
    )
    result = transformer.transform(bibdata)

    xml = result.to_xml
    expect(xml).to include("<language>fr</language>")
  end
end
