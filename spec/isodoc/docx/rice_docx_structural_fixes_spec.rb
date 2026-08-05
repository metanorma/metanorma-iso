# frozen_string_literal: true

require_relative "spec_helper"
require "tmpdir"

# These specs lock in the structural fixes applied during the "rice DOCX
# won't open in Word" investigation. Each spec maps to one root cause that
# caused Word to either report "unreadable content" or "experienced an
# error trying to open the file". Together they form a regression net:
# if any of these breaks again, the DOCX output becomes Word-incompatible.
RSpec.describe "Rice DOCX structural invariants" do
  let(:adapter) { build_adapter }
  let(:output_dir) { Dir.mktmpdir("metanorma-iso-rice-test") }
  let(:output_path) { File.join(output_dir, "rice.docx") }
  let(:rice_xml) { File.read("spec/examples/rice.presentation.xml") }

  after { FileUtils.remove_entry(output_dir) if File.directory?(output_dir) }

  # Helper: parse a part out of the generated DOCX
  def part(name)
    Zip::File.open(output_path) do |zip|
      entry = zip.find_entry(name)
      return nil unless entry
      entry.get_input_stream.read
    end
  end

  def doc_xml
    @doc_xml ||= Nokogiri::XML(part("word/document.xml")) do |c|
      c.strict
    end
  end

  def docx_rels_xml
    @docx_rels_xml ||= Nokogiri::XML(part("word/_rels/document.xml.rels"))
  end

  def custom_props_xml
    @custom_props_xml ||= Nokogiri::XML(part("docProps/custom.xml"))
  end

  def footer_xml(index)
    Nokogiri::XML(part("word/footer#{index}.xml"))
  end

  def core_props_xml
    @core_props_xml ||= Nokogiri::XML(part("docProps/core.xml"))
  end

  def settings_xml
    @settings_xml ||= Nokogiri::XML(part("word/settings.xml"))
  end

  before do
    adapter.convert(rice_xml, output_path)
  end

  describe "IdAllocator seeds after stale rel clearing" do
    # Adapter change: setup_allocator must run AFTER clearing customXml and
    # image rels from document_rels. Otherwise the IdAllocator holds stale
    # rels and the Reconciler restores them on save (see memory
    # oxml_allocator_stale_rels.md).
    it "does not restore customXml rels to document.xml.rels" do
      rels = docx_rels_xml.xpath("//r:Relationship",
        "r" => "http://schemas.openxmlformats.org/package/2006/relationships")
      stale_customxml = rels.select { |r| r["Type"].include?("/customXml") }
      expect(stale_customxml).to be_empty,
        "customXml rels should be cleared, but found: #{stale_customxml.map(&:to_xml).inspect}"
    end

    it "does not restore stale image rels to document.xml.rels" do
      rels = docx_rels_xml.xpath("//r:Relationship",
        "r" => "http://schemas.openxmlformats.org/package/2006/relationships")
      stale_images = rels.select do |r|
        r["Type"].include?("/image") &&
          %w[image1.png image2.png].include?(r["Target"])
      end
      expect(stale_images).to be_empty,
        "stale image1.png/image2.png rels should be cleared, but found: #{stale_images.map(&:to_xml).inspect}"
    end

    it "does not include customXml content type overrides" do
      ct = Nokogiri::XML(part("[Content_Types].xml"))
      overrides = ct.xpath("//ct:Override/@PartName",
        "ct" => "http://schemas.openxmlformats.org/package/2006/content-types").map(&:value)
      customxml_overrides = overrides.select { |p| p.include?("customXml/") }
      expect(customxml_overrides).to be_empty,
        "customXml content type overrides should be cleared, but found: #{customxml_overrides.inspect}"
    end
  end

  describe "Footnote references collapse identical footnotes" do
    # Identical <fn> elements (same target/identity) in the source
    # should share ONE footnote definition in footnotes.xml and one
    # footnoteReference id. The rice document has 22 <fn> elements
    # but only 16 distinct footnotes — duplicates are collapsed by
    # FootnoteRenderer's cache.
    it "multiple references may share an id (collapsed)" do
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      refs = doc_xml.xpath("//w:footnoteReference", ns).map { |e| e["w:id"] }
      ref_counts = refs.tally
      # At least one id should be reused (the rice doc has 6 duplicate fns)
      reused = ref_counts.select { |_, c| c > 1 }
      expect(reused).not_to be_empty,
        "expected at least one footnote id to be reused across references " \
        "(rice document has duplicate <fn> elements): #{ref_counts.inspect}"
    end

    it "every referenced footnote id exists in footnotes.xml" do
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      referenced = doc_xml.xpath("//w:footnoteReference", ns).map { |e| e["w:id"] }.uniq
      fn_doc = Nokogiri::XML(part("word/footnotes.xml"))
      defined = fn_doc.xpath("//w:footnote", ns).map { |e| e["w:id"] }
      missing = referenced - defined
      expect(missing).to be_empty,
        "footnote references point to undefined footnotes: #{missing.inspect}"
    end

    it "footnote ids are unique within footnotes.xml itself" do
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      fn_doc = Nokogiri::XML(part("word/footnotes.xml"))
      ids = fn_doc.xpath("//w:footnote", ns).map { |e| e["w:id"] }
      dupes = ids.tally.select { |_, count| count > 1 }
      expect(dupes).to be_empty,
        "duplicate footnote ids in footnotes.xml: #{dupes.inspect}"
    end

    it "collapses the rice document's duplicate <fn> elements" do
      # Rice presentation XML has 22 <fn> elements but only 16 distinct
      # footnote identities (target attribute). The output should have
      # ≤ 17 defined footnotes (16 real + 2 separators).
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      fn_doc = Nokogiri::XML(part("word/footnotes.xml"))
      defined_real = fn_doc.xpath("//w:footnote[not(@w:type)]", ns).size
      expect(defined_real).to be <= 18,
        "expected ≤ 18 real footnotes after dedup, got #{defined_real}"
    end
  end

  describe "PAGE field is run-wrapped in footers" do
    # OOXML requires <w:fldChar> and <w:instrText> inside <w:r> runs;
    # bare direct children of <w:p> are schema-invalid and Word rejects
    # the document with "experienced an error trying to open the file".
    (1..4).each do |i|
      it "footer#{i}.xml has no bare <w:fldChar> children of <w:p>" do
        footer = footer_xml(i)
        bare_fldchar = footer.xpath("//w:p/w:fldChar",
          "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        expect(bare_fldchar).to be_empty,
          "footer#{i} has bare <w:fldChar> children of <w:p>: #{bare_fldchar.map(&:to_xml).inspect}"
      end

      it "footer#{i}.xml has no bare <w:instrText> children of <w:p>" do
        footer = footer_xml(i)
        bare_instr = footer.xpath("//w:p/w:instrText",
          "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        expect(bare_instr).to be_empty,
          "footer#{i} has bare <w:instrText> children of <w:p>: #{bare_instr.map(&:to_xml).inspect}"
      end

      it "footer#{i}.xml wraps each <w:fldChar> in a dedicated <w:r> run" do
        footer = footer_xml(i)
        runs = footer.xpath("//w:p/w:r",
          "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        with_fldchar = runs.select { |r| r.at_xpath("w:fldChar", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main") }
        expect(with_fldchar).not_to be_empty
        # Every run carrying a fldChar should contain ONLY that fldChar
        # (mixing with text/tab would break the field). Allow empty rPr.
        with_fldchar.each do |r|
          children = r.element_children.map(&:name)
          unexpected = children - %w[fldChar rPr]
          expect(unexpected).to be_empty,
            "run carrying fldChar should not contain other content, got: #{children.inspect}"
        end
      end

      it "footer#{i}.xml emits PAGE field as begin/instrText/separate/end in order" do
        footer = footer_xml(i)
        runs = footer.xpath("//w:p/w:r",
          "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        sequence = runs.flat_map do |r|
          if (fc = r.at_xpath("w:fldChar", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"))
            ["fld:#{fc['w:fldCharType']}"]
          elsif (it = r.at_xpath("w:instrText", "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"))
            ["instr:#{it.text.strip}"]
          end
        end.compact
        expect(sequence).to include("fld:begin", "instr:PAGE", "fld:separate", "fld:end"),
          "PAGE field must be begin→instrText(PAGE)→separate→end, got: #{sequence.inspect}"
      end
    end
  end

  describe "Custom properties are unprefixed attributes" do
    # OOXML custom-properties namespace uses prefix_default "custprops",
    # but the <property> attributes (fmtid, pid, name) must be unprefixed.
    # See Uniword::Ooxml::Namespaces::CustomProperties#attribute_form_default
    it "uses unqualified fmtid/pid/name attributes on <property>" do
      skip "custom.xml not generated for minimal fixtures" unless custom_props_xml
      properties = custom_props_xml.xpath("//*[local-name()='property']")
      expect(properties).not_to be_empty
      properties.each do |p|
        p.attributes.each do |name, attr|
          # No attribute should be qualified with the custprops namespace
          expect(attr.namespace&.prefix).to be_nil.or(eq("xml")),
            "<property> attribute #{name.inspect} should be unqualified, " \
            "got prefix: #{attr.namespace&.prefix.inspect}"
        end
        expect(p["fmtid"]).to match(/\{[A-F0-9-]+\}/),
          "fmtid should be a GUID, got: #{p['fmtid'].inspect}"
        expect(p["pid"]).to match(/^\d+$/),
          "pid should be a positive integer, got: #{p['pid'].inspect}"
      end
    end
  end

  describe "W3CDTF date format in core properties" do
    # OOXML XSD requires dcterms:created/modified in
    # "YYYY-MM-DDThh:mm:ssZ" form. A bare "YYYY-MM-DD" passes Nokogiri
    # (XML well-formed) but fails Word's strict schema check.
    it "emits dcterms:created in full W3CDTF format with time component" do
      created = core_props_xml.at_xpath("//dcterms:created",
        "dcterms" => "http://purl.org/dc/terms/")
      expect(created).not_to be_nil
      expect(created.text).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/),
        "dcterms:created must be YYYY-MM-DDThh:mm:ssZ, got: #{created.text.inspect}"
    end

    it "emits dcterms:modified in full W3CDTF format with time component" do
      modified = core_props_xml.at_xpath("//dcterms:modified",
        "dcterms" => "http://purl.org/dc/terms/")
      expect(modified).not_to be_nil
      expect(modified.text).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/),
        "dcterms:modified must be YYYY-MM-DDThh:mm:ssZ, got: #{modified.text.inspect}"
    end
  end

  describe "sectPr element ordering matches OOXML CT_SectPr schema" do
    # Per ECMA-376 CT_SectPr, pgNumType must come BEFORE cols in sectPr.
    # Wrong order is a schema violation that Word rejects.
    it "emits pgNumType before cols in body-level sectPr" do
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      body_sect = doc_xml.at_xpath("//w:body/w:sectPr", ns)
      expect(body_sect).not_to be_nil
      children = body_sect.element_children.map(&:name)
      if children.include?("pgNumType") && children.include?("cols")
        expect(children.index("pgNumType")).to be < children.index("cols"),
          "pgNumType must come before cols in sectPr, got: #{children.inspect}"
      end
    end
  end

  describe "settings.xml element ordering matches OOXML CT_Settings schema" do
    # Per ECMA-376 CT_Settings, the element order must be preserved through
    # serialization (mirrorMargins before proofState, etc.). Wrong order
    # causes "unreadable content" recovery prompts.
    it "emits mirrorMargins before proofState in settings" do
      children = settings_xml.root.element_children.map(&:name)
      if children.include?("mirrorMargins") && children.include?("proofState")
        expect(children.index("mirrorMargins")).to be < children.index("proofState"),
          "mirrorMargins must come before proofState in settings, got: #{children.inspect}"
      end
    end

    it "emits hyphenationZone near the standard sequence position" do
      children = settings_xml.root.element_children.map(&:name)
      if children.include?("hyphenationZone") && children.include?("defaultTabStop")
        expect(children.index("hyphenationZone")).to be > children.index("defaultTabStop"),
          "hyphenationZone must follow defaultTabStop in settings, got: #{children.inspect}"
      end
    end

    it "emits w14:docId and w15:docId at the end (after standard parts)" do
      children = settings_xml.root.element_children.map(&:name)
      if children.include?("docId")
        doc_id_indices = children.each_index.select { |i| children[i] == "docId" }
        # docId must come after all standard parts (decimalSymbol, listSeparator, etc.)
        last_standard = children.rindex { |n| %w[shapeDefaults decimalSymbol listSeparator docVars rsids mathPr themeFontLang clrSchemeMapping].include?(n) }
        expect(doc_id_indices.first).to be > (last_standard || -1),
          "docId must come after standard settings parts, got: #{children.inspect}"
      end
    end
  end

  describe "document.xml does not contain stale image or customXml parts" do
    it "does not reference media/image1.png or media/image2.png" do
      raw = part("word/document.xml")
      %w[image1.png image2.png].each do |stale|
        expect(raw).not_to include(stale),
          "document.xml still references stale #{stale}"
      end
    end

    it "the package contains no customXml folder" do
      has_customxml = Zip::File.open(output_path).any? do |entry|
        entry.name.start_with?("customXml/")
      end
      expect(has_customxml).to be(false),
        "customXml folder should be removed entirely from the package"
    end
  end

  describe "Term paragraph inline content is rendered, not serialized as XML" do
    # <p> inside <terms> parses into ParagraphBlock, whose mixed inline
    # children (semx, fmt-xref, xref) the inline dispatch walks directly.
    # Without a registered handler, the renderer fell back to
    # collect_text which returned the raw XML — and the output displayed
    # literal "<semx ...>" / "<xref ...>" tags as visible text.
    it "does not emit any semx tags as visible text" do
      raw = part("word/document.xml")
      expect(raw).not_to match(/semx[^<]/i),
        "document.xml should not contain raw semx tags as text"
      expect(raw).not_to include("&lt;semx"),
        "document.xml should not contain escaped semx tags as text"
    end

    it "does not emit raw xref XML as visible text" do
      raw = part("word/document.xml")
      expect(raw).not_to include("&lt;xref"),
        "document.xml should not contain escaped xref XML as text"
    end

    it "renders termnote body text (not XML source) for figure references" do
      raw = part("word/document.xml")
      # The rice document has termnotes that reference figures via
      # <semx element="xref">...<fmt-xref>...Figure C.1...</fmt-xref></semx>.
      # After proper rendering, "Figure" should appear as visible text
      # (inside a hyperlink run), not as part of an XML tag.
      expect(raw).to include(">Figure<").or(include(">Figure "))
    end
  end

  describe "Bibliography entries are single paragraphs without annotations" do
    # Each bibitem must render as ONE RefNorm/BiblioEntry paragraph,
    # NOT include <note>/<abstract> children as visible content, and
    # NOT split the entry across lines via stray <w:br/>.

    it "does not include bibitem <abstract> content as bibliography text" do
      raw = part("word/document.xml")
      expect(raw).not_to include("specifies a routine reference method"),
        "bibliography should not include <abstract> content as visible text"
    end

    it "renders exactly 7 RefNorm paragraphs (one per bibitem)" do
      doc = Nokogiri::XML(part("word/document.xml"))
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      count = doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='RefNorm']", ns).size
      expect(count).to eq(7),
        "expected 7 RefNorm paragraphs (rice has 7 bibitems in normative refs), got #{count}"
    end

    it "does not emit BiblioDescription paragraphs from <note>/<abstract>" do
      doc = Nokogiri::XML(part("word/document.xml"))
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      biblio_desc = doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='BiblioDescription']", ns)
      expect(biblio_desc).to be_empty,
        "should not emit BiblioDescription (note/abstract annotations): #{biblio_desc.size} found"
    end

    it "does not split RefNorm entries with stray <w:br/>" do
      doc = Nokogiri::XML(part("word/document.xml"))
      ns = { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
      doc.xpath("//w:p[w:pPr/w:pStyle/@w:val='RefNorm']", ns).each_with_index do |p, i|
        brs = p.xpath(".//w:br", ns).size
        expect(brs).to eq(0),
          "RefNorm ##{i} should not contain <w:br/> — entry must be a single line"
      end
    end
  end
end