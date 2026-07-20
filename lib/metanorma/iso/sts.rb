# frozen_string_literal: true

require "sts"
require "metanorma/document"
require_relative "../iso_document"

require_relative "sts/transformer"

module Metanorma
  module Iso
    # Native metanorma-document ISO-STS transformer (the +:isosts+ output
    # format).
    #
    # QA GATE: this path is OFF by default. mnconvert
    # (+IsoDoc::Iso::IsoStsConvert+) remains the +:isosts+ default until the
    # ISO-STS transformer QA is signed off; only then is the default flipped.
    # Enable for testing / after sign-off with +METANORMA_ISO_NATIVE_STS=1+ or
    # +Metanorma::Iso::Sts.enabled = true+.
    #
    # NISO +:sts+ has no metanorma-document transformer and always stays on
    # mnconvert; this gate governs +:isosts+ only.
    module Sts
      class << self
        # Explicit override (true/false). When nil, falls back to the
        # +METANORMA_ISO_NATIVE_STS+ environment variable.
        attr_writer :enabled

        # @return [Boolean] whether the native ISO-STS transformer is enabled.
        #   Defaults to false (mnconvert).
        def enabled?
          return @enabled unless @enabled.nil?

          ENV["METANORMA_ISO_NATIVE_STS"] == "1"
        end
      end
    end
  end
end
