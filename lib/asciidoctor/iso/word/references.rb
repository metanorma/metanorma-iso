require "uuidtools"

module Asciidoctor
  module ISO::Word
    module References
      def iso_ref_entry(list, b)
        list.p **attr_code("id": b["anchor"], class: "MsoNormal") do |ref|
          isocode = b.at(ns("./isocode"))
          isodate = b.at(ns("./isodate"))
          isotitle = b.at(ns("./isotitle"))
          date_footnote = b.at(ns("./date_footnote"))
          reference = "ISO #{isocode.text}"
          reference += ": #{isodate.text}" if isodate
          ref << reference
          if date_footnote
            footnote_parse(date_footnote, ref)
          end
          ref.i { |i| i <<  " #{isotitle.text}" }
        end
      end

      def ref_entry(list, b)
        ref = b.at(ns("./ref"))
        p = b.at(ns("./p"))
        list.p **attr_code("id": ref["anchor"], class: "MsoNormal") do |r|
          r << ref.text
          p.children.each { |n| parse(n, r) }
        end
      end

      def biblio_list(f, s)
        isobiblio = f.xpath(ns("./iso_ref_title"))
        refbiblio = f.xpath(ns("./reference"))
        isobiblio.each do |b|
          iso_ref_entry(s, b)
        end
        refbiblio.each do |b|
          ref_entry(s, b)
        end
      end

      def norm_ref(isoxml, out)
        f = isoxml.at(ns("//norm_ref"))
        return unless f
        out.div do |div|
          div.h1 "2. Normative References"
          f.elements.each do |e|
            unless ["iso_ref_title" , "reference"].include? e.name
              parse(e, div)
            end
          end
          biblio_list(f, div)
        end
      end

      def bibliography(isoxml, out)
        f = isoxml.at(ns("//bibliography"))
        return unless f
        out.div do |div|
          div.h1 "Bibliography"
          f.elements.each do |e|
            unless ["iso_ref_title" , "reference"].include? e.name
              parse(e, div)
            end
          end
          biblio_list(f, div)
        end
      end
    end
  end
end

