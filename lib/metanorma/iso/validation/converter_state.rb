# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Snapshot of converter state needed by validation rules.
      # Built explicitly per run by the validator entry point (see
      # Metanorma::Iso::Validate#converter_state) so we never reach into
      # converter internals via +instance_variable_get+.
      ConverterState = Struct.new(
        :lang, :script, :doctype, :vocab, :amd, :i18n, :novalid, :document,
        keyword_init: true
      )
    end
  end
end
