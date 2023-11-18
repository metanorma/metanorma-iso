module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      STYLESMAP = {
        AltTerms: "AdmittedTerm",
        TableFootnote: "Tablefootnote",
        formula: "Formula",
        note: "Note",
        example: "Example",
        admonition: "Admonition",
        admonitiontitle: "AdmonitionTitle",
        sourcetitle: "SourceTitle",
        TableTitle: "Tabletitle",
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

      def new_styles(docxml)
        STYLESMAP.each do |k, v|
          docxml.xpath("//*[@class = '#{k}']").each { |s| s["class"] = v }
        end
        docxml.xpath("//h1[@class = 'ForewordTitle' or @class = 'IntroTitle']")
          .each { |h| h.name = "p" }
        dis_styles1(docxml)
        docxml.xpath("//p[not(@class)]").each { |p| p["class"] = "MsoBodyText" }
        stripbgcolor(docxml)
      end

      def sourcecode_style
        "Code"
      end

      def dis_styles1(docxml)
        amd_style(docxml)
        middle_title_style(docxml)
        code_style(docxml)
        figure_style(docxml)
        formula_style(docxml)
        note_style(docxml)
        example_style(docxml)
        dis_style_interactions(docxml)
        quote_style(docxml)
        smaller_code_style(docxml)
      end

      def middle_title_style(docxml)
        docxml.xpath("//p[@class = 'zzSTDTitle2']").each do |p|
          p1 = p.previous_element && p1.name == p &&
            p1["class"] = "zzSTDTitle2" or next
          p1 << " #{p.remove.children.to_xml}"
        end
      end

      def dis_style_interactions(docxml)
        docxml.xpath("//p[@class = 'Code' or @class = 'Code-' or " \
                     "@class = 'Code--']" \
                     "[following::p[@class = 'Examplecontinued']]").each do |p|
          p["style"] ||= ""
          p["style"] = "margin-bottom:12pt;#{p['style']}"
        end
      end

      def amd_style(docxml)
        @meta.get[:doctype] == "Amendment" or return
        docxml.xpath("//div[@class = 'WordSection3']//h1").each do |h|
          h.name = "p"
          h["style"] = "font-style:italic;page-break-after:avoid;"
        end
      end

      def para_style_change(div, class1, class2)
        s = class1 ? "@class = '#{class1}'" : "not(@class)"
        div.xpath(".//p[#{s}]").each do |p|
          p["class"] = class2
        end
      end

      def quote_style1(div)
        para_style_change(div, nil, "BodyTextindent1")
        para_style_change(div, "Code-", "Code--")
        para_style_change(div, "Code", "Code-")
        if div["class"] != "Example"
          para_style_change(div, "Example", "Exampleindent")
          para_style_change(div, "Examplecontinued", "Exampleindentcontinued")
        end
        if div["class"] != "Note"
          para_style_change(div, "Note", "Noteindent")
          para_style_change(div, "Notecontinued", "Noteindentcontinued")
        end
        div.xpath(".//table[@class = 'dl']").each do |t|
          t["style"] = "margin-left: 1cm;"
        end
      end

      def note_style(docxml)
        remove_note_label(docxml)
        note_continued_style(docxml)
      end

      def example_style(docxml)
        example_continued_style(docxml)
      end

      def example_continued_style(docxml)
        docxml.xpath("//div[@class = 'Example']").each do |d|
          d.xpath("./p").each_with_index do |p, i|
            p["class"] && p["class"] != "Example" and next
            p["class"] = (i.zero? ? "Example" : "Examplecontinued")
          end
        end
      end

      def note_continued_style(docxml)
        docxml.xpath("//div[@class = 'Note']").each do |d|
          d.xpath("./p").each_with_index do |p, i|
            p["class"] && p["class"] != "Note" and next
            p["class"] = (i.zero? ? "Note" : "Notecontinued")
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

      def formula_style(docxml)
        docxml.xpath("//div[@class = 'Formula']").each do |f|
          f.xpath(".//p[not(@class)]").each do |p|
            p["class"] = "Formula"
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

      def smaller_code_style(doc)
        smaller_code_style_names(doc)
        smaller_code_style_names2spans(doc)
      end

      # TODO read $smallerfonsize from CSS definitions
      SMALL_FONT_CLASSES =
        %w(pseudocode Note tablefootnote figdl MsoISOTable MsoTableGrid
           TableISO Example Notecontinued Noteindent Noteindentcontinued
           ListNumber5- ListContinue5- BodyTextIndent22 BodyTextIndent32
           Exampleindent2 Exampleindent2continued Noteindent2continued
           Noteindent2 example_label note_label Tablebody MsoNormalTable).freeze

      INLINE_CODE_CLASSES = %w(ISOCodebold ISOCodeitalic ISOCode).freeze

      def smaller_code_style_names(doc)
        klass = SMALL_FONT_CLASSES.map { |x| "@class = '#{x}'" }.join(" or ")
        doc.xpath("//*[#{klass}]") - doc.xpath("//*[#{klass}]//*[#{klass}]")
          .each do |d|
            INLINE_CODE_CLASSES.each do |n|
              d.xpath(".//span[@class = '#{n}']").each do |s|
                s["class"] += "-"
              end
            end
          end
      end

      def smaller_code_style_names2spans(doc)
        INLINE_CODE_CLASSES.each do |n|
          doc.xpath("//span[@class = '#{n}-']").each do |s|
            s["class"] = n
            s.children =
              "<span style='font-size: 9pt;'>#{s.children.to_xml}</span>"
          end
        end
      end

      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "a#{lvl}"
        end
      end

      def word_table_cell_para_style(cell)
        ret = cell["header"] == "true" ? "Tableheader" : "Tablebody"
        cell["class"] == "rouge-code" and ret = "Code"
        ret
      end

      def table_toc_class
        ["Table title", "Tabletitle", "Annex Table Title", "AnnexTableTitle"] +
          super
      end

      def figure_toc_class
        ["Figure Title", "Annex Figure Title", "AnnexFigureTitle"] + super
      end
    end
  end
end
