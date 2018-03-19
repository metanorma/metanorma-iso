require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module Cleanup
      # include footnotes inside figure
      def figure_footnote_cleanup(xmldoc)
        nomatches = false
        until nomatches
          q = "//figure/following-sibling::*[1][self::p and *[1][self::fn]]"
          nomatches = true
          xmldoc.xpath(q).each do |s|
            s.previous_element << s.first_element_child.remove
            s.remove
            nomatches = false
          end
        end
      end

      def table_footnote_renumber1(fn, i, seen)
        if seen[fn.text] then outnum = seen[fn.text]
        else
          i += 1
          outnum = i
          seen[fn.text] = outnum
        end
        fn["reference"] = (outnum - 1 + "a".ord).chr
        fn["table"] = true
        [i, seen]
      end

      def table_footnote_renumber(xmldoc)
        xmldoc.xpath("//table | //figure").each do |t|
          seen = {}
          i = 0
          t.xpath(".//fn").each do |fn|
            i, seen = table_footnote_renumber1(fn, i, seen)
          end
        end
      end

      def other_footnote_renumber1(fn, i, seen)
        unless fn["table"]
          if seen[fn.text] then outnum = seen[fn.text]
          else
            i += 1
            outnum = i
            seen[fn.text] = outnum
          end
          fn["reference"] = outnum.to_s
        end
        [i, seen]
      end

      PRE_NORMREF_FOOTNOTES = "//foreword//fn | //introduction//fn |"\
        "//clause[title = 'Scope']//fn" .freeze

      NORMREF_FOOTNOTES =
        "//references[title = 'Normative References']//fn |"\
        "//references[title = 'Normative References']//bibitem/note".freeze

      POST_NORMREF_FOOTNOTES =
        "//clause[not(title = 'Scope')]//fn | "\
        "//references[title = 'Bibliography']//fn | "\
        "//references[title = 'Bibliography']//bibitem/note".freeze

      def other_footnote_renumber(xmldoc)
        seen = {}
        i = 0
        xmldoc.xpath(PRE_NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
        xmldoc.xpath(NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
        xmldoc.xpath(POST_NORMREF_FOOTNOTES).each do |fn|
          i, seen = other_footnote_renumber1(fn, i, seen)
        end
      end

      def footnote_renumber(xmldoc)
        table_footnote_renumber(xmldoc)
        other_footnote_renumber(xmldoc)
        xmldoc.xpath("//fn").each do |fn|
          fn.delete("table")
        end
      end
    end
  end
end
