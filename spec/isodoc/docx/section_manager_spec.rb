# frozen_string_literal: true

require_relative "spec_helper"
require "metanorma-iso"

RSpec.describe IsoDoc::Iso::Docx::SectionManager do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:hf_renderer) { IsoDoc::Iso::Docx::HeaderFooterRenderer.new(resolver) }
  let(:section_mgr) { described_class.new(resolver, hf_renderer) }

  it "writes the three DIS sections with the cover break before copyright" do
    with_dis_package { |zip| expect_dis_sections(zip) }
  end

  it "serializes the DIS front matter page numbering as w:fmt" do
    with_dis_package do |zip|
      format = dis_front_matter_format(zip)
      expect(format).to eq("lowerRoman")
    end
  end

  def dis_front_matter_format(zip)
    document = Nokogiri::XML(zip.read("word/document.xml"))
    document.at_xpath("(//w:body/w:p/w:pPr/w:sectPr)[2]/w:pgNumType/@w:fmt")&.value
  end

  def with_dis_package(&block)
    fixture = "spec/fixtures/iso/is/document-en.dis.presentation.xml"
    Dir.mktmpdir do |dir|
      output = File.join(dir, "dis.docx")
      Metanorma::Iso::Processor.new.output(nil, fixture, output, :docx)
      Zip::File.open(output, &block)
    end
  end

  def expect_dis_sections(zip)
    document = Nokogiri::XML(zip.read("word/document.xml"))
    body = document.at_xpath("//w:body")
    sections = body.xpath("w:p/w:pPr/w:sectPr | w:sectPr")
    expect(sections.size).to eq(3)
    expect(sections.last.parent).to eq(body)
    expect_dis_layout(sections)
    expect_cover_position(sections.first.parent.parent)
    expect_section_references(zip, sections)
  end

  def expect_dis_layout(sections)
    cover, front, body = sections
    expect(sections.map { |sec| sec.xpath("w:pgSz/@w:w | w:pgSz/@w:h").map(&:value) })
      .to eq([%w[11906 16838]] * 3)
    margin_names = %w[top right bottom left header footer gutter]
    margins = sections.map do |sec|
      margin_names.map do |name|
        sec.at_xpath("w:pgMar/@w:#{name}")&.value
      end
    end
    expected_margins = [
      %w[794 737 284 851 709 0 567],
      %w[794 851 567 851 720 283 0],
      %w[794 851 567 851 720 283 0],
    ]
    expect(margins).to eq(expected_margins)
    expect(sections.xpath("w:cols/@w:space").map(&:value)).to eq(["720"] * 3)
    expect(sections.xpath("w:docGrid/@w:linePitch").map(&:value)).to eq(["360"] * 3)
    expect(cover.at_xpath("@w:rsidR")&.value).to eq("00000000")
    expect(front.at_xpath("@w:rsidR")&.value).to eq("00000000")
    expect(cover.at_xpath("w:pgNumType")).to be_nil
    expect(cover.at_xpath("w:titlePg")).to be_nil
    expect(body.at_xpath("w:pgNumType/@w:start")&.value).to eq("1")
  end

  def expect_cover_position(cover_break)
    copyright = cover_break.at_xpath("following-sibling::w:p[contains(., '© ISO')]")
    contents = copyright&.at_xpath("following-sibling::w:p[.//w:t = 'Contents']")
    expect(cover_break.xpath("preceding-sibling::w:p[contains(., '© ISO')]")).to be_empty
    expect(copyright).not_to be_nil
    expect(contents&.previous_element&.at_xpath(".//w:br[@w:type = 'page']")).not_to be_nil
  end

  def expect_section_references(zip, sections)
    rels = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
    targets = sections.map do |sec|
      sec.xpath("w:headerReference | w:footerReference").map do |ref|
        id = ref.at_xpath("@r:id").value
        rel = rels.at_xpath("/*/*[@Id = $id]", nil, id: id)
        kind = ref.name.delete_suffix("Reference")
        expect(rel["Type"]).to end_with("/#{kind}")
        expect(zip.find_entry("word/#{rel['Target']}")).not_to be_nil
        [kind, ref.at_xpath("@w:type").value, rel["Target"]]
      end
    end
    cover, *later = targets
    cover_types = [%w[header even], %w[footer even], %w[footer default]]
    later_types = [%w[header even], %w[header default], %w[footer even], %w[footer default]]
    expect(cover.map { |kind, type, _| [kind, type] }).to eq(cover_types)
    later.each do |refs|
      expect(refs.map { |kind, type, _| [kind, type] }).to eq(later_types)
    end
    expect(targets.flatten(1).map(&:last).uniq.size).to eq(11)
    cover.each do |_, _, target|
      part = Nokogiri::XML(zip.read("word/#{target}"))
      expect(part.root.element_children.map(&:name)).to eq(["p"])
      expect(part.root.text).to be_empty
    end
  end

  describe "#insert_cover_section" do
    it "inserts a section break paragraph after cover page" do
      doc = adapter.send(:create_document)
      doc.paragraph { |p| p << "Cover content" }

      section_mgr.insert_cover_section(doc)

      paragraphs = doc.model.body.paragraphs
      # Should have cover content + section break paragraph
      expect(paragraphs.length).to be >= 2

      # Last paragraph should have section properties
      sect_para = paragraphs.last
      expect(sect_para.properties&.section_properties).not_to be_nil
      sec = sect_para.properties.section_properties
      expect(sec.page_size.width).to eq(11_906)
      expect(sec.page_size.height).to eq(16_838)
    end

    it "sets cover page margins" do
      doc = adapter.send(:create_document)
      section_mgr.insert_cover_section(doc)

      sect_para = doc.model.body.paragraphs.last
      sec = sect_para.properties.section_properties
      expect(sec.page_margins.top).to eq(794)
      expect(sec.page_margins.gutter).to eq(567)
    end

    it "sets docGrid linePitch" do
      doc = adapter.send(:create_document)
      section_mgr.insert_cover_section(doc)

      sect_para = doc.model.body.paragraphs.last
      sec = sect_para.properties.section_properties
      expect(sec.doc_grid).not_to be_nil
    end
  end

  describe "#insert_front_matter_section" do
    it "inserts a section break with roman numeral page numbering" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      sect_para = doc.model.body.paragraphs.last
      sec = sect_para.properties.section_properties
      expect(sec.page_numbering).not_to be_nil
      expect(sec.page_numbering.fmt).to eq("lowerRoman")
    end

    it "includes header and footer references" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      sect_para = doc.model.body.paragraphs.last
      sec = sect_para.properties.section_properties
      expect(sec.header_references.length).to be >= 1
      expect(sec.footer_references.length).to be >= 1
    end

    it "uses valid rIds from template header/footer parts" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      sect_para = doc.model.body.paragraphs.last
      sec = sect_para.properties.section_properties

      # Verify rIds match template parts
      header_rids = sec.header_references.map(&:r_id)
      footer_rids = sec.footer_references.map(&:r_id)

      expect(header_rids).to include("rId16", "rId17")
      expect(footer_rids).to include("rId18", "rId19")
    end

    it "rewrites header content for front matter" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      # Find the header part and check its content
      parts = doc.model.header_footer_parts
      header_part = parts.find { |p| p[:r_id] == "rId16" }
      expect(header_part).not_to be_nil

      header_text = header_part[:content].paragraphs
        .map { |p| p.runs.map { |r| r.text }.join }.join
      expect(header_text).to include("ISO/CD 17301-1:2016(en)")
    end
  end

  describe "#apply_body_section" do
    it "sets body section properties with arabic page numbering" do
      doc = adapter.send(:create_document)
      section_mgr.apply_body_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      body = doc.model.body
      expect(body.section_properties).not_to be_nil
      sec = body.section_properties
      expect(sec.page_numbering.start).to eq(1)
    end

    it "sets correct page dimensions" do
      doc = adapter.send(:create_document)
      section_mgr.apply_body_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      sec = doc.model.body.section_properties
      expect(sec.page_size.width).to eq(11_906)
      expect(sec.page_size.height).to eq(16_838)
    end
  end

  describe "page numbering schemes" do
    it "exposes a roman scheme for the front matter section" do
      scheme = section_mgr.front_matter_scheme
      expect(scheme).to be_roman
      expect(scheme).to be_page_number
    end

    it "exposes an arabic scheme for the body section" do
      scheme = section_mgr.body_scheme
      expect(scheme).to be_arabic
      expect(scheme).to be_page_number
    end

    it "front matter section uses the scheme's format in its sectPr" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      sec = doc.model.body.paragraphs.last.properties.section_properties
      expect(sec.page_numbering.fmt).to eq(section_mgr.front_matter_scheme.format)
    end
  end

  describe "footer content via HeaderFooterRenderer" do
    it "writes a roman footer with FooterPageRomanNumber style" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      footer_part = doc.model.header_footer_parts
        .find { |p| p[:r_id] == IsoDoc::Iso::Docx::SectionManager::FRONT_FOOTER_DEFAULT }
      expect(footer_part).not_to be_nil

      para = footer_part[:content].paragraphs.first
      style_value = para_style_value(para)
      expect(style_value).to eq("FooterPageRomanNumber"),
        "front matter footer should use FooterPageRomanNumber, got: #{style_value.inspect}"
    end

    it "writes an arabic footer with FooterPageNumber style" do
      doc = adapter.send(:create_document)
      section_mgr.apply_body_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2024"
      )

      footer_part = doc.model.header_footer_parts
        .find { |p| p[:r_id] == IsoDoc::Iso::Docx::SectionManager::BODY_FOOTER_DEFAULT }
      expect(footer_part).not_to be_nil

      para = footer_part[:content].paragraphs.first
      style_value = para_style_value(para)
      expect(style_value).to eq("FooterPageNumber"),
        "body footer should use FooterPageNumber, got: #{style_value.inspect}"
    end

    it "embeds a complete PAGE field in every footer" do
      doc = adapter.send(:create_document)
      section_mgr.insert_front_matter_section(
        doc, header_text: "ISO/CD 17301-1:2016(en)", copyright_text: "© ISO 2016"
      )

      footer_part = doc.model.header_footer_parts
        .find { |p| p[:r_id] == IsoDoc::Iso::Docx::SectionManager::FRONT_FOOTER_DEFAULT }
      para = footer_part[:content].paragraphs.first
      # Field components live inside runs (bare <w:fldChar>/<w:instrText>
      # paragraph children are schema-invalid OOXML).
      fld_types = para.runs.filter_map { |r| r.field_char&.fldCharType }
      expect(fld_types).to eq(%w[begin separate end])
      instr = para.runs.filter_map { |r| r.instr_text&.content&.join }.join
      expect(instr).to include("PAGE")
    end
  end
end
