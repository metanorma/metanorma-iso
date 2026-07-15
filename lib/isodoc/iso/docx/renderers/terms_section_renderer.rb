# frozen_string_literal: true

module IsoDoc
  module Iso
    module Docx
      module Renderers
        # Renders a Terms section (clause containing term entries). The
        # title uses Heading1 style regardless of nested depth because
        # terms sections are always top-level document sections.
        #
        # The presentation XML emits the terms intro boilerplate twice
        # (once from localization, once from source) with slightly
        # different wording. The renderer deduplicates paragraphs whose
        # text starts with known boilerplate prefixes so the intro
        # appears once.
        class TermsSectionRenderer < SectionRenderer
          include ModelUtils

          # Boilerplate prefixes whose owning <p> should be deduped.
          # The presentation XML emits these twice (with slightly
          # different wording/URLs) — we keep the first occurrence.
          DEDUPED_PREFIXES = [
            "For the purposes of this document",
            "ISO and IEC maintain terminolog",
          ].freeze

          def title_style_for(_section)
            @resolver.heading_style(1)
          end

          private

          def walk_children(section, doc)
            seen = Set.new
            skipping_until_next = false

            each_ordered_element(section) do |type, obj|
              next if type == :text

              if skipping_until_next
                if block_follows_intro?(obj)
                  next
                end
                skipping_until_next = false
              end

              if dedup_intro?(obj, seen)
                skipping_until_next = true
                next
              end

              @walker.dispatch(obj, doc)
            end
          end

          def block_follows_intro?(node)
            return true if unordered_list?(node)
            return true if paragraph_with_intro_prefix?(node)

            false
          end

          def unordered_list?(node)
            node.is_a?(Lutaml::Model::Serializable) &&
              node.class.name&.end_with?("UnorderedList")
          end

          def paragraph_with_intro_prefix?(node)
            return false unless text_carrier?(node)

            text = collect_text(node).to_s.strip
            DEDUPED_PREFIXES.any? { |prefix| text.start_with?(prefix) }
          end

          def dedup_intro?(node, seen)
            return false unless text_carrier?(node)

            text = collect_text(node).to_s.strip
            prefix = DEDUPED_PREFIXES.find { |p| text.start_with?(p) }
            return false unless prefix

            if seen.include?(prefix)
              true
            else
              seen.add(prefix)
              false
            end
          end

          # Paragraph-like nodes — either ParagraphBlock (the canonical
          # model) or RawParagraph (used for <p> inside <terms> in
          # metanorma-document 0.2.6).
          def text_carrier?(node)
            return false unless node.is_a?(Lutaml::Model::Serializable)

            name = node.class.name
            name&.end_with?("ParagraphBlock") ||
              name&.end_with?("RawParagraph")
          end
        end
      end
    end
  end
end
