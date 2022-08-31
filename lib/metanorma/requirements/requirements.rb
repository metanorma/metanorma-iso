require_relative "modspec"

module Metanorma
  module Iso
    class Requirements < ::Metanorma::Requirements
      def create(type)
        case type
        when :modspec, :ogc
          Metanorma::Iso::Requirements::Modspec.new(parent: self)
        else super
        end
      end
    end
  end
end
