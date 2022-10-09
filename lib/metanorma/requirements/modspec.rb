module Metanorma
  class Requirements
    class Modspec
      # Don't want to inherit from Metanorma::Requirements::Modspec
      class Iso < ::Metanorma::Requirements::Modspec
        def recommendation_label_xref(elem, label, xrefs, _type)
          id = @reqtlabels[label]
          number = xrefs.anchor(id, :xref_reqt2reqt, false)
          number.nil? and return type
          elem.ancestors("requirement, recommendation, permission").empty? and
            return number
          "<xref target='#{id}'>#{number}</xref>"
        end

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

        def recommend_title(node, out)
          label = node.at(ns("./identifier")) or return
          out.add_child("<tr><td>#{@labels['modspec']['identifier']}</td>"\
                        "<td><tt>#{label.children.to_xml}</tt></td>")
        end

        def requirement_component_parse(node, out)
          if node["exclude"] != "true" && node.name == "description"
            lbl = "statement"
            recommend_class(node.parent) == "recommendclass" and
              lbl = "description"
            out << "<tr><td>#{@labels['modspec'][lbl]}</td>"\
                   "<td>#{node.children.to_xml}</td></tr>"
          else
            super
          end
        end

        def requirement_table_cleanup(node, table)
          return table unless table["type"] == "recommendclass"

          label = if node["type"] == "conformanceclass" then "conformancetests"
                  else "provisions" end
          ins = table.at(ns("./tbody/tr[td/table]")) or return table
          ins.replace("<tr><td>#{@labels['modspec'][label]}</td>" +
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

        def postprocess_anchor_struct(block, anchor)
          super
          anchor[:xref_reqt2reqt] = anchor[:xref_bare]
          if l = block.at(ns("./title"))
            anchor[:xref_reqt2reqt] =
              l10n("#{anchor[:xref_reqt2reqt]}: #{l.children.to_xml.strip}")
          end
          anchor
        end

        def reqt_ids(docxml)
          docxml.xpath(ns("//requirement | //recommendation | //permission"))
            .each_with_object({}) do |r, m|
              id = r.at(ns("./identifier")) or next
              m[id.text] =
                { id: r["id"],
                  lbl: @xrefs.anchor(r["id"], :xref_reqt2reqt, false) }
            end
        end

        def reqt_links_test(docxml)
          docxml.xpath(ns("//requirement | //recommendation | //permission"))
            .each_with_object({}) do |r, m|
              next unless %w(conformanceclass
                             verification).include?(r["type"])

              subj = r.at(ns("./classification[tag = 'target']/value"))
              id = r.at(ns("./identifier")) or next
              lbl = @xrefs.anchor(@reqt_ids[id.text.strip][:id], :xref_reqt2reqt,
                                  false)
              next unless subj

              m[subj.text] = { lbl: lbl, id: r["id"] }
            end
        end

        def reqt_links_class(docxml)
          docxml.xpath(ns("//requirement | //recommendation | //permission"))
            .each_with_object({}) do |r, m|
              next unless %w(class
                             conformanceclass).include?(r["type"])

              id = r.at(ns("./identifier")) or next
              r.xpath(ns("./requirement | ./recommendation | ./permission"))
                .each do |r1|
                id1 = r1.at(ns("./identifier")) or next
                lbl = @xrefs.anchor(@reqt_ids[id.text.strip][:id],
                                    :xref_reqt2reqt, false)
                next unless lbl

                m[id1.text] = { lbl: lbl, id: r["id"] }
              end
            end
        end
      end
    end
  end
end
