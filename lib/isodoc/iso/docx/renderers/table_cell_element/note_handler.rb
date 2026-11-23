# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        module TableCellElement
          # Renders a NoteBlock inside a table cell. Unlike the body-level
          # NoteRenderer, the cell version does not wrap the note in
          # Box-begin/Box-end. Paragraphs retain their boundaries and
          # other blocks use the cell dispatcher.
          class NoteHandler
            include Base
            include ModelUtils
            include BoxWrapper
            include NoteContent

            def render(element, target)
              if single_note_paragraph?(element)
                return render_paragraph(
                  block_children(element).first, target,
                  label: attribute_value(element, :fmt_name)
                )
              end

              children = block_children(element)
              label = attribute_value(element, :fmt_name)
              unless children.first.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
                render_paragraph(label, target) if label
                label = nil
              end
              children.each_with_index do |child, index|
                if child.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
                  render_paragraph(child, target, label: index.zero? ? label : nil)
                else
                  dispatch_block(child, target)
                end
              end
            end

            private

            # Rich note blocks keep their normal layout inside the cell.
            # Tables and lists still use the cell dispatcher's containment rules.
            def dispatch_block(element, target)
              renderer = rich_blocks.lookup(element.class)
              if renderer
                renderer.render(element, target)
              else
                @dispatcher.call(element, target)
              end
            end

            def rich_blocks
              @rich_blocks ||= Renderers::Registry.new do |registry|
                walker = Walker.new(method(:dispatch_block))
                options = { resolver: @resolver, context: @inline_renderer.context,
                            inline_renderer: @inline_renderer, walker: walker }
                image = ImageRenderer.new(**options)
                registry.register(Metanorma::Document::Components::IdElements::Image, image)
                registry.register(Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                                  FigureRenderer.new(**options, image_renderer: image))
                [
                  [Metanorma::Document::Components::AncillaryBlocks::ExampleBlock, ExampleRenderer],
                  [Metanorma::Document::Components::Paragraphs::ParagraphBlock, ParagraphRenderer],
                ].each do |model, renderer|
                  registry.register(model, renderer.new(**options))
                end
              end
            end

            # The label's text, or nil when it is blank.
            def label_string(label)
              text = collect_all_text(label).to_s.strip
              text.empty? ? nil : text
            end

            def render_paragraph(element, target, label: nil)
              cell_para = Uniword::Builder::ParagraphBuilder.new
              cell_para.style = @resolver.paragraph_style(:note)
              append_label(cell_para, label_string(label), inline: true) if label
              @inline_renderer.render(element, cell_para)
              target << cell_para
            end
          end
        end
      end
    end
  end
end
