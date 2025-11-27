module IsoDoc
  module Iso
    class Xref < IsoDoc::Xref
      def clause_order_main(docxml)
        if @klass.amd?(docxml)
          [{ path: "//sections/clause", multi: true }]
        else
          [{ path: "//sections/clause[@type = 'scope']" },
           { path: @klass.norm_ref_xpath },
           { path:
             "#{@klass.middle_clause(docxml)} | //sections/terms | " \
             "//sections/clause[descendant::terms or descendant::definitions] | " \
             "//sections/definitions | //sections/clause[@type = 'section']", multi: true }]
        end
      end

      def clause_order_back(docxml)
        if @klass.amd?(docxml)
          [{ path: @klass.norm_ref_xpath },
           { path: @klass.bibliography_xpath },
           { path: "//indexsect", multi: true },
           { path: "//colophon/*", multi: true }]
        else super
        end
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        clause.nil? and return
        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: nil, level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        clause.xpath(ns("./clause"))
          .each_with_object(clause_counter(0)) do |c, i|
          section_names1(c, semx(clause, "0"), i.increment(c).print, 2)
        end
      end

      def section_name_anchors(clause, num, level)
        if clause["type"] == "section"
          section_name_anchors_section(clause, num, level)
        elsif level > 1
          section_name_anchors_subclause(clause, num, level)
        else
          super
        end
      end

      def section_name_anchors_section(clause, num, level)
        xref = labelled_autonum(@labels["section"], num)
        label = labelled_autonum(@labels["section"], num)
        @anchors[clause["id"]] =
          { label:, xref:, elem: @labels["section"],
            title: clause_title(clause), level: level, type: "clause" }
      end

      # subclauses are not prefixed with "Clause" but @labels["subclause"],
      # which in ISO is "" (but in inheriting flavors/tastes may be "Subclause")
      # Retaining subtype for the semantics
      def section_name_anchors_subclause(clause, num, level)
        xref = labelled_autonum(@labels["subclause"], num)
        @anchors[clause["id"]] =
          { label: num, level: level, xref:, subtype: "clause",
            title: subclause_title(clause), elem: @labels["subclause"] }
      end

      def annex_name_anchors1(clause, num, level)
        level == 1 and return annex_name_anchors(clause, num, level)
        ret = { label: num, level: level, subtype: "annex" }
        ret2 = if level == 2
                 xref = labelled_autonum(@labels["clause"], num)
                 { xref:, elem: @labels["clause"] }
               else
                 { xref: semx(clause, num) }
               end
        @anchors[clause["id"]] = ret.merge(ret2)
      end

      def subclause_title(clause, use_elem_name: false)
        ret = clause.at(ns("./title"))&.text
        if use_elem_name && ret.blank?
          @i18n.labels["subclause"]&.capitalize
        else
          clause_title(clause, use_elem_name: use_elem_name)
        end
      end
    end
  end
end
