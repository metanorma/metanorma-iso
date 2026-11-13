# frozen_string_literal: true

# Entry point for the Uniword-based ISO DOCX/MHTML output tree
# (lib/isodoc/iso/docx/). Loads the tree in dependency order; the
# per-content-type subdirectories (renderers/, inline_renderers/) are
# autoloaded from their namespace files.

require "uniword"
require "metanorma/document"
require "metanorma/iso_document"

module IsoDoc
  module Iso
    module Docx
    end
  end
end

require "isodoc/iso/docx/errors"
require "isodoc/iso/docx_templates"
require "isodoc/iso/docx/model_utils"
require "isodoc/iso/docx/context"
require "isodoc/iso/docx/document_properties"
require "isodoc/iso/docx/bibdata_text"
require "isodoc/iso/docx/page_scheme"
require "isodoc/iso/docx/style_resolver"
require "isodoc/iso/docx/style_library"
require "isodoc/iso/docx/style_mapping_validator"
require "isodoc/iso/docx/template_extractor"
require "isodoc/iso/docx/template_provenance"
require "isodoc/iso/docx/inline_renderers"
require "isodoc/iso/docx/inline"
require "isodoc/iso/docx/renderers"
require "isodoc/iso/docx/box_wrapper"
require "isodoc/iso/docx/section_manager"
require "isodoc/iso/docx/toc_builder"
require "isodoc/iso/docx/boilerplate_renderer"
require "isodoc/iso/docx/comment_renderer"
require "isodoc/iso/docx/core_properties_builder"
require "isodoc/iso/docx/cover_renderer"
require "isodoc/iso/docx/definition_list_renderer"
require "isodoc/iso/docx/formula_renderer"
require "isodoc/iso/docx/header_footer_renderer"
require "isodoc/iso/docx/indexsect_renderer"
require "isodoc/iso/docx/middle_title_renderer"
require "isodoc/iso/docx/preface_renderer"
require "isodoc/iso/docx/sourcecode_renderer"
require "isodoc/iso/docx/colophon_renderer"
require "isodoc/iso/docx/adapter"
