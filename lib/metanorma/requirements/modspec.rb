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

          lbl += l10n(": ") if lbl
          lbl += title.children.to_xml
          lbl
        end

        # ISO labels modspec reqt as table, with reqt label as title
        def recommendation_header(reqt, out)
          reqt.ancestors("requirement, recommendation, permission").empty? or
            return out

          n = reqt.at(ns("./name")) and out << n
          out
        end

        def recommend_title(node, out)
          label = node.at(ns("./identifier")) or return
          out.add_child("<tr><td>#{@labels['modspec']['identifier']}</td>"\
                        "<td><tt>#{label.children.to_xml}</tt></td>")
        end
      end
    end
  end
end
