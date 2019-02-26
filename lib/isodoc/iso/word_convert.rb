require "isodoc"
require_relative "metadata"

module IsoDoc
  module Iso
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Cambria",serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Cambria",serif'),
          monospacefont: '"Courier New",monospace',
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: options[:alt] ? html_doc_path("style-human.scss") : html_doc_path("style-iso.scss"),
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          scripts: html_doc_path("scripts.html"),
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage.html"),
          wordintropage: html_doc_path("word_iso_intro.html"),
          ulstyle: "l3", 
          olstyle: "l2",
        }
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def implicit_reference(b)
        isocode = b.at(ns("./docidentifier")).text
        isocode == "IEV"
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
          colophon(body, docxml)
        end
      end

      def colophon(body, docxml)
        stage =  @meta.get[:stage_int]
        return if !stage.nil? && stage < 60
        body.br **{ clear: "all", style: "page-break-before:left;mso-break-type:section-break" }
        body.div **{ class: "colophon" } do |div|
        end
      end

      def introduction(isoxml, out)
        f = isoxml.at(ns("//introduction")) || return
        num = f.at(ns(".//clause")) ? "0" : nil
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          # div.h1 "Introduction", **attr_code(title_attr)
          clause_name(num, @introduction_lbl, div, title_attr)
          f.elements.each do |e|
            if e.name == "patent-notice"
              e.elements.each { |e1| parse(e1, div) }
            else
              parse(e, div) unless e.name == "title"
            end
          end
        end
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword")) || return
        page_break(out)
        out.div **attr_code(id: f["id"]) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def initial_anchor_names(d)
        super
        introduction_names(d.at(ns("//introduction")))
      end

      # we can reference 0-number clauses in introduction
      def introduction_names(clause)
        return if clause.nil?
        clause.xpath(ns("./clause")).each_with_index do |c, i|
          section_names1(c, "0.#{i + 1}", 2)
        end
      end

      # terms not defined in standoc
      def error_parse(node, out)
        case node.name
        when "appendix" then clause_parse(node, out)
        else
          super
        end
      end

      def annex_names(clause, num)
        appendix_names(clause, num)
        super
      end

      def appendix_names(clause, num)
        clause.xpath(ns("./appendix")).each_with_index do |c, i|
          @anchors[c["id"]] = anchor_struct(i + 1, nil, @appendix_lbl, "clause")
          @anchors[c["id"]][:level] = 2
          @anchors[c["id"]][:container] = clause["id"]
        end
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, xref: num }
        # subclauses are not prefixed with "Clause"
        clause.xpath(ns("./clause | ./terms | ./term | ./definitions")).
          each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] = { label: num, xref: num, level: level }
        clause.xpath(ns("./clause")).each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end

      def eref_localities1_zh(target, type, from, to)
        subsection = from&.text&.match(/\./)
        ret = type == "list" ? "" : ","
        ret += " 第#{from.text}" if from
        ret += "&ndash;#{to}" if to
        loc = (@locality[type] || type.sub(/^locality:/, "").capitalize )
        ret += " #{loc}" unless subsection && type == "clause" || type == "list" || target.match(/^IEV$|^IEC 60050-/)
        ret += ")" if type == "list"
        ret
      end

      def eref_localities1(target, type, from, to, lang = "en")
        subsection = from&.text&.match(/\./)
        type = type.downcase
        return l10n(eref_localities1_zh(target, type, from, to)) if lang == "zh"
        ret = type == "list" ? "" : ","
        loc = @locality[type] || type.sub(/^locality:/, "").capitalize
        ret += " #{loc}" unless subsection && type == "clause" || type == "list" || target.match(/^IEV$|^IEC 60050-/)
        ret += " #{from.text}" if from
        ret += "&ndash;#{to.text}" if to
        ret += ")" if type == "list"
        l10n(ret)
      end

      def prefix_container(container, linkend, target)
        delim = get_anchors[target][:type] == "listitem" ? " " : ", "
        l10n(get_anchors[container][:xref] + delim + linkend)
      end

      def example_p_parse(node, div)
        div.p do |p|
          p.span **{ class: "example_label" } do |s|
            s << example_label(node)
          end
          insert_tab(p, 1)
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def example_parse1(node, div)
        div.p do |p|
          p.span **{ class: "example_label" } do |s|
            s << example_label(node)
          end
          insert_tab(p, 1)
        end
        node.children.each { |n| parse(n, div) }
      end

      def example_parse(node, out)
        out.div **{ id: node["id"], class: "example" } do |div|
          if node.first_element_child.name == "p"
            example_p_parse(node, div)
          else
            example_parse1(node, div)
          end
        end
      end

      def termexamples_before_termnotes(node)
        return unless node.at(ns("./termnote")) && node.at(ns("./termexample"))
        return unless insert = node.at(ns("./definition"))
        insert = insertall_after_here(node, insert, "termexample")
        insert = insertall_after_here(node, insert, "termnote")
      end

      def term_parse(node, out)
        termexamples_before_termnotes(node)
        out.p **{ class: "Terms", style:"text-align:left;" } do |p|
          node.children.each { |c| parse(c, p) }
        end
      end

    end
  end
end
