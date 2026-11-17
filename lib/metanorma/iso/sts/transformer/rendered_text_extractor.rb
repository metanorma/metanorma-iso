# frozen_string_literal: true

module Metanorma
  module Iso
    module Sts
      module Transformer
        # Extracts plain text from typed model objects for non-math content
        # (titles, labels, list items, xref visible text). Stems are NEVER
        # text-extracted — the paragraph transformer routes them through
        # MathML passthrough via InlineFormula + Mml::V3::Math.
        class RenderedTextExtractor
          STEM_TYPES = [
            Metanorma::Document::Components::Inline::StemInlineElement,
            Metanorma::Document::Components::Inline::FmtStemElement,
            Metanorma::Document::Components::Inline::AsciimathElement,
            Metanorma::Document::Components::Inline::MathElement,
          ].freeze

          WALKABLE_TYPES = [
            Metanorma::Document::Components::Paragraphs::ParagraphBlock,
            Metanorma::Document::Components::Inline::SemxElement,
            Metanorma::Document::Components::Inline::StrongRawElement,
            Metanorma::Document::Components::Inline::EmRawElement,
            Metanorma::Document::Components::Inline::SpanElement,
            Metanorma::Document::Components::Inline::FmtPreferredElement,
            Metanorma::Document::Components::Inline::FmtXrefLabelElement,
            Metanorma::Document::Components::Inline::FmtConceptElement,
            Metanorma::Document::Components::Inline::ConceptElement,
            Metanorma::StandardDocument::Sections::ContentSection,
          ].freeze

          def self.text_of(node)
            return "" if node.nil?
            return node if node.is_a?(String)
            return "" if stem_type?(node)
            return "" unless walkable?(node)

            walker = new
            walker.collect(node)
            walker.to_text
          end

          def self.stem_type?(node)
            STEM_TYPES.any? { |t| node.is_a?(t) }
          end
          public_class_method :stem_type?

          def self.walkable?(node)
            WALKABLE_TYPES.any? { |t| node.is_a?(t) } ||
              node.class.method_defined?(:each_mixed_content)
          end
          public_class_method :walkable?

          # Section number from the presentation XML: the autonum
          # attribute (annexes, term notes) or the fmt-title/fmt-name
          # caption-label's autonum semx ("1", "8.1", "3.1"). The delim
          # between number and title is a <tab/>, which text extraction
          # drops, so the caption-label span must be isolated —
          # splitting the whole fmt-title text would glue number and
          # title together ("1Scope"). Single source of truth for both
          # the label extraction and the id derivation.
          def self.autonum_of(source_clause)
            if source_clause.class.method_defined?(:autonum) && source_clause.autonum
              return source_clause.autonum.to_s
            end

            title_wrapper = %i[fmt_title fmt_name].filter_map do |method|
              source_clause.public_send(method) if source_clause.class.method_defined?(method)
            end.first
            title_wrapper = Array(title_wrapper).first
            return nil unless title_wrapper

            caption_label_text(title_wrapper)
          end

          # Text of the <span class="fmt-caption-label"> inside a
          # fmt-title — the bare section number.
          def self.caption_label_text(fmt_title)
            return nil unless fmt_title.class.method_defined?(:each_mixed_content)

            label_span = nil
            fmt_title.each_mixed_content do |child|
              if child.is_a?(Metanorma::Document::Components::Inline::SpanElement) &&
                  child.class_attr == "fmt-caption-label"
                label_span = child
                break
              end
            end
            return nil unless label_span

            text = text_of(label_span).strip
            text.empty? ? nil : text
          end

          def initialize
            @parts = []
            @seen = {}
          end

          def to_text
            @parts.join.strip
          end

          def append_text(text)
            @parts << text
          end

          def collect_node_public(child)
            collect_node(child)
          end

          def collect(node)
            return if node.nil? || @seen.key?(node.object_id)
            @seen[node.object_id] = true

            if node.is_a?(String)
              @parts << node
              return
            end
            return unless self.class.walkable?(node)

            collect_content_mapped_text?(node) ||
              node.each_mixed_content { |child| collect_node(child) }
          end

          private

          # Elements like NameWithIdElement map their whole content to a
          # plain `text` attribute (no mixed_content), so walking yields
          # nothing. SpanElement declares BOTH mixed_content and a text
          # mapping — only take the attribute shortcut when there is no
          # mixed content to walk.
          def collect_content_mapped_text?(node)
            return false unless node.class.method_defined?(:text)
            return false unless node.class.method_defined?(:mixed_content?) && !node.mixed_content?

            text = node.text
            return false unless text.is_a?(String) && !text.empty?

            @parts << text
            true
          end

          def collect_node(child)
            if child.is_a?(String)
              @parts << child
              return
            end

            case child
            when *STEM_TYPES
              # Math content is handled by the paragraph transformer via
              # MathML passthrough. Text extraction is intentionally a no-op.
              nil
            when Metanorma::Document::Components::Inline::XrefElement
              @parts << xref_text(child)
            when Metanorma::Document::Components::Inline::SemxElement
              collect(child)
              collect_semx_inlines(child)
            when Metanorma::Document::Components::Inline::StrongRawElement,
                 Metanorma::Document::Components::Inline::EmRawElement,
                 Metanorma::Document::Components::Inline::SpanElement
              collect(child)
            else
              collect(child)
            end
          end

          SEMX_CHILD_ATTRS = %i[
            stem_child strong em sup sub tt underline strike
            preferred_child name_child title_child
            verbal_definition_child definition_child
            concept_child fn_child link_child
          ].freeze

          def collect_semx_inlines(semx)
            SEMX_CHILD_ATTRS.each do |attr|
              next unless semx.class.method_defined?(attr)
              val = semx.public_send(attr)
              next if val.nil?
              Array(val).each { |v| collect_node(v) }
            end
          end

          def xref_text(xref)
            txt = array_or_string_to_s(xref.text)
            return txt unless txt.nil? || txt.empty?

            rid = xref.target if xref.class.method_defined?(:target)
            return "" unless rid.is_a?(String) && !rid.empty?

            case rid
            when /\Asec-(.+)\z/, /\Afig-(.+)\z/, /\Atable-(.+)\z/, /\Afn-(.+)\z/
              Regexp.last_match(1)
            else
              rid
            end
          end

          def array_or_string_to_s(val)
            return val if val.is_a?(String)
            return "" unless val.is_a?(Array)
            val.map(&:to_s).reject(&:empty?).join.strip
          end
        end
      end
    end
  end
end
