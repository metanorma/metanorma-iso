# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Converts MN `<dl>`/`<dt>`/`<dd>` to STS `<def-list>`/`<def-item>`.
        # Follows mnconvert's shape: each dt/dd pair becomes a def-item with
        # term + def children, and the whole dd body (paragraphs, lists,
        # notes, examples, preformats) merges into the def's SINGLE <p> as
        # mixed content — the NISO STS def model wants one paragraph that
        # carries the run-in blocks (e.g. "The main document number of the
        # standard.<non-normative-example>…</non-normative-example>").
        class DlTransformer < Base
          def transform(source_dl)
            def_items = pair_dt_dd(source_dl)
            ModelBuilder.def_list(id: source_dl.id, def_items: def_items)
          end

          private

          def pair_dt_dd(source_dl)
            dts = Array(source_dl.dt)
            dds = Array(source_dl.dd)
            dts.each_with_index.map do |dt, i|
              build_def_item(dt, dds[i])
            end
          end

          def build_def_item(dt, dd)
            attrs = {}
            attrs[:id] = dt.id if dt.id

            term = build_term(dt)
            attrs[:term] = term if term

            defn = dd ? build_def(dd) : nil

            attrs[:defn] = defn if defn
            ModelBuilder.def_item(**attrs)
          end

          # NISO STS <term> is mixed content: the dt's inline children
          # (strong, em, tt, sub/sup, xref) transform INTO the term
          # through the guarded inline dispatch. The #122 crash fired
          # exactly here — the 3.5.21 engine dispatched the dt's walk
          # onto Sts::NisoSts::Term on a floating sts floor whose Term
          # declared no monospace slot. The guarded dispatch renders
          # what the target declares and keeps the rest as text.
          def build_term(dt)
            term_text = RenderedTextExtractor.text_of(dt)
            return nil if term_text.nil? || term_text.empty?

            entries = paragraph_transformer.entries_for(dt)
            ::Sts::NisoSts::Term.new do |term|
              if entries.empty?
                # The walk and the text extraction disagree at the
                # edges: the extracted text is the floor, so an
                # empty <term/> never ships.
                term.text term_text
              else
                inline_transformer.apply_inline_entries(entries, term)
              end
            end
          end

          # One <p> per def: the dd's paragraphs contribute their inline
          # entries (text runs merged across the paragraph boundary), and
          # the block siblings (lists, notes, examples, preformats) nest
          # inside the same p at their document position. The merged p
          # takes the first source paragraph's id.
          def build_def(dd)
            ModelBuilder.def(paragraph: [build_merged_paragraph(dd)])
          end

          def build_merged_paragraph(dd)
            paragraphs = Array(dd.p)
            first_id = paragraphs.first&.id

            ::Sts::NisoSts::Paragraph.new(id: first_id) do |p|
              paragraphs.each do |para|
                paragraph_transformer.entries_for(para).each do |kind, value|
                  append_inline(p, kind, value)
                end
              end

              Array(dd.ul).each { |ul| p.list list_transformer.transform(ul) }
              Array(dd.ol).each { |ol| p.list list_transformer.transform(ol) }
              Array(dd.example).each do |ex|
                example = note_transformer.transform(ex)
                p.non_normative_example example if example
              end
              Array(dd.note).each do |nt|
                note = note_transformer.transform(nt)
                p.non_normative_note note if note
              end
              Array(dd.sourcecode).each do |sc|
                pre = note_transformer.transform_preformat(sc)
                p.preformat pre if pre
              end
            end
          end

          # Consecutive text entries merge into the last string so the
          # built (never-parsed) mixed-content model serializes every
          # run — lutaml-model#1164 drops consecutive map_content text
          # entries beyond the first.
          def append_inline(target, kind, value)
            case kind
            when :text
              existing = target.text
              if existing.is_a?(Array) && existing.last.is_a?(String)
                existing[-1] = existing.last + value
              else
                target.text value
              end
            when :bold then target.bold value
            when :italic then target.italic value
            when :sub then target.sub value
            when :sup then target.sup value
            when :monospace then target.monospace value
            when :inline_formula then target.inline_formula value
            when :xref then target.xref value
            when :ext_link then target.ext_link value
            when :fn then target.fn value
            end
          end
        end
      end
    end
  end
end
