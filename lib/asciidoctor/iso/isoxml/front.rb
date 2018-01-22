require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"

module Asciidoctor
  module ISO
    module ISOXML
      module Front
        def metadata_id(node, xml)
          xml.id do |i|
            i.documentnumber node.attr("docnumber"),
              **attr_code(partnumber: node.attr("partnumber"))
            if node.attr("tc-docnumber")
              i.tc_documentnumber node.attr("tc-docnumber")
            end
          end
        end

        def metadata_version(node, xml)
          xml.version do |v|
            v.edition node.attr("edition") if node.attr("edition")
            v.revdate node.attr("revdate") if node.attr("revdate")
            if node.attr("copyright-year")
              v.copyright_year node.attr("copyright-year")
            end
          end
        end

        def metadata_author(node, xml)
          xml.author do |a|
            a.technical_committee node.attr("technical-committee"),
              **attr_code(number: node.attr("technical-committee-number"))
            if node.attr("subcommittee")
              a.subcommittee node.attr("subcommittee"),
                **attr_code(number: node.attr("subcommittee-number"))
            end
            if node.attr("workgroup")
              a.workgroup node.attr("workgroup"),
                **attr_code(number: node.attr("workgroup-number"))
            end
            a.secretariat node.attr("secretariat") if node.attr("secretariat")
          end
        end

        def metadata(node, xml)
          xml.documenttype node.attr("doctype")
          xml.documentstatus do |s|
            s.stage node.attr("docstage")
            s.substage node.attr("docsubstage") if node.attr("docsubstage")
          end
          metadata_id(node, xml)
          xml.language node.attr("language")
          metadata_version(node, xml)
          metadata_author(node, xml)
        end

        def title(node, xml)
          xml.title do |t0|
            ["en", "fr"].each do |lang|
              t0.title_info **{ language: lang } do |t|
                if node.attr("title-intro-#{lang}")
                  t.title_intro { |t1| t1 << node.attr("title-intro-#{lang}") }
                end
                t.title_main { |t1| t1 << node.attr("title-main-#{lang}") }
                if node.attr("title-part-#{lang}")
                  t.title_part node.attr("title-part-#{lang}")
                end
              end
            end
          end
        end
      end
    end
  end
end
