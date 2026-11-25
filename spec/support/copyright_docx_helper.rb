# frozen_string_literal: true

module CopyrightDocxHelper
  def copyright_paragraphs(document)
    texts = ["Copyright notice", "All rights reserved.", "ISO copyright office",
             "Legal notice.", "Feedback notice."]
    document.xpath("//w:body/w:p", ns).select { |p| texts.include?(p.text) }
  end

  def copyright_style_snapshot(styles)
    style = styles.at_xpath("//w:style[@w:styleId='zzCopyright']", ns)
    paths = %w[top left bottom right].map { |edge| "w:pPr/w:pBdr/w:#{edge}" }
    paths << "w:pPr/w:jc"
    paths.map do |xpath|
      style.at_xpath(xpath, ns)&.attribute_nodes&.to_h { |a| [a.name, a.value] }
    end
  end

  def copyright_template_styles(template)
    Zip::File.open(IsoDoc::Iso::DocxTemplates.template_path(template)) do |zip|
      Nokogiri::XML(zip.read("word/styles.xml"))
    end
  end

  def copyright_docx_parts(xml, template)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "copyright.docx")
      build_adapter(template: template).convert(xml, path)
      Zip::File.open(path) do |zip|
        %w[word/document.xml word/styles.xml].map do |part|
          Nokogiri::XML(zip.read(part))
        end
      end
    end
  end
end
