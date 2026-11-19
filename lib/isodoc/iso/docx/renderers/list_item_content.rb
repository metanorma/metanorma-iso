# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Shared list-item body rendering. The item's first paragraph (or
        # bare text) becomes the numbered list paragraph; every other
        # child (further paragraphs, nested lists, formula, figure, table,
        # note, ...) is dispatched in document order as a sibling block,
        # since OOXML cannot nest blocks inside a paragraph.
        module ListItemContent
          MAX_STYLE_LEVEL = 4

          private

          def render_item_content(item, doc, para)
            lead = Array(item.paragraphs).first
            if lead
              @inline_renderer.render(lead, para)
            else
              render_bare_item_inline(item, para)
            end
            doc << para
            render_item_blocks(item, doc, lead)
          end

          # A li with no lead paragraph carries its text inline. Its
          # fmt-name is the list label, which the list renderer supplies
          # itself (literal label or numPr), so it is never body content.
          def render_bare_item_inline(item, para)
            label = Array(item.fmt_name)
            each_ordered_element(item) do |type, obj|
              next if label.any? { |l| l.equal?(obj) }

              case type
              when :text then @inline_renderer.add_text(para, obj)
              when :element then @inline_renderer.dispatch_inline(obj, para)
              end
            end
          end

          def render_item_blocks(item, doc, lead)
            @context.with_list do
              each_ordered_element(item) do |type, obj|
                next if type == :text || obj.equal?(lead)

                @walker.dispatch(obj, doc)
              end
            end
          end

          # Zero-based nesting depth of the list being rendered.
          def list_level
            @context.list_depth
          end

          def style_level
            [list_level + 1, MAX_STYLE_LEVEL].min
          end
        end
      end
    end
  end
end
