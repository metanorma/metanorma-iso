# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Admonition (e.g., "Warning", "Caution") as a Box-
        # wrapped paragraph with Warningtext style. Era C uses the Box
        # wrap for visual emphasis; the admonition's text (including any
        # "Warning" label embedded by the presentation XML) goes inside
        # a single Warningtext-styled paragraph.
        class AdmonitionRenderer
          include Base
          include BoxWrapper

          def render(admonition, doc)
            with_box(doc) do
              para = build_paragraph(:admonition)
              @inline_renderer.render(admonition, para)
              doc << para
            end
          end
        end
      end
    end
  end
end
