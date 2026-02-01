module IsoDoc
  module Iso
    class Xref < IsoDoc::Xref
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
        nested_notes(elem)
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
    end
  end
end
