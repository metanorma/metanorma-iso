# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::ColophonRenderer do
  let(:adapter) { build_adapter }

  it "walks colophon clauses through the dispatcher" do
    xml = minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      <colophon id="colo">
        <clause id="colo-1">
          <title>Colophon</title>
          <p>Set in Times New Roman.</p>
        </clause>
      </colophon>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      body_text = pkg.document.body.paragraphs.flat_map do |p|
        p.runs.map { |r| r.text.to_s }
      end.join

      expect(body_text).to include("Set in Times New Roman."),
        "colophon clause body should render via walker"
    end
  end

  it "renders gracefully when colophon has no clauses" do
    xml = minimal_iso_xml(<<~INNER)
      <sections><clause id="c1"><title>Scope</title><p>Body.</p></clause></sections>
      <colophon id="colo-empty"></colophon>
    INNER

    expect do
      convert_and_extract(adapter, xml) { |_| }
    end.not_to raise_error
  end
end
