# frozen_string_literal: true

require "metanorma/mirror"

module Metanorma
  module Iso
    # ISO's mirror handler entries, contributed to the default registry
    # through the Mirror.register_default seam. Formerly hardcoded in
    # the harness's DefaultRegistry.
    module MirrorRegistration
      ISO_SECTION_ENTRIES = [
        [Metanorma::Iso::Document::Sections::IsoTermsSection,
         Metanorma::Mirror::Handlers::Section, { method_name: :terms }],
        [Metanorma::Iso::Document::Terms::IsoTerm,
         Metanorma::Mirror::Handlers::Term, {}],
        [Metanorma::Iso::Document::Sections::IsoPreface,
         Metanorma::Mirror::Handlers::Structural, { method_name: :preface }],
      ].freeze

      def self.register!
        return if @registered

        @registered = true
        Metanorma::Mirror.register_default do |registry|
          ISO_SECTION_ENTRIES.each do |model, handler, opts|
            registry.register(model, handler, **opts)
          end
        end
      end
    end
  end
end
