module IsoDoc
  module Iso
    module BaseConvert
      def middle_title(_isoxml, out)
        middle_title_main(out)
        middle_title_amd(out)
      end

      def middle_title_main(out)
        out.p(class: "zzSTDTitle1") do |p|
          p << @meta.get[:doctitleintro]
          p << " &#x2014; " if @meta.get[:doctitleintro] && @meta.get[:doctitlemain]
          p << @meta.get[:doctitlemain]
          p << " &#x2014; " if @meta.get[:doctitlemain] && @meta.get[:doctitlepart]
        end
        a = @meta.get[:doctitlepart] and out.p(class: "zzSTDTitle2") do |p|
          b = @meta.get[:doctitlepartlabel] and p << "#{b}: "
          p << "<br/><b>#{a}</b>"
        end
      end

      def middle_title_amd(out)
        a = @meta.get[:doctitleamdlabel] and out.p(class: "zzSTDTitle2") do |p|
          p << a
          a = @meta.get[:doctitleamd] and p << ": #{a}"
        end
        a = @meta.get[:doctitlecorrlabel] and out.p(class: "zzSTDTitle2") do |p|
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
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: f["id"] do |div|
          clause_name(f, f.at(ns("./title")), div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword")) or return
        @foreword = true
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          clause_name(nil, f.at(ns("./title")) || @i18n.foreword, s,
                      { class: "ForewordTitle" })
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
        @foreword = false
      end
    end
  end
end
