require_relative "iso/processor"

module Metanorma
  module Iso
    autoload :Document, "metanorma/iso/document"
    autoload :Validation, "metanorma/iso/validation"
    autoload :API, "metanorma/iso/api"

    def self.validate(xml, **opts)
      API.validate(xml, **opts)
    end
  end

  IsoDocument = Iso::Document
end
