require "asciidoctor/iso/isoxml/utils"
require "nokogiri"
require "jing"
require "pp"

module Asciidoctor
  module ISO
    module ISOXML
      module Validate
        class << self

          def title_intro_validate(root)
            title_intro_en = root.at("//title[@language='en']/title-intro")
            title_intro_fr = root.at("//title[@language='fr']/title-intro")
            if title_intro_en.nil? && !title_intro_fr.nil?
              warn "No English Title Intro!"
            end
            if !title_intro_en.nil? && title_intro_fr.nil?
              warn "No French Title Intro!"
            end
          end

          def title_part_validate(root)
            title_part_en = root.at("//title[@language='en']/title-part")
            title_part_fr = root.at("//title[@language='fr']/title-part")
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
            title_main_en = root.at("//title[@language='en']/title-main")
            if doctypes.match? title_main_en.text
              warn "Main Title may name document type"
            end
            title_intro_en = root.at("//title[@language='en']/title-intro")
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
              location = if c["id"].nil? && title.nil?
                           c.text[0..60] + "..."
                         else
                           c["id"]
                         end
              location += ":#{title.text}" unless title.nil?
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
          @@seq = [
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
            names = seqcheck(names, @@seq[0][:msg], @@seq[0][:val]) or return
            n = names[0]
            names = seqcheck(names, @@seq[1][:msg], @@seq[1][:val]) or return
            if n == { tag: "content", title: "Introduction" }
              names = seqcheck(names, @@seq[2][:msg], @@seq[2][:val]) or return
            end
            names = seqcheck(names, @@seq[3][:msg], @@seq[3][:val]) or return
            names = seqcheck(names, @@seq[4][:msg], @@seq[4][:val]) or return
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

          def schema_validate(doc)
            filename = File.join(File.dirname(__FILE__), "validate.rng")
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
            schema_validate(doc)
          end

          @@requirement_re_str = <<~REGEXP
            \\b
             ( shall | (is|are)_to |
                   (is|are)_required_(not_)?to |
                   has_to |
                   only\\b[^.,]+\\b(is|are)_permitted |
                   it_is_necessary |
                   (needs|need)_to |
                   (is|are)_not_(allowed | permitted |
                                   acceptable | permissible) |
                   (is|are)_not_to_be |
                   (need|needs)_not |
                   do_not )
                \\b
          REGEXP
          @@requirement_re =
            Regexp.new(@@requirement_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def requirement(text)
            text.split(/\.\s+/).each do |t|
              return t if @@requirement_re.match? t
            end
            nil
          end

          @@recommendation_re_str = <<~REGEXP
            \\b
                should |
                ought_(not_)?to |
                it_is_(not_)?recommended_that
            \\b
          REGEXP
          @@recommendation_re =
            Regexp.new(@@recommendation_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def recommendation(text)
            text.split(/\.\s+/).each do |t|
              return t if @@recommendation_re.match? t
            end
            nil
          end

          @@permission_re_str = <<~REGEXP
            \\b
                 may |
                (is|are)_(permitted | allowed | permissible ) |
                it_is_not_required_that |
                no\\b[^.,]+\\b(is|are)_required
            \\b
          REGEXP
          @@permission_re =
            Regexp.new(@@permission_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def permission(text)
            text.split(/\.\s+/).each do |t|
              return t if @@permission_re.match? t
            end
            nil
          end

          @@possibility_re_str = <<~REGEXP
            \\b
               can | cannot | be_able_to |
               there_is_a_possibility_of |
               it_is_possible_to | be_unable_to |
               there_is_no_possibility_of |
               it_is_not_possible_to
            \\b
          REGEXP
          @@possibility_re =
            Regexp.new(@@possibility_re_str.gsub(/\s/, "").gsub(/_/, "\\s"),
                       Regexp::IGNORECASE)

          def posssibility(text)
            text.split(/\.\s+/).each do |t|
              return t if @@possibility_re.match? t
            end
            nil
          end

          def external_constraint(text)
            text.split(/\.\s+/).each do |t|
              return t if /\b(must)\b/xi.match? t
            end
            nil
          end

          def style_no_guidance(node, text, docpart)
            r = requirement(text)
            style_warning(node, "#{docpart} may contain requirement", r) if r
            r = permission(text)
            style_warning(node, "#{docpart} may contain permission", r) if r
            r = recommendation(text)
            style_warning(node, "#{docpart} may contain recommendation", r) if r
          end

          def foreword_style(node, text)
            style_no_guidance(node, text, "Foreword")
          end

          def scope_style(node, text)
            style_no_guidance(node, text, "Scope")
          end

          def introduction_style(node, text)
            r = requirement(text)
            style_warning(node, "Introduction may contain requirement", r) if r
          end

          def termexample_style(node, text)
            style_no_guidance(node, text, "Term Example")
            style(node, text)
          end

          def note_style(node, text)
            style_no_guidance(node, text, "Note")
            style(node, text)
          end

          def footnote_style(node, text)
            style_no_guidance(node, text, "Footnote")
            style(node, text)
          end

          def style_warning(node, msg, text)
            w = "ISO style: WARNING (#{Utils::current_location(node)}): #{msg}"
            w += ": #{text}" if text
            warn w
          end

          # style check with a single regex
          def style_single_regex(n, text, re, warning)
            m = re.match(text) and style_warning(n, warning, m[:num])
          end

          # style check with a regex on a token
          # and a negative match on its preceding token
          def style_two_regex_not_prev(n, text, re, re_prev, warning)
            return if text.nil?
            words = text.split(/\W+/).each_index do |i|
              next if i == 0
              m = re.match text[i]
              m_prev = re_prev.match text[i - 1]
              if !m.nil? && m_prev.nil?
                style_warning(n, warning, m[:num])
              end
            end
          end

          def style(n, text)
            style_single_regex(n, text, /\b(?<num>[0-9]+\.[0-9]+)\b/,
                               "possible decimal point")
            style_two_regex_not_prev(n, text, /^(?<num>[0-9]{4,})$/,
                                     %r{(\bISO|\bIEC|\bIEEE|/)$},
                                     "number not broken up in threes")
            style_single_regex(n, text, /\b(?<num>[0-9.,]+%)/,
                               "no space before percent sign")
            style_single_regex(n, text, /\b(?<num>[0-9.,]+ \u00b1 [0-9,.]+ %)/,
                               "unbracketed tolerance before percent sign")
          end
        end
      end
    end
  end
end
