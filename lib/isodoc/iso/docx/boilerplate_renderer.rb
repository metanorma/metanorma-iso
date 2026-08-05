# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders boilerplate sections (copyright, license, legal) from the
      # document model's structured boilerplate attribute.
      #
      # Metanorma::StandardDocument::Boilerplate holds each statement as a
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

          walk_statements(boilerplate.license_statement, doc,
                          :warning_header, :warning)
        end

        # Render copyright statements on the copyright page.
        def render_copyright(boilerplate, doc)
          return unless boilerplate

          walk_statements(boilerplate.copyright_statement, doc,
                          :copyright_hdr, :copyright)

          address = find_address_block(boilerplate)
          render_address(doc, address) if address
        end

        private

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

        def render_paragraphs(section, doc, style_key)
          return unless section.class.attributes.key?(:paragraphs)

          Array(section.paragraphs).each do |content|
            para = Uniword::Builder::ParagraphBuilder.new
            para.style = @resolver.paragraph_style(style_key)

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

        def find_address_block(boilerplate)
          Array(boilerplate.copyright_statement).each do |stmt|
            text = find_address_in_section(stmt)
            return text if text
          end
          nil
        end

        # In ISO XML, the address is typically the paragraph after the
        # copyright message (contains "copyright office").
        def find_address_in_section(section)
          if section.class.attributes.key?(:paragraphs)
            address_para = Array(section.paragraphs).find do |p|
              collect_text(p).include?("copyright office")
            end
            return collect_text(address_para) if address_para
          end

          return nil unless section.class.attributes.key?(:subsection)

          Array(section.subsection).each do |sub|
            text = find_address_in_section(sub)
            return text if text
          end
          nil
        end

        def render_address(doc, address_text)
          return unless address_text

          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(:copyright_address)
          para << address_text
          doc << para
        end
      end
    end
  end
end
