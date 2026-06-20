# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::AdmonitionRenderer do
  let(:adapter) { build_adapter }

  it "renders warning admonition with Warningtext style inside Box wrappers" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <admonition id="w1" type="warning">
            <p>Do not operate without guard.</p>
          </admonition>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Box-begin"),
        "Box-begin should wrap admonition, got: #{styles.inspect}"
      expect(styles).to include("Warningtext"),
        "admonition body should use Warningtext, got: #{styles.inspect}"
      expect(styles).to include("Box-end"),
        "Box-end should close admonition, got: #{styles.inspect}"
    end
  end
end
