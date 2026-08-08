# frozen_string_literal: true

# Load lutaml-model's document-level Validation framework (Rule, Registry,
# Issue, Context, Profile, etc.). This is an external-gem require, not an
# internal-library path — the gem does not autoload the framework from its
# main entry, so consumers must require it explicitly.
require "lutaml/model/validation_framework"

module Metanorma
  module Iso
    # Model-driven validation namespace.
    #
    # Replaces the legacy Ruby + Nokogiri + RelaxNG/Jing pipeline with a
    # lutaml-model-native validator operating on {Metanorma::IsoDocument::Root}.
    # See TODO.validate/README.md for the migration plan of record.
    module Validation
      autoload :Context, "metanorma/iso/validation/context"
      autoload :ConverterState, "metanorma/iso/validation/converter_state"
      autoload :SharedState, "metanorma/iso/validation/shared_state"
      autoload :Issue, "metanorma/iso/validation/issue"
      autoload :Report, "metanorma/iso/validation/report"
      autoload :IssueTranslator, "metanorma/iso/validation/issue_translator"
      autoload :RuleRegistry, "metanorma/iso/validation/rule_registry"
      autoload :Profile, "metanorma/iso/validation/profile"
      autoload :Rules, "metanorma/iso/validation/rules"
      autoload :Reporter, "metanorma/iso/validation/reporter"
      autoload :ModelValidator, "metanorma/iso/validation/model_validator"
    end
  end
end
