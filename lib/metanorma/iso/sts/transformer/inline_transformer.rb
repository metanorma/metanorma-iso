# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        class InlineTransformer < Metanorma::Document::Sts::Transformer::InlineTransformer
          include Transformer::ContentText

          # Appends a source element's inline content onto an already
          # built target model (tbx:definition, tbx:note, tbx:example,
          # <def><p>…, NISO STS <term>): text runs and inline elements
          # land in walk order.
          def apply_inline_content(source, target)
            paragraph_transformer.entries_for(source).each do |kind, value|
              append_entry(target, kind, value)
            end
            target
          end

          # Appends pre-walked [kind, value] entries
          # (ParagraphTransformer#entries_for) through the same guarded
          # dispatch — the def-list term path, which walks the <dt>
          # directly instead of through apply_inline_content.
          def apply_inline_entries(entries, target)
            entries.each { |kind, value| append_entry(target, kind, value) }
            target
          end

          def transform(source_node)
            paragraph_transformer.transform(source_node)
          end

          # Kinds each TBX target can carry. Everything else in the walk
          # degrades to the value's visible text (append_entry) — the
          # slot probe decides, not this list.
          SUPPORTED = %i[
            text bold italic sub sup monospace
            inline_formula xref ext_link
          ].freeze

          # SINGLE SOURCE OF TRUTH for sts-ruby text-attribute names:
          # NisoSts models use :text, every TbxIsoTml model uses :value.
          TEXT_ATTR_FOR = {
            ::Sts::NisoSts::Paragraph => :text,
            ::Sts::NisoSts::Term => :text,
            ::Sts::TbxIsoTml::Definition => :value,
            ::Sts::TbxIsoTml::Note => :value,
            ::Sts::TbxIsoTml::Example => :value,
            ::Sts::TbxIsoTml::Source => :value,
            ::Sts::TbxIsoTml::Term => :value,
          }.freeze

          # Generic text carriers probed in order when the class is not
          # in (or has drifted out of) TEXT_ATTR_FOR.
          TEXT_ATTR_FALLBACKS = %i[text content value].freeze

          private

          # Every append probes the target's class for the slot first.
          # metanorma/metanorma-pdfa#122: the dispatch public_send'd
          # :monospace straight onto Sts::NisoSts::Term, and on the
          # floating sts floor of metanorma-iso 3.5.21 (`>= 0.5.6`, Term
          # grew its monospace slot only in sts 0.6.12) any definition
          # list whose term carried monospace text died with
          # NoMethodError and lost the whole STS output. A target that
          # lacks the slot keeps the run as text instead.
          def append_entry(target, kind, value)
            if kind == :text
              append_text(target, value)
            elsif supported_slot?(target, kind)
              target.public_send(kind, value)
            else
              append_text(target, inline_value_text(value))
            end

          end

          # Visible text of a built STS inline value on the degrade
          # path: its text carriers first, then the fn paragraph runs —
          # a run the target cannot slot must survive as text, not
          # vanish.
          def inline_value_text(value)
            text = extract_text_value(value)
            return text unless text.nil? || text.empty?
            return nil unless value.is_a?(::Sts::NisoSts::Fn)

            value.paragraph.map { |p| Array(p.text).join }.join(" ")
          end

          def supported_slot?(target, kind)
            SUPPORTED.include?(kind) && attribute_slot?(target, kind)
          end

          def attribute_slot?(target, name)
            target.class.attributes.key?(name)
          end

          # The target's text-carrier attribute: the class table first,
          # presence-checked so an sts rename degrades instead of
          # raising; then the generic carriers. A target declaring none
          # of them cannot receive text and the run is skipped.
          def text_attr_for(target)
            declared = TEXT_ATTR_FOR[target.class]
            return declared if declared && attribute_slot?(target, declared)

            TEXT_ATTR_FALLBACKS.find { |attr| attribute_slot?(target, attr) }
          end

          # Appends through the target's one-arg attribute call so the
          # builder's element-order tracking records the run at its
          # walk position (order is what interleaves the text runs
          # with the inline elements on to_xml). The walk entries
          # arrive pre-merged (ParagraphTransformer#entries_for), so
          # no two consecutive text entries ever hit the same
          # boundary — the lutaml-model#1164 single-text-per-boundary
          # rule is honored by construction.
          def append_text(target, value)
            return if value.nil? || value.to_s.empty?

            text_attr = text_attr_for(target)
            target.public_send(text_attr, value) if text_attr
          end
        end
      end
    end
  end
end
