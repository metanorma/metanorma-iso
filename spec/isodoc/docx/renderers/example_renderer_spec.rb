# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::ExampleRenderer do
  let(:adapter) { build_adapter }

  it "runs the EXAMPLE label inline at the head of the first body paragraph" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <fmt-name>EXAMPLE 1</fmt-name>
            <p>This is an example.</p>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs
      example_para = paras.find { |p| para_style_value(p) == "Example" }

      expect(example_para).not_to be_nil,
        "the label-carrying first paragraph should use Example, got: #{paras.map { |p| para_style_value(p) }.inspect}"

      texts = example_para.runs.map { |r| run_text(r) }.join
      expect(texts).to start_with("EXAMPLE"),
        "the EXAMPLE label should run inline in the first body paragraph, got: #{texts.inspect}"
      expect(texts).to include("This is an example."),
        "the example body should continue on the same paragraph, got: #{texts.inspect}"
    end
  end

  it "does not draw Era C boxes around examples" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <fmt-name>EXAMPLE 1</fmt-name>
            <p>This is an example.</p>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }

      expect(styles).not_to include("Box-begin"),
        "examples must not be wrapped in Box-begin (XSL inline-label contract)"
      expect(styles).not_to include("Box-title"),
        "examples must not carry a Box-title paragraph (label runs inline)"
      expect(styles).not_to include("Box-end"),
        "examples must not be wrapped in Box-end"
    end
  end

  it "indents 2nd+ example paragraphs (Exampleindentcontinued)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <fmt-name>EXAMPLE 1</fmt-name>
            <p>First example paragraph.</p>
            <p>Second example paragraph.</p>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| para_style_value(p) }
      example_count = styles.count("Example")
      continued_count = styles.count("Exampleindentcontinued")
      initial_count = styles.count("Exampleindent")

      expect(example_count).to eq(1),
        "label-carrying first paragraph should use Example, got: #{styles.inspect}"
      expect(initial_count).to eq(0),
        "no plain Exampleindent body paragraph should appear in inline mode, got: #{styles.inspect}"
      expect(continued_count).to eq(1),
        "second paragraph should use Exampleindentcontinued, got: #{styles.inspect}"
    end
  end

  it "places the label in its own keep-with-next paragraph in XSL block mode (table inside)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <example id="ex1">
            <fmt-name>EXAMPLE 1</fmt-name>
            <p>Example intro.</p>
            <table id="t1">
              <tbody>
                <tr>
                  <td>cell</td>
                </tr>
              </tbody>
            </table>
          </example>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs
      label_paras = paras.select do |p|
        para_style_value(p) == "Example" &&
          p.runs.map { |r| run_text(r) }.join.strip.start_with?("EXAMPLE")
      end

      expect(label_paras).not_to be_empty,
        "block mode should put the EXAMPLE label in its own paragraph"

      label_para = label_paras.first
      expect(label_para.properties&.keep_next_wrapper).not_to be_nil,
        "block-mode label paragraph should keep with next (XSL example-name-style)"
    end
  end
end
