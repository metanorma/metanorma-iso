# frozen_string_literal: true

require "set"

module Metanorma
  module Iso
    module Validation
      # Mutable cross-rule state. Populated by early rules (e.g. unique-ID
      # collection) and read by later rules (e.g. xref integrity).
      #
      # Lives on {Context} so every rule sees the same shared map within a run.
      #
      # The seq members are Sets: they collect one entry per identifier
      # across the whole document, and duplicate checks run per identifier,
      # so Array#include? made collection quadratic in document size.
      SharedState = Struct.new(
        :doc_ids, :doc_anchors, :doc_xrefs, :id_seq, :anchor_seq,
        keyword_init: true
      ) do
        def initialize(*args)
          super
          self.doc_ids     ||= {}
          self.doc_anchors ||= {}
          self.doc_xrefs   ||= {}
          self.id_seq      ||= Set.new
          self.anchor_seq  ||= Set.new
        end
      end
    end
  end
end
