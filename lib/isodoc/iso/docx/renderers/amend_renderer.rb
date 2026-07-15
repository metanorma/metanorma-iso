# frozen_string_literal: true

require "metanorma/document"
require "metanorma/iso_document"

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an AmendBlock. AmendBlock holds description and new_content
        # as AmendContentBlock collections; AmendContentBlock uses
        # +map_all_content+ so each block's children arrive as a raw XML
        # string. This renderer wraps that XML in a typed Lutaml container
        # so the walker can dispatch each child (<p>, <note>, <clause>,
        # etc.) through the normal renderer pipeline.
        #
        # Era C template uses:
        #   - BodyText style for description paragraphs (instructional
        #     text describing the change)
        #   - a3 (amend_newcontent) style for newcontent paragraphs
        #     (visually indented so reviewers can spot the replacement
        #     text)
        #
        # Zone dispatch via Context#with_amend + StyleResolver ensures
        # every paragraph inside the amend picks up the right style
        # without the renderer hardcoding style IDs.
        class AmendRenderer
          include Base

          ISO_NAMESPACE = "https://www.metanorma.org/ns/iso"
          private_constant :ISO_NAMESPACE

          def render(amend, doc)
            render_collection(amend, :description, doc)
            render_collection(amend, :new_content, doc)
          end

          private

          def render_collection(amend, attribute_name, doc)
            return unless amend.class.attributes.key?(attribute_name)

            zone = amend_zone_for(attribute_name)
            Array(amend.public_send(attribute_name)).each do |block|
              render_content_block(block, doc, zone)
            end
          end

          def amend_zone_for(attribute_name)
            attribute_name == :new_content ? :newcontent : :description
          end

          def render_content_block(block, doc, zone)
            return unless block.content

            wrapper = parse_raw_content(block.content)
            return unless wrapper

            @context.with_amend(zone) do
              @walker.walk(wrapper, doc)
            end
          end

          def parse_raw_content(raw_xml)
            wrapped = "<amend-content xmlns=\"#{ISO_NAMESPACE}\">" \
                      "#{raw_xml}</amend-content>"
            AmendContentWrapper.from_xml(wrapped)
          rescue StandardError
            nil
          end

          # Lightweight Lutaml container that restores typed-model access
          # to the raw XML stored inside AmendContentBlock#content.
          # Mixed-content mode preserves document order so the walker
          # dispatches children in the same order they appear in the XML.
          class AmendContentWrapper < Lutaml::Model::Serializable
            attribute :p,
                      Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                      collection: true
            attribute :note,
                      Metanorma::Document::Components::Blocks::NoteBlock,
                      collection: true
            attribute :clause,
                      Metanorma::IsoDocument::Sections::IsoClauseSection,
                      collection: true
            attribute :ol,
                      Metanorma::Document::Components::Lists::OrderedList,
                      collection: true
            attribute :ul,
                      Metanorma::Document::Components::Lists::UnorderedList,
                      collection: true
            attribute :table,
                      Metanorma::Document::Components::Tables::TableBlock,
                      collection: true
            attribute :figure,
                      Metanorma::Document::Components::AncillaryBlocks::FigureBlock,
                      collection: true

            xml do
              root "amend-content"
              mixed_content
              map_element "p", to: :p
              map_element "note", to: :note
              map_element "clause", to: :clause
              map_element "ol", to: :ol
              map_element "ul", to: :ul
              map_element "table", to: :table
              map_element "figure", to: :figure
            end
          end
          private_constant :AmendContentWrapper
        end
      end
    end
  end
end
