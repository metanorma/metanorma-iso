require "asciidoctor/iso/utils"
require "nokogiri"
require "jing"

module Asciidoctor
  module ISO
    module Validate
      class << self
        def title_validate(root)
          if root.at("//title/en/title_intro").nil? &&
              !root.at("//title/fr/title_intro").nil?
            warn "No English Title Intro!"
          end
          if !root.at("//title/en/title_intro").nil? &&
              root.at("//title/fr/title_intro").nil?
            warn "No French Title Intro!"
          end
          if root.at("//title/en/title_part").nil? &&
              !root.at("//title/fr/title_part").nil?
            warn "No English Title Part!"
          end
          if !root.at("//title/en/title_part").nil? &&
              root.at("//title/fr/title_part").nil?
            warn "No French Title Part!"
          end
          if root.at("//title/en/title_main") =~ /International\sStandard |
            Technical\sSpecification | Publicly\sAvailable\sSpecification |
            Technical\sReport | Guide /xi
            warn "Main Title may name document type"
          end
          if root.at("//title/en/title_main") =~ /International\sStandard |
            Technical\sSpecification | Publicly\sAvailable\sSpecification |
            Technical\sReport | Guide /xi
            warn "Part Title may name document type"
          end
        end

        def onlychild_clause_validate(root)
          root.
            xpath("//clause/clause | //annex/clause | //scope/clause").
            each do |c|
            clauses = c.xpath("../clause")
            if clauses.size == 1
              title = c.at("./title")
              location = if c["anchor"].nil? && title.nil?
                           c.text[0..60] + "..."
                         elsif title.nil?
                           c["anchor"] 
                         else 
                           c["anchor"] + ":#{title.text}"
                         end
              warn "ISO style: #{location}: subclause is only child"
            end
          end
        end

        def validate(doc)
          title_validate(doc.root)
          onlychild_clause_validate(doc.root)
          filename = File.join(File.dirname(__FILE__), "validate.rng")
          schema = Jing.new(filename)
          File.open(".tmp.xml", "w") { |f| f.write(doc.to_xml) }
          begin
            errors = schema.validate(".tmp.xml")
          rescue Jing::Error => e
            abort "what what what #{e}"
          end
          if errors.none?
            puts "Valid!"
          else
            errors.each do |error|
              puts "#{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end
        end

        def requirement(text)
          text.split(/\.\s+/).each do |t|
            matched = /\b(?<w>
                          ( shall | (is|are)\sto |
                           (is|are)\srequired\s(not\s)?to |
                           has\sto |
                           only\b[^.,]+\b(is|are)\spermitted |
                           it\s\is\snecessary |
                           (needs|need)\sto |
                           (is|are)\snot\s(allowed | permitted | acceptable | permissible) |
                           (is|are)\snot\sto\sbe |
                           (need|needs)\snot |
                           do\snot )
                         )\b/ix.match t
                         return t unless matched.nil?
          end
          nil
        end

        def recommendation(text)
          text.split(/\.\s+/).each do |t|
            matched = /\b(?<w>should |
                          ought\s(not\s)?to |
                          it\sis\s(not\s)?recommended\sthat 
                         )\b/xi.match t
                         return t unless matched.nil?
          end
          nil
        end

        def permission(text)
          text.split(/\.\s+/).each do |t|
            matched = /\b(?<w>may |
                          (is|are)\s(permitted | allowed | permissible ) |
                          it\sis\snot\srequired\sthat |
                          no\b[^.,]+\b(is|are)\srequired
                         )\b/xi.match t
                         return t unless matched.nil?
          end
          nil
        end

        def posssibility(text)
          text.split(/\.\s+/).each do |t|
            matched = /\b(?<w>can | cannot |
                          be\sable\sto |
                          there\sis\sa\spossibility\sof |
                          it\sis\spossible\to |
                          be\sunable\sto |
                          there\sis\sno\spossibility\sof |
                          it\sis\snot\spossible\sto
                         )\b/xi.match t
                         return t unless matched.nil?
          end
          nil
        end

        def external_constraint(text)
          text.split(/\.\s+/).each do |t|
            sentences.each do |t|
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
            warntext = "ISO style: WARNING (#{Utils::current_location(node)}): #{msg}"
            warntext += ": #{text}" if text
            warn warntext
          end

          def style(node, text)
            matched = /\b(?<number>[0-9]+\.[0-9]+)\b/.match text
            style_warning(node, "possible decimal point", matched[:number]) unless matched.nil?
            matched = /(?<!(ISO|IEC) )\b(?<number>[0-9][0-9][0-9][0-9]+)\b/.match text
            style_warning(node, "number not broken up in threes", matched[:number]) unless matched.nil?
            matched = /\b(?<number>[0-9.,]+%)/.match text
            style_warning(node, "no space before percent sign", matched[:number]) unless matched.nil?
            matched = /\b(?<number>[0-9.,]+ \u00b1 [0-9,.]+ %)/.match text
            style_warning(node, "unbracketed tolerance before percent sign", matched[:number]) unless matched.nil?
          end
        end
      end
    end
  end
