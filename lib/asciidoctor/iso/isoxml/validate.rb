require "asciidoctor/iso/isoxml/utils"
require "nokogiri"
require "jing"

module Asciidoctor
  module ISO
    module ISOXML
      module Validate
        class << self
          def title_intro_validate(root)
            #title_intro_en = root.at("//title/en/title_intro")
            #title_intro_fr = root.at("//title/fr/title_intro")
            title_intro_en = root.at("//title_info[@language='en']/title_intro")
            title_intro_fr = root.at("//title_info[@language='fr']/title_intro")
            if title_intro_en.nil? && !title_intro_fr.nil?
              warn "No English Title Intro!"
            end
            if !title_intro_en.nil? && title_intro_fr.nil?
              warn "No French Title Intro!"
            end
          end

          def title_part_validate(root)
            title_part_en = root.at("//title_info[@language='en']/title_part")
            title_part_fr = root.at("//title_info[@language='fr']/title_part")
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
            title_main_en = root.at("//title_info[@language='en']/title_main")
            if doctypes.match? title_main_en.text
              warn "Main Title may name document type"
            end
            title_intro_en = root.at("//title_info[@language='en']/title_intro")
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
            q = "//clause/clause | //annex/clause | //scope/clause"
            root.xpath(q).each do |c|
              next unless c.xpath("../clause").size == 1
              title = c.at("./title")
              location = if c["anchor"].nil? && title.nil?
                           c.text[0..60] + "..."
                         else
                           c["anchor"]
                         end
              location += ":#{title.text}" unless title.nil?
              warn "ISO style: #{location}: subclause is only child"
            end
          end

          def validate(doc)
            title_validate(doc.root)
            onlychild_clause_validate(doc.root)
            filename = File.join(File.dirname(__FILE__), "validate.rng")
            File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
            begin
              errors = Jing.new(filename).validate(".tmp.xml")
            rescue Jing::Error => e
              abort "what what what #{e}"
            end
            puts "Valid!" if errors.none?
            errors.each do |error|
              puts "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end

          @@requirement_re =
            Regexp.new(<<~"REGEXP", Regexp::EXTENDED | Regexp::IGNORECASE)
              \b(?<w>
                            ( shall | (is|are)\sto |
                             (is|are)\srequired\s(not\s)?to |
                             has\sto |
                             only\b[^.,]+\b(is|are)\spermitted |
                             it\s\is\snecessary |
                             (needs|need)\sto |
                             (is|are)\snot\s(allowed | permitted |
                                             acceptable | permissible) |
                                             (is|are)\snot\sto\sbe |
                                             (need|needs)\snot |
                                             do\snot )
                           )\b
          REGEXP

          def requirement(text)
            text.split(/\.\s+/).each do |t|
              matched = @@requirement_re.match t
              return t unless matched.nil?
            end
            nil
          end

          @@recommendation_re =
            Regexp.new(<<~"REGEXP", Regexp::EXTENDED | Regexp::IGNORECASE)
              \b(?<w>should |
              ought\s(not\s)?to |
              it\sis\s(not\s)?recommended\sthat
              )\b
          REGEXP

          def recommendation(text)
            text.split(/\.\s+/).each do |t|
              matched = @@recommendation_re.match t
              return t unless matched.nil?
            end
            nil
          end

          @@permission_re =            
            Regexp.new(<<~"REGEXP", Regexp::EXTENDED | Regexp::IGNORECASE)
              \b(?<w>may |
              (is|are)\s(permitted | allowed | permissible ) |
              it\sis\snot\srequired\sthat |
              no\b[^.,]+\b(is|are)\srequired
             )\b
          REGEXP

          def permission(text)
            text.split(/\.\s+/).each do |t|
              matched = @@permission_re.match t
              return t unless matched.nil?
            end
            nil
          end

          @@possibility_re =
            Regexp.new(<<~"REGEXP", Regexp::EXTENDED | Regexp::IGNORECASE)
            \b(?<w>can | cannot | be\sable\sto |
                  there\sis\sa\spossibility\sof |
                  it\sis\spossible\to | be\sunable\sto |
                  there\sis\sno\spossibility\sof |
                  it\sis\snot\spossible\sto)\b
          REGEXP

          def posssibility(text)
            text.split(/\.\s+/).each do |t|
              matched = @@possibility_re.match t
              return t unless matched.nil?
            end
            nil
          end

          def external_constraint(text)
            text.split(/\.\s+/).each do |t|
              matched = /\b(?<w>must)\b/xi.match t
              return t unless matched.nil?
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
