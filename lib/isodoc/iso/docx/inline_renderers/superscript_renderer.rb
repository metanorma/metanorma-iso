# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <sup> / <superscript> as a superscript run, applying
        # the vertical-align run property.
        class SuperscriptRenderer
          include Base

          def render(element, para)
            if rich_children?(element)
              parent.render_with_run_format(element, para) do |run|
                run.properties.vertical_align =
                  Uniword::Properties::VerticalAlign.new(value: "superscript")
              end
            else
              text = parent.collect_text(element)
              append_superscript_run(para, text)
            end
          end

          private

          def rich_children?(element)
            parent.ordered?(element) && parent.has_rich_children?(element)
          end

          def append_superscript_run(para, text)
            return if text.nil? || text.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text(text).superscript
            para << run.build
          end
        end
      end
    end
  end
end
