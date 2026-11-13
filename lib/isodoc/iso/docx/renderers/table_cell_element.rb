# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Per-element-type table cell renderer classes. Each handler renders
        # one kind of model element (paragraph, note, list) into a table
        # cell builder with cell-specific styling. The
        # TableCellElement::Registry maps model classes to handler instances
        # and dispatches elements.
        #
        # Adding a new cell element type = new handler class + one +register+
        # call in Registry#register_defaults — no edit to existing dispatch
        # logic (Open/Closed Principle).
        module TableCellElement
          ROOT = "isodoc/iso/docx/renderers/table_cell_element"
          autoload :Base, "#{ROOT}/base"
          autoload :CellTarget, "#{ROOT}/cell_target"
          autoload :Registry, "#{ROOT}/registry"
          autoload :ParagraphHandler, "#{ROOT}/paragraph_handler"
          autoload :NoteHandler, "#{ROOT}/note_handler"
          autoload :ListHandler, "#{ROOT}/list_handler"
        end
      end
    end
  end
end
