module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      def default_file_locations(_options)
        {
          wordstylesheet: html_doc_path("wordstyle-dis.scss"),
          standardstylesheet: html_doc_path("isodoc-dis.scss"),
          header: html_doc_path("header-dis.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage-dis.html"),
          wordintropage: html_doc_path("word_iso_intro-dis.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      def initialize(options)
        @libdir ||= File.dirname(__FILE__) # rubocop:disable Lint/DisjunctiveAssignmentInConstructor
        options.merge!(default_file_locations(options))
        super
      end

      def init_dis; end

      def style_cleanup(docxml)
        super
        dis_styles(docxml)
      end

      STYLESMAP = {
        AltTerms: "AdmittedTerm",
        TableFootnote: "Tablefootnote",
        formula: "Formula",
        note: "Note",
        NormRef: "RefNorm",
        biblio: "BiblioEntry",
        MsoNormal: "MsoBodyText",
        FigureTitle: "Figuretitle",
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
        code_style(docxml)
        figure_style(docxml)
        example_style(docxml)
      end

      def example_style(docxml)
        docxml.xpath("//div[@class = 'Example']").each do |d|
          d.xpath("./p").each_with_index do |p, i|
            next if p["class"] && p["class"] != "Example"

            p["class"] = (i.zero? ? "Example" : "Examplecontinued")
          end
        end
      end

      def figure_name_attrs(_node)
        { class: "FigureTitle", style: "text-align:center;" }
      end

      def table_title_attrs(_node)
        { class: "Tabletitle", style: "text-align:center;" }
      end

      def word_annex_cleanup1(docxml, lvl)
        docxml.xpath("//h#{lvl}[ancestor::*[@class = 'Section3']]").each do |h2|
          h2.name = "p"
          h2["class"] = "a#{lvl}"
        end
      end

      def span_parse(node, out)
        out.span **{ class: node["class"] } do |x|
          node.children.each { |n| parse(n, x) }
        end
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
          style='mso-element:field-begin'></span><span
          style='mso-spacerun:yes'>&#xA0;</span>TOC \\o &quot;2-#{level}&quot; \\h \\z \\t
          &quot;Heading 1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1;ANNEXN;1;ANNEXZ;1;na2;1;na3;1;na4;1;na5;1;na6;1;Title;1;Base_Heading;1;Box-title;1;Front Head;1;Index Head;1;AMEND Terms Heading;1;AMEND Heading 1 Unnumbered;1&quot;
           <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def render_identifier(ident)
        ret = super
        ret[:sdo] = std_docid_semantic(ret[:sdo])
        ret
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

      def make_tr_attr(cell, row, totalrows, header)
        super.merge(header: header)
      end

      def word_cleanup(docxml)
        word_table_cell_para(docxml)
        super
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

      def toWord(result, filename, dir, header)
        result = from_xhtml(word_cleanup(to_xhtml(result)))
          .gsub(/-DOUBLE_HYPHEN_ESCAPE-/, "--")
        @wordstylesheet = wordstylesheet_update
        ::Html2Doc::IsoDIS.new(
          filename: filename,
          imagedir: @localdir,
          stylesheet: @wordstylesheet&.path,
          header_file: header&.path, dir: dir,
          asciimathdelims: [@openmathdelim, @closemathdelim],
          liststyles: { ul: @ulstyle, ol: @olstyle }
        ).process(result)
        header&.unlink
        @wordstylesheet.unlink if @wordstylesheet.is_a?(Tempfile)
      end
    end
  end
end
