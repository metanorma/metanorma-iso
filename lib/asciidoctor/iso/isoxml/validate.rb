require "asciidoctor/iso/isoxml/utils"
require "nokogiri"
require "jing"

module Asciidoctor
  module ISO
    module ISOXML
      module Validate
        class << self

=begin
TODO
New validations:
symbols_abbrevs: can only be a dl
sequence of new sections
=end

          def title_intro_validate(root)
            title_intro_en = root.at("//title[@language='en']/title_intro")
            title_intro_fr = root.at("//title[@language='fr']/title_intro")
            if title_intro_en.nil? && !title_intro_fr.nil?
              warn "No English Title Intro!"
            end
            if !title_intro_en.nil? && title_intro_fr.nil?
              warn "No French Title Intro!"
            end
          end

          def title_part_validate(root)
            title_part_en = root.at("//title[@language='en']/title_part")
            title_part_fr = root.at("//title[@language='fr']/title_part")
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
            title_main_en = root.at("//title[@language='en']/title_main")
            if doctypes.match? title_main_en.text
              warn "Main Title may name document type"
            end
            title_intro_en = root.at("//title[@language='en']/title_intro")
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
              location = if c["anchor"].nil? && title.nil?
                           c.text[0..60] + "..."
                         else
                           c["anchor"]
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
            s = f.at("./references")
            unless s.nil?
              warn "ISO style: normative references contains subsections"
            end
          end

          def sections_sequence_validate(root)
            f = root.xpath(" //sections/content | //sections/terms | "\
                           "//sections/clause | //sections/references | "\
                           "//sections/annex")
            names = f.map { |s| { tag: s.name, title: s.at("./title").text } }
            n = names.shift
            unless n == { tag: "content", title: "Foreword" }
              warn "ISO style: Initial section must be (content) Foreword"
              return
            end
            return if names.empty?
            n = names.shift
            unless n == { tag: "content", title: "Introduction" } or
                n == { tag: "clause", title: "Scope" }
              warn "ISO style: Foreword must be followed by "\
                "(content) Introduction or (clause) Scope"
              return
            end
            return if names.empty?
            n = names.shift if n == { tag: "content", title: "Introduction" }
            unless n == { tag: "clause", title: "Scope" }
              warn "ISO style: Prefatory material must be followed by "\
                "(clause) Scope"
              return
            end
            return if names.empty?
            n == name.shift
            unless n == { tag: "references", title: "Normative References" }
              warn "ISO style: Scope must be followed by Normative References"
              return
            end
            return if names.empty?
            n == name.shift
            unless n == { tag: "terms", title: "Terms and Definitions" } or
                n == { tag: "terms", title: "Terms, Definitions, Symbols and Abbreviations" }
              warn "ISO style: Normative References must be followed by "\
                "Terms and Definitions"
              return
            end
            return if names.empty?
            n == name.shift
            if n == { tag: "clause", title: "Symbols and Abbreviations" }
              n == name.shift
            return if names.empty?
            end
            unless n[:tag] == "clause"
              warn "ISO style: Document must contain at least one clause"A
            end
            if n == { tag: "clause", title: "Scope" }
              warn "ISO style: Scope must occur before Terms and Definitions"
            end
            while n[:tag] == "clause"
            end
          end

          def content_validate(doc)
            title_validate(doc.root)
            foreword_validate(doc.root)
            normref_validate(doc.root)
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
            Regexp.new(@@requirement_re_str.gsub(/\s/,"").gsub(/_/, "\\s"), 
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
            Regexp.new(@@recommendation_re_str.gsub(/\s/,"").gsub(/_/, "\\s"), 
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
            Regexp.new(@@permission_re_str.gsub(/\s/,"").gsub(/_/, "\\s"), 
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
            Regexp.new(@@possibility_re_str.gsub(/\s/,"").gsub(/_/, "\\s"), 
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
            style_no_guidance(node, text, "Foonote")
            style(node, text)
          end

          def style_warning(node, msg, text)
            w = "ISO style: WARNING (#{Utils::current_location(node)}): #{msg}"
            w += ": #{text}" if text
            warn w
          end

          # style check with a single regex
          def style_single_regex(n, text, re, warning)
            m = re.match text
            unless m.nil?
              style_warning(n, warning, m[:num])
            end
          end

          # style check with a regex on a token
          # and a negative match on its preceding token
          def style_two_regex_not_prev(n, text, re, re_prev, warning)
            return if text.nil?
            words = text.split(/\W+/).each_index do |i|
              next if i == 0
              m = re.match text[i]
              m_prev = re_prev.match text[i-1]
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
