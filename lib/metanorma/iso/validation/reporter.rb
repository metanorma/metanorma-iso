# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Output formatters for {Report}. Each Reporter takes a Report and
      # returns a String. Reporters do not mutate the Report.
      #
      # Format selection is the caller's responsibility — the orchestrator
      # accepts +output_format:+ and routes to the right Reporter.
      module Reporter
        autoload :Base, "metanorma/iso/validation/reporter/base"
        autoload :Text, "metanorma/iso/validation/reporter/text"
        autoload :Json, "metanorma/iso/validation/reporter/json"
        autoload :Yaml, "metanorma/iso/validation/reporter/yaml"
      end
    end
  end
end
