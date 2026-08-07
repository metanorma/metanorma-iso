# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Discovery layer for Layer 3 rule classes. Walks the {Rules} module's
      # constants and returns every class that inherits from {Rules::Base}.
      #
      # Adding a rule is purely additive: drop a new file under
      # <tt>lib/metanorma/iso/validation/rules/</tt>, add one autoload line
      # to <tt>rules.rb</tt>, and {#all} picks it up automatically. No central
      # hash to maintain, no edits to existing code (OCP).
      class RuleRegistry
        def all
          Rules.constants.sort
            .map { |name| Rules.const_get(name) }
            .select { |constant| rule_class?(constant) }
        end

        private

        def rule_class?(constant)
          constant.is_a?(Class) && constant < Rules::Base
        end
      end
    end
  end
end
