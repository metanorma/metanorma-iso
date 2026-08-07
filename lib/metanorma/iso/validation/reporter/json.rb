# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Reporter
        # JSON format. Delegates to Report#to_json (lutaml-model Serializable).
        class Json < Base
          def format(report)
            report.to_json
          end
        end
      end
    end
  end
end
