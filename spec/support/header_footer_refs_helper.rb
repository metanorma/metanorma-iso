# frozen_string_literal: true

module HeaderFooterRefsHelper
  def template_part_references(zip)
    document = Nokogiri::XML(zip.read("word/document.xml"))
    relationships = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
    document.xpath("//w:sectPr").map do |section|
      section.xpath("w:headerReference | w:footerReference").to_h do |ref|
        id = ref.at_xpath("@r:id").value
        relation = relationships.at_xpath("/*/*[@Id = $id]", nil, id: id)
        target = relation&.[]("Target")
        [[ref.name.delete_suffix("Reference"), ref.at_xpath("@w:type").value],
         [target, relation&.[]("Type").to_s.split("/").last,
          !zip.find_entry("word/#{target}").nil?]]
      end
    end
  end

  def with_generated_header_footer_package(template, &block)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "sections.docx")
      build_adapter(template: template).convert(minimal_iso_xml("<sections/>"), path)
      Zip::File.open(path, &block)
    end
  end

  def template_effective_references(template)
    Zip::File.open(IsoDoc::Iso::DocxTemplates.template_path(template)) do |zip|
      _, front, body = template_part_references(zip)
      [front, front.merge(body)]
    end
  end

  def effective_part_alignment(styles, id)
    style = styles.at_xpath("//w:style[@w:styleId = $id]", nil, id: id)
    alignment = style.at_xpath("w:pPr/w:jc/@w:val")&.value
    return alignment if alignment

    base = style.at_xpath("w:basedOn/@w:val")&.value
    effective_part_alignment(styles, base) if base
  end

  def generated_part_styles(zip)
    template_part_references(zip).drop(1).map do |refs|
      refs.transform_values do |target, _|
        Nokogiri::XML(zip.read("word/#{target}")).xpath("//w:p/w:pPr/w:pStyle/@w:val").map(&:value)
      end
    end
  end
end
