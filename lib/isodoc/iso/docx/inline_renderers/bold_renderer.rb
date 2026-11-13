# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <strong> / <Strong> as a bold run. Uses
        # InlineRenderer#apply_bold_to_run when applying bold to nested
        # children, which promotes InlineCode character style to
        # InlineCodeBold (Era C's dedicated bold-code style).
        class BoldRenderer
          include Base

          def render(element, para)
            if element.is_a?(String)
              append_bold_run(para, element)
            elsif rich_children?(element)
              parent.render_with_run_format(element, para) do |run|
                parent.apply_bold_to_run(run)
              end
            else
              append_bold_run(para, parent.collect_text(element))
            end
          end

          private

          def rich_children?(element)
            parent.ordered?(element) && parent.has_rich_children?(element)
          end

          def append_bold_run(para, text)
            return if text.nil? || text.to_s.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text.to_s).bold
            para << run.build
          end
        end
      end
    end
  end
end
