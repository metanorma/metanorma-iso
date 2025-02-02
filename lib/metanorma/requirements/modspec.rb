module Metanorma
  class Requirements
    class Modspec
      class Iso < ::Metanorma::Requirements::Modspec
        def requirement_table_nested_cleanup(node, out, table)
          (out.xpath(ns(".//table")) - out.xpath(ns("./fmt-provision/table"))).each do |x|
            x["unnumbered"] = "true"
          end
          table["type"] == "recommendclass" or return super # table
          ins = table.at(ns("./tbody/tr[td/*/fmt-provision/table]")) or return table
          ins.replace(requirement_table_cleanup_nested_replacement(node, out, table))
          table.xpath(ns("./tbody/tr[td/*/fmt-provision/table]")).each(&:remove)
          out.xpath(ns("./*/fmt-provision")).each(&:remove)
          table
        end

        def requirement_table_cleanup_nested_replacement(node, out, table)
          label = "provision"
          node["type"] == "conformanceclass" and label = "conformancetest"
          n = nested_tables_names(table)
          hdr = @i18n.inflect(@labels["modspec"][label],
                              number: n.size == 1 ? "sg" : "pl")
          "<tr><th>#{hdr}</th><td>#{n.join('<br/>')}</td></tr>"
        end

        def nested_tables_names(table)
          table.xpath(ns("./tbody/tr/td/*/fmt-provision/table"))
            .each_with_object([]) do |t, m|
              id = t["original-id"] || t["id"]
              id and b = "<bookmark id='#{id}'/>"
              m << b + t.at(ns(".//fmt-name")).children.to_xml
            end
        end

        def postprocess_anchor_struct(block, anchor)
          super
          t = block.at(ns("./fmt-provision/table")) and
            anchor[:container] = t["id"]
          anchor[:modspec] = anchor[:xref_bare]
          if l = block.at(ns("./title"))
            anchor[:modspec] =
              l10n("#{anchor[:modspec]}<span class='fmt-caption-delim'>: </span><semx element='title' source='#{block['id']}'>#{l.children.to_xml.strip}</semx>")
          end
          /<xref/.match?(anchor[:modspec]) or
            anchor[:modspec] = "<xref target='#{block['id']}'>#{anchor[:modspec]}</xref>"
          anchor
        end
      end
    end
  end
end
