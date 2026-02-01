require_relative "xref_section"
require_relative "xref_figure"

module IsoDoc
  module Iso
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Xref
      attr_accessor :anchors_previous, :anchors

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
        @anchors[id][:xref] = @klass.connectives_spans(@i18n.nested_xref
          .sub("%1", table_label).sub("%2", x))
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

      def nested_notes(asset, container: true)
        notes = asset.xpath(ns(".//note")).reject { |n| uncountable_note?(n) }
        counter = Counter.new
        notes.noblank.each do |n|
          lbl = increment_label(notes, n, counter)
          @anchors[n["id"]] =
            { label: lbl, value: lbl, container: container ? asset["id"] : nil,
              xref: anchor_struct_xref(lbl, n, @labels["note_xref"]),
              elem: @labels["note_xref"], type: "note" }.compact
        end
      end

      def sequential_permission_body(id, parent_id, elem, label, klass, model,
container: false)
        e = elem["id"] || elem["original-id"]
        has_table_prefix = @anchors.dig(e, :has_table_prefix)
        has_table_prefix and return
        super
        # has_table_prefix and @anchors[e][:has_table_prefix] = true # restore
      end

      def localise_anchors(type = nil)
        @anchors.each do |id, v|
          type && v[:type] != type and next
          #v[:has_table_prefix] and next
          # has already been l10n'd, is copied from prev iteration
          %i(label value xref xref_bare modspec).each do |t|
            v[t] && !v[t].empty? or next
            # Skip if value unchanged from previous iteration
            @anchors_previous&.dig(id, t) == v[t] and next
            v[t] = @i18n.l10n(v[t])
          end
        end
      end
    end
  end
end
