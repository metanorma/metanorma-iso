# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders an OrderedList or UnorderedList inside a table cell.
          # Each list item becomes a numbered paragraph carrying the cell's
          # row-type style. The numbering kind (decimal vs dash) is selected
          # by the +num_id_key+ constructor parameter.
          class ListHandler
            include Base
            include ModelUtils

            NESTED_BLOCKS = %w[ul ol dl table note example sourcecode figure formula quote].freeze

            def initialize(num_id_key:, **dependencies)
              super(**dependencies)
              @num_id_key = num_id_key
            end

            def render(element, target)
              num_id = @resolver.numbering_id(@num_id_key)
              Array(element.listitem).each do |item|
                render_item(item, target, num_id)
              end
            end

            private

            def render_item(item, target, num_id)
              para = Uniword::Builder::ParagraphBuilder.new
              if target.style_key
                para.style = @resolver.paragraph_style(target.style_key)
              end
              para.numbering(num_id, 0) if num_id
              if nested_blocks?(item)
                render_item_blocks(item, para, target)
                return
              end
              append_item_content(item, para)
              target << para
            end

            def nested_blocks?(item)
              ordered?(item) && item.element_order.any? do |entry|
                entry.element? && NESTED_BLOCKS.include?(entry.name)
              end
            end

            def render_item_blocks(item, para, target)
              lead = Array(item.paragraphs).first
              children = []
              each_ordered_element(item) do |type, child|
                next if type == :text && child.strip.empty?
                next if Array(item.fmt_name).any? { |label| label.equal?(child) }

                children << [type, child]
              end
              while children.first && (children.first.first == :text || children.first.last.equal?(lead))
                type, child = children.shift
                if type == :text
                  @inline_renderer.add_text(para, child)
                else
                  @inline_renderer.render(child, para)
                  break
                end
              end
              target << para
              children.each do |type, child|
                if type == :text
                  text_para = Uniword::Builder::ParagraphBuilder.new
                  text_para.style = @resolver.paragraph_style(target.style_key) if target.style_key
                  @inline_renderer.add_text(text_para, child)
                  target << text_para
                else
                  dispatcher.call(child, target)
                end
              end
            end

            def append_item_content(item, para)
              paragraphs = item.paragraphs
              if paragraphs && !paragraphs.empty?
                paragraphs.each { |p| @inline_renderer.render(p, para) }
              else
                @inline_renderer.render(item, para)
              end
            end
          end
        end
      end
    end
  end
end
