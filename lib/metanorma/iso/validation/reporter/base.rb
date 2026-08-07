# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      module Reporter
        # Abstract Reporter. Subclasses implement +#format(report)+ and
        # return a String.
        class Base
          def format(_report)
            raise NotImplementedError,
                  "#{self.class} must implement #format(report)"
          end
        end
      end
    end
  end
end
