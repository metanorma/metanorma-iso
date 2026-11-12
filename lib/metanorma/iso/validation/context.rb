# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Immutable per-run context passed to every Rule's +#applicable?+ and
      # +#check+. Carries the deserialized model root, the converter log,
      # the converter-state snapshot, the mutable SharedState, and the
      # ACTIVE COMPOSITION (issue #1720): the ComposedRegistry whose
      # per-rule metadata (severity override, flavor attribution) applies
      # to this run. Rules and message decoration read the citation and
      # severity from here — never from hardcoded metadata — so an
      # imported rule is reported as the importing flavor's own.
      Context = Struct.new(:root, :log, :state, :shared, :registry,
                           keyword_init: true)
    end
  end
end
