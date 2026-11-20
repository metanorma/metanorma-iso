# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # ISO table footnotes: an <fn reference="a"> inside a table gets a
        # superscript letter in place, and its body goes into one
        # full-width row at the foot of the table, not into the page
        # footnotes. Repeated references share one body.
        module TableFootnotes
          private

          def collecting_table_footnotes(&)
            footnotes = {}
            handler = ->(note, para) { collect_table_footnote(note, para, footnotes) }
            @context.with_formula_key_footnotes(handler, &)
            footnotes
          end

          def collect_table_footnote(note, para, footnotes)
            label = note.reference

            append_footnote_label(para, label) unless note.hiddenref
            body = Array(@context.formula_footnote_bodies).find { |entry| entry.id == note.target }
            paragraphs = body ? Array(body.semx&.p) : Array(note.p)
            footnotes[footnote_key(note, label, paragraphs)] ||= [label, paragraphs] unless paragraphs.empty?
          end

          # A repeated reference carries the same target; without one, the
          # same label and content (markup too: a textless link differs only
          # by its target).
          def footnote_key(note, label, paragraphs)
            note.target || [label, paragraphs.map(&:to_xml)]
          end

          def append_footnote_label(para, label)
            properties = Uniword::Wordprocessingml::RunProperties.new(
              vertical_align: Uniword::Properties::VerticalAlign.new(value: "superscript"),
            )
            para << Uniword::Wordprocessingml::Run.new(text: label, properties: properties)
          end

          def append_table_footnotes(table, footnotes, columns:, style_key:)
            table.row do |row|
              row.cell do |cell|
                cell.column_span(columns)
                footnotes.each_value do |label, paragraphs|
                  append_table_footnote(cell, label, paragraphs, style_key)
                end
              end
            end
          end

          def append_table_footnote(cell, label, paragraphs, style_key)
            paragraphs.each_with_index do |part, index|
              para = build_paragraph(style_key)
              if index.zero?
                append_footnote_label(para, label)
                para << " "
              end
              @inline_renderer.render(part, para)
              cell << para
            end
          end
        end
      end
    end
  end
end
