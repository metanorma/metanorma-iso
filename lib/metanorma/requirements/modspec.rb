module Metanorma
  class Requirements
    class Modspec
      # Don't want to inherit from Metanorma::Requirements::Modspec
      class Iso < ::Metanorma::Requirements::Modspec
        def recommendation_label(elem, type, xrefs)
          lbl = super
          title = elem.at(ns("./title"))
          return lbl unless title &&
            elem.ancestors("requirement, recommendation, permission").empty?

          lbl += ": " if lbl
          lbl += title.children.to_xml
          l10n(lbl)
        end

        # ISO labels modspec reqt as table, with reqt label as title
        def recommendation_header(reqt, out)
          n = reqt.at(ns("./name")) and out << n
          out
        end

        def requirement_table_nested_cleanup(node, table)
          table["type"] == "recommendclass" or return table
          ins = table.at(ns("./tbody/tr[td/table]")) or return table
          ins.replace(requirement_table_cleanup_nested_replacement(node, table))
          table.xpath(ns("./tbody/tr[td/table]")).each(&:remove)
          table
        end

        def requirement_table_cleanup_nested_replacement(node, table)
          label = "provision"
          node["type"] == "conformanceclass" and label = "conformancetest"
          n = nested_tables_names(table)
          hdr = @i18n.inflect(@labels["modspec"][label],
                              number: n.size == 1 ? "sg" : "pl")
          "<tr><th>#{hdr}</th><td>#{n.join('<br/>')}</td></tr>"
        end

        def nested_tables_names(table)
          table.xpath(ns("./tbody/tr/td/table"))
            .each_with_object([]) do |t, m|
              m << t.at(ns("./name")).children.to_xml
            end
        end

        def postprocess_anchor_struct(block, anchor)
          super
          anchor[:modspec] = anchor[:xref_bare]
          if l = block.at(ns("./title"))
            anchor[:modspec] =
              l10n("#{anchor[:modspec]}: #{l.children.to_xml.strip}")
          end
          anchor
        end
      end
    end
  end
end
