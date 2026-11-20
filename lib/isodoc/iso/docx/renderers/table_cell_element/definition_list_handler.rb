# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a <dl> inside a table cell as one paragraph per dt and
          # dd, each carrying the cell's row-type style. Inline content,
          # footnotes included, goes through the cell's own renderers; a dd
          # that holds lists, a nested dl or a table hands each child to
          # the cell dispatcher.
          class DefinitionListHandler
            include Base
            include ModelUtils

            NESTED_BLOCKS = %w[ul ol dl table note example sourcecode figure formula quote].freeze

            def render(element, target)
              terms = Array(element.dt)
              definitions = Array(element.dd)
              append_paragraph(nil, target) if terms.empty? && definitions.empty?
              [terms.size, definitions.size].max.times do |index|
                append_paragraph(terms[index], target) if terms[index]
                render_definition(definitions[index], target)
              end
            end

            private

            def render_definition(node, target)
              if nested_blocks?(node)
                each_ordered_element(node) do |type, child|
                  if type == :text
                    append_loose_text(child, target)
                  else
                    dispatcher.call(child, target)
                    # A w:tc may not end in, or fuse, a w:tbl.
                    target << Uniword::Builder::ParagraphBuilder.new if table?(child)
                  end
                end
              else
                paragraphs_of(node).each { |part| append_paragraph(part, target) }
              end
            end

            def append_loose_text(text, target)
              return if text.strip.empty?

              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(target.style_key) if target.style_key
              para << text.strip
              target << para
            end

            def table?(child)
              child.is_a?(Metanorma::Document::Components::Tables::TableBlock)
            end

            def nested_blocks?(node)
              ordered?(node) &&
                node.element_order.any? { |entry| entry.element? && NESTED_BLOCKS.include?(entry.name) }
            end

            # A dd of several <p> becomes one paragraph each, not one run-on
            # paragraph.
            def paragraphs_of(node)
              return [] unless node

              parts = node.respond_to?(:p) ? Array(node.p) : []
              only_paragraphs = Array(node.element_order).all? do |entry|
                entry.element? ? entry.name == "p" : entry.text_content.to_s.strip.empty?
              end
              parts.size > 1 && only_paragraphs ? parts : [node]
            end

            # A nil node gives an empty paragraph: a w:tc needs one w:p.
            def append_paragraph(node, target)
              para = Uniword::Builder::ParagraphBuilder.new
              para.style = @resolver.paragraph_style(target.style_key) if target.style_key
              @inline_renderer.render(node, para) if node
              target << para
            end
          end
        end
      end
    end
  end
end
