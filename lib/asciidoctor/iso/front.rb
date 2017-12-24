require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module Front

      def metadata(node, xml)
        xml.documenttype node.attr("doctype")
        xml.documentstatus do |s|
          s.stage node.attr("docstage")
          s.substage node.attr("docsubstage") if node.attr("docsubstage")
        end
        docnum_attrs = { partnumber: node.attr("partnumber") }
        xml.id do |i|
          i.documentnumber node.attr("docnumber"), **attr_code(docnum_attrs)
          i.tc_documentnumber node.attr("tc-docnumber") if node.attr("tc-docnumber")
          i.ref_documentnumber node.attr("ref-docnumber") if node.attr("ref-docnumber")
        end
        xml.language node.attr("lanuage") 
        xml.version do |v|
          v.edition node.attr("edition") if node.attr("edition")
          v.revdate node.attr("revdate") if node.attr("revdate")
          v.copyright_year node.attr("copyright-year") if node.attr("copyright-year")
        end
        xml.author do |a| 
          tc_attrs = { number: node.attr("technical-committee-number") }
          a.technical_committee node.attr("technical-committee"), **attr_code(tc_attrs)
          sc_attrs = { number: node.attr("subcommittee-number") }
          a.subcommittee node.attr("subcommittee"), **attr_code(sc_attrs) if node.attr("subcommittee")
          wg_attrs = { number: node.attr("workgroup-number") }
          a.workgroup node.attr("workgroup"), **attr_code(wg_attrs) if node.attr("workgroup")
          a.secretariat node.attr("secretariat") if node.attr("secretariat")
        end
      end

      def title(node, xml)
        xml.title do |t0|
          t0.en do |t|
            t.title_intro {|t1| t1 << node.attr("title-intro-en") } if  node.attr("title-intro-en")
            t.title_main {|t1| t1 << node.attr("title-main-en") } if  node.attr("title-main-en")
            if node.attr("title-part-en")
              t.title_part node.attr("title-part-en")
            end
          end
          t0.fr do |t|
            t.title_intro {|t1| t1 << node.attr("title-intro-fr") } if  node.attr("title-intro-fr")
            t.title_main {|t1| t1 << node.attr("title-main-fr") } if  node.attr("title-main-fr")
            if node.attr("title-part-fr")
              t.title_part node.attr("title-part-fr")
            end
          end
        end
      end

    end
  end
end
