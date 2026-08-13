# frozen_string_literal: true

module Metanorma
  module Iso::Document
    class Root < Lutaml::Model::Serializable
      include Metanorma::Standoc::Document::RootAttributes

      def self.lutaml_default_register
        :iso_document
      end

      attribute :bibdata, Metanorma::Iso::Document::Metadata::IsoBibliographicItem
      attribute :preface, Metanorma::Iso::Document::Sections::IsoPreface
      attribute :sections, Metanorma::Iso::Document::Sections::IsoSections
      attribute :annex, Metanorma::Iso::Document::Sections::IsoAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::Standoc::Document::Namespace

        Metanorma::Standoc::Document::RootXmlMapping.apply(self)
      end
    end
  end
end
