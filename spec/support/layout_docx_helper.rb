# frozen_string_literal: true

module LayoutDocxHelper
  def converted_width_table(width_attribute, attachments, template: :dis, zone: :body, cell_content: "a")
    xml = minimal_iso_xml(<<~XML)
      <sections><clause id="scope"><title>Scope</title>
        <table id="t1" #{width_attribute}>
          <colgroup><col width="25%"/><col width="75%"/></colgroup>
          <tbody><tr><td>#{cell_content}</td><td>b</td></tr>
            <tr><td colspan="2">spanning cell</td></tr></tbody>
          #{attachments}
        </table>
      </clause></sections>
    XML
    if zone == :front
      xml = xml.sub('<sections><clause id="scope">', '<preface><foreword id="scope">')
        .sub("</clause></sections>", "</foreword></preface>")
    end
    Dir.mktmpdir do |dir|
      path = File.join(dir, "table.docx")
      build_adapter(template: template).convert(xml, path)
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

  def converted_header_texts(adapter, identifier)
    bib = if identifier.empty?
            ""
          else
            %(<bibdata><docidentifier type="iso-with-lang">#{identifier}</docidentifier></bibdata>)
          end
    xml = minimal_iso_xml(<<~XML)
      #{bib}
      <sections><clause id="scope"><title>Scope</title><p>Body.</p></clause></sections>
    XML
    Dir.mktmpdir do |dir|
      path = File.join(dir, "headers.docx")
      adapter.convert(xml, path)
      Zip::File.open(path) do |zip|
        document = Nokogiri::XML(zip.read("word/document.xml"))
        relationships = Nokogiri::XML(zip.read("word/_rels/document.xml.rels"))
        texts = document.xpath("//w:headerReference[@w:type!='first']", layout_ns).map do |reference|
          id = reference["r:id"]
          target = relationships.at_xpath("//*[@Id='#{id}']")["Target"]
          Nokogiri::XML(zip.read("word/#{target}")).xpath("//w:t", layout_ns).map(&:text).join
        end.uniq
        identifier.empty? ? texts : texts.reject(&:empty?)
      end
    end
  end

  def middle_title_lines(xml)
    styles = %w[MainTitle1 MainTitle2]
    convert_and_extract(adapter, xml) do |pkg|
      return pkg.document.body.paragraphs.filter_map do |paragraph|
        style = para_style_value(paragraph)
        next unless styles.include?(style)

        [style, paragraph.runs.map { |run| run_text(run) }.join]
      end
    end
  end
end
