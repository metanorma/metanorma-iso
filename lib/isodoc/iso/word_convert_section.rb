module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      MAIN_ELEMENTS =
        "//sections/*[@displayorder] | //annex[@displayorder] | " \
        "//bibliography/*[@displayorder]".freeze

      def colophon_section(_isoxml, out)
        stage = @meta.get[:stage_int]
        return if !stage.nil? && stage < 60

        br(out, "left")
        out.div class: "colophon" do |div|
        end
      end

      def indexsect_section(isoxml, out)
        isoxml.xpath(ns("//indexsect")).each do |i|
          indexsect(i, out)
        end
      end

      def indexsect(elem, out)
        indexsect_title(elem, out)
        br(out, "auto")
        out.div class: "index" do |div|
          elem.children.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def indexsect_title(clause, out)
        br(out, "always")
        out.div class: "WordSection3" do |div|
          clause_name(clause, clause.at(ns("./title")), div, nil)
        end
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
            style='mso-element:field-begin'></span><span
            style='mso-spacerun:yes'>&#xA0;</span>TOC
            \\o "1-#{level}" \\h \\z \\t "Heading
            1;1;ANNEX;1;Biblio Title;1;Foreword Title;1;Intro Title;1" <span
            style='mso-element:field-separator'></span></span>
        TOC
      end

      def bibliography_attrs
        { class: "BiblioTitle" }
      end

      def bibliography(node, out)
        node["hidden"] != "true" or return
        page_break(out)
        out.div do |div|
          div.h1 **bibliography_attrs do |h1|
            node&.at(ns("./title"))&.children&.each { |c2| parse(c2, h1) }
          end
          biblio_list(node, div, true)
        end
      end

      def bibliography_parse(node, out)
        node["hidden"] != true or return
        out.div do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out,
                             bibliography_attrs)
          biblio_list(node, div, true)
        end
      end

      def definition_parse(node, out)
        @definition = true
        super
        @definition = false
      end

      def termref_attrs
        { class: "Source" }
      end

      def termref_parse(node, out)
        out.p **termref_attrs do |p|
          node.children.each { |n| parse(n, p) }
        end
      end

      def annex_name(_annex, name, div)
        name.nil? and return
        name&.at(ns("./strong"))&.remove # supplied by CSS list numbering
        div.h1 class: "Annex" do |t|
          annex_name1(name, t)
          clause_parse_subtitle(name, t)
        end
      end

      def annex_name1(name, out)
        name.children.each do |c2|
          if c2.name == "span" && c2["class"] == "obligation"
            out.span style: "font-weight:normal;" do |s|
              c2.children.each { |c3| parse(c3, s) }
            end
          else parse(c2, out)
          end
        end
      end
    end
  end
end
