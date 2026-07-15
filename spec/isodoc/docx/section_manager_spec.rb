# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe IsoDoc::Iso::Docx::SectionManager do
  let(:adapter) { build_adapter }
  let(:resolver) { adapter.resolver }
  let(:hf_renderer) { IsoDoc::Iso::Docx::HeaderFooterRenderer.new(resolver) }
  let(:section_mgr) { described_class.new(resolver, hf_renderer) }

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
      expect(sec.page_numbering.format).to eq("lowerRoman")
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
      expect(sec.page_numbering.format).to eq(section_mgr.front_matter_scheme.format)
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
      style_value = para.properties&.style&.value
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
      style_value = para.properties&.style&.value
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
      expect(para.field_chars.map(&:fldCharType)).to eq(%w[begin separate end])
      expect(para.instr_text.map(&:text).join).to include("PAGE")
    end
  end
end
