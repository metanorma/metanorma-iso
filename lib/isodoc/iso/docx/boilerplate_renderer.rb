# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      # Renders boilerplate sections (copyright, license, legal) from the
      # document model's boilerplate attribute.
      #
      # The IsoDocument::Boilerplate model uses map_all_content, so its
      # content is a raw XML string. This class parses it into a structured
      # model via BoilerplateContent and renders each section with the
      # correct DOCX styles.
      #
      # Boilerplate is rendered in two parts:
      #   1. License/warning — on the cover page (before the cover sectPr)
      #   2. Copyright — on a separate page (after the cover sectPr)
      class BoilerplateRenderer
        def initialize(resolver, inline_renderer)
          @resolver = resolver
          @inline = inline_renderer
        end

        # Render license/warning statements for the cover page.
        def render_license(boilerplate, doc)
          content = parse_boilerplate(boilerplate)
          return unless content

          walk_statements(content.license_statement, doc, :warning_header, :warning)
        end

        # Render copyright statements on the copyright page.
        def render_copyright(boilerplate, doc)
          content = parse_boilerplate(boilerplate)
          return unless content

          walk_statements(content.copyright_statement, doc, :copyright_hdr, :copyright)

          address = find_address_block(content)
          render_address(doc, address) if address
        end

        private

        def parse_boilerplate(boilerplate)
          return nil unless boilerplate

          # Handle both the IsoDocument::Boilerplate (map_all_content → content string)
          # and direct access if the model has structured attributes.
          xml_content = if boilerplate.class.attributes.key?(:content)
                          boilerplate.content
                        else
                          nil
                        end

          return nil if xml_content.nil? || xml_content.strip.empty?

          # Wrap in namespace-declared root element for proper Lutaml parsing.
          wrapped = "<boilerplate xmlns=\"https://www.metanorma.org/ns/iso\">" \
                    "#{xml_content}</boilerplate>"
          BoilerplateContent.from_xml(wrapped)
        rescue StandardError
          nil
        end

        def walk_statements(statements, doc, title_style_key, body_style_key)
          Array(statements).each do |stmt|
            Array(stmt.clause).each do |clause|
              render_clause(clause, doc, title_style_key, body_style_key)
            end
          end
        end

        def render_clause(clause, doc, title_style_key, body_style_key)
          # Render title paragraph if present
          if clause.class.attributes.key?(:title) && clause.title
            render_text_paragraph(clause.title, doc, title_style_key)
          end

          # Render content paragraphs
          if clause.class.attributes.key?(:p)
            Array(clause.p).each do |para|
              render_content_paragraph(para, doc, body_style_key)
            end
          end
        end

        def render_text_paragraph(text, doc, style_key)
          para = Uniword::Builder::ParagraphBuilder.new
          para.style = @resolver.paragraph_style(style_key)
          para << text.to_s
          doc << para
        end

        def render_content_paragraph(content, doc, style_key)
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

        def find_address_block(content)
          # Look for address-like content in copyright clauses.
          # In ISO XML, the address is typically the paragraph with
          # id="boilerplate-address" or the one after the copyright message.
          Array(content.copyright_statement).each do |stmt|
            Array(stmt.clause).each do |clause|
              next unless clause.class.attributes.key?(:p)

              paragraphs = Array(clause.p)
              address_para = paragraphs.find do |p|
                text = extract_text(p)
                text && text.include?("copyright office")
              end
              return extract_text(address_para) if address_para
            end
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

        def extract_text(node)
          return node if node.is_a?(String)
          return nil unless node

          if node.is_a?(Lutaml::Model::Serializable)
            [:content, :text, :value].each do |attr|
              next unless node.class.attributes.key?(attr)
              val = node.public_send(attr)
              return val.to_s if val.is_a?(String) && !val.empty?
            end
          end
          nil
        end
      end

      # Lightweight model for parsing boilerplate XML content.
      # The IsoDocument::Boilerplate uses map_all_content (raw string),
      # so we re-parse with this model for structured traversal.
      #
      # This is a private implementation detail — only used by BoilerplateRenderer.
      class BoilerplateStatement < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :title, :string
        attribute :p, :string, collection: true

        xml do
          root "clause"
          map_attribute "id", to: :id
          map_element "title", to: :title
          map_element "p", to: :p
        end
      end

      class BoilerplateStatementWrapper < Lutaml::Model::Serializable
        attribute :clause, BoilerplateStatement, collection: true

        xml do
          root "statement"
          map_element "clause", to: :clause
        end
      end

      class BoilerplateContent < Lutaml::Model::Serializable
        attribute :copyright_statement, BoilerplateStatementWrapper, collection: true
        attribute :license_statement, BoilerplateStatementWrapper, collection: true
        attribute :legal_statement, BoilerplateStatementWrapper, collection: true
        attribute :feedback_statement, BoilerplateStatementWrapper, collection: true
        attribute :clause, BoilerplateStatement, collection: true

        xml do
          root "boilerplate"
          map_element "copyright-statement", to: :copyright_statement
          map_element "license-statement", to: :license_statement
          map_element "legal-statement", to: :legal_statement
          map_element "feedback-statement", to: :feedback_statement
          map_element "clause", to: :clause
        end
      end
    end
  end
end
