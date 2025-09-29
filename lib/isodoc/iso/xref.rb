require_relative "xref_section"

module IsoDoc
  module Iso
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Xref
      attr_accessor :anchors_previous, :anchors

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

      def initial_anchor_names(doc)
        super
        if @parse_settings.empty? || @parse_settings[:clauses]
          introduction_names(doc.at(ns("//introduction")))
        end
      end

      def asset_anchor_names(doc)
        super
        @parse_settings.empty? or return
        sequential_asset_names(doc.xpath(ns("//preface/*")))
      end

      def hierarchical_formula_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        clause.xpath(ns(".//formula")).noblank.each do |t|
          @anchors[t["id"]] = anchor_struct(
            hiersemx(clause, num, c.increment(t), t), t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", { unnumb: t["unnumbered"], container: true }
          )
        end
      end

      def subfigure_delim
        ")"
      end

      def figure_anchor(elem, sublabel, label, klass, container: false)
        if sublabel
          subfigure_anchor(elem, sublabel, label, klass, container: container)
        else
          @anchors[elem["id"]] = anchor_struct(
            label, elem, @labels[klass] || klass.capitalize, klass,
            { unnumb: elem["unnumbered"], container: }
          )
        end
      end

      def fig_subfig_label(label, sublabel)
        "#{label} #{sublabel}"
      end

      def subfigure_anchor(elem, sublabel, label, klass, container: false)
        figlabel = fig_subfig_label(label, sublabel)
        @anchors[elem["id"]] = anchor_struct(
          figlabel, elem, @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"] }
        )
        if elem["unnumbered"] != "true"
          # Dropping the parent figure label is specific to ISO
          p = elem.at("./ancestor::xmlns:figure")
          @anchors[elem["id"]][:label] = sublabel
          @anchors[elem["id"]][:xref] = @anchors[p["id"]][:xref] +
            " " + semx(elem, sublabel) + delim_wrap(subfigure_delim)
          x = @anchors[p["id"]][:container] and
            @anchors[elem["id"]][:container] = x
        end
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return
        (subfignum + 96).chr
      end

      def hierfigsep
        " "
      end

      def sequential_figure_names(clause, container: false)
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank
          .each_with_object(IsoDoc::XrefGen::Counter.new) do |t, c|
          j = subfigure_increment(j, c, t)
          sublabel = subfigure_label(j)
          figure_anchor(t, sublabel, c.print, "figure", container: container)
        end
        sequential_figure_class_names(clause, container: container)
      end

      def sequential_figure_class_names(clause, container: false)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .each do |t|
          c[t["class"]] ||= IsoDoc::XrefGen::Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, c.print, t["class"], container: container)
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank.each do |t|
          j = subfigure_increment(j, c, t)
          sublabel = subfigure_label(j)
          figure_anchor(t, sublabel, hiersemx(clause, num, c, t), "figure")
        end
        hierarchical_figure_class_names(clause, num)
      end

      def hierarchical_figure_class_names(clause, num)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .noblank.each do |t|
          c[t["class"]] ||= IsoDoc::XrefGen::Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, hiersemx(clause, num, c[t["class"]], t),
                        t["class"])
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref]
          .sub(/ \(All Parts\)/i, "") }
      end

      def list_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
            s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
          c = Counter.new
          notes.noblank.each do |n|
            @anchors[n["id"]] = anchor_struct(increment_label(notes, n, c), n,
                                              @labels["list"], "list",
                                              { unnumb: false, container: true })
            list_item_anchor_names(n, @anchors[n["id"]], 1, "",
                                   !single_ol_for_xrefs?(notes))
          end
          list_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      # all li in the ol in lists are consecutively numbered through @start
      def single_ol_for_xrefs?(lists)
        lists.size == 1 and return true
        start = 0
        lists.each_with_index do |l, i|
          i.zero? and next
          start += lists[i - 1].xpath(ns("./li")).size
          return false unless l["start"]&.to_i == start + 1
        end
        true
      end

      def sequential_table_names(clause, container: false)
        super
        modspec_table_xrefs(clause, container: container) if @anchors_previous
      end

      def modspec_table_xrefs(clause, container: false)
        clause.xpath(ns(".//table[@class = 'modspec']")).noblank.each do |t|
          n = @anchors[t["id"]][:xref]
          xref_to_modspec(t["id"], n) or next
          modspec_table_components_xrefs(t, n, container: container)
        end
      end

      def modspec_table_components_xrefs(table, table_label, container: false)
        table
          .xpath(ns(".//tr[@id] | .//td[@id] | .//bookmark[@id]")).each do |tr|
          xref_to_modspec(tr["id"], table_label) or next
          container or @anchors[tr["id"]].delete(:container)
        end
      end

      def xref_to_modspec(id, table_label)
        (@anchors[id] && !@anchors[id][:has_table_prefix]) or return
        @anchors[id][:has_table_prefix] = true
        x = @anchors_previous[id][:xref_bare] || @anchors_previous[id][:xref]
        @anchors[id][:xref] = l10n(@klass.connectives_spans(@i18n.nested_xref
          .sub("%1", table_label).sub("%2", x)))
        @anchors[id][:modspec] = @anchors_previous[id][:modspec]
        @anchors[id][:subtype] = "modspec" # prevents citetbl style from beign applied
        true
      end

      def bookmark_anchor_names(xml)
        xml.xpath(ns(".//bookmark")).noblank.each do |n|
          @anchors.dig(n["id"], :has_table_prefix) and next
          _parent, id = id_ancestor(n)
          # container = bookmark_container(parent)
          @anchors[n["id"]] = { type: "bookmark", label: nil, value: nil,
                                xref: @anchors.dig(id, :xref) || "???",
                                container: @anchors.dig(id, :container) }
        end
      end

      def hierarchical_table_names(clause, _num)
        super
        modspec_table_xrefs(clause) if @anchors_previous
      end

      def uncountable_note?(note)
        @anchors[note["id"]] || blank?(note["id"]) || note["type"] == "units" ||
          note["type"] == "requirement"
      end

      def note_anchor_names1(notes, counter)
        countable = notes.reject { |n| uncountable_note?(n) }
        countable.each do |n|
          @anchors[n["id"]] =
            anchor_struct(increment_label(countable, n, counter), n,
                          @labels["note_xref"], "note",
                          { unnum: false, container: true })
        end
      end
    end
  end
end
