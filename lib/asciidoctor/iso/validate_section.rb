require "nokogiri"

module Asciidoctor
  module ISO
    class Converter < Standoc::Converter
      def section_validate(doc)
        foreword_validate(doc.root)
        normref_validate(doc.root)
        symbols_validate(doc.root)
        sections_sequence_validate(doc.root)
        section_style(doc.root)
        subclause_validate(doc.root)
        super
      end

      # ISO/IEC DIR 2, 12.4
      def foreword_validate(root)
        f = root.at("//foreword") || return
        s = f.at("./clause")
        @log.add("Style", f, "foreword contains subclauses") unless s.nil?
      end

      # ISO/IEC DIR 2, 15.4
      def normref_validate(root)
        f = root.at("//references[@normative = 'true']") || return
        f.at("./references | ./clause") &&
          @log.add("Style", f, "normative references contains subclauses")
      end

      ONE_SYMBOLS_WARNING = "Only one Symbols and Abbreviated "\
        "Terms section in the standard".freeze

      NON_DL_SYMBOLS_WARNING = "Symbols and Abbreviated Terms can "\
        "only contain a definition list".freeze

      def symbols_validate(root)
        f = root.xpath("//definitions")
        f.empty? && return
        (f.size == 1) || @log.add("Style", f.first, ONE_SYMBOLS_WARNING)
        f.first.elements.each do |e|
          unless e.name == "dl"
            @log.add("Style", f.first, NON_DL_SYMBOLS_WARNING)
            return
          end
        end
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        unless accepted.include? n
          @log.add("Style", nil, msg)
          names = []
        end
        names
      end

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ =
        [
          {
            msg: "Initial section must be (content) Foreword",
            val:  [{ tag: "foreword", title: "Foreword" }],
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val:  [{ tag: "introduction", title: "Introduction" },
                   { tag: "clause", title: "Scope" }],
          },
          {
            msg: "Prefatory material must be followed by (clause) Scope",
            val: [{ tag: "clause", title: "Scope" }],
          },
          {
            msg: "Normative References must be followed by "\
            "Terms and Definitions",
            val: [
              { tag: "terms", title: "Terms and definitions" },
              { tag: "clause", title: "Terms and definitions" },
              {
                tag: "terms",
                title: "Terms, definitions, symbols and abbreviated terms",
              },
              {
                tag: "clause",
                title: "Terms, definitions, symbols and abbreviated terms",
              },
            ],
          },
      ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | "\
        "//sections/definitions | //sections/clause | //references[not(parent::clause)] | "\
        "//clause[descendant::references][not(parent::clause)]".freeze

      def sections_sequence_validate(root)
        f = root.xpath(SECTIONS_XPATH)
        names = f.map { |s| { tag: s.name, title: s&.at("./title")&.text } }
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val]) || return
        n = names[0]
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val]) || return
        if n == { tag: "introduction", title: "Introduction" }
          names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val]) || return
        end
        names = seqcheck(names, SEQ[3][:msg], SEQ[3][:val]) || return
        n = names.shift
        if n == { tag: "definitions", title: nil }
          n = names.shift || return
        end
        unless n
          @log.add("Style", nil, "Document must contain at least one clause")
          return
        end
        n[:tag] == "clause" ||
          @log.add("Style", nil, "Document must contain clause after "\
               "Terms and Definitions")
        n == { tag: "clause", title: "Scope" } &&
          @log.add("Style", nil, "Scope must occur before Terms and Definitions")
        n = names.shift || return
        while n[:tag] == "clause"
          n[:title] == "Scope" &&
            @log.add("Style", nil, "Scope must occur before Terms and Definitions")
          n = names.shift || return
        end
        unless n[:tag] == "annex" || n[:tag] == "references"
          @log.add("Style", nil, "Only annexes and references can follow clauses")
        end
        while n[:tag] == "annex"
          n = names.shift
          if n.nil?
            @log.add("Style", nil, "Document must include (references) "\
                 "Normative References")
            return
          end
        end
        n == { tag: "references", title: "Normative References" } ||
          @log.add("Style", nil, "Document must include (references) "\
               "Normative References")
        n = names.shift
        n == { tag: "references", title: "Bibliography" } ||
          @log.add("Style", nil, "Final section must be (references) Bibliography")
        names.empty? ||
          @log.add("Style", nil, "There are sections after the final Bibliography")
      end

      def style_warning(node, msg, text = nil)
        return if @novalid
        w = msg
        w += ": #{text}" if text
        @log.add("Style", node, w)
      end

      NORM_ISO_WARN = "non-ISO/IEC reference not expected as normative".freeze
      SCOPE_WARN = "Scope contains subclauses: should be succinct".freeze

      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[title = 'Scope']"))
        scope = root.at("//clause[title = 'Scope']/clause")
        # ISO/IEC DIR 2, 14.4
        scope.nil? || style_warning(scope, SCOPE_WARN, nil)
      end

      ASSETS_TO_STYLE =
        "//termsource | //formula | //termnote | //p[not(ancestor::boilerplate)] | "\
        "//li[not(p)] | //dt | //dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze

      NORM_BIBITEMS =
        "//references[@normative = 'true']/bibitem".freeze

      # ISO/IEC DIR 2, 10.2
      def norm_bibitem_style(root)
        root.xpath(NORM_BIBITEMS).each do |b|
          if b.at(Standoc::Converter::ISO_PUBLISHER_XPATH).nil?
            @log.add("Style", b, "#{NORM_ISO_WARN}: #{b.text}")
          end
        end
      end

      def asset_style(root)
        root.xpath("//example | //termexample").each { |e| example_style(e) }
        root.xpath("//definition").each { |e| definition_style(e) }
        root.xpath("//note").each { |e| note_style(e) }
        root.xpath("//fn").each { |e| footnote_style(e) }
        root.xpath(ASSETS_TO_STYLE).each { |e| style(e, extract_text(e)) }
        norm_bibitem_style(root)
        super
      end

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause").each do |c|
          style_warning(c, "Exceeds the maximum clause depth of 7", nil)
        end
      end
    end
  end
end
