# frozen_string_literal: true

require_relative "spec_helper"

# Tests NBSP post-processing through the public API
# (Metanorma::Iso::Sts.convert), not by calling the private
# apply_nbsp_to_text method via send(:.
RSpec.describe "NBSP processing via public API" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <bibdata type="standard">
          <title language="en" type="main">Test</title>
          <docidentifier>ISO 9999</docidentifier>
          <language>en</language>
        </bibdata>
        <sections>
          <clause id="c1"><title>Scope</title>
            <p id="p1">See ISO 8601 for details.</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end
  let(:sts) { Metanorma::Iso::Sts.convert(xml) }

  it "inserts NBSP between ISO and digit in text content" do
    nbsp = [0xC2, 0xA0].pack("C*").force_encoding("UTF-8")
    expect(sts).to include("ISO#{nbsp}8601")
  end

  it "does not modify attribute values" do
    expect(sts).to include('id="p1"')
  end
end
