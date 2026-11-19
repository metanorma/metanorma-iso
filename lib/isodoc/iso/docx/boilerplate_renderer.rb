# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders copyright, license, legal, and feedback statements from the
      # document model's structured boilerplate attribute.
      #
      # Metanorma::Standoc::Document::Boilerplate holds each statement as a
      # ContentSection collection; statements typically wrap their content
      # in an inner <clause> subsection. This renderer walks sections
      # recursively, emitting title and paragraph content with the correct
      # DOCX styles.
      #
      # Boilerplate is rendered in two parts:
      #   1. License/warning — on the cover page (before the cover sectPr)
      #   2. Copyright — on a separate page (after the cover sectPr)
      class BoilerplateRenderer
        include ModelUtils

        def initialize(resolver, inline_renderer)
          @resolver = resolver
          @inline = inline_renderer
        end

        # Render license/warning statements for the cover page.
        def render_license(boilerplate, doc)
          return unless boilerplate

          return if Array(boilerplate.license_statement).empty?

          walk_statements(boilerplate.license_statement, doc,
                          :warning_header, :warning)
          doc << spacer_paragraph
        end

        # Render copyright, legal, and feedback statements on the copyright page.
        def render_copyright(boilerplate, doc)
          return unless boilerplate

          walk_statements(boilerplate.copyright_statement, doc,
                          :copyright_hdr, :copyright_statement)

          walk_statements(boilerplate.legal_statement, doc,
                          :copyright_hdr, :copyright)
          walk_statements(boilerplate.feedback_statement, doc,
                          :copyright_hdr, :copyright)
        end

        private

        # The reference cover closes the warning box with a lone nbsp
        # paragraph (no style) before the cover section break; without it
        # the box border merges with whatever follows.
        def spacer_paragraph
          para = Uniword::Builder::ParagraphBuilder.new
          para << "\u00A0"
          para
        end

        def walk_statements(statements, doc, title_style_key, body_style_key)
          Array(statements).each do |stmt|
            render_section(stmt, doc, title_style_key, body_style_key)
          end
        end

        # Render a ContentSection: title paragraph, block paragraphs, then
        # any nested subsections (the boilerplate <clause> wrapper).
        def render_section(section, doc, title_style_key, body_style_key)
          render_title(section, doc, title_style_key)
          render_paragraphs(section, doc, body_style_key)

          return unless section.class.attributes.key?(:subsection)

          Array(section.subsection).each do |sub|
            render_section(sub, doc, title_style_key, body_style_key)
          end
        end

        def render_title(section, doc, style_key)
          return unless section.class.attributes.key?(:title)

          text = collect_text(section.title)
          return if text.empty?

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(style_key)
          para << text
          doc << para
        end

        # Only the copyright statement carries the address block; legal and
        # feedback paragraphs keep zzCopyright even if they name the office.
        def paragraph_style_key(content, style_key)
          return style_key unless style_key == :copyright_statement
          return :copyright unless address_paragraph?(content)

          :copyright_address
        end

        def render_paragraphs(section, doc, style_key)
          return unless section.class.attributes.key?(:paragraphs)

          Array(section.paragraphs).each do |content|
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(
              paragraph_style_key(content, style_key),
            )

            case content
            when String
              para << content
            when Lutaml::Model::Serializable
              @inline.render(content, para)
            else
              para << content.to_s
            end

            doc << para
          end
        end

        # The ISO copyright address paragraph (contains "copyright office")
        # is rendered once, in the address style, from its own content so
        # that line breaks and link text (email) are kept.
        def address_paragraph?(content)
          collect_text(content).include?("copyright office")
        end
      end
    end
  end
end
