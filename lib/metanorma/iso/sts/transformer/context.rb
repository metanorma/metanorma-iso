# frozen_string_literal: true

require "metanorma/iso/sts/profile"

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Delegates to the shared engine (metanorma-document 0.5.15,
        # Metanorma::Document::Sts) per metanorma-iso#1760 /
        # metanorma-document#165 — defaulting the context to the ISO
        # profile so class_overrides resolve the ISO subclasses.
        class Context < Metanorma::Document::Sts::Transformer::Context
          def initialize(source, presentation_xml: nil, profile: Metanorma::Iso::Sts::Profile.instance)
            super
          end

          # ISO overrides: the provision lookup reads the sibling
          # presentation XML through the ISO ProvisionIndex streaming
          # scan (Nokogiri byte-preserving), which keeps the U+00A0
          # label bytes the engine's parse path normalizes away.
          def provision_for(source_requirement)
            return nil unless provision_index

            anchor = requirement_anchor(source_requirement)
            return nil unless anchor

            provision_index.table_for(anchor)
          end

          def provision_index
            return @provision_index if @provision_index

            return nil if presentation_xml.nil? || presentation_xml.empty?

            @provision_index = ProvisionIndex.from_xml(presentation_xml)
          end
        end
      end
    end
  end
end
