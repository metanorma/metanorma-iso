# frozen_string_literal: true

require "metanorma/document"
# Resolves to the vendored copy in lib/metanorma/iso_document.rb (this gem's
# lib precedes metanorma-document's lib in $LOAD_PATH).
require "metanorma/iso_document"

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders an AmendBlock. AmendBlock holds description and new_content
        # as AmendContentBlock collections whose typed children (p, note,
        # ol, ul, dl) arrive in document order via element_order. The
        # renderer hands each block straight to the walker, which dispatches
        # every child through the normal renderer pipeline.
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
            @context.with_amend(zone) do
              @walker.walk(block, doc)
            end
          end
        end
      end
    end
  end
end
