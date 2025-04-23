require_relative "word_dis_cleanup"

module IsoDoc
  module Iso
    class WordDISConvert < WordConvert
      attr_accessor :bgstripcolor

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

      def init_dis(opt); end

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
        { class: "TableTitle", style: "text-align:center;" }
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
          style='mso-element:field-begin'></span><span
          style='mso-spacerun:yes'>&#xA0;</span>TOC \\o "2-#{level}" \\h \\z \\t
          "Heading 1,1,ANNEX,1,Biblio Title,1,Foreword Title,1,Intro Title,1,ANNEXN,1,ANNEXZ,1,na2,1,na3,1,na4,1,na5,1,na6,1,Title,1,Base_Heading,1,Box-title,1,Front Head,1,Index Head,1,AMEND Terms Heading,1,AMEND Heading 1 Unnumbered,1"
           <span style='mso-element:field-separator'></span></span>
        TOC
      end

      def make_tr_attr(cell, row, totalrows, header, bordered)
        super.merge(header: header)
      end

      def toWord(result, filename, dir, header)
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

      def middle_title_dis(node, out)
        out.p(class: "zzSTDTitle") do |p|
          node.children.each { |n| parse(n, p) }
        end
      end

      def middle_title_amd(node, out)
        out.p(class: "zzSTDTitle2") do |p|
          p.span(style: "font-weight:normal") do |s|
            node.children.each { |n| parse(n, s) }
          end
        end
      end

      def para_parse(node, out)
        case node["class"]
        when "zzSTDTitle1" then middle_title_dis(node, out)
        when "zzSTDTitle2" then middle_title_amd(node, out)
        else super
        end
      end

      def span_parse(node, out)
        st = node["style"]
        case node["class"]
        when "nonboldtitle"
          out.span **attr_code(style: "#{st};font-weight:normal") do |s|
            node.children.each { |n| parse(n, s) }
          end
        when "boldtitle"
          out.span **attr_code(style: st) do |s|
            node.children.each { |n| parse(n, s) }
          end
        else super
        end
      end

      def authority_cleanup(docxml)
        super
        if ["9", "6"].include?(@meta.get[:stage_int].to_s[0])
          copyright_prf(docxml)
        else
          copyright_dis(docxml)
        end
      end

      def copyright_prf(docxml)
        docxml.xpath("//p[@id = 'boilerplate-address']")&.each do |p|
          p["class"] = "zzCopyright"
          p["style"] = "text-indent:20.15pt;"
          p.replace(to_xml(p).gsub(%r{<br/>}, "</p>\n<p class='zzCopyright' " \
                                              "style='text-indent:20.15pt;'>"))
        end
        docxml.xpath("//p[@class = 'zzCopyrightHdr']")&.each(&:remove)
      end

      def copyright_dis(docxml)
        docxml.xpath("//p[@id = 'boilerplate-address']")&.each do |p|
          p["class"] = "zzCopyright"
          p.replace(to_xml(p).gsub(%r{<br/>}, "</p>\n<p class='zzCopyright'>"))
        end
        docxml.xpath("//p[@class = 'zzCopyrightHdr']")&.each(&:remove)
      end

      def list_title_parse(node, out)
        name = node.at(ns("./fmt-name")) or return
        klass = node["key"] == "true" ? "KeyTitle" : "ListTitle"
        out.p class: klass do |p|
          name.children&.each { |n| parse(n, p) }
        end
      end
    end
  end
end
