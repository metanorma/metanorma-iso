module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      def style_cleanup(docxml)
        super
        dis_styles(docxml)
      end

      STYLESMAP = {
        AltTerms: "AdmittedTerm",
        TableFootnote: "Tablefootnote",
        formula: "Formula",
        note: "Note",
        example: "Example",
        admonition: "Admonition",
        admonitiontitle: "AdmonitionTitle",
        sourcetitle: "SourceTitle",
        tabletitle: "TableTitle",
        titlepagesbhead: "TablePageSubhead",
        NormRef: "RefNorm",
        Biblio: "BiblioEntry",
        MsoNormal: "MsoBodyText",
        FigureTitle: "Figuretitle",
        zzwarning: "zzWarning",
        zzwarninghdr: "zzWarningHdr",
        quoteattribution: "QuoteAttribution",
        Sourcecode: "Code",
        zzSTDTitle1: "zzSTDTitle",
        zzSTDTitle2: "zzSTDTitle",
        zzCopyright1: "zzCopyright",
      }.freeze

      def dis_styles(docxml)
        STYLESMAP.each do |k, v|
          docxml.xpath("//*[@class = '#{k}']").each { |s| s["class"] = v }
        end
        docxml.xpath("//h1[@class = 'ForewordTitle' or @class = 'IntroTitle']")
          .each { |h| h.name = "p" }
        dis_styles1(docxml)
        docxml.xpath("//p[not(@class)]").each { |p| p["class"] = "MsoBodyText" }
      end

      def dis_styles1(docxml)
        remove_note_label(docxml)
        amd_style(docxml)
        code_style(docxml)
        figure_style(docxml)
        example_style(docxml)
        quote_style(docxml)
      end

      def amd_style(docxml)
        return unless @meta.get[:doctype] == "Amendment"

        docxml.xpath("//div[@class = 'WordSection3']//h1").each do |h|
          h.name = "p"
          h["style"] = "font-style:italic;page-break-after:avoid;"
        end
      end

      def quote_style(docxml)
        docxml.xpath("//div[@class = 'Quote' or @class = 'Note' or "\
                     "@class = 'Example']").each do |d|
                       quote_style1(d)
                     end
      end

      def quote_style1(div)
        div.xpath(".//p[not(@class)]").each do |p|
          p["class"] = "BodyTextindent1"
        end
        if div["class"] != "Example"
          div.xpath(".//p[@class = 'Example']").each do |p|
            p["class"] = "Exampleindent"
          end
          div.xpath(".//p[@class = 'Examplecontinued']").each do |p|
            p["class"] = "Exampleindentcontinued"
          end
        end
        div["class"] != "Note" and
          div.xpath(".//p[@class = 'Note']").each do |p|
            p["class"] = "Noteindent"
          end
      end

      def remove_note_label(doc)
        doc.xpath("//span[@class = 'note_label' or @class = 'example_label']")
          .each do |s|
          s.replace(s.children)
        end
      end

      def example_style(docxml)
        docxml.xpath("//div[@class = 'Example']").each do |d|
          d.xpath("./p").each_with_index do |p, i|
            next if p["class"] && p["class"] != "Example"

            p["class"] = (i.zero? ? "Example" : "Examplecontinued")
          end
        end
      end

      FIGURE_NESTED_STYLES =
        { Note: "Figurenote", example: "Figureexample" }.freeze

      def figure_style(docxml)
        docxml.xpath("//div[@class = 'figure']").each do |f|
          FIGURE_NESTED_STYLES.each do |k, v|
            f.xpath(".//*[@class = '#{k}']").each { |n| n["class"] = v }
          end
          f.xpath("./img").each do |i|
            i.replace("<p class='FigureGraphic'>#{i.to_xml}</p>")
          end
        end
      end

      def code_style(doc)
        span_style((doc.xpath("//tt//b") - doc.xpath("//tt//i//b")),
                   "ISOCodebold")
        span_style((doc.xpath("//tt//i") - doc.xpath("//tt//b//i")),
                   "ISOCodeitalic")
        span_style((doc.xpath("//b//tt") - doc.xpath("//b//i//tt")),
                   "ISOCodebold")
        span_style((doc.xpath("//i//tt") - doc.xpath("//i//b//tt")),
                   "ISOCodeitalic")
        span_style(doc.xpath("//tt"), "ISOCode")
      end

      def span_style(xpath, style)
        xpath.each do |elem|
          elem.name = "span"
          elem["class"] = style
        end
      end

      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "a#{lvl}"
        end
      end

      def word_cleanup(docxml)
        word_table_cell_para(docxml)
        super
        word_section_end_empty_para(docxml)
        docxml
      end

      def word_section_end_empty_para(docxml)
        docxml.at("//div[@class='WordSection1']/p[last()]").remove
      end

      def word_table_cell_para(docxml)
        docxml.xpath("//td | //th").each do |t|
          s = t["header"] == "true" ? "Tableheader" : "Tablebody"
          t.delete("header")
          if t.at("./p |./div")
            t.xpath("./p | ./div").each { |p| p["class"] = s }
          else
            t.children = "<div class='#{s}'>#{t.children.to_xml}</div>"
          end
        end
      end
    end
  end
end