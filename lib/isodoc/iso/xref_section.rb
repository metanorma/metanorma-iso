module IsoDoc
  module Iso
    class Xref < IsoDoc::Xref
      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: nil, level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = Counter.new(0, prefix: "0.")
        clause.xpath(ns("./clause")).each do |c|
          section_names1(c, i.increment(c).print, 2)
        end
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        super
      end

      def appendix_names(clause, _num)
        i = Counter.new
        clause.xpath(ns("./appendix")).each do |c|
          i.increment(c)
          @anchors[c["id"]] =
            anchor_struct(i.print, nil, @labels["appendix"],
                          "clause").merge(level: 2, subtype: "annex",
                                          container: clause["id"])
          j = Counter.new(0, prefix: "#{i.print}.")
          c.xpath(ns("./clause | ./references")).each do |c1|
            lbl = "#{@labels['appendix']} #{j.increment(c1).print}"
            appendix_names1(c1, l10n(lbl), 3, clause["id"])
          end
        end
      end

      # subclauses are not prefixed with "Clause"
      # retaining subtype for the semantics
      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num, subtype: "clause" }
        i = Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | " \
                        "./references"))
          .each do |c|
          section_names1(c, i.increment(c).print, level + 1)
        end
      end

      def section_name_anchors(clause, num, level)
        if clause["type"] == "section"
          @anchors[clause["id"]] =
            { label: l10n("#{@labels['section']} #{num}"),
              xref: l10n("#{@labels['section']} #{num}"),
              title: clause_title(clause), level: level, type: "clause",
              elem: @labels["section"] }
        else super
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   subtype: "annex" }
        i = Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns("./clause | ./references")).each do |c|
          annex_names1(c, i.increment(c).print, level + 1)
        end
      end

      def appendix_names1(clause, num, level, container)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   container: container }
        i = Counter.new(0, prefix: "#{num}.")
        clause.xpath(ns("./clause | ./references")).each do |c|
          appendix_names1(c, i.increment(c).print, level + 1, container)
        end
      end

      def annex_name_lbl(clause, num)
        super.sub(%r{<br/>(.*)$}, "<br/><span class='obligation'>\\1</span>")
      end
    end
  end
end
