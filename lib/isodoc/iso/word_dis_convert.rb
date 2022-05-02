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
        NormRef: "RefNorm",
      }.freeze

      def dis_styles(docxml)
        STYLESMAP.each do |k, v|
          docxml.xpath("//*[@class = '#{k}']").each do |s|
            s["class"] = v
          end
        end
      end
    end
  end
end
