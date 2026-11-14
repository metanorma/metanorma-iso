# frozen_string_literal: true

module Metanorma
  module Iso
    module Validation
      # Immutable per-run context passed to every Rule's +#applicable?+ and
      # +#check+. Carries the deserialized model root, the converter log,
      # the converter-state snapshot, the mutable SharedState, the
      # ACTIVE COMPOSITION (issue #1720): the ComposedRegistry whose
      # per-rule metadata (severity override, flavor attribution) applies
      # to this run, and the per-run WalkCache (memoized document facts
      # shared by the rules). Rules and message decoration read the
      # citation and severity from here — never from hardcoded metadata —
      # so an imported rule is reported as the importing flavor's own.
      #
      # The +walk_cache+ member defaults to a fresh {WalkCache} so every
      # construction site (orchestrator, specs, programmatic callers)
      # gets the per-run cache without wiring each of them.
      Context = Struct.new(:root, :log, :state, :shared, :registry,
                           :walk_cache, keyword_init: true) do
        def initialize(*args)
          super
          self.walk_cache ||= WalkCache.new
        end
      end
    end
  end
end
