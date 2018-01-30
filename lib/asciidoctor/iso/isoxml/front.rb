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
            i.projectnumber node.attr("docnumber"),
              **attr_code(part: node.attr("partnumber"))
            if node.attr("tc-docnumber")
              i.tc_documentnumber node.attr("tc-docnumber")
            end
          end
        end

        def metadata_version(node, xml)
          xml.version do |v|
            v.edition node.attr("edition") if node.attr("edition")
            v.revision_date node.attr("revdate") if node.attr("revdate")
          end
        end

        def metadata_author(node, xml)
          xml.creator **{ role: "author" } do |a|
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

        def metadata_copyright(node, xml)
          from = node.attr("copyright-year") || Date.today.year
          xml.copyright do |c|
            c.from from
            c.owner do |o|
              o.affiliation "ISO"
            end
          end
        end

        def metadata_status(node, xml)
          xml.status do |s|
            s.stage ( node.attr("docstage") || "60" )
            s.substage ( node.attr("docsubstage") || "60" )
          end
        end

        def metadata(node, xml)
          metadata_status(node, xml)
          metadata_author(node, xml)
          xml.language node.attr("language")
          xml.script "latn"
          xml.type node.attr("doctype")
          metadata_id(node, xml)
          metadata_version(node, xml)
          metadata_copyright(node, xml)
        end

        def title(node, xml)
          ["en", "fr"].each do |lang|
            xml.title **{ language: lang } do |t|
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
