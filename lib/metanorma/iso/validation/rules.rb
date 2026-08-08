# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Rule namespace. Each ISO_N / STANDOC_N log key gets its own class
      # (one file per rule). New rule = new file + one autoload line here.
      module Rules
        autoload :Base, "metanorma/iso/validation/rules/base"
        autoload :TreeTraversal, "metanorma/iso/validation/rules/tree_traversal"
        autoload :DoctypeRule, "metanorma/iso/validation/rules/doctype_rule"
        autoload :IterationRule, "metanorma/iso/validation/rules/iteration_rule"
        autoload :TechnicalCommitteeTypeRule,
                 "metanorma/iso/validation/rules/technical_committee_type_rule"
        autoload :SubcommitteeTypeRule,
                 "metanorma/iso/validation/rules/subcommittee_type_rule"
      end
    end
  end
end
