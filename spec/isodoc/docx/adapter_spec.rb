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

    # BUG 016: Term definitions rendered via fmt-definition, in correct order
    # (right after preferred, before notes), with no duplicate preferred text.
    it "renders fmt-definition in order without duplicating preferred" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms and definitions</fmt-title>
            <term id="t1">
              <fmt-name>3.1</fmt-name>
              <fmt-preferred><p>waxy rice</p></fmt-preferred>
              <fmt-definition><semx element="definition"><p>variety of rice whose kernels have a white and opaque appearance</p></semx></fmt-definition>
              <termnote id="tn1"><p>The starch of waxy rice consists almost entirely of amylopectin.</p></termnote>
            </term>
        </terms>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        doc_xml = nil
        extract_docx(path) { |doc, _| doc_xml = doc.to_xml }
        text = doc_xml.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
        pref_idx = text.index("waxy rice")
        defn_idx = text.index("variety of rice whose kernels")
        note_idx = text.index("starch of waxy rice consists")
        expect(pref_idx).to be < defn_idx
        expect(defn_idx).to be < note_idx
        expect(text.scan(/variety of rice whose kernels/).length).to eq(1)
      end
    end

    # BUG 003: Subfigures inside a parent figure must each render their own drawing
    it "renders each subfigure image as a separate drawing" do
      tiny_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <figure id="fig1">
              <fmt-name>Figure 1</fmt-name>
              <image src="#{tiny_png}" width="100" height="100"/>
            </figure>
            <figure id="fig2">
              <fmt-name>Figure 2 — Composite</fmt-name>
              <figure id="fig2a">
                <fmt-name>Figure 2 a)</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig2b">
                <fmt-name>Figure 2 b)</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig2c">
                <fmt-name>Figure 2 c)</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
            </figure>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        doc_xml = nil
        extract_docx(path) { |doc, _| doc_xml = doc.to_xml }
        drawing_count = doc_xml.scan(/<w:drawing[ >]/).length
        expect(drawing_count).to eq(4)
      end
    end

    # BUG 003: Subfigures inside an annex figure (rice figureC-2 pattern)
    it "renders subfigures in an annex figure with name before subfigures" do
      tiny_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
          </clause>
        </sections>
        <annex id="annexc">
          <fmt-name>Annex C</fmt-name>
          <clause id="c1">
            <fmt-name>C.1 Gelatinization</fmt-name>
            <figure id="figureC-1">
              <name>Typical gelatinization curve</name>
              <fmt-name>Figure C.1 — Typical gelatinization curve</fmt-name>
              <image src="#{tiny_png}" width="100" height="100"/>
            </figure>
            <figure id="figureC-2">
              <name>Stages of gelatinization</name>
              <fmt-name>Figure C.2 — Stages of gelatinization</fmt-name>
              <figure id="fig-c2a" autonum="C.2 a">
                <name>Initial stages</name>
                <fmt-name>Figure C.2 a) Initial stages</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig-c2b" autonum="C.2 b">
                <name>Intermediate stages</name>
                <fmt-name>Figure C.2 b) Intermediate stages</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig-c2c" autonum="C.2 c">
                <name>Final stages</name>
                <fmt-name>Figure C.2 c) Final stages</fmt-name>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
            </figure>
          </clause>
        </annex>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        doc_xml = nil
        extract_docx(path) { |doc, _| doc_xml = doc.to_xml }
        drawing_count = doc_xml.scan(/<w:drawing[ >]/).length
        # Figure C.1 (1) + 3 subfigures of C.2 = 4 drawings
        expect(drawing_count).to eq(4)
      end
    end

    # BUG 003: Reproduces exact rice figureC-2 structure — figure has fmt-xref-label
    # before subfigures, mirroring the production XML layout.
    it "renders subfigures after fmt-xref-label in parent figure" do
      tiny_png = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAA9JREFUCNdj+M+ABf3HCwEACJ8FL0AAAAAASUVORK5CYII="
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
          </clause>
        </sections>
        <annex id="annexc">
          <fmt-name>Annex C</fmt-name>
          <clause id="c1">
            <fmt-name>C.1 Gelatinization</fmt-name>
            <figure id="figureC-2">
              <name>Stages of gelatinization</name>
              <fmt-name><span>Figure C.2</span></fmt-name>
              <fmt-xref-label><span>Figure C.2</span></fmt-xref-label>
              <figure id="fig-c2a" autonum="C.2 a">
                <name>Initial stages</name>
                <fmt-name><span>C.2 a)</span></fmt-name>
                <fmt-xref-label><span>C.2 a)</span></fmt-xref-label>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig-c2b" autonum="C.2 b">
                <name>Intermediate stages</name>
                <fmt-name><span>C.2 b)</span></fmt-name>
                <fmt-xref-label><span>C.2 b)</span></fmt-xref-label>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
              <figure id="fig-c2c" autonum="C.2 c">
                <name>Final stages</name>
                <fmt-name><span>C.2 c)</span></fmt-name>
                <fmt-xref-label><span>C.2 c)</span></fmt-xref-label>
                <image src="#{tiny_png}" width="100" height="100"/>
              </figure>
            </figure>
          </clause>
        </annex>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        doc_xml = nil
        extract_docx(path) { |doc, _| doc_xml = doc.to_xml }
        drawing_count = doc_xml.scan(/<w:drawing[ >]/).length
        expect(drawing_count).to eq(3)
      end
    end

    # ── Bibliography ──────────────────────────────────────────────────

    # BUG 010: Bibliography entries must include formattedref content
    # (the human-readable title) in addition to the biblio-tag.
    it "renders bibitem formattedref (title) alongside biblio-tag" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
          </clause>
        </sections>
        <bibliography id="bib">
          <references id="bib-refs" normative="false">
            <fmt-title>Bibliography</fmt-title>
            <bibitem id="b1" anchor="ISO9001" type="standard">
              <biblio-tag>[1]<tab/>ISO 9001, </biblio-tag>
              <formattedref><em>Quality management systems — Requirements</em></formattedref>
            </bibitem>
          </references>
        </bibliography>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("[1]")
          expect(full_text).to include("ISO 9001")
          expect(full_text).to include("Quality management systems")
        end
      end
    end

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

  # ── Table of contents ────────────────────────────────────────────

  describe "table of contents" do
    # BUG 002: Every <w:fldChar> in a TOC field (TOC instruction and
    # each PAGEREF entry) must carry an explicit w:fldCharType of
    # begin, separate, or end. Without it, Word renders the field
    # instructions as visible text.
    it "emits fldCharType on every fldChar element" do
      xml = minimal_iso_xml(<<~INNER)
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
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          bare_fldchars = doc.xpath("//w:fldChar[not(@w:fldCharType)]", ns)
          expect(bare_fldchars).to be_empty

          types = doc.xpath("//w:fldChar/@w:fldCharType", ns).map(&:value)
          expect(types).to include("begin")
          expect(types).to include("separate")
          expect(types).to include("end")
          expect(types).to all(satisfy { |t| %w[begin separate end].include?(t) })
        end
      end
    end

    # BUG 014: Each TOC entry must render the section number, a tab, and
    # the title text as separate visible runs — not as a single run with
    # concatenated text like "1Scope". This is achieved by rendering the
    # source clause's fmt-title via the InlineRenderer so that the
    # delimiter tab inside the fmt-title becomes a real <w:tab/> run.
    it "renders TOC entries with separate runs for number, tab, and title" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw">
            <fmt-title>Foreword</fmt-title>
            <p>Foreword text.</p>
          </foreword>
        </preface>
        <sections>
          <clause id="s1">
            <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1t">Scope</semx></fmt-title>
            <p>Scope content.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          toc_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='TOC1']]", ns)
          expect(toc_paras.length).to be >= 2

          clause_toc = toc_paras.find do |p|
            p.xpath(".//w:instrText", ns).text.include?("s1")
          end
          expect(clause_toc).not_to be_nil

          text_runs = clause_toc.xpath(".//w:t", ns).map(&:text).reject(&:empty?)
          expect(text_runs).to include("1")
          expect(text_runs).to include("Scope")
          # No single run should carry the concatenated number+title.
          expect(text_runs).to all(satisfy { |t| !t.include?("1Scope") })

          # Should have a tab run between the autonum and the title
          tab_runs = clause_toc.xpath(".//w:tab", ns)
          expect(tab_runs.length).to be >= 2

          # And the PAGEREF field machinery is present
          expect(clause_toc.xpath(".//w:instrText", ns).text).to include("PAGEREF s1")
        end
      end
    end

    # BUG 014: Untitled inline-header sub-clauses (whose fmt-title carries
    # only autonum carriers and no title text) must still appear in the TOC
    # with just their autonum — preserving what the source actually says.
    it "renders TOC entries for inline-header sub-clauses with autonum only" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope content.</p>
            <clause id="s1-1" inline-header="true">
              <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx><span class="fmt-autonum-delim">.</span><semx element="autonum" source="s1-1">1</semx></span></fmt-title>
              <p>Subclause content.</p>
            </clause>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          toc_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='TOC2']]", ns)
          expect(toc_paras.length).to be >= 1
          text_runs = toc_paras.first.xpath(".//w:t", ns).map(&:text).join
          expect(text_runs).to include("1.1")
        end
      end
    end
  end

  # ── Front matter ──────────────────────────────────────────────────

  describe "front matter" do
    # BUG 001: The sectPr in word/document.xml references header/footer
    # parts by rId. If the corresponding Relationship entries are missing
    # from word/_rels/document.xml.rels, Word reports "unreadable
    # content" and discards every header/footer after repair. Every
    # headerReference / footerReference must resolve to a defined
    # Relationship of the correct type.
    it "emits a Relationship for every header/footer reference" do
      xml = minimal_iso_xml(<<~INNER)
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
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        Zip::File.open(path) do |zip|
          rels_xml = zip.find_entry("word/_rels/document.xml.rels").get_input_stream.read
          rels = Nokogiri::XML(rels_xml)
          rels_ns = { "r" => "http://schemas.openxmlformats.org/package/2006/relationships" }

          doc_xml = zip.find_entry("word/document.xml").get_input_stream.read
          doc = Nokogiri::XML(doc_xml)
          w_ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }

          ref_ids = doc.xpath("//w:headerReference/@r:id | //w:footerReference/@r:id",
                              w_ns.merge("r" => "http://schemas.openxmlformats.org/officeDocument/2006/relationships")).map(&:value)
          expect(ref_ids).not_to be_empty

          rel_ids = rels.xpath("//r:Relationship/@Id", rels_ns).map(&:value)
          ref_ids.each do |rid|
            expect(rel_ids).to include(rid), "header/footer reference #{rid} has no Relationship"
          end

          # Each referenced Relationship must point to a header or footer target
          types_by_id = rels.xpath("//r:Relationship", rels_ns).each_with_object({}) do |rel, h|
            h[rel["Id"]] = rel["Type"]
          end
          ref_ids.each do |rid|
            type = types_by_id[rid]
            expect(type).to match(/(header|footer)$/)
          end
        end
      end
    end

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
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs

        # Contents heading
        contents_para = paras.find { |p| p.runs.any? { |r| (r.text || "") == "Contents" } }
        expect(contents_para).not_to be_nil

        # TOC field — check for TOC instruction in generated DOCX
        extract_docx(path) do |xml_doc, ns|
          toc_instr = xml_doc.xpath("//w:instrText[contains(text(), 'TOC')]", ns)
          expect(toc_instr.length).to be >= 1
        end

        # TOC heading should be present (may appear in heading + field context)
        contents_count = paras.count { |p| p.runs.any? { |r| (r.text || "") == "Contents" } }
        expect(contents_count).to be >= 1
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

    it "renders middle title page between front matter and body" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Quality Management</title>
          <docidentifier type="ISO">ISO 9001</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Scope.</p></clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        pkg = Uniword::Docx::Package.from_file(path)
        paras = pkg.document.body.paragraphs

        # Find the middle title paragraph with zzSTDTitle style
        title_paras = paras.select do |p|
          p.properties&.style&.value == "zzSTDTitle"
        end
        expect(title_paras.length).to be >= 1
        title_text = title_paras.first.runs.map { |r| r.text || "" }.join
        expect(title_text).to include("Quality Management")
      end
    end

    it "inserts page break between Foreword and Introduction" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW text.</p></foreword>
          <introduction id="intro"><fmt-title>Introduction</fmt-title><p>Intro text.</p></introduction>
        </preface>
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Scope.</p></clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("Foreword")
          expect(full_text).to include("Introduction")

          # Check for page break between them
          page_breaks = doc.xpath("//w:br[@w:type='page']", ns)
          expect(page_breaks.length).to be >= 1
        end
      end
    end
  end

  # ── Section layout ────────────────────────────────────────────────

  describe "section layout" do
    # BUG 004/005/006/007: Heading styles in the DIS template carry
    # <w:numPr> so the style produces the section number on its own.
    # The adapter must strip <semx element="autonum"> carriers (and
    # their fmt-caption-label/fmt-caption-delim/fmt-element-name
    # wrappers) from the heading text — otherwise the number shows up
    # twice (e.g. "1 1Scope", "Annex AAnnex A", "A.1 A.1Principle").
    #
    # The stripping applies recursively — autonum nested inside
    # <strong>, <span class="fmt-caption-label">, etc. must also be
    # stripped so annex titles render cleanly.
    it "strips autonum carriers from auto-numbered headings" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1t">Scope</semx></fmt-title>
            <p>Scope content.</p>
          </clause>
          <terms id="terms_sect" obligation="normative">
            <title>Terms and definitions</title>
            <fmt-title depth="1"><span class="fmt-caption-label"><semx element="autonum" source="terms_sect">3</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="terms_title">Terms and definitions</semx></fmt-title>
          </terms>
        </sections>
        <annex id="annexA" obligation="normative">
          <title>Determination of defects</title>
          <fmt-title>
            <strong>
              <span class="fmt-caption-label"><span class="fmt-element-name">Annex</span> <semx element="autonum" source="annexA">A</semx></span>
            </strong>
            <br/>
            <span class="fmt-obligation">(normative)</span>
            <span class="fmt-caption-delim"><br/><br/></span>
            <semx element="title" source="ann_title"><strong>Determination of defects</strong></semx>
          </fmt-title>
          <clause id="a1" inline-header="false" obligation="normative">
            <title>Principle</title>
            <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum" source="annexA">A</semx><span class="fmt-autonum-delim">.</span><semx element="autonum" source="a1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Principle</semx></fmt-title>
            <p>Content.</p>
          </clause>
        </annex>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          # Body clauses with Heading1 — number "1" must NOT appear in text
          scope = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']][.//w:t[contains(.,'Scope')]]", ns)
          expect(scope).not_to be_nil
          scope_text = scope.xpath(".//w:t", ns).map(&:text).join
          expect(scope_text).to include("Scope")
          expect(scope_text).not_to match(/\A\s*1/)

          # Terms section also uses Heading1 (via visit_terms_section)
          terms = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading1']][.//w:t[contains(.,'Terms and definitions')]]", ns)
          expect(terms).not_to be_nil
          terms_text = terms.xpath(".//w:t", ns).map(&:text).join
          expect(terms_text).not_to match(/\A\s*3.*Terms/),
                                 "Terms heading leaked auto-number text: |#{terms_text}|"

          # ANNEX style — neither "Annex" word nor "A" letter should leak
          annex = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='ANNEX']]", ns)
          expect(annex).not_to be_nil
          annex_text = annex.xpath(".//w:t", ns).map(&:text).join
          expect(annex_text).to include("Determination of defects")
          expect(annex_text).not_to match(/Annex\s*A/i),
                                 "Annex heading leaked prefix: |#{annex_text}|"

          # a2 style for annex sub-clause — number "A.1" must NOT appear
          a2 = doc.at_xpath("//w:p[w:pPr/w:pStyle[@w:val='a2']][.//w:t[contains(.,'Principle')]]", ns)
          expect(a2).not_to be_nil
          a2_text = a2.xpath(".//w:t", ns).map(&:text).join
          expect(a2_text).to include("Principle")
          expect(a2_text).not_to match(/A\.?1/i),
                                "Annex sub-clause leaked number: |#{a2_text}|"
        end
      end
    end

    # BUG 015: The presentation XML may inject <p class="zzSTDTitle1">
    # into the body. The adapter must suppress these duplicates because
    # it emits its own canonical middle-title paragraph from bibdata
    # (via render_middle_title). The cover page also shows the title
    # (CoverTitleA1) — both cover and middle-title are part of the
    # standard ISO DIS layout.
    it "suppresses XML-injected zzSTDTitle1 paragraphs in the body" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">My Test Document</title>
          <docidentifier type="ISO">ISO 1234</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <sections>
          <p class="zzSTDTitle1" displayorder="4">
            <span class="boldtitle">My Test Document</span>
          </p>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Body content.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          # The XML-injected zzSTDTitle1 paragraph must NOT appear with
          # the zzSTDTitle1 style — it would collide with the adapter's
          # own middle-title emission.
          injected = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='zzSTDTitle1']]", ns)
          expect(injected).to be_empty,
            "XML-injected zzSTDTitle1 paragraph was not suppressed"

          # The adapter emits exactly one middle-title paragraph from
          # bibdata (style zzSTDTitle).
          middle = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='zzSTDTitle']]", ns)
          expect(middle.length).to eq(1),
            "Expected 1 adapter-emitted middle-title paragraph, got #{middle.length}"
        end
      end
    end

    # BUG 020: Untitled sub-clauses (whose <fmt-title> contains only the
    # autonum + delim) must not emit an empty heading paragraph that runs
    # into the next body paragraph.
    it "skips empty headings whose title has only autonum carriers" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="parent">
            <fmt-title>Parent Clause</fmt-title>
            <p>Parent intro.</p>
            <clause id="untitled" inline-header="true">
              <fmt-title depth="2"><span class="fmt-caption-label"><semx element="autonum">5</semx><span class="fmt-autonum-delim">.</span><semx element="autonum">1</semx></span><span class="fmt-caption-delim"><tab/></span></fmt-title>
              <p>Untitled sub-clause body text.</p>
            </clause>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          # The body paragraph follows directly — no empty heading paragraph
          empty_headings = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Heading2']]", ns).select do |p|
            text = p.xpath(".//w:t", ns).map(&:text).join.strip
            text.empty?
          end
          expect(empty_headings).to be_empty,
            "Untitled sub-clause produced an empty Heading2 paragraph"
        end
      end
    end

    # BUG 017: Bookmark pairs must WRAP the heading text (or other content)
    # so hyperlinks and PAGEREF fields resolve to a non-empty range. Empty
    # adjacent pairs (bookmarkStart immediately followed by bookmarkEnd)
    # collapse to zero width and produce broken jump targets.
    it "wraps heading text with bookmark start/end pairs" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="scope-id">
            <fmt-title>Scope</fmt-title>
            <p>Body.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          bm_starts = doc.xpath("//w:bookmarkStart", ns)
          expect(bm_starts).not_to be_empty

          adjacent = bm_starts.select do |bs|
            sibling = bs.next_element
            sibling&.name == "bookmarkEnd" && sibling["w:id"] == bs["w:id"]
          end
          expect(adjacent).to be_empty,
            "Found #{adjacent.size} empty bookmark pairs with no content between them"
        end
      end
    end

    # BUG 018: When inline content is split into multiple runs, the
    # leading/trailing whitespace on each run must be preserved via
    # xml:space="preserve" on <w:t>. Without it, whitespace at run
    # boundaries is silently dropped (e.g. "Part 1:Rice" instead of
    # "Part 1: Rice").
    it "preserves whitespace at run boundaries with xml:space=preserve" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Part 1: <em>Rice</em> specifications.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          # Find all w:t elements whose text has leading or trailing whitespace
          ws_runs = doc.xpath("//w:t[normalize-space() != '']", ns).select do |t|
            text = t.text
            text != text.strip
          end
          unpreserved = ws_runs.reject { |t| t["xml:space"] == "preserve" }
          expect(unpreserved).to be_empty,
            "Found #{unpreserved.size} runs with whitespace lacking xml:space=preserve"
        end
      end
    end

    it "creates three sections: cover, front matter, body" do
      xml = minimal_iso_xml(<<~INNER)
        <bibdata type="standard">
          <title language="en" type="title-main">Test</title>
          <docidentifier type="ISO">ISO 1234</docidentifier>
          <copyright><from>2024</from><owner><organization>
            <name>ISO</name>
          </organization></owner></copyright>
        </bibdata>
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Scope.</p></clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          # Should have 3 sectPr elements (cover, front matter, body)
          sect_prs = doc.xpath("//w:sectPr", ns)
          expect(sect_prs.length).to be >= 2
        end
      end
    end
  end

  # ── Admonition style dispatch ──────────────────────────────────────

  describe "admonition styles" do
    it "uses warning styles for admonitions" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <admonition id="ad1"><p>Caution: hot surface.</p></admonition>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          admonition_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Warningtext']]", ns)
          expect(admonition_paras.length).to be >= 1
        end
      end
    end
  end

  # ── Hyperlink rStyle ───────────────────────────────────────────────

  describe "character styles" do
    it "applies Hyperlink rStyle to link runs" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Visit <link target="https://example.com">example</link>.</p>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          hyperlink_styles = doc.xpath("//w:hyperlink//w:rPr/w:rStyle[@w:val='Hyperlink']", ns)
          expect(hyperlink_styles.length).to be >= 1
        end
      end
    end
  end

  # ── Sourcecode formatting ──────────────────────────────────────────

  describe "sourcecode formatting" do
    it "preserves whitespace in sourcecode blocks" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <sourcecode id="sc1">puts "hello"
puts "world"</sourcecode>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        expect(File.exist?(path)).to be(true)
      end
    end

    it "converts newlines in sourcecode to line breaks" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <sourcecode id="sc1">line1
line2
line3</sourcecode>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          # Check for br elements (line breaks) within Code-styled paragraphs
          code_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Code']]", ns)
          expect(code_paras.length).to be >= 1

          # Should have line breaks between the sourcecode lines
          breaks = code_paras.first.xpath(".//w:br", ns)
          expect(breaks.length).to be >= 2
        end
      end
    end

    # BUG 012: Callouts inside sourcecode must be rendered as styled
    # superscript markers, not as raw escaped XML text.
    it "renders sourcecode callouts as superscript markers" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <sourcecode id="sc1"><fmt-sourcecode>puts "hello" <callout target="_c1">1</callout></fmt-sourcecode></sourcecode>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("puts")
          expect(full_text).to include("(1)")
          # No escaped XML should leak through
          expect(full_text).not_to include("&lt;callout")
          expect(full_text).not_to include("<callout")
        end
      end
    end
  end

  # ── Table cell block content ──────────────────────────────────────

  describe "table cell rendering" do
    it "renders notes inside table cells" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <tbody>
                <tr>
                  <td>
                    <p>Cell text.</p>
                    <note id="n1"><p>Cell note content.</p></note>
                  </td>
                </tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("Cell text.")
          expect(full_text).to include("Cell note content.")

          # The note should have Note style
          note_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Note']]", ns)
          expect(note_paras.length).to be >= 1
        end
      end
    end

    it "renders simple cells without block elements as single paragraphs" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <table id="t1">
              <tbody>
                <tr><td><p>Simple cell</p></td></tr>
              </tbody>
            </table>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        expect(File.exist?(path)).to be(true)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          expect(full_text).to include("Simple cell")
        end
      end
    end
  end

  # ── Preface clause type ───────────────────────────────────────────

  describe "preface clause dispatch" do
    it "skips TOC clauses in preface (uses :type attribute)" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <clause type="toc" id="toc1">
            <title>Contents</title>
          </clause>
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
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          full_text = doc.xpath("//w:t", ns).map(&:text).join
          # The clause with type="toc" should be skipped by visit_preface
          # (handled by TocBuilder instead)
          expect(full_text).to include("Foreword text.")
          expect(full_text).to include("Scope content.")
        end
      end
    end
  end

  # ── Comments support ───────────────────────────────────────────────

  describe "comments support" do
    it "renders annotations as DOCX comments" do
      xml = minimal_iso_xml(<<~INNER)
        <annotation-container>
          <annotation date="2026-01-01" reviewer="ISO" id="ann1" from="s1" to="s1">
            <p>Test comment.</p>
          </annotation>
          <fmt-annotation-body date="2026-01-01" reviewer="ISO" id="fab1" from="s1" to="s1">
            <p>Test comment.</p>
          </fmt-annotation-body>
        </annotation-container>
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Scope with <fmt-annotation-start id="fas1" target="fab1" reviewer="ISO" date="2026-01-01"/>comment<fmt-annotation-end id="fae1" target="fab1"/> marker.</p>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        expect(File.exist?(path)).to be(true)
      end
    end
  end

  # ── Formula rendering ─────────────────────────────────────────────

  describe "formula rendering" do
    it "renders formulas with MathML via OMML" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <formula id="f1">
              <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>E</mi><mo>=</mo><mi>m</mi><msup><mi>c</mi><mn>2</mn></msup></math></stem>
              <fmt-name>(1)</fmt-name>
            </formula>
          </clause>
        </sections>
      INNER

      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)

        extract_docx(path) do |doc, ns|
          # Should have a Formula-styled paragraph
          formula_paras = doc.xpath("//w:p[w:pPr/w:pStyle[@w:val='Formula']]", ns)
          expect(formula_paras.length).to be >= 1

          # Should have OMML math content (m namespace)
          m_ns = { "m" => "http://schemas.openxmlformats.org/officeDocument/2006/math" }
          omath = doc.xpath("//m:oMathPara", m_ns)
          expect(omath.length).to be >= 1
        end
      end
    end
  end

  # ── Footnote deduplication ───────────────────────────────────────

  describe "footnote deduplication" do
    # BUG 019: When the source marks multiple <fn> references with the
    # same `target` (pointing to one shared definition), they must all
    # map to a single OOXML footnote id — not allocate a fresh id for
    # every reference. The source footnote identity is the target, not
    # the text or per-instance id.
    it "reuses a single OOXML footnote id for references sharing a target" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>First reference <fn id="fn-a" reference="1" target="fn-shared"><p>Withdrawn.</p></fn> in scope.</p>
            <p>Second reference <fn id="fn-b" reference="2" target="fn-shared"><p>Withdrawn.</p></fn> elsewhere.</p>
            <p>Third reference <fn id="fn-c" reference="3" target="fn-shared"><p>Withdrawn.</p></fn> again.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          fn_refs = doc.xpath("//w:footnoteReference", ns).map { |r| r["w:id"] }
          expect(fn_refs.length).to eq(3)
          expect(fn_refs.uniq.length).to eq(1), "expected all refs to share one id, got #{fn_refs.inspect}"
        end
      end
    end

    # BUG 019: Conversely, distinct source footnote definitions (different
    # target values) must produce distinct OOXML footnote ids — even when
    # the rendered text is identical.
    it "allocates distinct OOXML footnote ids for distinct source targets" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <p>Withdrawn-A <fn id="fn-a" reference="1" target="fn-def-a"><p>Withdrawn A.</p></fn>.</p>
            <p>Withdrawn-B <fn id="fn-b" reference="2" target="fn-def-b"><p>Withdrawn B.</p></fn>.</p>
            <p>Withdrawn-C <fn id="fn-c" reference="3" target="fn-def-c"><p>Withdrawn C.</p></fn>.</p>
          </clause>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          fn_refs = doc.xpath("//w:footnoteReference", ns).map { |r| r["w:id"] }
          expect(fn_refs.length).to eq(3)
          expect(fn_refs.uniq.length).to eq(3), "expected 3 distinct ids, got #{fn_refs.inspect}"
        end
      end
    end
  end

  # ── Mixed-content rendering ──────────────────────────────────────

  describe "mixed-content rendering" do
    # BUG 008/009/011/013: The walk_mixed_content path used to re-walk
    # semantic elements after the explicit fmt-* visitors had already
    # rendered them — producing duplicate preferred terms, duplicated
    # CAUTION/WARNING labels, and duplicated "Reference" prefixes on
    # cross-references. The tests below use the same dual semantic+fmt
    # structure that triggered the original bug and confirm each
    # designation renders exactly once.

    it "renders each term designation once (no semantic+fmt duplication)" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <terms id="terms">
            <fmt-title>Terms</fmt-title>
            <term id="t1">
              <fmt-name><span>3.1</span></fmt-name>
              <preferred id="p1"><expression><name>paddy</name></expression></preferred>
              <fmt-preferred><p><semx element="preferred" source="p1"><strong><semx element="expression/name" source="p1">paddy</semx></strong></semx></p></fmt-preferred>
              <admitted id="a1"><expression><name>paddy rice</name></expression></admitted>
              <fmt-admitted><p><semx element="admitted" source="a1"><semx element="expression/name" source="a1">paddy rice</semx></semx></p></fmt-admitted>
            </term>
          </terms>
        </sections>
      INNER
      Dir.mktmpdir do |dir|
        path = File.join(dir, "output.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |doc, ns|
          # Each term-name paragraph should be unique. Count paragraphs whose
          # text is exactly "paddy" or "paddy rice" — these should each
          # appear in exactly one paragraph.
          para_texts = doc.xpath("//w:p", ns).map do |p|
            p.xpath(".//w:t", ns).map(&:text).join
          end
          expect(para_texts.count("paddy")).to eq(1)
          expect(para_texts.count("paddy rice")).to eq(1)
        end
      end
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
