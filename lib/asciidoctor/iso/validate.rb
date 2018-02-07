require "asciidoctor/iso/utils"
require_relative "./validate_style.rb"
require "nokogiri"
require "jing"
require "pp"

module Asciidoctor
  module ISO
    module Validate
      def title_intro_validate(root)
        title_intro_en = root.at("//title-intro[@language='en']")
        title_intro_fr = root.at("//title-intro[@language='fr']")
        if title_intro_en.nil? && !title_intro_fr.nil?
          warn "No English Title Intro!"
        end
        if !title_intro_en.nil? && title_intro_fr.nil?
          warn "No French Title Intro!"
        end
      end

      def title_part_validate(root)
        title_part_en = root.at("//title-part[@language='en']")
        title_part_fr = root.at("//title-part[@language='fr']")
        if title_part_en.nil? && !title_part_fr.nil?
          warn "No English Title Part!"
        end
        if !title_part_en.nil? && title_part_fr.nil?
          warn "No French Title Part!"
        end
      end

      def title_names_type_validate(root)
        doctypes = /International\sStandard | Technical\sSpecification |
        Publicly\sAvailable\sSpecification | Technical\sReport | Guide /xi
        title_main_en = root.at("//title-main[@language='en']")
        if doctypes.match? title_main_en.text
          warn "Main Title may name document type"
        end
        title_intro_en = root.at("//title-intro[@language='en']")
        if !title_intro_en.nil? && doctypes.match?(title_intro_en.text)
          warn "Part Title may name document type"
        end
      end

      def title_validate(root)
        title_intro_validate(root)
        title_part_validate(root)
        title_names_type_validate(root)
      end

      def onlychild_clause_validate(root)
        q = "//subsection"
        root.xpath(q).each do |c|
          next unless c.xpath("../subsection").size == 1
          title = c.at("./title")
          location = c["id"] || c.text[0..60] + "..."
          location += ":#{title.text}" if c["id"] && !title.nil?
          warn "ISO style: #{location}: subsection is only child"
        end
      end

      def foreword_validate(root)
        f = root.at("//content[title = 'Foreword']")
        s = f.at("./subsection")
        warn "ISO style: foreword contains subsections" unless s.nil?
      end

      def normref_validate(root)
        f = root.at("//references[title = 'Normative References']")
        f.at("./references") and
          warn "ISO style: normative references contains subsections"
      end

      def symbols_validate(root)
        f = root.at("//clause[title = 'Symbols and Abbreviations']")
        return if f.nil?
        f.elements do |e|
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
          val:  [{ tag: "content", title: "Foreword" }],
        },
        {
          msg: "Prefatory material must be followed by (clause) Scope",
          val:  [{ tag: "content", title: "Introduction" },
                 { tag: "clause", title: "Scope" }],
        },
        {
          msg: "Prefatory material must be followed by (clause) Scope",
          val: [{ tag: "clause", title: "Scope" }],
        },
        {
          msg: "Scope must be followed by Normative References",
          val: [{ tag: "references", title: "Normative References" }]
        },
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

      def sections_sequence_validate(root)
        f = root.xpath(" //sections/content | //sections/terms | "\
                       "//sections/clause | //sections/references | "\
                       "//sections/annex")
        names = f.map { |s| { tag: s.name, title: s.at("./title").text } }
        names = seqcheck(names, SEQ[0][:msg], SEQ[0][:val]) or return
        n = names[0]
        names = seqcheck(names, SEQ[1][:msg], SEQ[1][:val]) or return
        if n == { tag: "content", title: "Introduction" }
          names = seqcheck(names, SEQ[2][:msg], SEQ[2][:val]) or return
        end
        names = seqcheck(names, SEQ[3][:msg], SEQ[3][:val]) or return
        names = seqcheck(names, SEQ[4][:msg], SEQ[4][:val]) or return
        n = names.shift
        if n == { tag: "clause", title: "Symbols and Abbreviations" }
          n = names.shift or return
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
        n == { tag: "references", title: "Bibliography" } or
          warn "ISO style: Final section must be (references) Bibliography"
        names.empty? or
          warn "ISO style: There are sections after the final Bibliography"
      end

      def iso8601_validate(root)
        root.xpath("//review/@date | //revision-date").each do |d|
          /^\d{8}(T\d{4,6})?$/.match? d.text or
            warn "ISO style: #{d.text} is not an ISO 8601 date"
        end
      end

      def content_validate(doc)
        title_validate(doc.root)
        foreword_validate(doc.root)
        normref_validate(doc.root)
        symbols_validate(doc.root)
        iso8601_validate(doc.root)
        onlychild_clause_validate(doc.root)
        sections_sequence_validate(doc.root)
      end

      def schema_validate(doc, filename)
        File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
        begin
          errors = Jing.new(filename).validate(".tmp.xml")
        rescue Jing::Error => e
          abort "what what what #{e}"
        end
        warn "Valid!" if errors.none?
        errors.each do |error|
          warn "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
        end
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(doc, File.join(File.dirname(__FILE__),
                                       "isostandard.rng"))
      end
    end
  end
end
