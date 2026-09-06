# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Immutable per-run context passed to every Rule's +#applicable?+ and
      # +#check+. Carries the deserialized model root, the converter log,
      # the converter-state snapshot, and the mutable SharedState.
      Context = Struct.new(:root, :log, :state, :shared, keyword_init: true)
    end
  end
end
