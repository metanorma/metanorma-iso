# frozen_string_literal: true

# Full ISO document load path: models + alias + register substitutions
# + flavor-table registration. Downstream flavors that only need the
# model classes should require metanorma/iso/document/models instead.
require_relative "document/models"

require "metanorma/iso/registers"
Metanorma::Iso::Registers.setup

# OCP adoption: ONE registration in the metanorma-core flavor table —
# model root, processor, pubid, and per-format renderers. Re-basing to
# another renderer is a change to this entry only.
require "metanorma-core"
require "metanorma/iso/html"
require "metanorma/iso/mirror"
Metanorma::Iso::MirrorRegistration.register!

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
                                    name: :iso,
                                    gem: "metanorma-iso",
                                    model_root: Metanorma::Iso::Document::Root,
                                    processor: defined?(Metanorma::Iso::Processor) ? Metanorma::Iso::Processor : nil,
                                    pubid_module: :"Pubid::Iso",
                                    renderers: { html: Metanorma::Iso::Html::Renderer },
                                  ))

# Mark alias as deprecated AFTER setup so the register's own reference
# doesn't trip the warning.
module Metanorma
  deprecate_constant :IsoDocument
end
