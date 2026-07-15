# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module InlineRenderers
        # Renders <fmt-xref target="..."> — a presentation-layer cross
        # reference whose children may include rich formatting. The
        # resulting Word hyperlink preserves the children's runs.
        class FmtXrefRenderer
          include Base

          def render(element, para)
            target = element.target
            return fallback(element, para) unless target

            link_model = build_hyperlink_with_runs(element, target)
            return if link_model.runs.empty?

            parent.apply_hyperlink_style(link_model)
            para << link_model
          end

          private

          def fallback(element, para)
            parent.render_mixed_inline_fallback(element, para)
          end

          def build_hyperlink_with_runs(element, target)
            link_model = Uniword::Wordprocessingml::Hyperlink.new
            link_model.anchor = target

            temp = Uniword::Builder::ParagraphBuilder.new
            parent.render_mixed_inline_fallback(element, temp)
            temp.model.runs.each { |r| link_model.runs << r }

            if link_model.runs.empty?
              text = parent.collect_text(element)
              return link_model unless text && !text.empty?

              link_model.runs << Uniword::Wordprocessingml::Run.new(text: text)
            end
            link_model
          end
        end
      end
    end
  end
end
