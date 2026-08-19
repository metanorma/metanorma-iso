# frozen_string_literal: true

# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/iso.rb). Re-opening
# an existing module is idempotent.
module Metanorma
  module Iso
  end
end

# Metanorma::Iso::Document — the ISO-specific document model.
#
# This is the canonical home for IsoDocument. It is NOT a vendored copy
# of metanorma-document. The ownership model is:
#
#   metanorma-document  → Metanorma::Document (components, relaton)
#   metanorma-standoc   → Metanorma::Standoc::Document (generic standard document)
#   metanorma-iso       → Metanorma::Iso::Document (ISO-specific extensions)
#
# IsoDocument extends StandardDocument with ISO-specific types:
# IsoBibliographicItem, IsoSections, IsoPreface, IsoTermsSection, etc.
#
# Standoc is required eagerly because StandardDocument lives there. Loading
# metanorma/document alone would still resolve StandardDocument while
# metanorma-document ships its legacy copy, but the canonical home is
# metanorma-standoc and the require makes that explicit.
#
# All autoloads below use absolute paths so this tree is self-contained.

require "metanorma/document"
require "metanorma/standoc"

module Metanorma
  module Iso::Document
    autoload :AnnotationContainer, "#{__dir__}/document/annotation_container"
    autoload :Blocks, "#{__dir__}/document/blocks"
    autoload :Boilerplate, "#{__dir__}/document/boilerplate"
    autoload :Metadata, "#{__dir__}/document/metadata"
    autoload :Root, "#{__dir__}/document/root"
    autoload :Sections, "#{__dir__}/document/sections"
    autoload :Terms, "#{__dir__}/document/terms"
  end
end

# Reassign the Metanorma::IsoDocument alias to point at our canonical
# Iso::Document BEFORE setup_iso_register runs (the register references
# Metanorma::IsoDocument to wire type substitutions). Silently overrides
# any prior constant (older metanorma-document releases shipped their
# own IsoDocument) to avoid Ruby's "already initialized constant"
# warning. Scheduled for removal once downstream consumers migrate.
module Metanorma
  existing = defined?(Metanorma::IsoDocument) && Metanorma::IsoDocument
  if !existing.equal?(Metanorma::Iso::Document)
    Metanorma.send(:remove_const, :IsoDocument) if existing
    IsoDocument = Metanorma::Iso::Document
  end
end

Metanorma::Iso::Registers.setup

# OCP adoption: register the ISO flavor with the metanorma-document
# harness (renderer + pubid). The harness itself ships zero flavor
# knowledge; this file is the single registration point for ISO.
require "metanorma/iso/html"

Metanorma::Html.register_flavor(Metanorma::Html::Flavor.new(
                                  name: :iso,
                                  model_class: Metanorma::Iso::Document::Root,
                                  renderer_class: Metanorma::Iso::Html::Renderer,
                                  pubid_module: :"Pubid::Iso",
                                ))
Metanorma::Html::Generator.register_taste(
  Metanorma::Iso::Document::Root, "ICC", Metanorma::Iso::Html::IccRenderer,
)

# Mark alias as deprecated AFTER setup so the register's own reference
# doesn't trip the warning.
module Metanorma
  deprecate_constant :IsoDocument
end
