# frozen_string_literal: true

module Metanorma
  module IsoDocument
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :iso_document
      end

      attribute :bibdata, Metanorma::IsoDocument::Metadata::IsoBibliographicItem
      attribute :preface, Metanorma::IsoDocument::Sections::IsoPreface
      attribute :sections, Metanorma::IsoDocument::Sections::IsoSections
      attribute :annex, Metanorma::IsoDocument::Sections::IsoAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end
