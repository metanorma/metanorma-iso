# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ExampleRenderer do
  let(:adapter) { build_adapter }

  it "renders example body inside Box wrappers with Exampleindent style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <p>This is an example.</p>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Box-begin"),
        "Box-begin should wrap example, got: #{styles.inspect}"
      expect(styles).to include("Exampleindent"),
        "example body should use Exampleindent, got: #{styles.inspect}"
      expect(styles).to include("Box-end"),
        "Box-end should close example, got: #{styles.inspect}"
    end
  end

  it "preserves in-example zone for nested children" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <p>First example paragraph.</p>
            <p>Second example paragraph.</p>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }
      example_count = styles.count("Exampleindent")
      continued_count = styles.count("Exampleindentcontinued")
      expect(example_count).to eq(1),
        "first paragraph should use Exampleindent, got: #{styles.inspect}"
      expect(continued_count).to eq(1),
        "second paragraph should use Exampleindentcontinued, got: #{styles.inspect}"
    end
  end
end
