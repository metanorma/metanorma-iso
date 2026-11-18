# frozen_string_literal: true
module Metanorma
  module Iso
    module Sts
      module Transformer
        class InlineTransformer < Base
          # Appends a source element's inline content onto an already
          # built target model (tbx:definition, tbx:note, tbx:example,
          # <def><p>…): text runs and inline elements land in walk order.
          def apply_inline_content(source, target)
            paragraph_transformer.entries_for(source).each do |kind, value|
              append_entry(target, kind, value)
            end
            target
          end

          def transform(source_node)
            paragraph_transformer.transform(source_node)
          end

          private

          # Kinds each TBX target can carry; everything else in the walk
          # (fn, lists) has no counterpart on the model and is skipped.
          SUPPORTED = %i[
            text bold italic sub sup monospace
            inline_formula xref ext_link
          ].freeze

          def append_entry(target, kind, value)
            return unless SUPPORTED.include?(kind)

            if kind == :text
              append_text(target, value)
            else
              target.public_send(kind, value)
            end
          end

          # SINGLE SOURCE OF TRUTH for sts-ruby text-attribute names:
          # NisoSts models use :text, every TbxIsoTml model uses :value.
          TEXT_ATTR_FOR = {
            ::Sts::NisoSts::Paragraph => :text,
            ::Sts::TbxIsoTml::Definition => :value,
            ::Sts::TbxIsoTml::Note => :value,
            ::Sts::TbxIsoTml::Example => :value,
            ::Sts::TbxIsoTml::Source => :value,
            ::Sts::TbxIsoTml::Term => :value,
          }.freeze

          # lutaml-model serializes built (never-parsed) mixed-content
          # models by keeping at most one text entry per element boundary;
          # consecutive text entries after the first are dropped on to_xml
          # (lutaml-model#1164). Merging consecutive strings into the last
          # entry preserves the full content.
          def append_text(target, value)
            text_attr = TEXT_ATTR_FOR.fetch(target.class, :value)
            existing = target.public_send(text_attr)
            if existing.is_a?(Array) && existing.last.is_a?(String)
              existing[-1] = existing.last + value
            else
              target.public_send(text_attr, value)
            end
          end
        end
      end
    end
  end
end
