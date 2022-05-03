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
        FigureTitle: "Figuretitle",
        TableFootnote: "Tablefootnote",
        formula: "Formula",
        example: "Example",
        note: "Note",
        NormRef: "RefNorm",
        MsoNormal: "MsoBodyText",
      }.freeze

      def dis_styles(docxml)
        STYLESMAP.each do |k, v|
          docxml.xpath("//*[@class = '#{k}']").each { |s| s["class"] = v }
        end
        docxml.xpath("//h1[@class = 'ForewordTitle' or @class = 'IntroTitle']")
          .each { |h| h.name = "p" }
        docxml.xpath("//p[not(@class)]").each { |p| p["class"] = "MsoBodyText" }
        code_style(docxml)
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
          style='mso-spacerun:yes'>&#xA0;</span>TOC \\o &quot;2-#{level}&quot; \\h \\z \\u &quot;Heading
           1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro
           Title;1;ANNEXN;1;ANNEXZ;1;na2;1;na3;1;na4;1;na5;1;na6;1;Title;1;Base_Heading;1;Box-title;1;Front
           Head;1;Index Head;1;AMEND Terms Heading;1;AMEND Heading 1 Unnumbered;1&quot;
           <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def render_identifier(ident)
        ret = super
        ret[:sdo] = std_docid_semantic(ret[:sdo])
        ret
      end

      def code_style(doc)
        (doc.xpath("//tt//b") - doc.xpath("//tt//i//b")).each do |b|
          span_style(b, "ISOCode_bold")
        end
        (doc.xpath("//tt//i") - doc.xpath("//tt//b//i")).each do |i|
          span_style(i, "ISOCode_italic")
        end
        (doc.xpath("//b//tt") - doc.xpath("//b//i//tt")).each do |b|
          span_style(b, "ISOCode_bold")
        end
        (doc.xpath("//i//tt") - doc.xpath("//i//b//tt")).each do |i|
          span_style(i, "ISOCode_italic")
        end
        doc.xpath("//tt").each do |t|
          span_style(t, "ISOCode")
        end
      end

      def span_style(elem, style)
        elem.name = "span"
        elem["style"] = style
      end
    end
  end
end
