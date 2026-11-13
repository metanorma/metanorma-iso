# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a normative references section (<references normative="true">)
        # or informative bibliography section as a Heading1 paragraph followed
        # by an optional intro paragraph and the list of bibliographic items.
        #
        # The section behaves like a clause (Heading1 from fmt-title) but
        # contains <bibitem> children that are dispatched to
        # BibliographyRenderer. Without this renderer the section's
        # children were walked as anonymous mixed content — the title,
        # intro, and bibitems all collapsed into a single paragraph.
        class ReferencesRenderer
          include Base
          include ModelUtils

          def render(section, doc)
            @context.with_bibliography do
              is_normative = normative?(section)
              @context.with_normative(is_normative) do
                render_heading(section, doc)
                render_intro(section, doc)
                render_bibitems(section, doc)
              end
            end
          end

          private

          def normative?(section)
            return false unless section.class.attributes.key?(:normative)

            section.normative.to_s == "true"
          end

          def render_heading(section, doc)
            title = section.fmt_title if section.class.attributes.key?(:fmt_title)
            title ||= section.title if section.class.attributes.key?(:title)
            return unless title

            para = build_unstyled_paragraph
            style = @resolver.heading_style(1)
            para.style = style if style
            @inline_renderer.render_heading(title, para)
            doc << para
          end

          def render_intro(section, doc)
            return unless section.class.attributes.key?(:p)

            Array(section.p).each do |p|
              para = build_unstyled_paragraph
              @inline_renderer.render(p, para)
              doc << para
            end
          end

          def render_bibitems(section, doc)
            return unless section.class.attributes.key?(:references)

            Array(section.references).each do |bib|
              @walker.dispatch(bib, doc)
            end
          end
        end
      end
    end
  end
end