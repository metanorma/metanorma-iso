require_relative "word_dis_styles"

module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      def remove_note_label(doc)
        doc.xpath("//span[@class = 'note_label' or @class = 'example_label']")
          .each do |s|
          s.replace(s.children)
        end
      end

      def word_cleanup(docxml)
        word_table_cell_para(docxml)
        super
        word_section_end_empty_para(docxml)
        docxml
      end

      def word_section_end_empty_para(docxml)
        docxml.at("//div[@class='WordSection1']/p[last()]")&.remove
      end

      def word_table_cell_para(docxml)
        docxml.xpath("//td | //th").each do |t|
          s = word_table_cell_para_style(t)
          t.delete("header")
          if t.at("./p |./div")
            t.xpath("./p | ./div").each { |p| p["class"] = s }
          else
            t.children = "<div class='#{s}'>#{to_xml(t.children)}</div>"
          end
        end
      end

      def stripbgcolor(docxml)
        @bgstripcolor == "true" or return
        %w(aucollab audeg aufname aurole ausuffix ausurname bibarticle bibetal
           bibfname bibfpage bibissue bibjournal biblpage bibnumber
           biborganization bibsuppl bibsurname biburl bibvolume bibyear
           citebib citeen citefig citefn citetbl bibextlink citeeq citetfn
           auprefix citeapp citesec stddocNumber stddocPartNumber
           stddocTitle aumember stdfootnote stdpublisher stdsection stdyear
           stddocumentType bibalt-year bibbook bbichapterno bibchaptertitle
           bibed-etal bibed-fname bibeditionno bibed-organization bibed-suffix
           bibed-surname bibinstitution bibisbn biblocation bibpagecount
           bibpatent bibpublisher bibreportnum bibschool bibseries bibseriesno
           bibtrans stdsuppl citesection).each do |t|
          docxml.xpath("//span[@class = '#{t}']").each do |s|
            s["style"] ||= ""
            s["style"] = "mso-pattern:none;#{s['style']}"
          end
        end
      end
    end
  end
end
