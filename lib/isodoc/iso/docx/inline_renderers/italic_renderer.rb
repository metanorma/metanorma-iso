# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <em> / <emphasis> as an italic run. When the element
        # has rich children (nested formatting), the run format is
        # applied recursively so the italic carries through nested
        # content without losing its inner styling.
        class ItalicRenderer
          include Base

          def render(element, para)
            if element.is_a?(String)
              append_italic_run(para, element)
            elsif rich_children?(element)
              parent.render_with_run_format(element, para) do |run|
                run.properties.italic = Uniword::Properties::Italic.new
              end
            else
              append_italic_run(para, parent.collect_text(element))
            end
          end

          private

          def rich_children?(element)
            parent.ordered?(element) && parent.has_rich_children?(element)
          end

          def append_italic_run(para, text)
            return if text.nil? || text.to_s.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text.to_s).italic
            para << run.build
          end
        end
      end
    end
  end
end
