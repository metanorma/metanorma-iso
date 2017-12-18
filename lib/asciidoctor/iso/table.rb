module Asciidoctor
  module ISO
    module Table
      # Syntax:
      #   [[id]]
      #   .Title
      #   |===
      #   |col | col
      #   |===
      def table(node)
        noko do |xml|
          has_body = false
          table_attributes = {
            anchor: node.id,
          }

          xml.table **attr_code(table_attributes) do |xml_table|
            [:head, :body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
              has_body = true if tblsec == :body
            end
            warn "asciidoctor: WARNING (#{current_location(node)}): tables must have at least one body row" unless has_body

            xml_table.tname node.title if node.title?
            table_head_body_and_foot node, xml_table
          end
        end
      end

      private

      def table_head_body_and_foot(node, xml)
        [:head, :body, :foot].reject { |tblsec| node.rows[tblsec].empty? }.each do |tblsec|
          tblsec_tag = "t#{tblsec}"
          # "anchor" attribute from tblsec.id not supported
          xml.send tblsec_tag do |xml_tblsec|
            node.rows[tblsec].each_with_index do |row, i|
              # id not supported on row
              xml_tblsec.tr do |xml_tr|
                rowlength = 0
                row.each do |cell|
                  cell_attributes = {
                    anchor: cell.id,
                    colspan: cell.colspan,
                    rowspan: cell.rowspan,
                    align: cell.attr("halign"),
                  }

                  cell_tag = (tblsec == :head || cell.style == :header ? "th" : "td")

                  rowlength += cell.text.size
                  xml_tr.send cell_tag, **attr_code(cell_attributes) do |thd|
                    thd << (cell.style == :asciidoc ? cell.content : cell.text)
                  end
                end
                warn "asciidoctor: WARNING (#{current_location(node)}): row #{i} of table (count including header rows) is longer than 72 ascii characters" if rowlength > 72
              end
            end
          end
        end
      end
    end
  end
end
