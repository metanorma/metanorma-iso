# frozen_string_literal: true

module LayoutDocxHelper
  def converted_width_table(width_attribute, attachments)
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="scope"><title>Scope</title>
        <table id="t1" #{width_attribute}>
          <colgroup><col width="25%"/><col width="75%"/></colgroup>
          <tbody><tr><td>a</td><td>b</td></tr>
            <tr><td colspan="2">spanning cell</td></tr></tbody>
          #{attachments}
        </table>
      </clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "table.docx")
      build_adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        Nokogiri::XML(zip.read("word/document.xml")).at_xpath("//w:tbl", layout_ns)
      end
    end
  end

  def layout_ns
    { "w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  end

  def table_width_values(table)
    %w[type w].map { |attr| table.at_xpath("w:tblPr/w:tblW/@w:#{attr}", layout_ns).value }
  end

  def table_grid_values(table)
    table.xpath("w:tblGrid/w:gridCol/@w:w", layout_ns).map { |w| w.value.to_i }
  end

  def header_parts(root)
    root.header_footer_parts.of_kind(:header)
  end

  def footer_parts(root)
    root.header_footer_parts.of_kind(:footer)
  end

  def part_properties(part)
    part.content.paragraphs.map { |p| p.properties.to_xml }
  end

  def part_text(part)
    Nokogiri::XML(part.content.to_xml).xpath("//w:t", layout_ns).map(&:text).join
  end

  def footer_layout(part)
    runs = part.content.paragraphs.flat_map(&:runs)
    order = runs.filter_map do |run|
      if run.instr_text
        :page
      elsif run_text(run).include?("©")
        :copyright
      end
    end
    [part_properties(part), runs.count(&:tab), order]
  end
end
