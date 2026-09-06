# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Discovery layer for Layer 3 rule classes. Walks the {Rules} module's
      # constants and returns every concrete (non-abstract) class that
      # inherits from {Rules::Base}. Abstract intermediates like StyleRule
      # declare +abstract!+ and are excluded from discovery.
      #
      # Adding a rule is purely additive: drop a new file under
      # <tt>lib/metanorma/iso/validation/rules/</tt>, add one autoload line
      # to <tt>rules.rb</tt>, and {#all} picks it up automatically.
      class RuleRegistry
        def all
          Rules.constants.sort
            .map { |name| Rules.const_get(name) }
            .select { |constant| concrete_rule_class?(constant) }
        end

        private

        def concrete_rule_class?(constant)
          return false unless constant.is_a?(Class)
          return false unless constant < Rules::Base
          return false if constant.abstract_rule?

          true
        end
      end
    end
  end
end
