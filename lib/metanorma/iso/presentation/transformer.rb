# frozen_string_literal: true

require "metanorma/iso/document"
require "metanorma/document/components/inline/fmt_ladl_label_data"
require_relative "model_tree"
require_relative "display"

module Metanorma
  module Iso
    module Presentation
      # Native presentation for labelled ISO clauses and ordinary content.
      # Numbering belongs to the supplied LADL processor, never this stage.
      class Transformer
        class UnsupportedContent < ArgumentError; end

        def call(semantic_root, flavor:, options:)
          unless semantic_root.instance_of?(Metanorma::Iso::Document::Root) && flavor.to_s == "iso"
            raise ArgumentError, "Native ISO presentation requires an ISO Root and flavor :iso"
          end
          labeler = options[:document_labeler]
          unless labeler.respond_to?(:call)
            raise ArgumentError, "Native ISO presentation requires options[:document_labeler]"
          end

          # Copy the Ruby object graph, including framework order/namespace state.
          # No document serialization, XML parser or temporary files are involved.
          root = Marshal.load(Marshal.dump(semantic_root))
          root.type = "presentation"
          tree = ModelTree.new(root)
          check_supported!(tree)
          tree.assign_ids!
          labelled = labeler.call(root, flavor: flavor, options: options)
          unless labelled.equal?(root)
            raise ArgumentError, "document_labeler must return its supplied ISO Root"
          end
          Display.new(tree).apply
          root
        end

        private

        # These need native adapters beyond heading/caption/xref projection. Do
        # not let a presentation marker silently advertise their conversion.
        UNSUPPORTED = %i[bibliography term terms definitions requirement recommendation permission
                         amend stem fn eref concept indexsect term_sources].freeze

        def check_supported!(tree)
          tree.nodes.each do |node|
            UNSUPPORTED.each do |key|
              next unless tree.value(node, key)
              next if Array(tree.value(node, key)).empty?

              raise UnsupportedContent, "Native ISO presentation does not yet support #{key}"
            end
          end
        end
      end
    end
  end
end
