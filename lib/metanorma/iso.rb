require_relative "iso/processor"
require_relative "iso/document"

module Metanorma
  module Iso
    autoload :Validation, "metanorma/iso/validation"
    autoload :API, "metanorma/iso/api"

    def self.validate(xml, **opts)
      API.validate(xml, **opts)
    end
  end
end
