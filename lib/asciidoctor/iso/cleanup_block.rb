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
      def para_cleanup(xmldoc)
        xmldoc.xpath("//p[not(@id)]").each do |x|
          x["id"] = Utils::anchor_or_uuid
        end
        xmldoc.xpath("//note[not(@id)][not(ancestor::bibitem)]"\
                     "[not(ancestor::table)]").each do |x|
          x["id"] = Utils::anchor_or_uuid
        end
      end

      def dl_table_cleanup(xmldoc)
        # move Key dl after table footer
        q = "//table/following-sibling::*[1]"\
          "[self::p and normalize-space() = 'Key']"
        xmldoc.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

      def header_rows_cleanup(xmldoc)
        xmldoc.xpath("//table[@headerrows]").each do |s|
          thead = s.at("./thead") ||
            thead = s.children.first.add_previous_sibling("<thead/>").first
          (thead.xpath("./tr").size...s["headerrows"].to_i).each do
            row = s.at("./tbody/tr")
            row.parent = thead
          end
          s.delete("headerrows")
        end
      end

      def table_cleanup(xmldoc)
        dl_table_cleanup(xmldoc)
        notes_table_cleanup(xmldoc)
        header_rows_cleanup(xmldoc)
      end

      def notes_table_cleanup(xmldoc)
        # move notes into table
        nomatches = false
        until nomatches
          q = "//table/following-sibling::*[1][self::note]"
          nomatches = true
          xmldoc.xpath(q).each do |n|
            n.previous_element << n.remove
            nomatches = false
          end
        end
      end

      def formula_cleanup(x)
        # include where definition list inside stem block
        q = "//formula/following-sibling::*[1]"\
          "[self::p and text() = 'where']"
        x.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

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

      def figure_dl_cleanup(xmldoc)
        # include key definition list inside figure
        q = "//figure/following-sibling::*"\
          "[self::p and normalize-space() = 'Key']"
        xmldoc.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

      def subfigure_cleanup(xmldoc)
        # examples containing only figures become subfigures of figures
        nodes = xmldoc.xpath("//example/figure")
        while !nodes.empty?
          nodes[0].parent.name = "figure"
          nodes = xmldoc.xpath("//example/figure")
        end
      end

      def figure_cleanup(xmldoc)
        figure_footnote_cleanup(xmldoc)
        figure_dl_cleanup(xmldoc)
        subfigure_cleanup(xmldoc)
      end

      def table_footnote_renumber(xmldoc)
        xmldoc.xpath("//table | //figure").each do |t|
          seen, i = {}, 0
          t.xpath(".//fn").each do |fn|
            if seen[fn.text] then outnum = seen[fn.text]
            else
              i += 1
              outnum = i
              seen[fn.text] = outnum
            end
            fn["reference"] = (outnum - 1 + "a".ord).chr
            fn["table"] = true
          end
        end
      end

      def other_footnote_renumber1(fn, i, seen, outnum)
        unless fn["table"]
          if seen[fn.text] then outnum = seen[fn.text]
          else
            i += 1
            outnum = i
            seen[fn.text] = outnum
          end
          fn["reference"] = outnum.to_s
        end
        [i, seen, outnum]
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
        outnum = 0
        xmldoc.xpath(PRE_NORMREF_FOOTNOTES).each do |fn|
          i, seen, outnum = other_footnote_renumber1(fn, i, seen, outnum)
        end
        xmldoc.xpath(NORMREF_FOOTNOTES).each do |fn|
          i, seen, outnum = other_footnote_renumber1(fn, i, seen, outnum)
        end
        xmldoc.xpath(POST_NORMREF_FOOTNOTES).each do |fn|
          i, seen, outnum = other_footnote_renumber1(fn, i, seen, outnum)
        end
      end

      def footnote_renumber(xmldoc)
        table_footnote_renumber(xmldoc)
        other_footnote_renumber(xmldoc)
        xmldoc.xpath("//fn").each do |fn|
          fn.delete("table")
        end
      end

      def sections_cleanup(x)
        s = x.at("//sections")
        foreword = x.at("//foreword")
        s.previous = foreword.remove if foreword
        introduction = x.at("//introduction")
        s.previous = introduction.remove if introduction
        x.xpath("//sections/references").reverse_each { |r| s.next = r.remove }
        x.xpath("//sections/annex").reverse_each { |r| s.next = r.remove }
      end

      def obligations_cleanup(x)
        (s = x.at("//foreword")) && s["obligation"] = "informative"
        (s = x.at("//introduction")) && s["obligation"] = "informative"
        (s = x.at("//clause[title = 'Scope']")) && s["obligation"] = "normative"
        (s = x.at("//clause[title = 'Symbols and Abbreviated Terms']")) &&
          s["obligation"] = "normative"
        x.xpath("//references").each { |r| r["obligation"] = "informative" }
        x.xpath("//terms").each { |r| r["obligation"] = "normative" }
        x.xpath("//symbols-abbrevs").each { |r| r["obligation"] = "normative" }
        x.xpath("//annex | //clause").each do |r|
          r["obligation"] = "normative" unless r["obligation"]
        end
        x.xpath("//subsection").each do |r|
          r["obligation"] = r.at("./ancestor::*/@obligation").text
        end
      end
    end
  end
end
