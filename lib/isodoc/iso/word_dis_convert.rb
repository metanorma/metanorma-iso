require_relative "word_dis_cleanup"

module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      def default_file_locations(_options)
        { wordstylesheet: html_doc_path("wordstyle-dis.scss"),
          standardstylesheet: html_doc_path("isodoc-dis.scss"),
          header: html_doc_path("header-dis.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage-dis.html"),
          wordintropage: html_doc_path("word_iso_intro-dis.html"),
          ulstyle: "l3",
          olstyle: "l2" }
      end

      def initialize(options)
        @libdir ||= File.dirname(__FILE__) # rubocop:disable Lint/DisjunctiveAssignmentInConstructor
        options.merge!(default_file_locations(options))
        super
      end

      def init_dis; end

      def convert1(docxml, filename, dir)
        update_coverpage(docxml)
        super
      end

      def update_coverpage(docxml)
        stage = docxml.at(ns("//bibdata/status/stage"))&.text
        substage = docxml.at(ns("//bibdata/status/substage"))&.text
        if /^9/.match?(stage) || (stage == "60" && substage == "60")
          @wordcoverpage = html_doc_path("word_iso_titlepage.html")
        elsif stage == "60" && substage == "00"
          @wordcoverpage = html_doc_path("word_iso_titlepage-prf.html")
        end
      end

      def figure_name_attrs(_node)
        { class: "FigureTitle", style: "text-align:center;" }
      end

      def table_title_attrs(_node)
        { class: "Tabletitle", style: "text-align:center;" }
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
          style='mso-spacerun:yes'>&#xA0;</span>TOC \\o "2-#{level}" \\h \\z \\t
          "Heading 1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1;ANNEXN;1;ANNEXZ;1;na2;1;na3;1;na4;1;na5;1;na6;1;Title;1;Base_Heading;1;Box-title;1;Front Head;1;Index Head;1;AMEND Terms Heading;1;AMEND Heading 1 Unnumbered;1"
           <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def render_identifier(ident)
        ret = super
        ret[:sdo] = std_docid_semantic(ret[:sdo])
        ret
      end

      def make_tr_attr(cell, row, totalrows, header)
        super.merge(header: header)
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

      def middle_title(_isoxml, out)
        middle_title_dis(out)
      end

      def middle_title_dis(out)
        out.p(**{ class: "zzSTDTitle" }) do |p|
          p << @meta.get[:doctitleintro]
          @meta.get[:doctitleintro] && @meta.get[:doctitlemain] and p << " &#x2014; "
          p << @meta.get[:doctitlemain]
          @meta.get[:doctitlemain] && @meta.get[:doctitlepart] and p << " &#x2014; "
          if @meta.get[:doctitlepart]
            b = @meta.get[:doctitlepartlabel] and
              p << "<span style='font-weight:normal'>#{b}</span> "
            p << " #{@meta.get[:doctitlepart]}"
          end
          @meta.get[:doctitleamdlabel] || @meta.get[:doctitleamd] ||
            @meta.get[:doctitlecorrlabel] and middle_title_dis_amd(p)
        end
      end

      def middle_title_dis_amd(para)
        para.span(**{ style: "font-weight:normal" }) do |p|
          if a = @meta.get[:doctitleamdlabel]
            p << " #{a}"
            a = @meta.get[:doctitleamd] and p << ": #{a}"
          end
          if a = @meta.get[:doctitlecorrlabel]
            p << " #{a}"
          end
        end
      end
    end
  end
end
