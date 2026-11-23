# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Keep paragraph-only examples inline; render nested blocks as cell
          # siblings because a Word paragraph cannot contain a table or list.
          class ExampleHandler < ParagraphHandler
            include ModelUtils
            include BoxWrapper
            include NoteContent

            NESTED_BLOCKS = %w[ul ol dl table note example sourcecode figure formula quote].freeze

            def render(element, target)
              return render_paragraphs(element, target) unless nested_blocks?(element)

              each_ordered_element(element) do |type, child|
                if type == :text
                  append_text(child, target) unless child.strip.empty?
                else
                  dispatcher.call(child, target)
                end
              end
            end

            private

            # The label starts the first paragraph, as in the body example;
            # the hidden name is not printed and later paragraphs stay apart.
            def render_paragraphs(element, target)
              children = block_children(element)
              return super if children.empty?

              children.each_with_index do |child, index|
                para = Uniword::Builder::ParagraphBuilder.new
                para.style = @resolver.paragraph_style(target.style_key) if target.style_key
                append_label(para, label_text(element), inline: true) if index.zero?
                @inline_renderer.render(child, para)
                target << para
              end
            end

            def append_text(text, target)
              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(target.style_key) if target.style_key
              @inline_renderer.add_text(para, text)
              target << para
            end

            def nested_blocks?(element)
              ordered?(element) && element.element_order.any? do |entry|
                entry.element? && NESTED_BLOCKS.include?(entry.name)
              end
            end
          end
        end
      end
    end
  end
end
