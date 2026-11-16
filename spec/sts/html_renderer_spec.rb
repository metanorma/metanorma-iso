# frozen_string_literal: true

require_relative "spec_helper"

# Exercise the HTML renderer's dispatch table against ISO-STS XML
# fragments. Each example parses a small XML string into the typed model
# (populating element_order) and asserts on the rendered HTML — no doubles,
# no programmatic model construction (which would leave element_order nil).
RSpec.describe Metanorma::Iso::Sts::HtmlRenderer do
  let(:renderer) { described_class::Ruby.new }

  def render(xml, **opts)
    renderer.render(xml, **opts)
  end

  describe "fragment mode (full_document: false)" do
    it "renders an empty <standard> as an empty <main> shell" do
      xml = '<standard dtd-version="1.2" xml:lang="en"/>'
      expect(render(xml, full_document: false).strip).to eq("<main></main>")
    end

    it "renders a body paragraph as <p>" do
      xml = '<standard><body><p>Hello world</p></body></standard>'
      html = render(xml, full_document: false)
      expect(html).to include("<p>Hello world</p>")
    end

    it "renders a section with title as <section><h2>...</h2></section>" do
      xml = <<~XML
        <standard><body>
          <sec id="sec_scope"><title>Scope</title><p>Body</p></sec>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include('<section id="sec_scope">')
      expect(html).to include("<h2")
      expect(html).to include("Scope")
      expect(html).to include('href="#sec_scope"')
    end

    it "renders bullet and ordered lists" do
      xml = <<~XML
        <standard><body>
          <list list-type="bullet">
            <list-item><p>one</p></list-item>
            <list-item><p>two</p></list-item>
          </list>
          <list list-type="order">
            <list-item><p>first</p></list-item>
          </list>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include("<ul>")
      expect(html).to include("<ol>")
      expect(html).to include("<li>")
      expect(html).to include("one")
      expect(html).to include("first")
    end

    it "renders a figure with a graphic" do
      xml = <<~XML
        <standard><body>
          <fig id="fig_1"><graphic xlink:href="image.png"/></fig>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include("image.png")
      expect(html).to include("<img")
    end

    it "renders an ext-link as an anchor" do
      xml = <<~XML
        <standard><body>
          <p>See <ext-link xlink:href="https://example.org">example</ext-link>.</p>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include('<a href="https://example.org">example</a>')
    end

    it "renders an xref as an in-page anchor" do
      xml = <<~XML
        <standard><body>
          <p>See <xref rid="sec_scope">Scope</xref>.</p>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include('href="#sec_scope"')
      expect(html).to include("Scope")
    end

    it "renders inline phrase tags (bold, italic, sub, sup)" do
      xml = <<~XML
        <standard><body>
          <p><bold>important</bold><italic>emphasis</italic><sub>n</sub><sup>2</sup></p>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include("<strong>important</strong>")
      expect(html).to include("<em>emphasis</em>")
      expect(html).to include("<sub>n</sub>")
      expect(html).to include("<sup>2</sup>")
    end

    it "renders a note as a labelled div" do
      xml = <<~XML
        <standard><body>
          <non-normative-note><p>Heads up.</p></non-normative-note>
        </body></standard>
      XML
      html = render(xml, full_document: false)
      expect(html).to include('<div class="note">')
      expect(html).to include('<span class="note-label">NOTE</span>')
      expect(html).to include("Heads up.")
    end
  end

  describe "full document mode (default)" do
    it "wraps the fragment in a branded HTML page" do
      xml = '<standard><body><p>Body content</p></body></standard>'
      html = render(xml)

      expect(html).to start_with("<!DOCTYPE html>")
      expect(html).to include("<html")
      expect(html).to include("</html>")
      expect(html).to include("ISO")
      expect(html).to include("Body content")
    end

    it "uses the iso-meta title-wrap main as the hero title" do
      xml = <<~XML
        <standard>
          <front><iso-meta>
            <title-wrap xml:lang="en"><main>Test Document Title</main></title-wrap>
          </iso-meta></front>
          <body><p>Body</p></body>
        </standard>
      XML
      html = render(xml)
      expect(html).to include("Test Document Title")
      expect(html).to include("hero-title")
    end
  end
end
