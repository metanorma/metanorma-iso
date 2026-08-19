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

require "metanorma/iso/registers"
Metanorma::Iso::Registers.setup

# OCP adoption: ONE registration in the metanorma-core flavor table —
# model root, processor, pubid, and per-format renderers. Re-basing to
# another renderer is a change to this entry only.
require "metanorma-core"

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
