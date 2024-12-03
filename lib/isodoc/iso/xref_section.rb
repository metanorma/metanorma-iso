module IsoDoc
  module Iso
    class Xref < IsoDoc::Xref
      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: nil, level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        #i = Counter.new(0, prefix: "0")
        i = clause_counter(0)
        clause.xpath(ns("./clause")).each do |c|
          section_names1(c, semx(clause, "0"), i.increment(c).print, 2)
        end
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        super
      end

      def appendix_names(clause, _num)
        i = clause_counter(0)
        clause.xpath(ns("./appendix")).each do |c|
          i.increment(c)
          num = semx(c, i.print)
          lbl = labelled_autonum(@labels["appendix"], num)
          @anchors[c["id"]] =
            anchor_struct(i.print, c, @labels["appendix"],
                          "clause").merge(level: 2, subtype: "annex",
                                          container: clause["id"])
          j = clause_counter(0)
          c.xpath(ns("./clause | ./references")).each do |c1|
            appendix_names1(c1, lbl, j.increment(c1).print, 3, clause["id"])
          end
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
          #num = semx(clause, num)
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

      def appendix_names1(clause, parentnum, num, level, container)
        #num = labelled_autonum(@labels["appendix"], num)
        num = clause_number_semx(parentnum, clause, num)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   container: container }
        i = clause_counter(0)
        clause.xpath(ns("./clause | ./references")).each do |c|
          appendix_names1(c, num, i.increment(c).print, level + 1, container)
        end
      end
    end
  end
end
