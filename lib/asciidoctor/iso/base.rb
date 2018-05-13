require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "sass"
require "isodoc"

module Asciidoctor
  module ISO
    module Base
      Asciidoctor::Extensions.register do
        inline_macro Asciidoctor::ISO::AltTermInlineMacro
        inline_macro Asciidoctor::ISO::DeprecatedTermInlineMacro
        inline_macro Asciidoctor::ISO::DomainTermInlineMacro
      end

      def content(node)
        node.content
      end

      def skip(node, name = nil)
        name = name || node.node_name
        w = "converter missing for #{name} node in ISO backend"
        Utils::warning(node, w, nil)
        nil
      end

      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def generate_css(filename, stripwordcss, fontheader)
        stylesheet = File.read(filename, encoding: "UTF-8")
        stylesheet.gsub!(/(\s|\{)mso-[^:]+:[^;]+;/m, "\\1") if stripwordcss
        engine = Sass::Engine.new(fontheader + stylesheet, syntax: :scss)
        outname = File.basename(filename, ".*") + ".css"
        File.open(outname, "w") { |f| f.write(engine.render) }
        @files_to_delete << outname
        outname
      end

      def html_converter(node)
        css = generate_css(html_doc_path("style-iso.scss"), true, @fontheader)
        IsoDoc::Convert.new(
          htmlstylesheet: css,
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          i18nyaml: node.attr("i18nyaml"),
          scripts: html_doc_path("scripts.html"),
        )
      end

      def html_converter_alt(node)
        fontheader = @fontheader.gsub(/"Cambria",serif/, '"Lato",sans-serif').
          gsub(/"Courier New",monospace/, '"Space Mono", monospace')
        css = generate_css(html_doc_path("style-human.scss"), true, fontheader)
        IsoDoc::Convert.new(
          htmlstylesheet: css,
          htmlcoverpage: html_doc_path("html_iso_titlepage.html"),
          htmlintropage: html_doc_path("html_iso_intro.html"),
          i18nyaml: node.attr("i18nyaml"),
          scripts: html_doc_path("scripts.html"),
        )
      end

      def doc_converter(node)
        IsoDoc::WordConvert.new(
          wordstylesheet:  generate_css(html_doc_path("wordstyle.scss"),
                                        false, @fontheader),
          standardstylesheet: generate_css(html_doc_path("isodoc.scss"),
                                           false, @fontheader),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_iso_titlepage.html"),
          wordintropage: html_doc_path("word_iso_intro.html"),
          i18nyaml: node.attr("i18nyaml"),
          ulstyle: "l3",
          olstyle: "l2",
        )
      end

      def init(node)
        @fn_number = 0
        @draft = false
        @refids = Set.new
        @anchors = {}
        @draft = node.attributes.has_key?("draft")
        @novalid = node.attr("novalid")
        @fontheader = default_fonts(node)
        @files_to_delete = []
      end

      def default_fonts(node)
        b = node.attr("body-font") ||
          (node.attr("script") == "Hans" ? '"SimSun",serif' :
           '"Cambria",serif')
        h = node.attr("header-font") ||
          (node.attr("script") == "Hans" ? '"SimHei",sans-serif' :
           '"Cambria",serif')
        m = node.attr("monospace-font") || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def document(node)
        init(node)
        ret = makexml(node).to_xml(indent: 2)
        filename = node.attr("docfile").gsub(/\.adoc$/, "").gsub(%r{^.*/}, "")
        File.open(filename, "w") { |f| f.write(ret) }
        unless node.attr("nodoc")
          html_converter_alt(node).convert(filename + ".xml")
          system "mv #{filename}.html #{filename}_alt.html"
          html_converter(node).convert(filename + ".xml")
          doc_converter(node).convert(filename + ".xml")
        end
        @files_to_delete.each { |f| system "rm #{f}" }
        ret
      end

      def makexml1(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<iso-standard>"]
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</iso-standard>"
        textcleanup(result.flatten * "\n")
      end

      def makexml(node)
        result = makexml1(node)
        ret1 = cleanup(Nokogiri::XML(result))
        ret1.root.add_namespace(nil, "http://riboseinc.com/isoxml")
        validate(ret1) unless @novalid
        ret1
      end

      def draft?
        @draft
      end

      def front(node, xml)
        xml.bibdata **attr_code(type: node.attr("doctype")) do |b|
          metadata node, b
        end
        metadata_version(node, xml)
      end

      def middle(node, xml)
        xml.sections do |s|
          s << node.content if node.blocks?
        end
      end

      def term_source_attr(seen_xref)
        { bibitemid: seen_xref.children[0]["target"],
          format: seen_xref.children[0]["format"],
          type: "inline" }
      end

      def add_term_source(xml_t, seen_xref, m)
        xml_t.origin seen_xref.children[0].content,
          **attr_code(term_source_attr(seen_xref))
        m[:text] && xml_t.modification do |mod|
          mod.p { |p| p << m[:text].sub(/^\s+/, "") }
        end
      end

      TERM_REFERENCE_RE_STR = <<~REGEXP.freeze
        ^(?<xref><xref[^>]+>([^<]*</xref>)?)
               (,\s(?<text>.*))?
        $
      REGEXP
      TERM_REFERENCE_RE =
        Regexp.new(TERM_REFERENCE_RE_STR.gsub(/\s/, "").gsub(/_/, "\\s"),
                   Regexp::IGNORECASE | Regexp::MULTILINE)

      def extract_termsource_refs(text, node)
        matched = TERM_REFERENCE_RE.match text
        if matched.nil?
          Utils::warning(node, "term reference not in expected format", text)
        end
        matched
      end

      def termsource(node)
        matched = extract_termsource_refs(node.content, node) || return
        noko do |xml|
          attrs = { status: matched[:text] ? "modified" : "identical" }
          xml.termsource **attrs do |xml_t|
            seen_xref = Nokogiri::XML.fragment(matched[:xref])
            add_term_source(xml_t, seen_xref, matched)
          end
        end.join("\n")
      end
    end
  end
end
