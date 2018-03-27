require "nokogiri"

module Asciidoctor
  module ISO
    module Validate
      def section_validate(doc)
        foreword_validate(doc.root)
        normref_validate(doc.root)
        symbols_validate(doc.root)
        sections_sequence_validate(doc.root)
        section_style(doc.root)
        sourcecode_style(doc.root)
        asset_style(doc.root)
      end

      def foreword_validate(root)
        f = root.at("//foreword") || return
        s = f.at("./subclause")
        warn "ISO style: foreword contains subclauses" unless s.nil?
      end

      def normref_validate(root)
        f = root.at("//references[title = 'Normative References']") || return
        f.at("./references") &&
          warn("ISO style: normative references contains subclauses")
      end

      ONE_SYMBOLS_WARNING = "ISO style: only one Symbols and Abbreviated "\
        "Terms section in the standard".freeze

      NON_DL_SYMBOLS_WARNING = "ISO style: Symbols and Abbreviated Terms can "\
        "only contain a definition list".freeze

      def symbols_validate(root)
        f = root.xpath("//definitions")
        f.empty? && return
        (f.size == 1) || warn(ONE_SYMBOLS_WARNING)
        f.first.elements.each do |e|
          unless e.name == "dl"
            warn(NON_DL_SYMBOLS_WARNING)
            return
          end
        end
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        unless accepted.include? n
          warn "ISO style: #{msg}"
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
              { tag: "terms", title: "Terms and Definitions" },
              { tag: "clause", title: "Terms and Definitions" },
              {
                tag: "terms",
                title: "Terms, Definitions, Symbols and Abbreviated Terms",
              },
              {
                tag: "clause",
                title: "Terms, Definitions, Symbols and Abbreviated Terms",
              },
            ],
          },
      ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | "\
        "//definitions | //sections/clause | //references[not(parent::clause)] | "\
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
          warn "ISO style: Document must contain at least one clause"
          return
        end
        n[:tag] == "clause" ||
          warn("ISO style: Document must contain clause after "\
               "Terms and Definitions")
        n == { tag: "clause", title: "Scope" } &&
          warn("ISO style: Scope must occur before Terms and Definitions")
        n = names.shift || return
        while n[:tag] == "clause"
          n[:title] == "Scope" &&
            warn("ISO style: Scope must occur before Terms and Definitions")
          n = names.shift || return
        end
        unless n[:tag] == "annex" || n[:tag] == "references"
          warn "ISO style: Only annexes and references can follow clauses"
        end
        while n[:tag] == "annex"
          n = names.shift
          if n.nil?
            warn("ISO style: Document must include (references) "\
                 "Normative References")
            return
          end
        end
        n == { tag: "references", title: "Normative References" } ||
          warn("ISO style: Document must include (references) "\
               "Normative References")
        n = names.shift
        n == { tag: "references", title: "Bibliography" } ||
          warn("ISO style: Final section must be (references) Bibliography")
        names.empty? ||
          warn("ISO style: There are sections after the final Bibliography")
      end

      NORM_ISO_WARN = "non-ISO/IEC reference not expected as normative".freeze
      SCOPE_WARN = "Scope contains subclauses: should be succint".freeze

      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[title = 'Scope']"))
        scope = root.at("//clause[title = 'Scope']/subclause")
        scope.nil? || style_warning(scope, SCOPE_WARN, nil)
      end

      def sourcecode_style(root)
        root.xpath("//sourcecode").each do |x|
          callouts = x.elements.select { |e| e.name == "callout" }
          annotations = x.elements.select { |e| e.name == "annotation" }
          if callouts.size != annotations.size
            warn "#{x['id']}: mismatch of callouts and annotations"
          end
        end
      end

      ASSETS_TO_STYLE =
        "//termsource | //formula | //termnote | //p | //li[not(p)] | "\
        "//dt | //dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze

      NORM_BIBITEMS =
        "//references[title = 'Normative References']/bibitem".freeze

      def asset_title_style(root)
        root.xpath("//figure[image][not(title)]").each do |node|
          style_warning(node, "Figure should have title", nil)
        end
        root.xpath("//table[not(title)]").each do |node|
          style_warning(node, "Table should have title", nil)
        end
      end

      def norm_bibitem_style(root)
        root.xpath(NORM_BIBITEMS).each do |b|
          if b.at(Cleanup::ISO_PUBLISHER_XPATH).nil?
            Utils::warning(b, NORM_ISO_WARN, b.text)
          end
        end
      end

      def asset_style(root)
        root.xpath("//example | //termexample").each { |e| example_style(e) }
        root.xpath("//note").each { |e| note_style(e) }
        root.xpath("//fn").each { |e| footnote_style(e) }
        root.xpath(ASSETS_TO_STYLE).each { |e| style(e, extract_text(e)) }
        asset_title_style(root)
        norm_bibitem_style(root)
      end
    end
  end
end
