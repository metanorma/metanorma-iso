# frozen_string_literal: true

module ContainedDocxHelper
  def contained_ns
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  end

  def converted_contained_table(xml)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "contained.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        Nokogiri::XML(zip.read("word/document.xml"))
          .at_xpath("//w:tbl[not(ancestor::w:tbl)]", contained_ns)
      end
    end
  end
end
