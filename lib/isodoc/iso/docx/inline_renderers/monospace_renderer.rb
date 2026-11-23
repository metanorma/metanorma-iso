# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <tt> / <monospace> as a run with the InlineCode
        # character style (Era C). The styleId flows from
        # style_mapping.yml via StyleResolver.
        class MonospaceRenderer
          include Base

          def render(element, para)
            if parent.ordered?(element) && parent.has_rich_children?(element)
              return render_rich(element, para)
            end

            text = parent.collect_text(element)
            return if text.nil? || text.empty?

            parent.add_text_with_char_style(para, text, :inline_code)
          end

          private

          # Keep nested xref/link/footnote/stem/bold content in order and
          # give every produced text run the InlineCode style. A link's
          # Hyperlink style yields to it; other styles are kept.
          def render_rich(element, para)
            link_style = parent.resolver.character_style(:hyperlink)
            parent.render_with_run_format(element, para) do |run|
              current = run.properties.style&.value
              next if current && current != link_style

              parent.apply_run_char_style(run, :inline_code)
            end
          end
        end
      end
    end
  end
end
