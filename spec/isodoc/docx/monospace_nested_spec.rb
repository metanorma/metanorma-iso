# frozen_string_literal: true

require_relative "spec_helper"

# <tt> keeps nested inline content (the xref below arrives as a <semx>
# the TtElement model retains) in order, styled as InlineCode.
RSpec.describe IsoDoc::Iso::Docx::InlineRenderers::MonospaceRenderer do # rubocop:disable RSpec/SpecFilePathFormat
  def render_tt(inner)
    context = IsoDoc::Iso::Docx::Context.new
    resolver = IsoDoc::Iso::Docx::StyleResolver.new(
      IsoDoc::Iso::DocxStyleMapping.new, context
    )
    parent = IsoDoc::Iso::Docx::InlineRenderer.new(
      context, resolver, Uniword::Builder::DocumentBuilder.new
    )
    xml = minimal_iso_xml("<sections><clause id='c'><p><tt>#{inner}</tt>" \
                          "</p></clause></sections>")
    p_el = parse_iso_document(xml).sections.clause.first.paragraphs.first
    tt = nil
    parent.each_ordered_element(p_el) do |type, obj|
      (tt = obj) && break if type == :element
    end
    para = Uniword::Builder::ParagraphBuilder.new
    described_class.new(parent).render(tt, para)
    runs_of(para.build.to_xml)
  end

  # [[text, rStyle], ...] for every run, in document order.
  def runs_of(xml)
    Nokogiri::XML(xml).remove_namespaces!.xpath("//r").map do |r|
      [r.xpath(".//t").map(&:text).join,
       r.to_xml[/rStyle w:val="([^"]+)"/, 1]]
    end
  end

  it "keeps plain tt as one InlineCode run, whitespace intact" do
    expect(render_tt("a  b")).to eq([["a  b", "InlineCode"]])
  end

  it "keeps a nested xref once, in order, styled InlineCode" do
    runs = render_tt("a <semx element='xref' source='i'>" \
                     "<fmt-xref target='c'>[c]</fmt-xref></semx> b")
    expect(runs).to eq([["a ", "InlineCode"], ["[c]", "InlineCode"],
                        [" b", "InlineCode"]])
  end
end
