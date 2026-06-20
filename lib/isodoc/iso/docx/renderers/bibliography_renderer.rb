# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a BibliographicItem as a single bibliography-entry paragraph
        # with a bookmark and the BiblioEntry/RefNorm style (selected by
        # whether the surrounding bibliography is normative or informative).
        #
        # The bookmark anchor (when present) lets hyperlinks scroll to the
        # entry; the content is the biblio tag (auto-numbered citation)
        # followed by the formatted reference text.
        class BibliographyRenderer
          include Base
          include ModelUtils

          def render(bibitem, doc)
            para = build_unstyled_paragraph
            para.style = bib_item_style
            with_bibitem_bookmark(bibitem, para) do
              render_bib_item_content(bibitem, para)
            end
            doc << para
          end

          private

          def bib_item_style
            key = @context.in_normative ? :ref_norm : :biblio_entry
            @resolver.paragraph_style(key)
          end

          def with_bibitem_bookmark(bibitem, para)
            name = bibitem_bookmark_name(bibitem)
            return yield unless name

            bm_id = @context.next_bookmark_id.to_s
            para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id, name: name)
            yield
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
          end

          def bibitem_bookmark_name(bibitem)
            if bibitem.class.attributes.key?(:anchor) && bibitem.anchor
              return bibitem.anchor
            end
            return bibitem.id if bibitem.class.attributes.key?(:id) && bibitem.id

            nil
          end

          def render_bib_item_content(bibitem, para)
            tag = attribute_value(bibitem, :biblio_tag)
            if tag
              @inline_renderer.render(tag, para)
            else
              text = collect_text(bibitem)
              para << text if text && !text.empty?
            end
            render_formatted_ref(bibitem, para)
          end

          def render_formatted_ref(bibitem, para)
            ref = attribute_value(bibitem, :formatted_ref)
            return unless ref

            @inline_renderer.render(ref, para)
          end

          def attribute_value(node, attr)
            return nil unless node.class.attributes.key?(attr)

            node.public_send(attr)
          end
        end
      end
    end
  end
end
