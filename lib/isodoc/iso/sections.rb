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

=begin
      def introduction(clause, out)
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div class: "Section3", id: clause["id"] do |div|
          clause_name(clause, clause.at(ns("./title")), div, title_attr)
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end
=end

      def foreword(clause, out)
        @foreword = true
        page_break(out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(nil, clause.at(ns("./title")) || @i18n.foreword, s,
                      { class: "ForewordTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
        @foreword = false
      end
    end
  end
end
