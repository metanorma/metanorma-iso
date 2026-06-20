# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"
require "zip"
require "nokogiri"

RSpec.describe "DOCX integration", type: :integration do
  let(:adapter) { build_adapter }
  let(:ns) { { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
               "r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships" } }

  def generate_docx(xml_body)
    xml = minimal_iso_xml(xml_body)
    dir = Dir.mktmpdir
    output_path = File.join(dir, "output.docx")
    adapter.convert(xml, output_path)
    output_path
  end

  def extract_docx_xml(path, entry_name)
    Zip::File.open(path) do |zip|
      entry = zip.find_entry(entry_name)
      return nil unless entry

      Nokogiri::XML(entry.get_input_stream.read)
    end
  end

  # ── Template round-trip ──────────────────────────────────────────

  describe "ISO template round-trip" do
    it "template loads and re-saves successfully" do
      template_path = IsoDoc::Iso::DocxTemplates.template_path(:dis)
      expect(File.exist?(template_path)).to be(true)

      dir = Dir.mktmpdir
      output_path = File.join(dir, "template-rt.docx")
      doc = Uniword::Builder::DocumentBuilder.from_file(template_path)
      doc.save(output_path)
      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0
    end
  end

  # ── DOCX structure ──────────────────────────────────────────────

  describe "generated DOCX structure" do
    it "contains word/document.xml" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test content.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        expect(zip.find_entry("word/document.xml")).not_to be_nil
      end
    end

    it "contains [Content_Types].xml" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        expect(zip.find_entry("[Content_Types].xml")).not_to be_nil
      end
    end

    it "document.xml contains w:body with paragraphs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Test paragraph content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      body = doc.at_xpath("//w:body", ns)
      expect(body).not_to be_nil

      paragraphs = body.xpath("w:p", ns)
      expect(paragraphs.length).to be >= 2 # title + paragraph
    end

    it "headings have correct styleId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      heading = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']]", ns)
      expect(heading).not_to be_nil
    end

    it "bookmark start/end pairs are balanced" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="scope">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      starts = doc.xpath("//w:bookmarkStart", ns)
      ends = doc.xpath("//w:bookmarkEnd", ns)
      expect(starts.length).to eq(ends.length)
    end

    it "section properties have A4 page size" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      pg_sz = doc.at_xpath("//w:pgSz", ns)
      expect(pg_sz).not_to be_nil
      expect(pg_sz["w:w"]).to eq("11906")
      expect(pg_sz["w:h"]).to eq("16838")
    end

    it "bold runs use w:b" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p><strong>Bold text</strong></p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      bold_runs = doc.xpath("//w:rPr/w:b", ns)
      expect(bold_runs.length).to be >= 1
    end

    it "italic runs use w:i" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p><em>Italic text</em></p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      italic_runs = doc.xpath("//w:rPr/w:i", ns)
      expect(italic_runs.length).to be >= 1
    end
  end

  # ── Table structure ─────────────────────────────────────────────

  describe "table structure" do
    it "contains w:tbl with rows and cells" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1</fmt-name>
              <thead>
                <tr><th>H1</th><th>H2</th></tr>
              </thead>
              <tbody>
                <tr><td>C1</td><td>C2</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      tbl = doc.at_xpath("//w:tbl", ns)
      expect(tbl).not_to be_nil
      rows = tbl.xpath("w:tr", ns)
      expect(rows.length).to eq(2)
    end

    it "applies Tableheader style to header cell paragraphs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1</fmt-name>
              <thead>
                <tr><th>Header A</th><th>Header B</th></tr>
              </thead>
              <tbody>
                <tr><td>Body 1</td><td>Body 2</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      header_cell_paras = doc.xpath("//w:tbl//w:tr[1]//w:tc//w:p[w:pPr/w:pStyle[@w:val='Tableheader']]", ns)
      expect(header_cell_paras.length).to be >= 1
    end

    it "applies Tablebody style to body cell paragraphs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1</fmt-name>
              <thead>
                <tr><th>H1</th><th>H2</th></tr>
              </thead>
              <tbody>
                <tr><td>Cell A</td><td>Cell B</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      body_cell_paras = doc.xpath("//w:tbl//w:tr[2]//w:tc//w:p[w:pPr/w:pStyle[@w:val='Tablebody']]", ns)
      expect(body_cell_paras.length).to be >= 1
    end

    it "renders table title with Tabletitle style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1 — Test table</fmt-name>
              <thead>
                <tr><th>H1</th></tr>
              </thead>
              <tbody>
                <tr><td>Cell</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      title_para = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Tabletitle']]", ns)
      expect(title_para).not_to be_nil
    end
  end

  # ── Hyperlink character style ───────────────────────────────────

  describe "hyperlink rendering" do
    it "applies Hyperlink character style to external link runs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Visit <link target="https://example.com">example site</link> now.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")

      hyperlink_el = doc.at_xpath("//w:hyperlink", ns)
      expect(hyperlink_el).not_to be_nil

      styled_run = hyperlink_el.at_xpath(".//w:r[w:rPr/w:rStyle[@w:val='Hyperlink']]", ns)
      expect(styled_run).not_to be_nil
    end

    it "external hyperlink has r:id attribute referencing a relationship" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>See <link target="https://example.com">link</link>.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      hyperlink_el = doc.at_xpath("//w:hyperlink", ns)
      expect(hyperlink_el).not_to be_nil
      rid = hyperlink_el["r:id"]
      expect(rid).not_to be_nil
      expect(rid).to match(/\ArId\d+\z/)
    end
  end

  # ── Header/footer references ────────────────────────────────────

  describe "header and footer references" do
    it "sectPr contains headerReference" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      header_ref = doc.at_xpath("//w:sectPr/w:headerReference", ns)
      expect(header_ref).not_to be_nil
    end

    it "sectPr contains footerReference" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      footer_ref = doc.at_xpath("//w:sectPr/w:footerReference", ns)
      expect(footer_ref).not_to be_nil
    end

    it "header and footer files exist in the package" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        header_entries = zip.entries.select { |e| e.name.match?(%r{word/header\d+\.xml}) }
        footer_entries = zip.entries.select { |e| e.name.match?(%r{word/footer\d+\.xml}) }
        expect(header_entries.length).to be >= 1
        expect(footer_entries.length).to be >= 1
      end
    end

    it "footer contains page number field" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      Zip::File.open(path) do |zip|
        footer_entry = zip.entries.find { |e| e.name.match?(%r{word/footer\d+\.xml}) }
        expect(footer_entry).not_to be_nil

        footer_doc = Nokogiri::XML(footer_entry.get_input_stream.read)
        fld_char = footer_doc.at_xpath("//w:fldChar|//w:fldSimple|//w:instrText",
                                       "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        expect(fld_char).not_to be_nil
      end
    end

    it "headerReference has valid r:id format" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Content.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      header_ref = doc.at_xpath("//w:sectPr/w:headerReference", ns)
      expect(header_ref).not_to be_nil
      rid = header_ref["r:id"]
      expect(rid).to match(/\ArId\d+\z/)
    end
  end

  # ── List numbering ──────────────────────────────────────────────

  describe "list numbering" do
    it "unordered list paragraphs have dash_list numId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <ul>
              <li><p>Item 1</p></li>
              <li><p>Item 2</p></li>
            </ul>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      num_ids = doc.xpath("//w:numPr/w:numId/@w:val", ns).map(&:to_s)
      expect(num_ids.length).to be >= 2
      expect(num_ids.uniq).to include("3")
    end

    it "ordered arabic list uses decimal numId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <ol type="arabic">
              <li><p>Step 1</p></li>
              <li><p>Step 2</p></li>
            </ol>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      num_ids = doc.xpath("//w:numPr/w:numId/@w:val", ns).map(&:to_s)
      expect(num_ids.uniq).to include("1")
    end

    it "ordered alpha list uses decimal numId" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <ol type="alpha">
              <li><p>Item a</p></li>
              <li><p>Item b</p></li>
            </ol>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      num_ids = doc.xpath("//w:numPr/w:numId/@w:val", ns).map(&:to_s)
      expect(num_ids.uniq).to include("1")
    end
  end

  # ── Paragraph styles by element type ────────────────────────────

  describe "paragraph style assignment" do
    it "foreword title uses ForewordTitle style" do
      path = generate_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Foreword text.</p>
          </foreword>
        </preface>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      foreword_title = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='ForewordTitle']]", ns)
      expect(foreword_title).not_to be_nil
    end

    it "foreword body uses ForewordText style" do
      path = generate_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>This is the foreword body text.</p>
          </foreword>
        </preface>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      foreword_body = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='ForewordText']]", ns)
      expect(foreword_body).not_to be_nil
    end

    it "introduction title uses IntroTitle style" do
      path = generate_docx(<<~INNER)
        <preface>
          <introduction id="intro">
            <fmt-title>Introduction</fmt-title>
            <p>Intro text.</p>
          </introduction>
        </preface>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      intro_title = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='IntroTitle']]", ns)
      expect(intro_title).not_to be_nil
    end

    it "note uses Era C Box wrappers with Noteindent body" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <note id="n1"><p>This is a note.</p></note>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      box_begin = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Box-begin']]", ns)
      noteindent = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Noteindent']]", ns)
      box_end = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Box-end']]", ns)
      expect(box_begin).not_to be_nil
      expect(noteindent).not_to be_nil
      expect(box_end).not_to be_nil
    end

    it "example uses Era C Box wrappers with Exampleindent body" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <example id="e1"><p>This is an example.</p></example>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      box_begin = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Box-begin']]", ns)
      exampleindent = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Exampleindent']]", ns)
      box_end = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Box-end']]", ns)
      expect(box_begin).not_to be_nil
      expect(exampleindent).not_to be_nil
      expect(box_end).not_to be_nil
    end

    it "body paragraphs use Normal style (no explicit pStyle)" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>This is body text.</p>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      # Body text paragraphs have no pStyle (or pStyle with nil val)
      body_para = doc.at_xpath("//w:p[not(w:pPr/w:pStyle[@w:val])]", ns)
      expect(body_para).not_to be_nil
    end

    it "annex title uses ANNEX style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope.</p>
          </clause>
        </sections>
        <annex id="a1">
          <fmt-title>Annex A (informative)</fmt-title>
          <p>Annex content.</p>
        </annex>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      annex_title = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='ANNEX']]", ns)
      expect(annex_title).not_to be_nil
    end

    it "sourcecode uses Code style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <sourcecode id="sc1">puts "hello"</sourcecode>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      code_para = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Code']]", ns)
      expect(code_para).not_to be_nil
    end

    it "quote uses Disp-quotep style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <quote id="q1"><p>Quoted text here.</p></quote>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      quote_para = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Disp-quotep']]", ns)
      expect(quote_para).not_to be_nil
    end

    it "term name uses TermNum style" do
      path = generate_docx(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>adapter</name></expression></preferred>
              <fmt-name>3.1</fmt-name>
              <definition><verbal-definition><p>A component that converts data.</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      term_num_para = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='TermNum']]", ns)
      expect(term_num_para).not_to be_nil
    end

    it "formula description paragraphs use Formuladescription style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi><mo>=</mo><mi>m</mi><msup><mi>c</mi><mn>2</mn></msup></math></stem>
              <p>where E is energy, m is mass, and c is the speed of light.</p>
            </formula>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      desc_para = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Formuladescription']]", ns)
      expect(desc_para).not_to be_nil,
        "paragraph inside <formula> should use Formuladescription style"
    end
  end

  # ── Context-aware style resolution ──────────────────────────────

  describe "context-aware style resolution" do
    it "normative references section title uses BiblioTitle style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Ref.</p>
          </clause>
        </sections>
        <bibliography>
          <references id="bib-norm" normative="true">
            <fmt-title>Normative references</fmt-title>
            <bibitem id="ISO712" anchor="ISO712">
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      ref_title = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='BiblioTitle']]", ns)
      expect(ref_title).not_to be_nil
    end

    it "informative bibliography uses BiblioEntry style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Ref.</p>
          </clause>
        </sections>
        <bibliography>
          <references id="bib-inform" normative="false">
            <fmt-title>Bibliography</fmt-title>
            <bibitem id="ISO9001" anchor="ISO9001">
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">9001</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      bib_entry = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='BiblioEntry']]", ns)
      expect(bib_entry).not_to be_nil
    end

    it "bibliography spans render as plain text runs" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Ref.</p>
          </clause>
        </sections>
        <bibliography>
          <references id="bib-norm" normative="true">
            <fmt-title>Normative references</fmt-title>
            <bibitem id="ISO712" anchor="ISO712">
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">712</span>:<span class="stdyear">2009</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      all_text = doc.xpath("//w:t", ns).map(&:text).join
      expect(all_text).to include("ISO")
      expect(all_text).to include("712")
      expect(all_text).to include("2009")
    end
  end

  # ── Heading levels ──────────────────────────────────────────────

  describe "heading level assignment" do
    it "nested clauses use Heading1 through Heading3" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Level 1</fmt-title>
            <p>L1 content.</p>
            <clause id="s1-1">
              <fmt-title>Level 2</fmt-title>
              <p>L2 content.</p>
              <clause id="s1-1-1">
                <fmt-title>Level 3</fmt-title>
                <p>L3 content.</p>
              </clause>
            </clause>
          </clause>
        </sections>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      h1 = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']]", ns)
      h2 = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading2']]", ns)
      h3 = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading3']]", ns)
      expect(h1).not_to be_nil
      expect(h2).not_to be_nil
      expect(h3).not_to be_nil
    end

    it "annex sub-clauses use a2 style" do
      path = generate_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope.</p>
          </clause>
        </sections>
        <annex id="a1">
          <fmt-title>Annex A (informative)</fmt-title>
          <p>Annex intro.</p>
          <clause id="a1-1">
            <fmt-title>A.1 Sub-clause</fmt-title>
            <p>Sub-clause content.</p>
          </clause>
        </annex>
      INNER

      doc = extract_docx_xml(path, "word/document.xml")
      annex_h2 = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='a2']]", ns)
      expect(annex_h2).not_to be_nil
    end
  end

  # ── Full document conversion ────────────────────────────────────

  describe "full document conversion" do
    it "converts a document with all major elements" do
      xml_body = <<~INNER
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>This is the foreword with <em>italic</em> and <strong>bold</strong> text.</p>
          </foreword>
          <introduction id="intro">
            <fmt-title>Introduction</fmt-title>
            <p>Introduction paragraph.</p>
          </introduction>
        </preface>
        <sections>
          <clause id="scope">
            <fmt-title>Scope</fmt-title>
            <p>This International Standard defines requirements.</p>
            <clause id="scope-general">
              <fmt-title>General</fmt-title>
              <p>General scope text.</p>
            </clause>
          </clause>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>quality</name></expression></preferred>
              <definition><verbal-definition><p>Degree of excellence.</p></verbal-definition></definition>
              <termnote id="tn1"><p>Quality is subjective.</p></termnote>
            </term>
          </terms>
        </sections>
        <annex id="annex-a">
          <fmt-title>Annex A (informative)</fmt-title>
          <p>Additional information.</p>
          <table id="t1">
            <fmt-name>Table A.1</fmt-name>
            <thead>
              <tr><th>Column 1</th><th>Column 2</th></tr>
            </thead>
            <tbody>
              <tr><td>Value 1</td><td>Value 2</td></tr>
            </tbody>
          </table>
        </annex>
        <bibliography id="bib">
          <fmt-title>Bibliography</fmt-title>
          <p>[1] ISO 9001, Quality management systems.</p>
        </bibliography>
      INNER

      path = generate_docx(xml_body)
      expect(File.exist?(path)).to be(true)
      expect(File.size(path)).to be > 0

      doc = extract_docx_xml(path, "word/document.xml")
      expect(doc).not_to be_nil
    end
  end

  # ── convert_model ───────────────────────────────────────────────

  describe "convert_model" do
    it "produces valid DOCX from a pre-parsed model" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Model conversion test.</p>
          </foreword>
        </preface>
      INNER

      model = parse_iso_document(xml)
      dir = Dir.mktmpdir
      output_path = File.join(dir, "model.docx")
      adapter.convert_model(model, output_path)

      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0

      doc = extract_docx_xml(output_path, "word/document.xml")
      expect(doc).not_to be_nil
    end
  end

  # ── Real-world XML from mn-samples-iso ─────────────────────────

  describe "real-world document conversion" do
    let(:guide_xml_path) do
      File.expand_path("../../../../mn-samples-iso/site/documents/guide/document.xml",
                        __dir__)
    end

    before do
      skip "mn-samples-iso guide XML not available" unless File.exist?(guide_xml_path)
    end

    it "converts mn-samples-iso guide document to valid DOCX" do
      xml = File.read(guide_xml_path, encoding: "utf-8")
      dir = Dir.mktmpdir
      output_path = File.join(dir, "guide.docx")
      adapter.convert(xml, output_path)

      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 20_000

      doc = extract_docx_xml(output_path, "word/document.xml")
      expect(doc).not_to be_nil

      paragraphs = doc.xpath("//w:p", ns)
      expect(paragraphs.length).to be >= 35

      headings = doc.xpath("//w:p[w:pPr/w:pStyle[contains(@w:val, 'Heading')]]", ns)
      expect(headings.length).to be >= 5
    end
  end
end
