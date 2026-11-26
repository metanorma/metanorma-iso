# frozen_string_literal: true

# Delegates to the shared engine (metanorma-document 0.5.15, Metanorma::Document::Sts)
# per metanorma-iso#1760 / metanorma-document#165 — defaulting to the ISO
# profile so the branding (publisher identity) resolves.

require "metanorma/iso/sts/profile"

module Metanorma
  module Iso
    module Sts
      module HtmlRenderer
        class Ruby < Metanorma::Document::Sts::HtmlRenderer::Ruby
          def initialize(**opts)
            opts[:profile] ||= Metanorma::Iso::Sts::Profile.instance
            super
          end
        end
      end
    end
  end
end
