module IsoDoc
  module Iso
    module BaseConvert
      def middle_title(out)
        middle_title_main(out)
        middle_title_amd(out)
      end

      def middle_title_main(out)
        out.p(**{ class: "zzSTDTitle1" }) do |p|
          p << @meta.get[:doctitleintro]
          p << " &mdash; " if @meta.get[:doctitleintro] && @meta.get[:doctitlemain]
          p << @meta.get[:doctitlemain]
          p << " &mdash; " if @meta.get[:doctitlemain] && @meta.get[:doctitlepart]
        end
        a = @meta.get[:doctitlepart] and out.p(**{ class: "zzSTDTitle2" }) do |p|
          b = @meta.get[:doctitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end

      def middle_title_amd(out)
        a = @meta.get[:doctitleamdlabel] and out.p(**{ class: "zzSTDTitle2" }) do |p|
          p << a
          a = @meta.get[:doctitleamd] and p << ": #{a}"
        end
        a = @meta.get[:doctitlecorrlabel] and out.p(**{ class: "zzSTDTitle2" }) do |p|
          p << a
        end
      end

      def annex(isoxml, out)
        amd(isoxml) and @suppressheadingnumbers = @oldsuppressheadingnumbers
        super
        amd(isoxml) and @suppressheadingnumbers = true
      end

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction")) || return
        num = f.at(ns(".//clause")) ? "0" : nil
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(num, @introduction_lbl, div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword")) || return
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def clause_parse_title(node, div, c1, out)
        return inline_header_title(out, node, c1) if c1.nil?
        super
      end
    end
  end
end
