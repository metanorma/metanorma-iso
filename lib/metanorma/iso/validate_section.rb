require "nokogiri"

module Metanorma
  module ISO
    class Converter < Standoc::Converter
      def section_validate(doc)
        doctype = doc&.at("//bibdata/ext/doctype")&.text
        unless %w(amendment technical-corrigendum).include? doctype
          foreword_validate(doc.root)
          normref_validate(doc.root)
          symbols_validate(doc.root)
          sections_presence_validate(doc.root)
          sections_sequence_validate(doc.root)
        end
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
        (f.size == 1 || @vocab) or
          @log.add("Style", f.first, ONE_SYMBOLS_WARNING)
        f.first.elements.reject { |e| %w(title dl).include? e.name }.empty? or
          @log.add("Style", f.first, NON_DL_SYMBOLS_WARNING)
        @vocab and f.each do |f1|
          f1.at("./ancestor::annex") or
            @log.add("Style", f1, "In vocabulary documents, Symbols and "\
                                  "Abbreviated Terms are only permitted in annexes")
        end
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        return [] if n.nil?

        test = accepted.map { |a| n.at(a) }
        if test.all?(&:nil?)
          @log.add("Style", nil, msg)
        end
        names
      end

      def sections_presence_validate(root)
        root.at("//sections/clause[@type = 'scope']") or
          @log.add("Style", nil, "Scope clause missing")
        root.at("//references[@normative = 'true']") or
          @log.add("Style", nil, "Normative references missing")
        root.at("//terms") or
          @log.add("Style", nil, "Terms & definitions missing")
      end

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ =
        [
          { msg: "Initial section must be (content) Foreword",
            val: ["./self::foreword"] },
          { msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::introduction", "./self::clause[@type = 'scope']"] },
          { msg: "Prefatory material must be followed by (clause) Scope",
            val: ["./self::clause[@type = 'scope']"] },
          { msg: "Normative References must be followed by "\
                 "Terms and Definitions",
            val: ["./self::terms | .//terms"] },
        ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | "\
        "//sections/definitions | //sections/clause | "\
        "//references[not(parent::clause)] | "\
        "//clause[descendant::references][not(parent::clause)]".freeze

      def sections_sequence_validate(root)
        names, n = sections_sequence_validate_start(root)
        if @vocab
          names, n = sections_sequence_validate_body_vocab(names, n)
        else
          names, n = sections_sequence_validate_body(names, n)
        end
        sections_sequence_validate_end(names, n)
      end

      def sections_sequence_validate_start(root)
        names = root.xpath(SECTIONS_XPATH)
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val])
        n = names[0]
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val])
        n&.at("./self::introduction") and
          names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val])
        names = seqcheck(names, SEQ[3][:msg], SEQ[3][:val])
        n = names.shift
        n = names.shift if n&.at("./self::definitions")
        [names, n]
      end

      def sections_sequence_validate_body(names, elem)
        if elem.nil? || elem.name != "clause"
          @log.add("Style", elem, "Document must contain at least one clause")
        end
        elem&.at("./self::clause") ||
          @log.add("Style", elem, "Document must contain clause after "\
                                  "Terms and Definitions")
        elem&.at("./self::clause[@type = 'scope']") &&
          @log.add("Style", elem,
                   "Scope must occur before Terms and Definitions")
        elem = names.shift
        while elem&.name == "clause"
          elem&.at("./self::clause[@type = 'scope']")
          @log.add("Style", elem,
                   "Scope must occur before Terms and Definitions")
          elem = names.shift
        end
        %w(annex references).include? elem&.name or
          @log.add("Style", elem,
                   "Only annexes and references can follow clauses")
        [names, elem]
      end

      def sections_sequence_validate_body_vocab(names, elem)
        while elem && %w(clause terms).include?(elem.name)
          elem = names.shift
        end
        %w(annex references).include? elem&.name or
          @log.add("Style", elem,
                   "Only annexes and references can follow terms and clauses")
        [names, elem]
      end

      def sections_sequence_validate_end(names, elem)
        while elem&.name == "annex"
          elem = names.shift
          if elem.nil?
            @log.add("Style", nil, "Document must include (references) "\
                                   "Normative References")
          end
        end
        elem&.at("./self::references[@normative = 'true']") ||
          @log.add("Style", nil, "Document must include (references) "\
                                 "Normative References")
        elem = names&.shift
        elem&.at("./self::references[@normative = 'false']") ||
          @log.add("Style", elem,
                   "Final section must be (references) Bibliography")
        names.empty? ||
          @log.add("Style", elem,
                   "There are sections after the final Bibliography")
      end

      NORM_ISO_WARN = "non-ISO/IEC reference not expected as normative".freeze
      SCOPE_WARN = "Scope contains subclauses: should be succinct".freeze

      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[@type = 'scope']"))
        scope = root.at("//clause[@type = 'scope']/clause")
        # ISO/IEC DIR 2, 14.4
        scope.nil? || style_warning(scope, SCOPE_WARN, nil)
        tech_report_style(root)
      end

      def tech_report_style(root)
        root.at("//bibdata/ext/doctype")&.text == "technical-report" or return
        root.xpath("//sections/clause[not(@type = 'scope')] | //annex")
          .each do |s|
          r = requirement_check(extract_text(s)) and
            style_warning(s,
                          "Technical Report clause may contain requirement", r)
        end
      end

      ASSETS_TO_STYLE =
        "//termsource | //formula | //termnote | "\
        "//p[not(ancestor::boilerplate)] | //li[not(p)] | //dt | "\
        "//dd[not(p)] | //td[not(p)] | //th[not(p)]".freeze

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
        root.xpath("//definition/verbal-definition").each do |e|
          definition_style(e)
        end
        root.xpath("//note").each { |e| note_style(e) }
        root.xpath("//fn").each { |e| footnote_style(e) }
        root.xpath(ASSETS_TO_STYLE).each { |e| style(e, extract_text(e)) }
        norm_bibitem_style(root)
        super
      end

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause")
          .each do |c|
          style_warning(c, "Exceeds the maximum clause depth of 7", nil)
        end
      end

      # ISO/IEC DIR 2, 22.3.2
      def onlychild_clause_validate(root)
        root.xpath(Standoc::Utils::SUBCLAUSE_XPATH).each do |c|
          next unless c.xpath("../clause").size == 1

          title = c.at("./title")
          location = c["id"] || "#{c.text[0..60]}..."
          location += ":#{title.text}" if c["id"] && !title.nil?
          @log.add("Style", nil, "#{location}: subclause is only child")
        end
      end
    end
  end
end
