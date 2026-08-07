# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Rule namespace. Each ISO_N / STANDOC_N log key gets its own class
      # (one file per rule). New rule = new file + one autoload line here.
      module Rules
        autoload :Base, "metanorma/iso/validation/rules/base"
        autoload :DoctypeRule, "metanorma/iso/validation/rules/doctype_rule"
      end
    end
  end
end
