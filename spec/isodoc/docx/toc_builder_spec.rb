# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::TocBuilder do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:context) { IsoDoc::Iso::Docx::Context.new }
  let(:doc) { adapter.send(:create_document) }
  let(:inline_renderer) { IsoDoc::Iso::Docx::InlineRenderer.new(context, resolver, doc) }
  let(:toc_builder) { described_class.new(resolver, inline_renderer, context) }

  describe "#render" do
    it "renders TOC heading with Contents title" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.map { |p| entry_runs(p).map { |r| r.text || "" }.join }
      expect(texts.first).to include("Contents")
    end

    it "renders TOC entries for body sections" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Scope text.</p></clause>
          <clause id="terms"><fmt-title>Terms and definitions</fmt-title><p>Terms.</p></clause>
        </sections>
        <annex id="a1"><fmt-title>Annex A</fmt-title><p>Annex.</p></annex>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.map { |p| entry_runs(p).map { |r| r.text || "" }.join }
      # Each entry trails the PAGEREF placeholder page number.
      expect(texts).to include(a_string_including("Foreword"))
      expect(texts).to include(a_string_including("Scope"))
      expect(texts).to include(a_string_including("Terms and definitions"))
      expect(texts).to include(a_string_including("Annex A"))
    end

    it "uses TOC1/TOC2/TOC3 styles based on heading depth" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1">
            <fmt-title>Scope</fmt-title>
            <clause id="s1-1"><fmt-title>General</fmt-title><p>Text.</p></clause>
          </clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc1_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "TOC1"
      end
      toc2_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p) == "TOC2"
      end

      expect(toc1_paras.length).to be >= 1
      expect(toc2_paras.length).to be >= 1
    end

    it "renders PAGEREF fields in TOC entries" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      # Find TOC entry paragraphs (not the heading)
      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end

      # Each TOC entry should have field characters
      field_chars = toc_paras.flat_map { |p| entry_runs(p) }.select do |r|
        r.field_char || r.instr_text
      end
      expect(field_chars.length).to be > 0
    end

    it "selects the cached entry set on a Word field refresh" do
      xml = minimal_iso_xml("<sections><clause id=\"s1\"><fmt-title>Scope</fmt-title></clause></sections>")
      toc_builder.render(parse_iso_document(xml), doc)
      instr = doc.model.body.paragraphs.flat_map { |p| entry_runs(p) }.filter_map(&:instr_text)
        .map { |i| Array(i.text).join }.find { |t| t.include?("TOC") }

      # a2/a3 (annex sub-clauses) are listed in \t at level 1, matching
      # the cached entries; \u would also pull in other outline styles.
      expect(instr).to eq(
        ' TOC \\o "1-3" \\h \\z \\t "Foreword Title,1,Intro Title,1,ANNEX,1,a2,1,a3,1,Biblio Title,1" ',
      )
    end

    it "asks Word to refresh the placeholder page numbers on open" do
      xml = minimal_iso_xml("<sections><clause id=\"s1\"><fmt-title>Scope</fmt-title></clause></sections>")
      toc_builder.render(parse_iso_document(xml), doc)

      expect(doc.model.settings.update_fields).not_to be_nil
    end

    it "handles model with no sections gracefully" do
      xml = minimal_iso_xml("<sections/>")
      model = parse_iso_document(xml)

      toc_builder.render(model, doc)

      # Should at least have the heading
      texts = doc.model.body.paragraphs.map { |p| entry_runs(p).map { |r| r.text || "" }.join }
      expect(texts).to include("Contents")
    end

    it "skips TOC-type clauses to avoid duplication" do
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <clause type="toc" id="toc1"><fmt-title depth="1">Contents</fmt-title></clause>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end

      # Should have entries but not duplicate the TOC clause
      scope_entries = toc_paras.select do |p|
        entry_runs(p).any? { |r| run_text(r).include?("Scope") }
      end
      expect(scope_entries.length).to be >= 1
    end

    it "excludes the auto-generated ToC clause from the entries" do
      # The presentation XML carries the Contents clause as
      # <clause type="toc"> in the preface; the ToC title paragraph is
      # rendered separately, so the clause must not also appear as a
      # TOC-styled entry (the PDF ToC has no "Contents" line).
      xml = minimal_iso_xml(<<~INNER)
        <preface>
          <clause type="toc" id="toc1"><fmt-title depth="1">Contents</fmt-title></clause>
        </preface>
        <sections>
          <clause id="scope"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      entry_texts = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end.map do |p|
        entry_runs(p).map { |r| Array(r.text).join }.join
      end
      expect(entry_texts).not_to include(a_string_including("Contents")),
        "the type=toc Contents clause must not appear as a ToC entry"
    end

    it "renders annex entries from the single-line toc variant-title" do
      xml = minimal_iso_xml(<<~INNER)
        <sections/>
        <annex id="a1" obligation="normative">
          <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><br/><span class="fmt-obligation">(normative)</span><br/><br/><semx element="title" source="a1t">Annex text</semx></fmt-title>
          <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex text</semx></variant-title>
          <clause id="a1-1"><fmt-title>Annex sub</fmt-title><p>Body.</p></clause>
        </annex>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      toc_paras = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end
      annex_entry = toc_paras.find do |p|
        entry_runs(p).any? { |r| run_text(r) == "Annex text" }
      end
      expect(annex_entry).not_to be_nil

      # The entry carries the variant-title composition: label + tab +
      # title, with no line breaks and no obligation line.
      texts = entry_runs(annex_entry).map { |r| run_text(r) }
      expect(texts).not_to include("(normative)")
      expect(entry_runs(annex_entry).map(&:break).compact).to be_empty
      expect(entry_runs(annex_entry).any?(&:tab)).to be(true)
    end

    it "falls back to fmt-title when no toc variant-title is present" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      model = parse_iso_document(xml)
      toc_builder.render(model, doc)

      texts = doc.model.body.paragraphs.flat_map do |p|
        entry_runs(p).map { |r| run_text(r) }
      end
      expect(texts).to include("Scope")
    end

    it "lists annex sub-clauses to level 3 in the TOC1 style" do
      sub = lambda do |id, label, text, inner = ""|
        %(<clause id="#{id}"><fmt-title><span class="fmt-caption-label"><semx element="autonum" source="#{id}">#{label}</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="#{id}t">#{text}</semx></fmt-title><p>Body.</p>#{inner}</clause>)
      end
      deep = sub.call("a1-1-1-1", "A.1.1.1", "Annex level four")
      level3 = sub.call("a1-1-1", "A.1.1", "Annex level three", deep)
      level2 = sub.call("a1-1", "A.1", "Annex sub one", level3)
      xml = minimal_iso_xml(<<~INNER)
        <sections/>
        <annex id="a1">
          <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex text</semx></fmt-title>
          #{level2}
          #{sub.call('a1-2', 'A.2', 'Annex sub two')}
        </annex>
      INNER

      toc_builder.render(parse_iso_document(xml), doc)

      entries = doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.match?(/\ATOC\d\z/)
      end
      texts = entries.map { |p| entry_runs(p).map { |r| run_text(r) }.join }
      expect(texts.size).to eq(4)
      expect(texts[1]).to include("Annex sub one")
      expect(texts[2]).to include("Annex level three")
      expect(texts[3]).to include("Annex sub two")
      expect(texts.join).not_to include("Annex level four")
      expect(texts[0]).to include("Annex text")
      # The submission lists every annex sub-clause in TOC1.
      expect(entries.map { |p| para_style_value(p) }).to all(eq("TOC1"))
    end
  end

  describe "TOC field structure" do
    it "wraps the static entries in a single TOC field result" do
      xml = minimal_iso_xml(<<~INNER)
        <sections>
          <clause id="s1"><fmt-title>Scope</fmt-title><p>Test.</p></clause>
          <clause id="s2"><fmt-title>Another</fmt-title><p>Test.</p></clause>
        </sections>
      INNER

      adapter = build_adapter
      docx = nil
      Dir.mktmpdir do |dir|
        path = File.join(dir, "toc.docx")
        adapter.convert(xml, path)
        extract_docx(path) do |xml_doc, ns|
          docx = xml_doc
          ns_hash = ns
          paras = xml_doc.xpath("//w:p[w:pPr/w:pStyle[starts-with(@w:val, 'TOC')]]", ns_hash)
          expect(paras.length).to be >= 2

          # Exactly one TOC field instruction, inside the FIRST entry
          # paragraph, ahead of its entry text.
          toc_instrs = xml_doc.xpath("//w:instrText[contains(text(), 'TOC \\o')]", ns_hash)
          expect(toc_instrs.length).to eq(1)
          first = paras.first
          expect(first.xpath(".//w:instrText[contains(text(), 'TOC \\o')]", ns_hash)).not_to be_empty
          entry_texts = first.xpath(".//w:t", ns_hash).map(&:text)
          expect(entry_texts.join).not_to be_empty

          # The field separate precedes the entry content; the last entry
          # paragraph carries the TOC field end.
          types = first.xpath(".//w:fldChar/@w:fldCharType", ns_hash).map(&:value)
          expect(types.first).to eq("begin")
          expect(types).to include("separate")
          last = paras.last
          expect(last.xpath(".//w:fldChar[@w:fldCharType='end']", ns_hash)
            .length).to be >= 2 # PAGEREF end + TOC field end

          # No standalone paragraph carries only the field machinery.
          lone_field = xml_doc.xpath(
            "//w:p[w:instrText[contains(text(), 'TOC \\o')] " \
            "and not(w:pPr/w:pStyle[starts-with(@w:val, 'TOC')])]",
            ns_hash,
          )
          expect(lone_field).to be_empty
        end
      end
      expect(docx).not_to be_nil
    end
  end

  describe "TOC entry run order" do
    # A ToC entry paragraph must read: heading text, then the
    # page-number tab, then the PAGEREF field (metanorma-pdfa#119). The
    # heading's label → title separator is flattened to a space — a tab
    # at that position has no stop ahead of the pen and jumps to the
    # page-number stop, carrying the heading text to the right margin
    # behind a dot leader.

    def toc_entry_xml
      minimal_iso_xml(<<~INNER)
        <preface>
          <foreword id="fw"><fmt-title>Foreword</fmt-title><p>FW.</p></foreword>
        </preface>
        <sections>
          <clause id="s1">
            <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1t">Scope</semx></fmt-title>
            <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="s1">1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1t">Scope</semx></variant-title>
            <p>Scope text.</p>
            <clause id="s1-1">
              <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1-1">1.1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1-1t">Requirements</semx></fmt-title>
              <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="s1-1">1.1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1-1t">Requirements</semx></variant-title>
              <p>Text.</p>
              <clause id="s1-1-1">
                <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="s1-1-1">1.1.1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1-1-1t">Handling of JavaScript actions</semx></fmt-title>
                <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="s1-1-1">1.1.1</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="s1-1-1t">Handling of JavaScript actions</semx></variant-title>
                <p>Text.</p>
              </clause>
            </clause>
          </clause>
        </sections>
        <annex id="a1" obligation="normative">
          <fmt-title><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><br/><span class="fmt-obligation">(normative)</span><br/><br/><semx element="title" source="a1t">Annex text</semx></fmt-title>
          <variant-title type="toc"><span class="fmt-caption-label"><semx element="autonum" source="a1">A</semx></span><span class="fmt-caption-delim"><tab/></span><semx element="title" source="a1t">Annex text</semx></variant-title>
          <p>Annex.</p>
        </annex>
        <bibliography>
          <references>
            <title>Bibliography</title>
            <p>Intro.</p>
          </references>
        </bibliography>
      INNER
    end

    def toc_paras(doc)
      doc.model.body.paragraphs.select do |p|
        para_style_value(p)&.start_with?("TOC")
      end
    end

    def run_kind(run)
      return :instr if run.instr_text
      return :"field_#{run.field_char.fldCharType}" if run.field_char
      return :tab if run.tab
      return :text unless Array(run.text).join.empty?

      :other
    end

    def run_kinds(para)
      entry_runs(para).map { |r| run_kind(r) }
    end

    def pageref_position(runs)
      runs.index do |r|
        r.instr_text && Array(r.instr_text.text).join.include?("PAGEREF")
      end
    end

    # A ToC entry paragraph must read: heading text runs, exactly one
    # tab (the page-number tab), then the PAGEREF field machinery with
    # a non-empty placeholder result — and no heading text past the
    # tab. The TOC field opening that precedes the first entry's text
    # is skipped before the check.
    def assert_entry_run_order(para)
      runs = entry_runs(para)
      kinds = run_kinds(para)
      start = kinds.index(:text)
      expect(start).not_to be_nil,
        "entry paragraph carries no heading text: #{kinds.inspect}"

      entry = kinds[start..]
      tab_at = start + entry.index(:tab)
      expect(entry.count(:tab)).to eq(1),
        "entry paragraph must carry exactly one tab (the page-number tab)"

      pageref_at = pageref_position(runs)
      expect(pageref_at).not_to be_nil
      expect(pageref_at).to be > tab_at,
        "PAGEREF field must follow the page-number tab"
      expect(runs[tab_at + 1...pageref_at].any? { |r| run_kind(r) == :field_begin })
        .to be(true), "PAGEREF field must open after the page-number tab"

      # Heading text runs sit before the tab; the only text after it is
      # the field result.
      heading_text = kinds.each_index.select do |i|
        kinds[i] == :text && i < pageref_at
      end
      expect(heading_text).not_to be_empty
      expect(heading_text.max).to be < tab_at,
        "heading text found after the page-number tab: #{kinds.inspect}"

      # The field result is the placeholder page number: non-empty text
      # between the field separate and the field end.
      result = runs[(pageref_at + 2)...-1].find do |r|
        run_kind(r) == :text
      end
      expect(Array(result&.text).join).not_to be_empty,
        "PAGEREF field must carry a placeholder page-number result"
    end

    it "renders heading text, tab, page field per level" do
      model = parse_iso_document(toc_entry_xml)
      toc_builder.render(model, doc)

      paras = toc_paras(doc)
      expect(paras.length).to be >= 5
      paras.each { |p| assert_entry_run_order(p) }
    end

    it "styles the level-3 entry TOC3 and the annex entry TOC1" do
      model = parse_iso_document(toc_entry_xml)
      toc_builder.render(model, doc)

      styles = toc_paras(doc).map { |p| para_style_value(p) }
      expect(styles).to include("TOC1", "TOC2", "TOC3")
    end

    it "emits no empty entry for the untitled bibliography wrapper" do
      model = parse_iso_document(toc_entry_xml)
      toc_builder.render(model, doc)

      texts = toc_paras(doc).map do |p|
        entry_runs(p).map { |r| Array(r.text).join }.join
      end
      # Each entry trails the PAGEREF placeholder page number.
      expect(texts).to include(a_string_including("Bibliography"))
      expect(texts).not_to include(""),
        "the bibliography wrapper must not emit an empty ToC entry " \
        "with a PAGEREF to a nonexistent bookmark"
    end

    it "emits heading text, one tab, then the PAGEREF field in document.xml" do
      adapter = build_adapter
      Dir.mktmpdir do |dir|
        path = File.join(dir, "toc.docx")
        adapter.convert(toc_entry_xml, path)
        extract_docx(path) do |xml_doc, ns|
          paras = xml_doc.xpath(
            "//w:p[w:pPr/w:pStyle[starts-with(@w:val, 'TOC')]]", ns,
          )
          expect(paras.length).to be >= 5

          paras.each do |p|
            runs = p.xpath("./w:r | ./w:hyperlink/w:r", ns)
            kinds = runs.map do |r|
              if r.at_xpath("./w:instrText", ns)
                :instr
              elsif (fc = r.at_xpath("./w:fldChar/@w:fldCharType", ns))
                :"field_#{fc.value}"
              elsif r.at_xpath("./w:tab", ns)
                :tab
              elsif r.at_xpath("./w:t", ns) && !r.at_xpath("./w:t", ns).text.empty?
                :text
              else
                :other
              end
            end

            start = kinds.index(:text)
            expect(start).not_to be_nil,
              "document.xml entry carries no heading text"
            entry = kinds[start..]
            tab_at = start + entry.index(:tab)
            expect(entry.count(:tab)).to eq(1)

            pageref_at = start + entry.index(:instr)
            heading_text = kinds.each_index.select do |i|
              kinds[i] == :text && i < pageref_at
            end
            expect(heading_text.max).to be < tab_at,
              "heading text found after the page-number tab"

            begin_at = start + entry.index(:field_begin)
            expect(begin_at).to be > tab_at,
              "PAGEREF field must open after the page-number tab"

            # Placeholder page number: non-empty result between the
            # field separate and the field end.
            separate_at = start + entry.index(:field_separate)
            end_at = start + entry.rindex(:field_end)
            result = runs[(separate_at + 1)...end_at].find do |r|
              t = r.at_xpath("./w:t", ns)
              t && !t.text.empty?
            end
            expect(result).not_to be_nil,
              "PAGEREF field must carry a placeholder page-number result"
          end
        end
      end
    end
  end
end
