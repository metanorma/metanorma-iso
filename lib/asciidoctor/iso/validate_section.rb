require "nokogiri"
require "pp"

module Asciidoctor
  module ISO
    module Validate
      def section_validate(doc)
        foreword_validate(doc.root)
        normref_validate(doc.root)
        symbols_validate(doc.root)
        sections_sequence_validate(doc.root)
      end

      def foreword_validate(root)
        f = root.at("//foreword") || return
        s = f.at("./subsection")
        warn "ISO style: foreword contains subsections" unless s.nil?
      end

      def normref_validate(root)
        f = root.at("//references[title = 'Normative References']") || return
        f.at("./references") and
          warn "ISO style: normative references contains subsections"
      end

      def symbols_validate(root)
        (f = root.xpath("//symbols-abbrevs") && !f.nil?) || return
        (f.size == 1) || warn("ISO style: only one Symbols and Abbreviations"\
          "section in the standard")
        f.first.elements do |e|
          unless e.name == "dl"
            warn "ISO style: Symbols and Abbreviations can only contain "\
              "a definition list"
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
      SEQ = [
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
        # we skip normative references, it goes to end of list
        {
          msg: "Normative References must be followed by "\
          "Terms and Definitions",
          val: [
            { tag: "terms", title: "Terms and Definitions" },
            { tag: "terms",
              title: "Terms, Definitions, Symbols and Abbreviations" }
          ]
        },
      ]

      SECTIONS_XPATH = 
        " //foreword | //introduction | //sections/terms | "\
        "//sections/clause | ./references | ./annex".freeze

      def sections_sequence_validate(root)
        f = root.xpath(SECTIONS_XPATH)
        names = f.map { |s| { tag: s.name, title: s.at("./title").text } }
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val]) or return
        n = names[0]
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val]) or return
        if n == { tag: "introduction", title: "Introduction" }
          names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val]) or return
        end
        names = seqcheck(names, SEQ[3][:msg], SEQ[3][:val]) or return
        n = names.shift
        if n == { tag: "clause", title: "Symbols and Abbreviations" }
          n = names.shift or return
        end
        unless n
          warn "ISO style: Document must contain at least one clause"
          return
        end
        n[:tag] == "clause" or
          warn "ISO style: Document must contain at least one clause"
        n == { tag: "clause", title: "Scope" } and
          warn "ISO style: Scope must occur before Terms and Definitions"
        n = names.shift or return
        while n[:tag] == "clause"
          n[:title] == "Scope" and
            warn "ISO style: Scope must occur before Terms and Definitions"
          n[:title] == "Symbols and Abbreviations" and
            warn "ISO style: Symbols and Abbreviations must occur "\
            "right after Terms and Definitions"
          n = names.shift or return
        end
        unless n[:tag] == "annex" or n[:tag] == "references"
          warn "ISO style: Only annexes and references can follow clauses"
        end
        while n[:tag] == "annex"
          n = names.shift or return
        end
        n == { tag: "references", title: "Normative References" } or
          warn "ISO style: Document must include (references) "\
          "Normative References"
        n = names.shift
        n == { tag: "references", title: "Bibliography" } or
          warn "ISO style: Final section must be (references) Bibliography"
        names.empty? or
          warn "ISO style: There are sections after the final Bibliography"
      end
    end
  end
end
