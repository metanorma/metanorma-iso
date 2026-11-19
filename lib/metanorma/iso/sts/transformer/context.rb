# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class Context
          attr_reader :source, :id_generator, :footnote_collector, :presentation_xml

          def initialize(source, presentation_xml: nil)
            @source = source
            # Claim the renamed ids (annex apps, terms sections, terms,
            # figures) in document order before any transform runs, so
            # xref rid values pointing forward resolve.
            @id_generator = IdGenerator.new.pre_register(source)
            @footnote_collector = FootnoteCollector.new
            @presentation_xml = presentation_xml
          end

          # The typed provision <table> the sibling presentation XML
          # rendered for +source_requirement+ (matched by anchor), or nil
          # when no presentation XML is available or the requirement has
          # no provision of its own.
          def provision_for(source_requirement)
            return nil unless provision_index

            anchor = requirement_anchor(source_requirement)
            return nil unless anchor

            provision_index.table_for(anchor)
          end

          # Lazy: the streaming scan over the presentation XML only pays
          # off when a requirement actually asks for its provision table.
          def provision_index
            return @provision_index if @provision_index

            return nil if presentation_xml.nil? || presentation_xml.empty?

            @provision_index = ProvisionIndex.from_xml(presentation_xml)
          end

          def language
            source.language || "en"
          end

          def docidentifier
            source.docidentifier
          end

          private

          # Requirements are identified across the semantic and
          # presentation trees by their +anchor+; the bare id is a uuid
          # that differs between the two.
          def requirement_anchor(requirement)
            

            anchor = requirement.anchor
            anchor.nil? || anchor.empty? ? nil : anchor
          end
        end
      end
    end
  end
end
