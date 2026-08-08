require "nokogiri"

module Metanorma
  module Iso
    class Validate < Standoc::Validate
      def section_validate(doc)
        unless %w(amendment technical-corrigendum).include? @doctype
          normref_validate(doc.root)
          symbols_validate(doc.root)
          sections_sequence_validate(doc.root)
        end
        section_style(doc.root)
        subclause_validate(doc.root)
        @vocab and vocab_terms_titles_validate(doc.root)
        super
      end

      # ISO_23 foreword structure: migrated to
      # Metanorma::Iso::Validation::Rules::ForewordStructureRule (TODO 15).
      # ISO_24 normref structure: blocked on TODO 33 model extension
      # (StandardReferencesSection drops nested clause/refs children).
      # ISO_29/30/31 section presence: migrated to ScopePresenceRule,
      # NormativeReferencesPresenceRule, TermsPresenceRule (TODO 18).
      # ISO_39 scope subclauses: migrated to ScopeSubclausesRule (TODO 20).
      # ISO_43 only-child clause: migrated to OnlyChildClauseRule (TODO 21).

      # ISO/IEC DIR 2, 15.4
      def normref_validate(root)
        f = root.at("//references[@normative = 'true']") || return
        f.at("./references | ./clause") &&
          @log.add("ISO_24", f)
      end

      def symbols_validate(root)
        # Migrated to Layer 3 rules: SymbolsSectionCountRule (ISO_25),
        # SymbolsSectionContentRule (ISO_26), SymbolsInAnnexRule (ISO_27).
        # See TODO.validate/17.
      end

      def seqcheck(names, msg, accepted)
        n = names.shift
        return [] if n.nil?

        test = accepted.map { |a| n.at(a) }
        if test.all?(&:nil?)
          @log.add("ISO_28", nil, params: [msg])
        end
        names
      end

      def sections_presence_validate(root)
        # Migrated to Layer 3 rules (ScopePresenceRule, NormativeReferencesPresenceRule,
        # TermsPresenceRule). Method retained as no-op to keep the call site
        # stable during incremental migration; remove once all callers are gone.
      end

      # spec of permissible section sequence
      # we skip normative references, it goes to end of list
      SEQ = [
        { msg: "Initial section must be (content) Foreword",
          val: ["./self::foreword"] },
        { msg: "Prefatory material must be followed by (clause) Scope",
          val: ["./self::introduction", "./self::clause[@type = 'scope']"] },
        { msg: "Prefatory material must be followed by (clause) Scope",
          val: ["./self::clause[@type = 'scope']"] },
        { msg: "Normative References must be followed by " \
               "Terms and Definitions",
          val: ["./self::terms | .//terms"] },
      ].freeze

      SECTIONS_XPATH =
        "//foreword | //introduction | //sections/terms | .//annex | " \
        "//sections/definitions | //sections/clause | " \
        "//references[not(parent::clause)] | " \
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
          @log.add("ISO_32", elem)
        end
        elem&.at("./self::clause") or
          @log.add("ISO_33", elem)
        elem&.at("./self::clause[@type = 'scope']") and
          @log.add("ISO_34", elem)
        elem = names.shift
        while elem&.name == "clause"
          elem&.at("./self::clause[@type = 'scope']") and
            @log.add("ISO_34", elem)
          elem = names.shift
        end
        %w(annex references).include? elem&.name or
          @log.add("ISO_36", elem)
        [names, elem]
      end

      def sections_sequence_validate_body_vocab(names, elem)
        while elem && %w(clause terms).include?(elem.name)
          elem = names.shift
        end
        %w(annex references).include? elem&.name or
          @log.add("ISO_37", elem)
        [names, elem]
      end

      def sections_sequence_validate_end(names, elem)
        while elem&.name == "annex"
          elem = names.shift
          if elem.nil?
            @log.add("ISO_38", nil)
          end
        end
        elem.nil? and return
        elem&.at("./self::references[@normative = 'true']") ||
          @log.add("ISO_38", nil)
        elem = names&.shift
        elem.nil? and return
        elem&.at("./self::references[@normative = 'false']") ||
          @log.add("ISO_40", elem)
        names.empty? ||
          @log.add("ISO_41", elem)
      end

      def section_style(root)
        foreword_style(root.at("//foreword"))
        introduction_style(root.at("//introduction"))
        scope_style(root.at("//clause[@type = 'scope']"))
        # ISO_39 scope subclauses: migrated to ScopeSubclausesRule (TODO 20).
        tech_report_style(root)
      end

      def tech_report_style(root)
        @doctype == "technical-report" or return
        root.xpath("//sections/clause[not(@type = 'scope')] | //annex")
          .each do |s|
          r = requirement_check(extract_text(s)) and
            style_warning(s,
                          "Technical Report clause may contain requirement", r)
        end
      end

      # ISO_42 normative bibitem style: migrated to
      # Metanorma::Iso::Validation::Rules::NormativeBibitemRule (TODO 10).

      def subclause_validate(root)
        root.xpath("//clause/clause/clause/clause/clause/clause/clause/clause")
          .each do |c|
          style_warning(c, "Exceeds the maximum clause depth of 7", nil)
        end
      end

      # ISO/IEC DIR 2, 22.3.2
      # ISO_43 only-child clause: migrated to OnlyChildClauseRule (TODO 21).

      # https://www.iso.org/ISO-house-style.html#iso-hs-s-formatting-r-vocabulary
      def vocab_terms_titles_validate(root)
        terms = root.xpath("//sections/terms | //sections/clause[.//terms]")
        if terms.size == 1
          ((t = terms.first.at("./title")) && (t&.text == @i18n.termsdef)) or
            @log.add("ISO_44", terms.first)
        elsif terms.size > 1
          terms.each do |x|
            ((t = x.at("./title")) && /^#{@i18n.termsrelated}/.match?(t&.text)) or
              @log.add("ISO_45", x)
          end
        end
      end
    end
  end
end
