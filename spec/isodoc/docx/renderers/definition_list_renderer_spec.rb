# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::DefinitionListRenderer do
  let(:adapter) { build_adapter }

  describe "formula-zone dl rendering (KeyTitle + KeyText)" do
    it "renders dt as KeyTitle and dd as KeyText inside <formula>" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><mo>=</mo><mi>y</mi></math></stem>
              <dl>
                <dt>X</dt>
                <dd>The X coordinate</dd>
                <dt>Y</dt>
                <dd>The Y coordinate</dd>
              </dl>
            </formula>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| p.properties&.style&.value }

        expect(styles).to include("KeyTitle"),
          "expected at least one KeyTitle paragraph, got: #{styles.inspect}"
        expect(styles).to include("KeyText"),
          "expected at least one KeyText paragraph, got: #{styles.inspect}"
      end
    end
  end

  describe "general dl rendering (Definition style)" do
    it "renders both dt and dd as Definition outside formula" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="c1">
            <title>Scope</title>
            <dl>
              <dt>Term1</dt>
              <dd>Definition for term1</dd>
            </dl>
          </clause>
        </sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        body = pkg.document.body
        styles = body.paragraphs.map { |p| p.properties&.style&.value }

        expect(styles).to include("Definition"),
          "expected at least one Definition paragraph, got: #{styles.inspect}"
        expect(styles).not_to include("KeyTitle"),
          "KeyTitle should not appear outside formula zone, got: #{styles.inspect}"
      end
    end
  end
end
