require "mn-requirements"
require_relative "modspec"

module Metanorma
  class Requirements
    class Iso < ::Metanorma::Requirements
      def create(type)
        case type
        when :modspec, :ogc
          ::Metanorma::Requirements::Modspec::Iso.new(parent: self,
                                                      isodoc: @isodoc)
        else ::Metanorma::Requirements::Default.new(parent: self,
                                                    isodoc: @isodoc)
        end
      end
    end
  end
end
