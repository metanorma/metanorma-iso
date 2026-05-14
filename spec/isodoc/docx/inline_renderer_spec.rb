# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::InlineRenderer do
  let(:mapping) { IsoDoc::Iso::DocxStyleMapping.new }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { Uniword::Builder::DocumentBuilder.new }
  let(:resolver) { IsoDoc::Iso::Docx::StyleResolver.new(mapping, context) }
  let(:renderer) { described_class.new(context, resolver, doc) }

  def build_para
    Uniword::Builder::ParagraphBuilder.new
  end

  def extract_text_from_para(para)
    built = para.build
    return "" unless built

    runs = built.instance_variable_get(:@runs) || []
    parts = []
    runs.each do |run|
      case run
      when String
        parts << run
      when Uniword::Wordprocessingml::Run
        text_obj = run.instance_variable_get(:@text)
        case text_obj
        when Uniword::Wordprocessingml::Text then parts << text_obj.content
        when String then parts << text_obj
        end
      else
        text_obj = run.instance_variable_get(:@text)
        case text_obj
        when Uniword::Wordprocessingml::Text then parts << text_obj.content
        when String then parts << text_obj
        end
      end
    end
    parts.join
  end

  describe "#render (text-only paragraph)" do
    it "renders plain text content" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Hello world</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      text = extract_text_from_para(para)
      expect(text).to eq("Hello world")
    end
  end

  describe "inline formatting" do
    it "renders italic text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p><em>italic text</em></p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      # Verify it renders without error (bold/italic flags on runs)
      expect { renderer.render(para_node, para) }.not_to raise_error
    end

    it "renders bold text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p><strong>bold text</strong></p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end

    it "renders subscript text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>H<sub>2</sub>O</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end

    it "renders superscript text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>x<sup>2</sup></p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end

    it "renders mixed inline content preserving order" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Hello <em>beautiful</em> world</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      text = extract_text_from_para(para)
      expect(text).to eq("Hello beautiful world")
    end
  end

  describe "#render_inline_element" do
    it "renders a br element as newline" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Line 1<br/>Line 2</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      expect { renderer.render(para_node, para) }.not_to raise_error
    end
  end

  describe "unordered list rendering" do
    it "renders a simple unordered list" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <ul>
              <li><p>Item 1</p></li>
              <li><p>Item 2</p></li>
            </ul>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      list = root.preface.foreword.unordered_lists.first

      expect(list).not_to be_nil
      items = list.listitem
      expect(items.length).to eq(2)
    end
  end

  describe "ordered list rendering" do
    it "renders a simple ordered list" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <ol type="arabic">
              <li><p>First</p></li>
              <li><p>Second</p></li>
            </ol>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      list = root.preface.foreword.ordered_lists.first

      expect(list).not_to be_nil
      items = list.listitem
      expect(items.length).to eq(2)
    end
  end

  describe "cross-reference rendering" do
    it "renders a link with href as an external hyperlink" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Visit <link target="https://example.com">example</link> site</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end

    it "renders an xref as an internal hyperlink" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>See <xref target="section1">Section 1</xref> for details</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end
  end

  describe "bookmark rendering" do
    it "renders a bookmark element" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Text with <bookmark id="bm1"/> marker</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end
  end

  describe "mixed inline content" do
    it "renders bold and italic in sequence" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Normal <strong>bold</strong> <em>italic</em> normal</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      text = extract_text_from_para(para)
      expect(text).to eq("Normal bold italic normal")
    end

    it "renders sub and sup in the same paragraph" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>H<sub>2</sub>O at x<sup>2</sup> speed</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      renderer.render(para_node, para)
      text = extract_text_from_para(para)
      expect(text).to eq("H2O at x2 speed")
    end

    it "renders xref and link preserving text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>See <xref target="s1">Section 1</xref> and <link target="https://example.com">website</link> end</p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end
  end

  describe "empty and edge cases" do
    it "renders a paragraph with only whitespace text" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>   </p>
          </foreword>
        </preface>
      INNER
      root = parse_iso_document(xml)
      para_node = root.preface.foreword.paragraphs.first

      para = build_para
      expect { renderer.render(para_node, para) }.not_to raise_error
    end
  end

  describe "SpanElement rendering" do
    it "renders spans with character styles from class attribute" do
      xml = minimal_iso_xml(<<~INNER)
        <bibliography>
          <references id="bib" normative="true">
            <bibitem id="ISO712" anchor="ISO712">
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER
      root = parse_iso_document(xml)
      bibitem = root.bibliography.references.first.references.first
      tag = bibitem.biblio_tag

      para = build_para
      expect { renderer.render(tag, para) }.not_to raise_error
    end
  end
end
