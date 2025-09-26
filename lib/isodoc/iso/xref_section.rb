module IsoDoc
  module Iso
    class Xref < IsoDoc::Xref
      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: nil, level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = clause_counter(0)
        clause.xpath(ns("./clause")).each do |c|
          section_names1(c, semx(clause, "0"), i.increment(c).print, 2)
        end
      end

      # subclauses are not prefixed with "Clause"
      # retaining subtype for the semantics
      def section_name_anchors(clause, num, level)
        if clause["type"] == "section"
          xref = labelled_autonum(@labels["section"], num)
          label = labelled_autonum(@labels["section"], num)
          @anchors[clause["id"]] =
            { label:, xref:, elem: @labels["section"],
              title: clause_title(clause), level: level, type: "clause" }
        elsif level > 1
          @anchors[clause["id"]] =
            { label: num, level: level, xref: num, subtype: "clause" }
        else super end
      end

      def annex_name_anchors1(clause, num, level)
        level == 1 and return annex_name_anchors(clause, num, level)
        ret = { label: num, level: level, subtype: "annex" }
        ret2 = if level == 2
                 xref = labelled_autonum(@labels["clause"], num)
                 { xref:, # l10n("#{@labels['clause']} #{num}"),
                   elem: @labels["clause"] }
               else
                 { xref: semx(clause, num) }
               end
        @anchors[clause["id"]] = ret.merge(ret2)
      end
    end
  end
end
