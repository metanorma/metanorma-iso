# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders a sourcecode callout as a superscript "(N)" run.
        class CalloutRenderer
          include Base

          def render(element, para)
            text = parent.collect_callout_text(element)
            return if text.nil? || text.empty?

            run = Uniword::Builder::RunBuilder.new
            run.text("(#{text})").superscript
            para << run.build
          end
        end
      end
    end
  end
end
