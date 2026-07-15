# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::AmendRenderer do
  let(:adapter) { build_adapter }

  it "renders amend description paragraphs with BodyText style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a1" change="modify">
            <description>
              <p>Replace &quot;5 %&quot; with &quot;10 %&quot;.</p>
            </description>
          </amend>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      body_text_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "BodyText"
      end

      expect(body_text_paras.length).to be >= 1,
        "expected at least one BodyText paragraph for amend description"

      text = body_text_paras.flat_map { |p| p.runs.map { |r| r.text || "" }.join }.join
      expect(text).to include("Replace"),
        "amend description text should appear in BodyText paragraph"
    end
  end

  it "renders amend newcontent paragraphs with a3 style" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a2" change="modify">
            <description>
              <p>Replace the first sentence with the following:</p>
            </description>
            <newcontent>
              <p>The marking and labelling on the packaging shall clearly identify the type of rice.</p>
            </newcontent>
          </amend>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      a3_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "a3"
      end

      expect(a3_paras.length).to eq(1),
        "expected exactly one a3 paragraph for amend newcontent, " \
        "got #{a3_paras.length}"

      text = a3_paras.first.runs.map { |r| r.text || "" }.join
      expect(text).to include("marking and labelling"),
        "amend newcontent text should appear in a3 paragraph"
    end
  end

  it "renders description before newcontent" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a3" change="modify">
            <description>
              <p>Instruction text.</p>
            </description>
            <newcontent>
              <p>Replacement text.</p>
            </newcontent>
          </amend>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      body_text_idx = styles.index("BodyText")
      a3_idx = styles.index("a3")

      expect(body_text_idx).to be < a3_idx,
        "description (BodyText) should appear before newcontent (a3)"
    end
  end

  it "renders amend with no newcontent gracefully" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a4" change="modify">
            <description>
              <p>Description only.</p>
            </description>
          </amend>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      a3_paras = pkg.document.body.paragraphs.select do |p|
        p.properties&.style&.value == "a3"
      end

      expect(a3_paras).to be_empty,
        "no newcontent should not produce a3 paragraphs"
    end
  end

  it "renders note inside amend newcontent via NoteRenderer" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a5" change="modify">
            <description>
              <p>Add the following note:</p>
            </description>
            <newcontent>
              <note>
                <p>Note text inside amend newcontent.</p>
              </note>
            </newcontent>
          </amend>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      styles = pkg.document.body.paragraphs.map { |p| p.properties&.style&.value }

      expect(styles).to include("Noteindent"),
        "note inside amend newcontent should be rendered via NoteRenderer, " \
        "got styles: #{styles.inspect}"
    end
  end

  it "leaves amend zone after rendering (no style bleed)" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <amend id="a6" change="modify">
            <description>
              <p>Amend description.</p>
            </description>
            <newcontent>
              <p>Amend newcontent.</p>
            </newcontent>
          </amend>
          <p>Body paragraph after amend.</p>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paragraphs = pkg.document.body.paragraphs
      last_text = paragraphs.last.runs.map { |p| p.text || "" }.join

      expect(last_text).to include("Body paragraph after amend")

      last_style = paragraphs.last.properties&.style&.value
      expect(last_style).not_to eq("a3"),
        "amend newcontent style should not bleed into following body paragraph"
      expect(last_style).not_to eq("BodyText"),
        "amend description style should not bleed into following body paragraph"
    end
  end
end
