require "mn-requirements"
require_relative "modspec"

module Metanorma
  class Requirements
    class Iso < ::Metanorma::Requirements
      def create(type)
        conv = ::IsoDoc::Iso::PresentationXMLConvert.new({})
        case type
        when :modspec, :ogc
          ::Metanorma::Requirements::Modspec::Iso.new(parent: self, isodoc: conv)
        else ::Metanorma::Requirements::Default.new(parent: self, isodoc: conv)
        end
      end
    end
  end
end
