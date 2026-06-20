# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an Admonition (e.g., "Warning", "Caution") as a Box-
        # wrapped block. Era C uses the Box wrap for visual emphasis.
        #
 # The admonition's caption (fmt_name or name) is rendered first as a
        # separate Warningtitle-styled paragraph; the body content follows
        # inside a Warningtext-styled paragraph (or walker when the
        # admonition has multiple child paragraphs).
        class AdmonitionRenderer
          include Base
          include BoxWrapper

          def render(admonition, doc)
            with_box(doc) do
              render_title(admonition, doc)
              render_body(admonition, doc)
            end
          end

          private

          def render_title(admonition, doc)
            title = attribute_value(admonition, :fmt_name) ||
                    attribute_value(admonition, :name)
            return unless title

            para = build_paragraph(:admonition_title)
            @inline_renderer.render(title, para)
            doc << para
          end

          def render_body(admonition, doc)
            paragraphs = attribute_collection(admonition, :paragraphs)
            if paragraphs.empty?
              render_inline_body(admonition, doc)
            else
              paragraphs.each { |p| render_body_paragraph(p, doc) }
            end
          end

          def render_inline_body(admonition, doc)
            para = build_paragraph(:admonition)
            @inline_renderer.render(admonition, para)
            doc << para
          end

          def render_body_paragraph(p, doc)
            para = build_paragraph(:admonition)
            @inline_renderer.render(p, para)
            doc << para
          end

          def attribute_value(node, attr)
            return nil unless node.class.attributes.key?(attr)

            value = node.public_send(attr)
            value.is_a?(Array) ? value.first : value
          end

          def attribute_collection(node, attr)
            return [] unless node.class.attributes.key?(attr)

            Array(node.public_send(attr))
          end
        end
      end
    end
  end
end
