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

        def reqt_links_test1(reqt, acc)
          return unless %w(conformanceclass
                           verification).include?(reqt["type"])

          subj = reqt_extract_target(reqt)
          id = reqt.at(ns("./identifier")) or return
          lbl = @xrefs.anchor(@reqt_ids[id.text.strip][:id], :xref_reqt2reqt,
                              false)
          return unless subj

          acc[subj.text] = { lbl: lbl, id: reqt["id"] }
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