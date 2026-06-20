# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a BibliographicItem as a bibliography-entry paragraph
        # (BiblioEntry for informative, RefNorm for normative) followed
        # by zero or more annotation paragraphs (BiblioDescription) for
        # any <note> or <abstract> children of the bibitem.
        #
        # The bookmark anchor (when present) lets hyperlinks scroll to
        # the entry; the entry content is the biblio tag (auto-numbered
        # citation) followed by the formatted reference text.
        class BibliographyRenderer
          include Base
          include ModelUtils

          def render(bibitem, doc)
            render_entry(bibitem, doc)
            render_annotations(bibitem, doc)
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

          def render_annotations(bibitem, doc)
            annotation_nodes(bibitem).each do |node|
              para = build_paragraph(:biblio_description)
              render_annotation_text(node, para)
              doc << para
            end
          end

          def annotation_nodes(bibitem)
            notes = attribute_collection(bibitem, :note)
            abstracts = attribute_collection(bibitem, :abstract)
            notes + abstracts
          end

          def render_annotation_text(node, para)
            paragraphs = annotation_paragraphs(node)
            if paragraphs.empty?
              text = collect_all_text(node)
              para << text if text && !text.empty?
              return
            end

            paragraphs.each do |p|
              @inline_renderer.render(p, para)
            end
          end

          def annotation_paragraphs(node)
            p_attr = node.class.attributes.key?(:p) ? node.p : nil
            Array(p_attr)
          end

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

          def attribute_value(node, attr)
            return nil unless node.class.attributes.key?(attr)

            node.public_send(attr)
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
