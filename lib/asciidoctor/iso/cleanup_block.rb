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

      # move Key dl after table footer
      def dl_table_cleanup(xmldoc)
        q = "//table/following-sibling::*[1]"\
          "[self::p and normalize-space() = 'Key']"
        xmldoc.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

      def insert_thead(s)
        thead = s.at("./thead")
        return thead unless thead.nil?
        if tname = s.at("./name")
          thead = tname.add_next_sibling("<thead/>").first
          return thead
        end
        s.children.first.add_previous_sibling("<thead/>").first
      end

      def header_rows_cleanup(xmldoc)
        xmldoc.xpath("//table[@headerrows]").each do |s|
          thead = insert_thead(s)
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

      # move notes into table
      def notes_table_cleanup(xmldoc)
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

      # include where definition list inside stem block
      def formula_cleanup(x)
        q = "//formula/following-sibling::*[1]"\
          "[self::p and text() = 'where']"
        x.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

      # include key definition list inside figure
      def figure_dl_cleanup(xmldoc)
        q = "//figure/following-sibling::*"\
          "[self::p and normalize-space() = 'Key']"
        xmldoc.xpath(q).each do |s|
          if !s.next_element.nil? && s.next_element.name == "dl"
            s.previous_element << s.next_element.remove
            s.remove
          end
        end
      end

      # examples containing only figures become subfigures of figures
      def subfigure_cleanup(xmldoc)
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

      def make_preface(x, s)
        if x.at("//foreword | //introduction")
          preface = s.add_previous_sibling("<preface/>").first
          foreword = x.at("//foreword")
          preface.add_child foreword.remove if foreword
          introduction = x.at("//introduction")
          preface.add_child introduction.remove if introduction
        end
      end

      def make_bibliography(x, s)
        if x.at("//sections/references")
          biblio = s.add_next_sibling("<bibliography/>").first
          x.xpath("//sections/references").each { |r| biblio.add_child r.remove }
        end
      end

      def sections_cleanup(x)
        s = x.at("//sections")
        make_preface(x, s)
        make_bibliography(x, s)
        x.xpath("//sections/annex").reverse_each { |r| s.next = r.remove }
      end

      def obligations_cleanup(x)
        obligations_cleanup_info(x)
        obligations_cleanup_norm(x)
        obligations_cleanup_inherit(x)
      end

      def obligations_cleanup_info(x)
        (s = x.at("//foreword")) && s["obligation"] = "informative"
        (s = x.at("//introduction")) && s["obligation"] = "informative"
        x.xpath("//references").each { |r| r["obligation"] = "informative" }
      end

      def obligations_cleanup_norm(x)
        (s = x.at("//clause[title = 'Scope']")) && s["obligation"] = "normative"
        (s = x.at("//clause[title = 'Symbols and Abbreviated Terms']")) &&
          s["obligation"] = "normative"
        x.xpath("//terms").each { |r| r["obligation"] = "normative" }
        x.xpath("//symbols-abbrevs").each { |r| r["obligation"] = "normative" }
      end

      def obligations_cleanup_inherit(x)
        x.xpath("//annex | //clause").each do |r|
          r["obligation"] = "normative" unless r["obligation"]
        end
        x.xpath("//subclause").each do |r|
          r["obligation"] = r.at("./ancestor::*/@obligation").text
        end
      end
    end
  end
end
