# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a BibliographicItem as a single bibliography-entry
        # paragraph (BiblioEntry for informative, RefNorm for normative).
        #
        # The bookmark anchor (when present) lets hyperlinks scroll to
        # the entry; the entry content is the biblio tag (auto-numbered
        # citation) followed by the formatted reference text.
        #
        # <note> and <abstract> children of the bibitem are metadata
        # about the cited document (withdrawn status, abstract text)
        # and are NOT rendered as visible content — including them
        # produced stray "Withdrawn." and abstract paragraphs after
        # each entry. The reference rice.docx doesn't show them.
        class BibliographyRenderer
          include Base
          include ModelUtils

          def render(bibitem, doc)
            render_entry(bibitem, doc)
          end

          private

          def render_entry(bibitem, doc)
            para = build_unstyled_paragraph
            para.style = bib_item_style
            with_bibitem_bookmark(bibitem, para) do
              render_bib_entry_content(bibitem, para)
            end
            doc << para
          end

          def bib_item_style
            key = @context.in_normative ? :ref_norm : :biblio_entry
            @resolver.paragraph_style(key)
          end

          def with_bibitem_bookmark(bibitem, para)
            name = bibitem_bookmark_name(bibitem)
            return yield unless name

            bm_id = @context.next_bookmark_id.to_s
            para << Uniword::Wordprocessingml::BookmarkStart.new(id: bm_id,
                                                                 name: name)
            yield
            para << Uniword::Wordprocessingml::BookmarkEnd.new(id: bm_id)
          end

          def bibitem_bookmark_name(bibitem)
            anchor = attribute_value(bibitem, :anchor)
            return anchor if anchor

            id = attribute_value(bibitem, :id)
            id if id
          end

          def render_bib_entry_content(bibitem, para)
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
        end
      end
    end
  end
end
