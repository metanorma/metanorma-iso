# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

RSpec.describe IsoDoc::Iso::Docx::Adapter do
  let(:adapter) { build_adapter }

  def expect_valid_docx(xml_body)
    xml = minimal_iso_xml(xml_body)
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "output.docx")
      adapter.convert(xml, output_path)
      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0
      output_path
    end
  end

  describe "#convert" do
    it "converts a minimal ISO document to DOCX" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>This is the foreword.</p>
          </foreword>
        </preface>
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>This is the scope.</p>
          </clause>
        </sections>
      INNER
    end

    it "handles an empty document gracefully" do
      expect_valid_docx("")
    end

    # ── Inline formatting ────────────────────────────────────────────

    it "converts inline formatting" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Normal <em>italic</em> <strong>bold</strong> text.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
    end

    it "converts subscript and superscript" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>H<sub>2</sub>O and x<sup>2</sup></p>
          </foreword>
        </preface>
        <sections/>
      INNER
    end

    it "converts cross-references and links" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="scope">
            <fmt-title>Scope</fmt-title>
            <p>See <xref target="annex1">Annex A</xref> for details.</p>
          </clause>
        </sections>
        <annex id="annex1">
          <fmt-title>Annex A</fmt-title>
          <p>Annex content with <link target="https://example.com">link</link>.</p>
        </annex>
      INNER
    end

    # ── Block elements ────────────────────────────────────────────────

    it "converts a table" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <fmt-name>Table 1</fmt-name>
              <thead>
                <tr><th>Header 1</th><th>Header 2</th></tr>
              </thead>
              <tbody>
                <tr><td>Cell 1</td><td>Cell 2</td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER
    end

    it "converts unordered lists" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <ul>
              <li><p>Item A</p></li>
              <li><p>Item B</p></li>
            </ul>
          </clause>
        </sections>
      INNER
    end

    it "converts ordered lists" do
      expect_valid_docx(<<~INNER)
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
    end

    it "converts definition lists" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <dl>
              <dt>Term A</dt>
              <dd><p>Definition of A.</p></dd>
              <dt>Term B</dt>
              <dd><p>Definition of B.</p></dd>
            </dl>
          </clause>
        </sections>
      INNER
    end

    it "converts notes and examples" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <note id="n1"><p>This is a note.</p></note>
            <example id="e1"><p>This is an example.</p></example>
          </clause>
        </sections>
      INNER
    end

    it "converts sourcecode blocks" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <sourcecode id="sc1">puts "hello"</sourcecode>
          </clause>
        </sections>
      INNER
    end

    it "converts formulas" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi><mo>=</mo><mi>m</mi><msup><mi>c</mi><mn>2</mn></msup></math></stem>
            </formula>
          </clause>
        </sections>
      INNER
    end

    it "converts quote blocks" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <quote id="q1"><p>Quoted text here.</p></quote>
          </clause>
        </sections>
      INNER
    end

    it "converts admonitions" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <admonition id="ad1"><p>Warning: danger ahead.</p></admonition>
          </clause>
        </sections>
      INNER
    end

    # ── Section structure ─────────────────────────────────────────────

    it "converts deeply nested clauses" do
      expect_valid_docx(<<~INNER)
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
    end

    it "converts a document with introduction" do
      expect_valid_docx(<<~INNER)
        <preface>
          <introduction id="intro">
            <fmt-title>Introduction</fmt-title>
            <p>Introduction paragraph.</p>
          </introduction>
        </preface>
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope content.</p>
          </clause>
        </sections>
      INNER
    end

    # ── Annex handling ────────────────────────────────────────────────

    it "converts a single annex" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope content.</p>
          </clause>
        </sections>
        <annex id="a1">
          <fmt-title>Annex A (informative)</fmt-title>
          <p>Annex content.</p>
        </annex>
      INNER
    end

    it "converts an annex with sub-clauses" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope text.</p>
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
    end

    it "converts multiple annexes" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope.</p>
          </clause>
        </sections>
        <annex id="a1">
          <fmt-title>Annex A</fmt-title>
          <p>Annex A content.</p>
        </annex>
        <annex id="a2">
          <fmt-title>Annex B</fmt-title>
          <p>Annex B content.</p>
        </annex>
      INNER
    end

    # ── Terms and definitions ─────────────────────────────────────────

    it "converts a terms section with terms" do
      expect_valid_docx(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>adapter</name></expression></preferred>
              <definition><verbal-definition><p>A component that converts data.</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      INNER
    end

    it "converts a term with notes and examples" do
      expect_valid_docx(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>converter</name></expression></preferred>
              <definition><verbal-definition><p>A tool that transforms input.</p></verbal-definition></definition>
              <termnote id="tn1"><p>Converters may be lossy.</p></termnote>
              <termexample id="te1"><p>HTML to DOCX is a conversion.</p></termexample>
            </term>
          </terms>
        </sections>
      INNER
    end

    it "converts a term with admitted and deprecated terms" do
      expect_valid_docx(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <preferred><expression><name>document</name></expression></preferred>
              <admitted><expression><name>record</name></expression></admitted>
              <deprecates><expression><name>file</name></expression></deprecates>
              <definition><verbal-definition><p>Information and its medium.</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      INNER
    end

    # ── Bibliography ──────────────────────────────────────────────────

    it "converts bibliography with title and paragraphs" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Foreword text.</p>
          </foreword>
        </preface>
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope content.</p>
          </clause>
        </sections>
        <bibliography id="bib">
          <fmt-title>Bibliography</fmt-title>
          <p>[1] ISO 9001, Quality management.</p>
        </bibliography>
      INNER
    end

    it "converts bibliography with references sub-sections" do
      expect_valid_docx(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope content.</p>
          </clause>
        </sections>
        <bibliography id="bib">
          <fmt-title>Bibliography</fmt-title>
          <references id="bib-norm" normative="true">
            <fmt-title>Normative references</fmt-title>
            <p>[1] ISO 9001</p>
          </references>
          <references id="bib-inform" normative="false">
            <p>[2] ISO 14001</p>
          </references>
        </bibliography>
      INNER
    end

    # ── Full document ─────────────────────────────────────────────────

    it "converts a full document with all major elements" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Foreword with <em>italic</em> and <strong>bold</strong> text.</p>
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
    end
  end

  describe "#convert_model" do
    it "converts a pre-parsed model to DOCX" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Pre-parsed model test.</p>
          </foreword>
        </preface>
      INNER

      model = parse_iso_document(xml)

      Dir.mktmpdir do |dir|
        output_path = File.join(dir, "output.docx")
        adapter.convert_model(model, output_path)
        expect(File.exist?(output_path)).to be(true)
        expect(File.size(output_path)).to be > 0
      end
    end
  end

  describe "numbering" do
    it "resolves numIds from template numbering definitions" do
      mapping = adapter.resolver
      expect(mapping.numbering_id(:dash_list)).to eq(3)
      expect(mapping.numbering_id(:decimal_list)).to eq(1)
      expect(mapping.numbering_id(:body_clause)).to eq(4)
    end
  end

  describe "parse_dimension" do
    let(:utils) do
      obj = Object.new
      obj.extend(IsoDoc::Iso::Docx::ModelUtils)
      obj
    end

    it "converts CSS units to EMU/twips" do
      expect(utils.parse_dimension("10pt")).to eq(200)
      expect(utils.parse_dimension("100px")).to eq(952_500)
      expect(utils.parse_dimension("1in")).to eq(914_400)
    end

    it "returns nil for nil input" do
      expect(utils.parse_dimension(nil)).to be_nil
    end
  end

  describe "bibliography rendering with character styles" do
    def extract_docx(path)
      require "zip"
      Zip::File.open(path) do |zip|
        doc = Nokogiri::XML(zip.find_entry("word/document.xml").get_input_stream.read)
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        yield doc, ns
      end
    end

    it "renders biblio-tag spans as plain text runs" do
      xml = minimal_iso_xml(<<~INNER)
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

      Dir.mktmpdir do |dir|
        path = File.join(dir, "bib.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          ref_paras = doc.xpath("//w:p", ns).select { |p| p.xpath(".//w:t", ns).text.include?("ISO 712") }
          expect(ref_paras.length).to be >= 1
        end
      end
    end

    it "renders informative bibliography with BiblioEntry style" do
      xml = minimal_iso_xml(<<~INNER)
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
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">9001</span>:<span class="stdyear">2015</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "bib.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          bib_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='BiblioEntry']]", ns)
          expect(bib_paras.length).to be >= 1
        end
      end
    end

    it "renders biblio-tag with part number as text" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Ref.</p>
          </clause>
        </sections>
        <bibliography>
          <references id="bib-norm" normative="true">
            <fmt-title>Normative references</fmt-title>
            <bibitem id="ISO8351-1" anchor="ISO8351-1">
              <biblio-tag><span class="stdpublisher">ISO </span><span class="stddocNumber">8351</span>-<span class="stddocPartNumber">1</span>:<span class="stdyear">1994</span></biblio-tag>
            </bibitem>
          </references>
        </bibliography>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "bib.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("ISO 8351-1:1994")
        end
      end
    end
  end

  describe "semantic XML term rendering" do
    def extract_docx(path)
      require "zip"
      Zip::File.open(path) do |zip|
        doc = Nokogiri::XML(zip.find_entry("word/document.xml").get_input_stream.read)
        ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
        yield doc, ns
      end
    end

    it "renders terms with synthesized term numbers" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1" type="scope">
            <title>Scope</title>
            <p>Scope text.</p>
          </clause>
          <terms id="terms">
            <title>Terms and definitions</title>
            <term id="t1" anchor="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <definition><verbal-definition><p>Rice with husk.</p></verbal-definition></definition>
            </term>
            <term id="t2" anchor="husked_rice">
              <preferred><expression><name>husked rice</name></expression></preferred>
              <definition><verbal-definition><p>Rice without husk.</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
        <bibliography>
          <references id="bib-norm" normative="true">
            <title>Normative references</title>
            <p>The following documents are referred to.</p>
          </references>
        </bibliography>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "terms.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          term_nums = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='TermNum']]", ns)
          expect(term_nums.length).to be >= 2
          expect(term_nums[0].xpath("w:r/w:t", ns).text).to eq("3.1")
          expect(term_nums[1].xpath("w:r/w:t", ns).text).to eq("3.2")

          terms = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Terms']]", ns)
          expect(terms.length).to be >= 2
          expect(terms[0].xpath("w:r/w:t", ns).text).to include("paddy")
          expect(terms[1].xpath("w:r/w:t", ns).text).to include("husked rice")
        end
      end
    end

    it "renders term with admitted and deprecated names" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <terms id="terms">
            <title>Terms and definitions</title>
            <term id="t1" anchor="doc">
              <preferred><expression><name>document</name></expression></preferred>
              <admitted><expression><name>record</name></expression></admitted>
              <deprecates><expression><name>file</name></expression></deprecates>
              <definition><verbal-definition><p>Information and its medium.</p></verbal-definition></definition>
            </term>
          </terms>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "terms.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          alt_terms = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='AltTerms']]", ns)
          expect(alt_terms.length).to be >= 1
          expect(alt_terms.first.xpath("w:r/w:t", ns).text).to include("record")

          dep_terms = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='DeprecatedTerms']]", ns)
          expect(dep_terms.length).to be >= 1
        end
      end
    end

    it "renders term source with origin and localities" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <terms id="terms">
            <title>Terms and definitions</title>
            <term id="t1" anchor="paddy">
              <preferred><expression><name>paddy</name></expression></preferred>
              <definition><verbal-definition><p>Rice with husk.</p></verbal-definition></definition>
              <source type="authoritative" status="identical">
                <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                  <localityStack>
                    <locality type="clause">
                      <referenceFrom>3.1</referenceFrom>
                    </locality>
                  </localityStack>
                </origin>
              </source>
            </term>
          </terms>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "terms.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          source_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Source']]", ns)
          expect(source_paras.length).to be >= 1
          source_text = source_paras.first.xpath("w:r/w:t", ns).text
          expect(source_text).to include("[SOURCE:")
          expect(source_text).to include("ISO 7301:2011")
          expect(source_text).to include("3.1")
        end
      end
    end
  end

  # ── Front matter ──────────────────────────────────────────────────

  describe "front matter" do
    it "renders cover page from bibdata" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-intro">Cereals</title>
          <title language="en" type="title-main">Specifications</title>
          <title language="en" type="title-part">Rice</title>
          <title language="en" type="title-part-prefix">Part 1</title>
          <docidentifier type="ISO" primary="true">ISO/CD 17301-1:2016</docidentifier>
          <date type="updated"><on>2016-05-01</on></date>
          <contributor><role type="author"/><organization>
            <name>ISO</name><abbreviation>ISO</abbreviation>
          </organization></contributor>
          <copyright><from>2016</from><owner><organization>
            <name>ISO</name><abbreviation>ISO</abbreviation>
          </organization></owner></copyright>
        </bibdata>
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Test foreword.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs

        # First paragraph: doc identifier
        cover_para = paras.find { |p| p.runs.any? { |r| (r.text || "").include?("ISO/CD 17301") } }
        expect(cover_para).not_to be_nil

        # Title paragraph
        title_para = paras.find { |p| p.runs.any? { |r| (r.text || "").include?("Specifications") } }
        expect(title_para).not_to be_nil
      end
    end

    it "renders warning from boilerplate" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <license-statement>
            <clause>
              <title>Warning for WDs and CDs</title>
              <p>This document is not an ISO International Standard.</p>
            </clause>
          </license-statement>
        </boilerplate>
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Test foreword.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs
        texts = paras.map { |p| p.runs.map { |r| r.text || "" }.join }.compact

        expect(texts).to include("Warning for WDs and CDs")
        expect(texts).to include("This document is not an ISO International Standard.")
      end
    end

    it "renders copyright from boilerplate" do
      xml = minimal_iso_xml(<<~INNER)
        <boilerplate>
          <copyright-statement>
            <clause>
              <p>© ISO 2016</p>
              <p>All rights reserved.</p>
            </clause>
          </copyright-statement>
        </boilerplate>
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Test foreword.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs
        texts = paras.map { |p| p.runs.map { |r| r.text || "" }.join }.compact

        expect(texts).to include("© ISO 2016")
        expect(texts).to include("All rights reserved.")
      end
    end

    it "renders TOC from preface clause with type=toc" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <clause type="toc" id="toc1">
            <fmt-title depth="1">Contents</fmt-title>
          </clause>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Test foreword.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs

        # Contents heading
        contents_para = paras.find { |p| p.runs.any? { |r| (r.text || "") == "Contents" } }
        expect(contents_para).not_to be_nil

        # TOC field
        toc_para = paras.find { |p| p.simple_fields.any? { |f| f.instr&.include?("TOC") } }
        expect(toc_para).not_to be_nil

        # TOC clause should not be rendered again as regular clause
        contents_count = paras.count { |p| p.runs.any? { |r| (r.text || "") == "Contents" } }
        expect(contents_count).to eq(1)
      end
    end

    it "handles document without bibdata gracefully" do
      expect_valid_docx(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Test foreword.</p>
          </foreword>
        </preface>
        <sections/>
      INNER
    end
  end
end

RSpec.describe IsoDoc::Iso::Docx::Adapter, "Simple template" do
  let(:adapter) { build_adapter(template: :simple) }

  it "creates adapter with Simple template" do
    expect(adapter.resolver.numbering_id(:dash_list)).to eq(18)
    expect(adapter.resolver.numbering_id(:annex_clause)).to eq(7)
  end

  it "converts a minimal document using Simple template" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="s1">
          <fmt-title>Scope</fmt-title>
          <p>Simple template test.</p>
        </clause>
      </sections>
    INNER
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "output.docx")
      adapter.convert(xml, output_path)
      expect(File.exist?(output_path)).to be(true)
      expect(File.size(output_path)).to be > 0
    end
  end
end
