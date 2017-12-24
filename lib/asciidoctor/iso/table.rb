module Asciidoctor
  module ISO
    module Table
      def table(node)
        noko do |xml|
          has_body = false
          xml.table **attr_code(anchor: node.id) do |xml_table|
            %i(head body foot).reject do |tblsec|
              node.rows[tblsec].empty?
            end.each do |tblsec|
              has_body = true if tblsec == :body
            end
            xml_table.name node.title if node.title?
            table_head_body_and_foot node, xml_table
          end
        end
      end

      private

      def table_head_body_and_foot(node, xml)
        %i(head body foot).reject do |tblsec|
          node.rows[tblsec].empty?
        end.each do |tblsec|
          tblsec_tag = "t#{tblsec}"
          # "anchor" attribute from tblsec.id not supported
          xml.send tblsec_tag do |xml_tblsec|
            node.rows[tblsec].each_with_index do |row, i|
              xml_tblsec.tr do |xml_tr|
                rowlength = 0
                row.each do |cell|
                  cell_attributes = {
                    anchor: cell.id,
                    colspan: cell.colspan,
                    rowspan: cell.rowspan,
                    align: cell.attr("halign"),
                  }

                  cell_tag = "td"
                  cell_tag = "th" if tblsec == :head || cell.style == :header
                  rowlength += cell.text.size
                  xml_tr.send cell_tag, **attr_code(cell_attributes) do |thd|
                    thd << (cell.style == :asciidoc ? cell.content : cell.text)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
