# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Reporter
        # YAML format. Delegates to Report#to_yaml (lutaml-model Serializable).
        class Yaml < Base
          def format(report)
            report.to_yaml
          end
        end
      end
    end
  end
end
