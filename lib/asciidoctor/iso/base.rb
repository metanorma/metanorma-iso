require "date"
require "nokogiri"
require "htmlentities"
require "json"
require "pathname"
require "open-uri"
require "pp"
require "sass"
require "isodoc"
require "relaton"

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

      def html_converter(node)
        IsoDoc::Iso::HtmlConvert.new(
          script: node.attr("script"),
          bodyfont: node.attr("body-font"),
          headerfont: node.attr("header-font"),
          monospacefont: node.attr("monospace-font"),
          i18nyaml: node.attr("i18nyaml"),
        )
      end

      def html_converter_alt(node)
        IsoDoc::Iso::HtmlConvert.new(
          script: node.attr("script"),
          bodyfont: node.attr("body-font"),
          headerfont: node.attr("header-font"),
          monospacefont: node.attr("monospace-font"),
          i18nyaml: node.attr("i18nyaml"),
          alt: true,
        )
      end

      def doc_converter(node)
        IsoDoc::Iso::WordConvert.new(
          script: node.attr("script"),
          bodyfont: node.attr("body-font"),
          headerfont: node.attr("header-font"),
          monospacefont: node.attr("monospace-font"),
          i18nyaml: node.attr("i18nyaml"),
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
        @filename = node.attr("docfile") ?
          node.attr("docfile").gsub(/\.adoc$/, "").gsub(%r{^.*/}, "") : ""
        @no_isobib_cache = node.attr("no-isobib-cache")
        @no_isobib = node.attr("no-isobib")
        @bibdb = nil
        init_bib_caches(node)
      end

      def init_bib_caches(node)
        unless (@no_isobib_cache || @no_isobib)
          globalname = bibliocache_name(true)
          localname = bibliocache_name(false) if node.attr("local-cache")
          if node.attr("flush-caches")
            system("rm -f #{globalname}") unless globalname.nil?
            system("rm -f #{localname}") unless localname.nil?
          end
        end        
        @bibdb = Relaton::Db.new(globalname, localname) unless @no_isobib
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
        unless node.attr("nodoc") || !node.attr("docfile")
          File.open(@filename + ".xml", "w") { |f| f.write(ret) }
          html_converter_alt(node).convert(@filename + ".xml")
          system "mv #{@filename}.html #{@filename}_alt.html"
          html_converter(node).convert(@filename + ".xml")
          doc_converter(node).convert(@filename + ".xml")
        end
        @files_to_delete.each { |f| system "rm #{f}" }
        ret
      end

      def makexml1(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<iso-standard>"]
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</iso-standard>"
        @bibdb.save() if @bibdb
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

      def doctype(node)
        node.attr("doctype")
      end

      def front(node, xml)
        xml.bibdata **attr_code(type: doctype(node)) do |b|
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
