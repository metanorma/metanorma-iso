module Metanorma
  class Requirements
    class Modspec
      # Don't want to inherit from Metanorma::Requirements::Modspec
      class Iso < ::Metanorma::Requirements::Modspec
        def recommendation_label(elem, type, xrefs)
          lbl = super
          title = elem.at(ns("./title"))
          return lbl unless title # &&

          #  elem.ancestors("requirement, recommendation, permission").empty?

          lbl += l10n(": ") if lbl
          lbl += title.children.to_xml
          lbl
        end

        # ISO labels modspec reqt as table, with reqt label as title
        def recommendation_header(reqt, out)
          n = reqt.at(ns("./name")) and out << n
          out
        end

        def recommend_title(node, out)
          label = node.at(ns("./identifier")) or return
          out.add_child("<tr><td>#{@labels['modspec']['identifier']}</td>"\
                        "<td><tt>#{label.children.to_xml}</tt></td>")
        end

        def requirement_component_parse(node, out)
          if node["exclude"] != "true" && node.name == "description"
            out << "<tr><td>#{@labels['modspec']['description']}</td>"\
                   "<td>#{node.children.to_xml}</td></tr>"
          else
            super
          end
        end

        def requirement_table_cleanup(table)
          return table unless table["type"] == "recommendclass"

          ins = table.at(ns("./tbody/tr[td/table]")) or return table
          ins.replace("<tr><td>#{@labels['modspec']['provisions']}</td>" +
                      "<td>#{nested_tables_names(table)}</td></tr>")
          table.xpath(ns("./tbody/tr[td/table]")).each(&:remove)
          table
        end

        def nested_tables_names(table)
          table.xpath(ns("./tbody/tr/td/table"))
            .each_with_object([]) do |t, m|
              m << t.at(ns("./name")).children.to_xml
            end.join("<br/>")
        end
      end
    end
  end
end
