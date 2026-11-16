# frozen_string: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class TermTransformer < Base
          def transform(source_term)
            content = []

            term_number = extract_term_number(source_term)
            add_preferred_name(content, source_term)
            add_definition(content, source_term)
            add_standalone_paragraphs(content, source_term)
            add_lists(content, source_term)
            add_term_notes(content, source_term)
            add_term_examples(content, source_term)
            add_sources(content, source_term)

            attrs = {}
            attrs[:id] = source_term.id if source_term.id
            # The term number ("3.1") becomes the section's <title>,
            # which the renderer emits as a TermNum heading matching
            # MN's "<h3 class='TermNum'>3.5.12</h3>" layout. Previously
            # it was emitted as a leading <p>, which the parity check
            # did not see as a heading.
            attrs[:title] = ::Sts::NisoSts::Title.new(content: [term_number]) if term_number
            paragraphs, lists, notes = partition_content(content)
            attrs[:paragraphs] = paragraphs if paragraphs.any?
            attrs[:list] = lists if lists.any?
            attrs[:non_normative_note] = notes if notes.any?

            nested = Array(source_term.term).map { |sub| transform(sub) }
            attrs[:sec] = nested if nested.any?

            ::Sts::NisoSts::Section.new(attrs)
          end

          def partition_content(content)
            paragraphs = content.grep(::Sts::NisoSts::Paragraph)
            lists = content.grep(::Sts::NisoSts::List)
            notes = content.grep(::Sts::NisoSts::NonNormativeNote)
            others = content.reject do |c|
              [::Sts::NisoSts::Paragraph, ::Sts::NisoSts::List,
               ::Sts::NisoSts::NonNormativeNote].any? { |k| c.is_a?(k) }
            end
            [paragraphs + others, lists, notes]
          end

          private

          # The term number ("3.1") from the term's fmt-name caption label.
          def extract_term_number(source_term)
            section_transformer.extract_autonum(source_term)
          end

          def add_preferred_name(content, source_term)
            para = preferred_name_paragraph(source_term)
            content << para if para
          end

          # Preferred names often contain math (e.g. "maximum capacity
          # (E_max)"). The typed TermNameElement drops stems, so we prefer
          # the rendered fmt_preferred tree and route it through the
          # paragraph transformer so MathML passes through verbatim.
          # Falls back to text-only paragraph when no rendered tree exists.
          def preferred_name_paragraph(source_term)
            fmt = Array(source_term.fmt_preferred).first if source_term.class.method_defined?(:fmt_preferred)
            if fmt && fmt.class.method_defined?(:p)
              p = Array(fmt.p).first
              return paragraph_transformer.transform(p) if p
            end

            text = preferred_name_text(source_term)
            return nil if text.nil? || text.empty?

            ::Sts::NisoSts::Paragraph.new(text: [text])
          end

          def preferred_name_text(source_term)
            preferred = Array(source_term.preferred).first
            return nil unless preferred

            expression = preferred.expression
            return RenderedTextExtractor.text_of(preferred) unless expression

            names = Array(expression.name)
            return RenderedTextExtractor.text_of(preferred) if names.empty?

            RenderedTextExtractor.text_of(names.first)
          end

          def add_definition(content, source_term)
            definition = Array(source_term.definition).first
            return unless definition

            vd = definition.verbal_definition
            return unless vd

            Array(vd.p).each { |p| content << paragraph_transformer.transform(p) }
          end

          def add_standalone_paragraphs(content, source_term)
            Array(source_term.p).each { |p| content << paragraph_transformer.transform(p) }
          end

          def add_lists(content, source_term)
            definition = Array(source_term.definition).first
            return unless definition

            vd = definition.verbal_definition
            return unless vd

            Array(vd.ul).each { |ul| content << list_transformer.transform(ul) }
            Array(vd.ol).each { |ol| content << list_transformer.transform(ol) }
          end

          def add_list_items(content, list)
            Array(list.listitem).each do |li|
              Array(li.paragraphs).each { |p| content << paragraph_transformer.transform(p) }
            end
          end

          # Term notes become <non-normative-note> carrying their own
          # label ("Note 1 to entry:") — plain "Note" notes leave the
          # kind label to the renderer. Nested <ul>/<ol> inside the
          # termnote become sibling <list> children of the note so the
          # renderer emits them after the paragraphs.
          def add_term_notes(content, source_term)
            Array(source_term.termnote).each do |tn|
              paragraphs = Array(tn.p).map { |p| paragraph_transformer.transform(p) }
              lists = Array(tn.ul).map { |ul| list_transformer.transform(ul) } +
                      Array(tn.ol).map { |ol| list_transformer.transform(ol) }
              next if paragraphs.empty? && lists.empty?

              attrs = { p: paragraphs }
              attrs[:list] = lists if lists.any?
              label = term_note_label(tn)
              attrs[:label] = ::Sts::NisoSts::Label.new(content: [label]) if label
              content << ::Sts::NisoSts::NonNormativeNote.new(attrs)
            end
          end

          # MN renders term notes "<span class='term-note-label'>
          # Term notes become <non-normative-note> with a "Note:" label
          # — matching MN's "<span class='termnote_label'>Note: </span>"
          # prefix inside the note paragraph. The entity's autonum
          # ("Note 1 to entry:") isn't surfaced in MN's term notes, so
          # we mirror that here.
          def term_note_label(_note_obj)
            "Note:"
          end

          def add_term_examples(content, source_term)
            Array(source_term.termexample).each { |te| add_typed_note_paragraphs(content, te, "Example", colon: true) }
          end

          def add_typed_note_paragraphs(content, note_obj, label, colon: false)
            suffix = colon ? ": " : "  "
            Array(note_obj.p).each_with_index do |p, i|
              para = paragraph_transformer.transform(p)
              if i.zero?
                existing = para.content.to_a
                para.content = ["#{label}#{suffix}#{existing.first || ''}"] + existing[1..]
              end
              content << para
            end
            Array(note_obj.ul).each { |ul| content << list_transformer.transform(ul) }
            Array(note_obj.ol).each { |ol| content << list_transformer.transform(ol) }
          end

          def build_list(list, list_type)
            list_transformer.transform_with_type(list, list_type)
          end

          def add_sources(content, source_term)
            Array(source_term.source).each { |s| content << build_source(s) }
          end

          def build_source(source)
            origin = source.origin
            return nil unless origin

            citeas = origin.citeas
            locality = extract_locality(origin)
            ordinal = bib_ordinal(origin)

            text = "[SOURCE: #{citeas}"
            if locality
              text << ", #{locality}"
              text << "[#{ordinal}]" if ordinal
              text << " "
            end
            text << "]"
            ::Sts::NisoSts::Paragraph.new(text: [text])
          end

          def extract_locality(origin)
            ls_arr = origin.locality_stack
            return nil unless ls_arr.is_a?(Array) && ls_arr.any?

            parts = []
            ls_arr.each do |ls|
              Array(ls.bib_locality).each do |loc|
                from = loc.reference_from
                val = case from
                      when String then from
                      when nil then ""
                      else
                        cv = from.content rescue nil
                        cv ? Array(cv).first.to_s : from.to_s
                      end
                parts << val if val && !val.empty?
              end
            end
            parts.empty? ? nil : parts.join(", ")
          end

          def bib_ordinal(origin)
            bibitemid = origin.bibitemid
            return nil unless bibitemid

            bib = context.source.typed_root.bibliography
            return nil unless bib

            items = Array(bib.references).flat_map { |rs| Array(rs.references) }
            items.each_with_index do |item, i|
              return (i + 1).to_s if item.id == bibitemid || item.anchor == bibitemid
            end
            nil
          end
        end
      end
    end
  end
end
