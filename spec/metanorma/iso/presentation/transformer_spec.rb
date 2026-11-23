# frozen_string_literal: true

require "rspec"
require "metanorma/iso/presentation/transformer"
require "metanorma/ladl"
require "metanorma/ladl/document_adapter"
require_relative "native_fixture"

RSpec.describe Metanorma::Iso::Presentation::Transformer do
  include NativeIsoFixture

  def transform(root = native_iso_fixture, labeler: native_labeler)
    described_class.new.call(root, flavor: :iso, options: { document_labeler: labeler })
  end

  it "transforms semantic rich titles and target references through real LADL and native ISO HTML" do
    semantic = native_iso_fixture
    original = Marshal.dump(semantic)
    result = transform(semantic)
    expect(result).to be_instance_of(Metanorma::Iso::Document::Root)
    expect(result.type).to eq("presentation")
    expect(Marshal.dump(semantic)).to eq(original)
    expect(semantic.sections.clause.first.fmt_title).to be_nil
    expect(result.sections.clause.first.title.em.first.text).to eq(["rich"])
    expect(result.sections.clause.first.fmt_title.span.last.em.first.text).to eq(["rich"])
    renderer = Metanorma::Core::Flavors.renderer_for(result, format: :html, flavor: :iso)
    expect(renderer).to eq(Metanorma::Iso::Html::Renderer)
    html = renderer.new.generate_body(result)
    expect(html).to include("A <em>rich</em> title", "Retained body.", 'href="#method"', "Clause 2", "the procedure")
    expect(html.scan('href="#method"').length).to eq(2)
    expect(html.index("rich")).to be < html.index("Retained body.")
    expect(result.sections.clause.map(&:displayorder)).to eq([1, 2])
    expect(result.bibdata.doc_identifier.first.value).to eq("ISO 99999:2026")
    expect(result.bibdata.titles.items.first.value).to eq("Native ISO presentation")
  end

  it "preserves authored identifiers and generates repeatable missing identifiers" do
    first = transform
    second = transform
    expect(first.sections.clause.map(&:id)).to eq(%w[scope method])
    expect(first.sections.clause.first.paragraphs.first.id).to start_with("_native_")
    expect(Marshal.dump(first)).to eq(Marshal.dump(second))
  end

  it "is idempotent without duplicate rendered references or semantic input mutation" do
    first = transform
    second = transform(first)
    renderer = Metanorma::Iso::Html::Renderer.new
    expect(renderer.generate_body(second)).to eq(renderer.generate_body(first))
    expect(second.sections.clause.first.paragraphs.first.semx.length).to eq(2)
  end

  it "requires the actual labeler and labelled sections instead of supplying counters" do
    expect { described_class.new.call(native_iso_fixture, flavor: :iso, options: {}) }
      .to raise_error(ArgumentError, /document_labeler/)
    expect { transform(labeler: ->(root, **) { root }) }
      .to raise_error(described_class::UnsupportedContent, /LADL label missing/)
  end

  it "rejects duplicate IDs before invoking the labeler" do
    root = native_iso_fixture
    root.sections.clause.last.id = "scope"
    expect { transform(root) }.to raise_error(ArgumentError, /Duplicate ISO content id scope/)
  end

  it "rejects labeler replacement of the typed root" do
    expect { transform(labeler: ->(_root, **) { native_iso_fixture }) }
      .to raise_error(ArgumentError, /must return its supplied ISO Root/)
  end

  it "fails explicitly on unsupported math rather than marking it presented" do
    root = native_iso_fixture
    root.sections.clause.first.paragraphs.first.stem = [inline::StemInlineElement.new]
    expect { transform(root) }.to raise_error(described_class::UnsupportedContent, /stem/)
    expect(root.type).to eq("semantic")
  end

  it "formats real table captions and annex headings from the shared profile" do
    root = native_iso_fixture
    clause = root.sections.clause.last
    table = Metanorma::Document::Components::Tables::TableBlock.new(id: "measurements",
      name: inline::NameWithIdElement.new(text: ["Measurements"]))
    clause.tables = [table]
    clause.element_order << Lutaml::Xml::Element.new("Element", "table")
    annex_class = Metanorma::Iso::Document::Sections::IsoAnnexSection
    annex = annex_class.new(id: "annex", title: inline::TitleWithAnnotationElement.new(text: ["Worked example"]))
    ordered(annex, "title")
    root.annex = [annex]
    result = transform(root)
    rendered_table = result.sections.clause.last.tables.first
    expect(rendered_table.fmt_name.span.first.text).to eq(["Table 1 "])
    expect(rendered_table.fmt_name.span.last.text).to eq(["Measurements"])
    expect(result.annex.first.fmt_title.span.first.text).to eq(["Annex A "])
    html = Metanorma::Iso::Html::Renderer.new.generate_body(result)
    expect(html).to include("Table 1", "Measurements", "Annex A", "Worked example")
  end

  it "preserves rich authored section and paragraph interleaving" do
    root = native_iso_fixture
    body = root.sections.clause.last
    sub = Metanorma::Iso::Document::Sections::IsoClauseSection.new(id: "nested",
      title: inline::TitleWithAnnotationElement.new(text: ["Nested"]),
      paragraphs: [Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: ["Inside."])])
    ordered(sub, "title", "p")
    body.clause = [sub]
    body.paragraphs << Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: ["After nested."])
    ordered(body, "title", "p", "clause", "p")
    result = transform(root)
    html = Metanorma::Iso::Html::Renderer.new.generate_body(result)
    expect(html.index("Retained body.")).to be < html.index("Inside.")
    expect(html.index("Inside.")).to be < html.index("After nested.")
    expect(result.sections.clause.last.clause.first.fmt_title.span.first.text).to eq(["2.1 "])
  end

  it "projects the shared profile's label direction without changing rich authored content" do
    path = File.join(Gem::Specification.find_by_name("metanorma-ladl").full_gem_path, "ladl/iso-iec.yaml")
    data = YAML.safe_load(File.read(path))
    data.fetch("instances").select { |row| row["type"] == "LabelTemplate" }
      .each { |row| row.fetch("properties")["direction"] = "rtl" }
    profile = Metanorma::Ladl::Profile.from_yaml(YAML.safe_dump(data))
    result = transform(labeler: native_labeler(profile: profile))
    heading = result.sections.clause.first.fmt_title
    expect(heading.span.first.style).to eq("direction: rtl; unicode-bidi: isolate")
    expect(heading.span.last.em.first.text).to eq(["rich"])
    html = Metanorma::Iso::Html::Renderer.new.generate_body(result)
    expect(html).to include('style="direction: rtl; unicode-bidi: isolate"', "A <em>rich</em> title")
  end

  it "does not invoke XML serialization or parsing in the native stage" do
    events = []
    trace = TracePoint.new(:call) do |event|
      events << [event.defined_class, event.method_id] if %i[to_xml from_xml].include?(event.method_id)
    end
    trace.enable { transform }
    expect(events).to be_empty
  end
end
