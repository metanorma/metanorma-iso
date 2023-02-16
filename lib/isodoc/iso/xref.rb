require_relative "xref_section"

module IsoDoc
  module Iso
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Xref
      attr_accessor :anchors_previous, :anchors

      def initial_anchor_names(doc)
        if @klass.amd(doc) then initial_anchor_names_amd(doc)
        else initial_anchor_names1(doc)
        end
        if @parse_settings.empty? || @parse_settings[:clauses]
          introduction_names(doc.at(ns("//introduction")))
        end
      end

      def initial_anchor_names_amd(doc)
        if @parse_settings.empty? || @parse_settings[:clauses]
          ["//preface/*", "//sections/clause"].each do |xpath|
            doc.xpath(ns(xpath)).each do |c|
              c.element? and preface_names(c)
            end
          end
        end
      end

      def asset_anchor_names(doc)
        super
        @parse_settings.empty? or return
        sequential_asset_names(doc.xpath(ns("//preface/*")))
      end

      def initial_anchor_names1(doc)
        if @parse_settings.empty? || @parse_settings[:clauses]
          doc.xpath(ns("//preface/*")).each do |c|
            c.element? and preface_names(c)
          end
          # potentially overridden in middle_section_asset_names()
          sequential_asset_names(doc.xpath(ns("//preface/*")))
          n = Counter.new
          n = section_names(doc.at(ns("//clause[@type = 'scope']")), n, 1)
          n = section_names(doc.at(ns(@klass.norm_ref_xpath)), n, 1)
          doc.xpath(ns("//sections/clause[not(@type = 'scope')] | " \
                       "//sections/terms | //sections/definitions")).each do |c|
            n = section_names(c, n, 1)
          end
        end
      end

      def hierarchical_formula_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        clause.xpath(ns(".//formula")).each do |t|
          next if blank?(t["id"])

          @anchors[t["id"]] = anchor_struct(
            "#{num}#{hiersep}#{c.increment(t).print}", t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", t["unnumbered"]
          )
        end
      end

      def figure_anchor(elem, sublabel, label, klass)
        @anchors[elem["id"]] = anchor_struct(
          (sublabel ? "#{label} #{sublabel}" : label),
          nil, @labels[klass] || klass.capitalize, klass, elem["unnumbered"]
        )
        sublabel && elem["unnumbered"] != "true" and
          @anchors[elem["id"]][:label] = sublabel
      end

      def sequential_figure_names(clause)
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank
          .each_with_object(IsoDoc::XrefGen::Counter.new) do |t, c|
          j = subfigure_increment(j, c, t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, c.print, "figure")
        end
        sequential_figure_class_names(clause)
      end

      def sequential_figure_class_names(clause)
        c = {}
        j = 0
        clause.xpath(ns(".//figure[@class][not(@class = 'pseudocode')]"))
          .each do |t|
          c[t["class"]] ||= IsoDoc::XrefGen::Counter.new
          j = subfigure_increment(j, c[t["class"]], t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, c.print, t["class"])
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(FIGURE_NO_CLASS)).noblank.each do |t|
          j = subfigure_increment(j, c, t)
          label = "#{num}#{hiersep}#{c.print}"
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, label, "figure")
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
          label = "#{num}#{hiersep}#{c.print}"
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          figure_anchor(t, sublabel, label, t["class"])
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref]
          .sub(/ \(All Parts\)/i, "") }
      end

      def back_anchor_names(docxml)
        super
        if @parse_settings.empty? || @parse_settings[:clauses]
          docxml.xpath(ns("//indexsect")).each { |b| preface_names(b) }
        end
      end

      def list_anchor_names(sections)
        sections.each do |s|
          notes = s.xpath(ns(".//ol")) - s.xpath(ns(".//clause//ol")) -
            s.xpath(ns(".//appendix//ol")) - s.xpath(ns(".//ol//ol"))
          c = Counter.new
          notes.reject { |n| blank?(n["id"]) }.each do |n|
            @anchors[n["id"]] = anchor_struct(increment_label(notes, n, c), n,
                                              @labels["list"], "list", false)
            list_item_anchor_names(n, @anchors[n["id"]], 1, "",
                                   !single_ol_for_xrefs?(notes))
          end
          list_anchor_names(s.xpath(ns(CHILD_SECTIONS)))
        end
      end

      # all li in the ol in lists are consecutively numbered through @start
      def single_ol_for_xrefs?(lists)
        return true if lists.size == 1

        start = 0
        lists.each_with_index do |l, i|
          next if i.zero?

          start += lists[i - 1].xpath(ns("./li")).size
          return false unless l["start"]&.to_i == start + 1
        end
        true
      end

      def sequential_table_names(clause)
        super
        modspec_table_xrefs(clause) if @anchors_previous
      end

      def modspec_table_xrefs(clause)
        clause.xpath(ns(".//table[@class = 'modspec']")).noblank.each do |t|
          n = @anchors[t["id"]][:xref]
          xref_to_modspec(t["id"], n) or next
          modspec_table_components_xrefs(t, n)
        end
      end

      def modspec_table_components_xrefs(table, table_label)
        table.xpath(ns(".//tr[@id]")).each do |tr|
          xref_to_modspec(tr["id"], table_label) or next
          @anchors[tr["id"]].delete(:container)
        end
      end

      def xref_to_modspec(id, table_label)
        (@anchors[id] && !@anchors[id][:has_modspec]) or return
        @anchors[id][:has_modspec] = true
        x = @anchors_previous[id][:xref_bare] || @anchors_previous[id][:xref]
        @anchors[id][:xref] = l10n("#{table_label}, #{x}")
        @anchors[id][:modspec] = @anchors_previous[id][:modspec]
        @anchors[id][:subtype] = "modspec" # prevents citetbl style from beign applied
        true
      end

      def hierarchical_table_names(clause, _num)
        super
        modspec_table_xrefs(clause) if @anchors_previous
      end

      def note_anchor_names1(notes, counter)
        notes.each do |n|
          next if @anchors[n["id"]] || blank?(n["id"]) || n["type"] == "units"

          @anchors[n["id"]] =
            anchor_struct(increment_label(notes, n, counter), n,
                          @labels["note_xref"], "note", false)
        end
      end
    end
  end
end
