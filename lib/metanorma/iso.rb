require_relative "iso/processor"

module Metanorma
  module Iso
    autoload :Validation, "metanorma/iso/validation"
    autoload :API, "metanorma/iso/api"

    # Convenience shortcut for Metanorma::Iso::API.validate.
    # @see Metanorma::Iso::API.validate
    def self.validate(xml, **opts)
      API.validate(xml, **opts)
    end
  end
end
