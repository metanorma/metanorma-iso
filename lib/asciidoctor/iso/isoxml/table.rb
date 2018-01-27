module Asciidoctor
  module ISO
    module ISOXML
      module Table
        def table(node)
          noko do |xml|
            xml.table **{ id: Utils::anchor_or_uuid(node) } do |xml_table|
              %i(head body foot).reject do |tblsec|
                node.rows[tblsec].empty?
              end
              xml_table.name node.title if node.title?
              table_head_body_and_foot node, xml_table
            end
          end
        end

        private

        def table_cell1(cell, thd)
          if cell.style == :asciidoc
            thd << cell.content
          else
            thd << cell.text
            Validate::style(cell, cell.text)
          end
        end

        def table_cell(c, xml_tr, tblsec)
          cell_attributes = { id: c.id, colspan: c.colspan,
                              rowspan: c.rowspan, align: c.attr("halign") }
          cell_tag = "td"
          cell_tag = "th" if tblsec == :head || c.style == :header
          xml_tr.send cell_tag, **attr_code(cell_attributes) do |thd|
            table_cell1(c, thd)
          end
        end

        def table_head_body_and_foot(node, xml)
          %i(head body foot).reject { |s| node.rows[s].empty? }.each do |s|
            xml.send "t#{s}" do |xml_tblsec|
              node.rows[s].each do |row|
                xml_tblsec.tr do |xml_tr|
                  row.each { |cell| table_cell(cell, xml_tr, s) }
                end
              end
            end
          end
        end
      end
    end
  end
end
