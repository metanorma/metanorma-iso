# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe IsoDoc::Iso::Docx::Renderers::OrderedListRenderer do
  let(:adapter) { build_adapter }

  def li_xml(id, label, delim, text, extra = "")
    <<~LI
      <li id="#{id}"><fmt-name><semx element="autonum" source="#{id}">#{label}</semx><span class="fmt-label-delim">#{delim}</span></fmt-name><p>#{text}</p>#{extra}</li>
    LI
  end

  def label_and_tab(para)
    runs = para.runs
    [run_text(runs.first), !runs[1].tab.nil?, runs[2..].map { |r| run_text(r) }.join]
  end

  it "renders every item as a ListNumber1 paragraph with its text" do
    xml = minimal_iso_xml(<<~INNER)
      <sections>
        <clause id="c1">
          <title>Scope</title>
          <ol id="ol1" type="arabic">
            #{li_xml('l1', '1', ')', 'One.')}
            #{li_xml('l2', '2', ')', 'Two.')}
          </ol>
        </clause>
      </sections>
    INNER

    convert_and_extract(adapter, xml) do |pkg|
      paras = pkg.document.body.paragraphs.select do |p|
        para_style_value(p) == "ListNumber1"
      end
      expect(paras.map { |p| label_and_tab(p) }).to eq(
        [["1)", true, "One."], ["2)", true, "Two."]],
      )
    end
  end

  it "dispatches OrderedList via exact-class lookup" do
    registry = IsoDoc::Iso::Docx::Renderers::Registry.new do |r|
      r.register(
        Metanorma::Document::Components::Lists::OrderedList,
        :ordered_renderer,
      )
    end

    expect(registry.lookup(Metanorma::Document::Components::Lists::OrderedList))
      .to eq(:ordered_renderer)
  end

  describe "ISO label rendering (reference: literal label + tab, no numPr)" do
    it "renders the presentation label as literal text then a tab, without numPr" do
      nested = "<ol id=\"o2\" type=\"arabic\">#{li_xml('l2', '1', ')', 'Inner')}</ol>"
      xml = minimal_iso_xml(<<~INNER)
        <sections><clause id="c1"><title>Scope</title>
          <ol id="o1" type="alphabet">
            #{li_xml('l1', 'a', ')', 'Outer', nested)}
            #{li_xml('l3', 'b', ')', 'Second')}
          </ol>
          <ol id="o3" type="roman_upper">#{li_xml('l4', 'I', '.', 'Fresh')}</ol>
        </clause></sections>
      INNER

      convert_and_extract(adapter, xml) do |pkg|
        paras = pkg.document.body.paragraphs.select do |p|
          para_style_value(p).to_s.start_with?("ListNumber")
        end

        expect(paras.map { |p| para_style_value(p) }).to eq(
          %w[ListNumber1 ListNumber2 ListNumber1 ListNumber1],
        )
        expect(paras.map { |p| p.properties&.numbering_properties }).to all(be_nil)
        expect(paras.map { |p| label_and_tab(p) }).to eq(
          [["a)", true, "Outer"], ["1)", true, "Inner"],
           ["b)", true, "Second"], ["I.", true, "Fresh"]],
        )
      end
    end
  end

  describe "items without a lead paragraph (label must not double)" do
    def fmt_name(label)
      "<fmt-name><semx element=\"autonum\" source=\"x\">#{label}</semx><span class=\"fmt-label-delim\">)</span></fmt-name>"
    end

    def list_paras(inner)
      xml = minimal_iso_xml(<<~INNER)
        <sections><clause id="c1"><title>Scope</title>#{inner}</clause></sections>
      INNER
      convert_and_extract(adapter, xml) do |pkg|
        return pkg.document.body.paragraphs.select do |p|
          para_style_value(p).to_s.start_with?("ListNumber") ||
              %w[Note Noteindent].include?(para_style_value(p))
        end
      end
    end

    def texts(paras)
      paras.map { |p| p.runs.map { |r| r.tab ? "<TAB>" : run_text(r) }.join }
    end

    it "renders a fmt-name-only item as the label once" do
      paras = list_paras("<ol id=\"o1\"><li id=\"l1\">#{fmt_name('a')}</li></ol>")
      expect(texts(paras)).to eq(["a)<TAB>"])
    end

    it "renders a fmt-name + note item as the label once, then the note" do
      paras = list_paras(
        "<ol id=\"o1\"><li id=\"l1\">#{fmt_name('b')}<note id=\"n1\"><p>a note</p></note></li></ol>",
      )
      expect(texts(paras)).to eq(["b)<TAB>", "a note"])
    end

    it "renders a fmt-name + nested ol item as the label once" do
      paras = list_paras(
        "<ol id=\"o1\"><li id=\"l1\">#{fmt_name('c')}<ol id=\"o2\"><li id=\"l2\">#{fmt_name('1')}<p>inner</p></li></ol></li></ol>",
      )
      expect(texts(paras)).to eq(["c)<TAB>", "1)<TAB>inner"])
      expect(paras.map { |p| para_style_value(p) }).to eq(%w[ListNumber1 ListNumber2])
    end
  end

  describe "semantic XML without a fmt-name label" do
    %w[<ol\ id="o1"><li\ id="l1"><p>plain</p></li></ol>
       <ol\ id="o1"><li\ id="l1"><fmt-name/><p>plain</p></li></ol>].each do |frag|
      it "falls back to numPr with no tab or literal label (#{frag[0, 40]})" do
        xml = minimal_iso_xml(<<~INNER)
          <sections><clause id="c1"><title>Scope</title>#{frag}</clause></sections>
        INNER
        convert_and_extract(adapter, xml) do |pkg|
          para = pkg.document.body.paragraphs.find { |p| para_style_value(p) == "ListNumber1" }
          expect(para.runs.map { |r| run_text(r) }.join).to eq("plain")
          expect(para.runs.any?(&:tab)).to be(false)
          expect(para.properties.numbering_properties.num_id.value).to eq(1)
        end
      end
    end
  end
end
