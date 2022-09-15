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
          doc.xpath(ns("//preface/*")).each do |c|
            c.element? and preface_names(c)
          end
          doc.xpath(ns("//sections/clause")).each do |c|
            c.element? and preface_names(c)
          end
        end
        if @parse_settings.empty?
          sequential_asset_names(doc.xpath(ns("//preface/*")))
          middle_section_asset_names(doc)
          termnote_anchor_names(doc)
          termexample_anchor_names(doc)
        end
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
          doc.xpath(ns("//sections/clause[not(@type = 'scope')] | "\
                       "//sections/terms | //sections/definitions")).each do |c|
            n = section_names(c, n, 1)
          end
        end
        if @parse_settings.empty?
          middle_section_asset_names(doc)
          termnote_anchor_names(doc)
          termexample_anchor_names(doc)
        end
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        return if clause.nil?

        clause.at(ns("./clause")) and
          @anchors[clause["id"]] = { label: "0", level: 1, type: "clause",
                                     xref: clause.at(ns("./title"))&.text }
        i = Counter.new
        clause.xpath(ns("./clause")).each do |c|
          i.increment(c)
          section_names1(c, "0.#{i.print}", 2)
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
          j = Counter.new
          c.xpath(ns("./clause | ./references")).each do |c1|
            j.increment(c1)
            lbl = "#{@labels['appendix']} #{i.print}.#{j.print}"
            appendix_names1(c1, l10n(lbl), 3, clause["id"])
          end
        end
      end

      # subclauses are not prefixed with "Clause"
      # retaining subtype for the semantics
      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num, subtype: "clause" }
        i = Counter.new
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions | "\
                        "./references"))
          .each do |c|
          i.increment(c)
          section_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   subtype: "annex" }
        i = Counter.new
        clause.xpath(ns("./clause | ./references")).each do |c|
          i.increment(c)
          annex_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def appendix_names1(clause, num, level, container)
        @anchors[clause["id"]] = { label: num, xref: num, level: level,
                                   container: container }
        i = Counter.new
        clause.xpath(ns("./clause | ./references")).each do |c|
          i.increment(c)
          appendix_names1(c, "#{num}.#{i.print}", level + 1, container)
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

      def figure_anchor(elem, sublabel, label)
        @anchors[elem["id"]] = anchor_struct(
          (sublabel ? "#{label} #{sublabel}" : label),
          nil, @labels["figure"], "figure", elem["unnumbered"]
        )
        sublabel && elem["unnumbered"] != "true" and
          @anchors[elem["id"]][:label] = sublabel
      end

      def sequential_figure_names(clause)
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]"))
          .each_with_object(IsoDoc::XrefGen::Counter.new) do |t, c|
          j = subfigure_increment(j, c, t)
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          next if blank?(t["id"])

          figure_anchor(t, sublabel, c.print)
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure |  .//sourcecode[not(ancestor::example)]"))
          .each do |t|
          j = subfigure_increment(j, c, t)
          label = "#{num}#{hiersep}#{c.print}"
          sublabel = j.zero? ? nil : "#{(j + 96).chr})"
          next if blank?(t["id"])

          figure_anchor(t, sublabel, label)
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

      def annex_name_lbl(clause, num)
        super.sub(%r{<br/>(.*)$}, "<br/><span class='obligation'>\\1</span>")
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
          (@anchors[t["id"]] && !@anchors[t["id"]][:modspec]) or next
          n = @anchors[t["id"]][:xref]
          @anchors[t["id"]][:modspec] = true
          @anchors[t["id"]][:xref] =
            l10n("#{n}, #{@anchors_previous[t['id']][:xref_bare]}")
          modspec_table_components_xrefs(t, n)
        end
      end

      def modspec_table_components_xrefs(table, table_label)
        table.xpath(ns(".//tr[@id]")).each do |tr|
          (@anchors[tr["id"]] && !@anchors[tr["id"]][:modspec]) or next
          @anchors[tr["id"]][:modspec] = true
          @anchors[tr["id"]][:xref] =
            l10n("#{table_label}, #{@anchors_previous[tr['id']][:xref]}")
          @anchors[tr["id"]].delete(:container)
        end
      end

      def hierarchical_table_names(clause, _num)
        super
        modspec_table_xrefs(clause) if @anchors_previous
      end
    end
  end
end
